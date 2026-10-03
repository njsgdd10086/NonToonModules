// NonToon Modules - ShadeReplace phase (main light restore + emission)
//
// (1) Main light restore
// NonToon 0.2.x + Shader Core 0.2.x in the Built-in RP frequently never accumulates the main
// directional light (probes: _LightColor0 ~= 0.73 while lightSum.color stayed 0), so sd.lightColor
// collapses to the ambient term and the avatar renders several times darker than lilToon.
//
// Two traps learned the hard way - do not undo these:
//   a) Take the BRIGHTER of the two, do not ADD them. Adding gave saturate(0.284 + 0.73) = 1.0, so
//      every lit surface rendered as albedo * 1.0 (the raw texture) and blew out: the washed-out
//      white face / flat clothes.
//   b) Do NOT multiply by an attenuation from this shader. UNITY_LIGHT_ATTENUATION(atten, i,
//      vertex.position) and SHADOW_ATTENUATION(i) both return a bogus small value here (the shadow
//      coords are not set up the way the macros expect), which dimmed everything by ~0.8x
//      (measured deviation from lilToon 0.39 -> 0.77). Shadowing is NonToon's Shade ramp job anyway.
//   c) Clamp the strength to 1. A value > 1 pushes the light past saturation and reproduces the very
//      white-face bug this module exists to fix (an earlier 1.6 calibration - made against a scene
//      whose lighting had been altered for testing - did exactly that).
// Measured with the settings below (same camera, layered metrics): mean 1.04x, median 1.04x,
// bright quartile 0.91x of lilToon.
//
// (2) Emission (lilToon has it, NonToon does not)
//   lilToon: col += _EmissionColor.rgb * _EmissionColor.a * _EmissionBlend * _EmissionMainStrength * mask
//   The converter folds every factor except the mask into _EmissionStrength and bakes the shape
//   (_EmissionMap preferred, else _EmissionBlendMask) into the shared mask channel
//   _EmissionMaskChannel. The final colour is albedo * lightColor, so dividing by albedo yields
//   exactly col += emission. Added after the saturate so glow may blow out, like lilToon.
//
// Other phase notes (probed):
//   * The phase is also injected into the VERTEX program - harmless, writes to sd there are dead.
//   * sd.col / sd.add / sd.postadd written here do NOT survive; sd.lightColor is the one that does.
//   * Never declare SC_Texture2D in a module's properties.hlsl: Shader Core then drops the whole
//     module and its phase stops running entirely. Use the shared mask instead.
//   * Never give a mask the A channel: every NonToon module defaults to A, so taking A silently
//     rewrites Shade / MatCap / rim / etc. (measured: the whole face turned white).
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    half strength = min(_MainLightStrength, 1.0h);
    half3 mainLight = _LightColor0.rgb * strength;
    sd.lightColor = saturate(max(sd.lightColor, mainLight));

    if (_EmissionStrength > 0.0h)
    {
        half em = sd.mask[_EmissionMaskChannel];
        half3 albedo = max(sd.albedoAlpha.rgb, 0.05h);
        sd.lightColor += _EmissionColor.rgb * _EmissionStrength * em / albedo;
    }
}
