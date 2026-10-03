// NonToon MainLight module (provided by NonToon Modules)
//
// WHY THIS EXISTS
//   Measured on NonToon 0.2.x + Shader Core 0.2.x (Built-in RP): the main directional light never
//   reaches the material. Probing the shading data showed
//       _LightColor0      ~= 1.0   (Unity does hand the main light to the pass)
//       lightSum.color    == 0     (NonToon / Shader Core never accumulate it)
//       sd.lightColor     ~= 0.285 constant on every pixel
//   i.e. the whole model is lit by the ambient term only. Everything then behaves exactly as observed:
//   the highlights still matched lilToon (both were ambient-lit), while shadow / mid tones came out
//   2~3x darker than lilToon (hair 0.36x, clothes 0.30~0.40x), and turning the light up to 4x white
//   changed nothing at all.
//
// WHAT IT DOES
//   Hooks __SC_PHASE_modifylight__ (right after sd.lightColor is computed and before sd.col is
//   multiplied by the light) and adds the main light back:
//       sd.lightColor += _LightColor0.rgb * saturate(dot(N, L)) * attenuation
//   The attenuation is Unity's own UNITY_LIGHT_ATTENUATION, so cast shadows are respected and the
//   module adds nothing where the surface is in shadow.
//
//   _MainLightStrength lets this be dialled back (0 = off, 1 = full) without turning the module off.
//
// NOTE: keep this file ASCII-only (non-ASCII comments got mangled by an editor round trip once and
// silently commented out the effect).
if (_Enable)
{
    half3 lightDir = _WorldSpaceLightPos0.xyz;
    half3 lightCol = _LightColor0.rgb;

    // Unity's own shadow / distance attenuation for the main light (same macro the built-in shaders use).
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);

    half ndl = saturate(dot(sd.N_detail, lightDir));
    half3 mainLight = lightCol * ndl * atten * _MainLightStrength;

    // Only add what is missing: if lightSum already carries the main light (future NonToon versions,
    // or URP where the loop works) this module should not double it.
    half3 have = saturate(lightSum.color);
    half3 missing = max(mainLight - have, 0.0h);

    sd.lightColor = saturate(sd.lightColor + missing);
}
