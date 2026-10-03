// NonToon ShadeReplace module (provided by NonToon Modules)
//
// Two measured problems are fixed here at __SC_PHASE_modifylight__:
//
// 1) The main directional light never reaches the material on NonToon 0.2.x + Shader Core 0.2.x (BRP).
//    Probes: _LightColor0 ~= 0.73 but lightSum.color == 0, so sd.lightColor collapsed to the ambient term
//    (~0.285 on every pixel); raising the light to 4x white changed nothing. No N.L is applied here on
//    purpose - NonToon's own convention is light.color = _LightColor0 * attenuation and the directional
//    falloff belongs to the shading term below.
//
// 2) NonToon's Shade ramp is a no-op on these materials (index 0 and index -1 render identically), so
//    nothing ever applies lilToon's shadow colour. lilToon shades with
//        indirectCol = min(shadowColor, albedo) * lightColor   (lightColor WITHOUT the cast-shadow attenuation)
//        col         = lerp(indirectCol, albedo * lightColor, lns)   lns = NdotL * shadow attenuation
//    Note the un-attenuated light: that is why lilToon stays bright inside a cast shadow (measured 0.5~0.7
//    while this material sat at 0.20~0.26). The part the cast shadow removed is added back below.
//
// Sign note: _WorldSpaceLightPos0 points FROM the light, so ndl uses -lightDir.
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    half3 mainRaw = _LightColor0.rgb;
    half3 have = saturate(lightSum.color);
    // 1) restore the main light that the loop never accumulated (with its cast shadow)
    // 2) then undo exactly the part that its cast shadow removed, because lilToon multiplies the shadow
    //    colour by the un-attenuated light. Doing (1) with mainRaw and then (2) double-counted the light.
    half3 sceneLight = saturate(env + lightSum.color + max(mainRaw * atten - have, 0.0h));
    half3 fullLight = saturate(sceneLight + mainRaw * (1.0h - atten));

    half3 lightDir = _WorldSpaceLightPos0.xyz;
    half3 nrm = dot(sd.N, sd.N) > 0.001h ? sd.N : normalize(vertex.N);
    half ndl = saturate(dot(nrm, -lightDir));
    half shade = saturate(ndl * 0.5h + 0.5h) * atten;

    half s1 = saturate((shade - saturate(_ShadowBorder - _ShadowBlur * 0.5h)) /
                       max(0.0001h, saturate(_ShadowBorder + _ShadowBlur * 0.5h) - saturate(_ShadowBorder - _ShadowBlur * 0.5h)));
    half s2 = saturate((shade - saturate(_Shadow2ndBorder - _Shadow2ndBlur * 0.5h)) /
                       max(0.0001h, saturate(_Shadow2ndBorder + _Shadow2ndBlur * 0.5h) - saturate(_Shadow2ndBorder - _Shadow2ndBlur * 0.5h)));
    half s3 = saturate((shade - saturate(_Shadow3rdBorder - _Shadow3rdBlur * 0.5h)) /
                       max(0.0001h, saturate(_Shadow3rdBorder + _Shadow3rdBlur * 0.5h) - saturate(_Shadow3rdBorder - _Shadow3rdBlur * 0.5h)));

    half3 indirect = _ShadowColor.rgb;
    indirect = lerp(indirect, _Shadow2ndColor.rgb, _Shadow2ndColor.a * (1.0h - s2));
    indirect = lerp(indirect, _Shadow3rdColor.rgb, _Shadow3rdColor.a * (1.0h - s3));
    indirect = lerp(indirect, indirect * sd.albedoAlpha.rgb, _ShadowMainStrength);

    half3 albedo = max(sd.albedoAlpha.rgb, 0.002h);
    half3 shadowTerm = min(indirect, albedo) / albedo;
    half mixS = lerp(1.0h, s1, _ShadowStrength);
    sd.lightColor = saturate(fullLight * lerp(shadowTerm, 1.0h, mixS));
}
