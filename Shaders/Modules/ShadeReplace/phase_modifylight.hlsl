// NonToon Modules - ShadeReplace phase (main light restore + emission)
//
// (1) Main light restore.
// NonToon 0.2.x + Shader Core 0.2.x in the Built-in RP often never accumulates the main directional
// light (probes: _LightColor0 ~= 0.73 while lightSum.color stayed 0), so sd.lightColor collapses to the
// ambient term and the avatar renders several times darker than lilToon.
// IMPORTANT: take the BRIGHTER of the two instead of adding them.
//   Adding gave saturate(0.284 + 0.73) = 1.0, i.e. every lit surface rendered as albedo * 1.0 (the raw
//   texture) and blew out - measured as the washed-out white face / flat clothes.
//   Taking the max gives 0.73, which is what lilToon uses (clamp(_LightColor0 * atten, Min, Max)),
//   and it is a no-op wherever NonToon already accumulates the light itself.
//
// (2) Emission (lilToon has it, NonToon does not).
//   lilToon: col += _EmissionColor.rgb * _EmissionColor.a * _EmissionBlend * _EmissionMainStrength * mask
//   The converter folds every factor except the mask into _EmissionStrength, and bakes the shape
//   (_EmissionMap preferred, else _EmissionBlendMask) into the shared mask channel
//   _EmissionMaskChannel. The final colour is albedo * lightColor, so dividing by albedo here yields
//   exactly col += emission. Added AFTER the saturate so glow is allowed to blow out, like lilToon.
//
// Phase notes (probed, do not repeat):
//   * The phase is also injected into the VERTEX program - harmless, writes to sd there are dead.
//   * sd.col / sd.add / sd.postadd written here do NOT survive; sd.lightColor is the one that does.
//   * Never declare SC_Texture2D in a module's properties.hlsl: Shader Core then drops the whole
//     module (its phase stops running entirely). Use the shared mask instead.
//   * Never give a mask the A channel: every NonToon module defaults to A, so taking A for our mask
//     silently rewrites Shade / MatCap / rim / etc. (measured: the whole face turned white).
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    half3 mainLight = _LightColor0.rgb * atten * _MainLightStrength;
    sd.lightColor = saturate(max(sd.lightColor, mainLight));

    if (_EmissionStrength > 0.0h)
    {
        half em = sd.mask[_EmissionMaskChannel];
        half3 albedo = max(sd.albedoAlpha.rgb, 0.05h);
        sd.lightColor += _EmissionColor.rgb * _EmissionStrength * em / albedo;
    }
}
