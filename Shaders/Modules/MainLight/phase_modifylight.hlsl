// NonToon MainLight module - same idea as ShadeReplace but standalone (see that module for the analysis).
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    half3 mainLight = _LightColor0.rgb * atten * _MainLightStrength;
    half3 have = saturate(lightSum.color);
    sd.lightColor = saturate(sd.lightColor + max(mainLight - have, 0.0h));
}
