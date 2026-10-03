// NOTE: keep this file ASCII-only.
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    half3 mainLight = _LightColor0.rgb * atten * _MainLightStrength;
    half3 have = saturate(lightSum.color);
    sd.lightColor = saturate(sd.lightColor + max(mainLight - have, 0.0h));
    // emission: lilToon col += _EmissionColor.rgb * _EmissionColor.a * _EmissionBlend * mask
    half3 albedo = max(sd.albedoAlpha.rgb, 0.05h);
    half em = sd.mask[_EmissionMaskChannel];
    sd.lightColor += _EmissionColor.rgb * _EmissionStrength * em / albedo;
}
