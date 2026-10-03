// NonToon Modules - ShadeReplace phase (main light restore + emission)
//
// (1) Main light restore - take the BRIGHTER of the two, never add (adding saturates to 1.0 and
//     renders every lit surface as the raw albedo: the washed-out white face). Never multiply by an
//     attenuation from this shader either: UNITY_LIGHT_ATTENUATION(atten, i, vertex.position) and
//     SHADOW_ATTENUATION(i) both return a bogus small value here (measured deviation 0.39 -> 0.77).
//
// (2) Emission - carried entirely by the shared mask, NOT by material properties:
//     the converter bakes "shape x strength x colour" into the mask's R/G/B channels, because Shader
//     Core's float/color module properties never reach the shader (measured: _EmissionStrength,
//     _EmissionColor, _LightBoost, _ShadeGradientIndex all read as 0 no matter what the material stores,
//     while SCConstValue keywords and texture uploads work fine). The shape comes from the alpha of
//     lilToon's _EmissionMap - its RGB is almost pure white and would light up the whole face.
//     col = albedo * lightColor, so dividing by albedo gives exactly col += emission.
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    half strength = min(_MainLightStrength, 1.0h);
    half3 mainLight = _LightColor0.rgb * strength;
    sd.lightColor = saturate(max(sd.lightColor, mainLight));

    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    half3 albedo = max(sd.albedoAlpha.rgb, 0.05h);
    sd.lightColor += emission / albedo;
}
