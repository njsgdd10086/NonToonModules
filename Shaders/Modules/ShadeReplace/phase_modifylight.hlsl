// NonToon ShadeReplace module (provided by NonToon Modules)
//
// 1) Light: restores the main directional light that NonToon 0.2.x + Shader Core 0.2.x never accumulate in
//    the Built-in RP. Probes showed _LightColor0 ~= 0.73 while lightSum.color stayed 0, so sd.lightColor
//    collapsed to the ambient term on every pixel and raising the light to 4x white changed nothing.
//    It only adds what is missing, so it is a no-op where the light loop already works.
//
// 2) Emission: lilToon does col += _EmissionColor.rgb * _EmissionColor.a * _EmissionBlend * mask.
//    NonToon has no emission property, and its own Lighten module ("As Emission") does nothing in the
//    projects we tested (setting LightBoost to 5 changed no pixel), so the emission is added here through
//    sd.postadd, which NonToon adds AFTER col has been multiplied by the light - exactly the additive
//    behaviour lilToon has. The mask texture is baked by NonToonMaskBuilder from _EmissionBlendMask.
//
// Hooked at __SC_PHASE_modifylight__: sd.N may already be zero at postpixel, and postadd is still ahead.
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    // --- main light restore ---
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    half3 mainLight = _LightColor0.rgb * atten * _MainLightStrength;
    half3 have = saturate(lightSum.color);
    sd.lightColor = saturate(sd.lightColor + max(mainLight - have, 0.0h));

    // --- emission (additive, masked) ---
    if (_EmissionStrength > 0.0h)
    {
        half4 em = SCSample(_EmissionMask, sampler_BaseTexture, sd.uv);
        half m = _EmissionMaskChannel == 0 ? em.r
               : _EmissionMaskChannel == 1 ? em.g
               : _EmissionMaskChannel == 2 ? em.b
               : em.a;
        // Fold the emission into lightColor: the final colour is albedo * lightColor, so adding
        // E / albedo here produces albedo * lightColor + E. Writing sd.col or sd.postadd instead does
        // not survive (measured: a pure-green write to sd.col at this phase came out as magenta).
        half3 albedo = max(sd.albedoAlpha.rgb, 0.05h);
        sd.lightColor += _EmissionColor.rgb * _EmissionStrength * m / albedo;
    }
}
