// NonToon Shade-Replace module (provided by NonToon Modules)
//
// WHY THIS EXISTS
//   lilToon shades with:   col = lerp(indirectCol, directCol, lns)
//   where indirectCol is the **absolute** shadow colour (it may be BRIGHTER than the albedo - measured
//   on a real model: clothes shadow = 1.41~1.71x albedo, hair = 1.06~1.37x).
//   NonToon's Shade module instead MULTIPLIES the colour by a gradient that is clamped to [0,1]
//   (the gradient texture is RGBA32 and sRGB), so it can only ever darken. Every material whose
//   lilToon shadow is brighter than its albedo therefore comes out darker - that is the whole
//   "clothes/hair too dark while the face looks fine" problem.
//   A bake-side workaround (brighten the base texture by K and divide the gradient by K) was tried and
//   measured; it cannot work reliably because three different colour spaces meet there
//   (lilToon material colours, the baked base texture, and Shader Core's sRGB gradient Texture2DArray).
//
// WHAT IT DOES
//   Runs at __SC_PHASE_postpixel__ (after sd.col has been multiplied by sd.lightColor) and simply
//   REPLACES the shaded colour with lilToon's own blend, using the absolute shadow colours that the
//   converter writes into the material - those are plain material properties, so they are not clamped
//   to 1 and there is no texture in the middle.
//
//   The shade value is recomputed here (same formula NonToon's Shade module uses) so this module works
//   with or without that module being active. The converter turns the Shade gradient off
//   (_ShadeGradientIndex = -1) when it enables this one, so nothing is applied twice.
//
// NOTE: keep this file ASCII-only (non-ASCII comments got mangled by an editor round trip once and
// silently commented out the effect).
if (_Enable)
{
    // Shade coordinate: same as NonToon's Shade module (range defaults to 0..1).
    half NdotL_N = dot(sd.N, sd.L);
    half NdotL_Detail = dot(sd.N_detail, sd.L);
    half shade = saturate(min(NdotL_N * 0.5h + 0.5h, 1.0h) + (NdotL_Detail - NdotL_N) * 0.5h);

    // lilToon's lilTooningScale: smooth window [border - blur/2, border + blur/2].
    half s1 = saturate((shade - saturate(_ShadowBorder - _ShadowBlur * 0.5h)) /
                       max(0.0001h, saturate(_ShadowBorder + _ShadowBlur * 0.5h) - saturate(_ShadowBorder - _ShadowBlur * 0.5h)));
    half s2 = saturate((shade - saturate(_Shadow2ndBorder - _Shadow2ndBlur * 0.5h)) /
                       max(0.0001h, saturate(_Shadow2ndBorder + _Shadow2ndBlur * 0.5h) - saturate(_Shadow2ndBorder - _Shadow2ndBlur * 0.5h)));
    half s3 = saturate((shade - saturate(_Shadow3rdBorder - _Shadow3rdBlur * 0.5h)) /
                       max(0.0001h, saturate(_Shadow3rdBorder + _Shadow3rdBlur * 0.5h) - saturate(_Shadow3rdBorder - _Shadow3rdBlur * 0.5h)));

    // Stacked shadow colour (lilToon: alpha of each layer is its strength).
    half3 indirect = _ShadowColor.rgb;
    indirect = lerp(indirect, _Shadow2ndColor.rgb, _Shadow2ndColor.a * (1.0h - s2));
    indirect = lerp(indirect, _Shadow3rdColor.rgb, _Shadow3rdColor.a * (1.0h - s3));

    // lilToon's _ShadowMainStrength multiplies the albedo into the shadow colour.
    indirect = lerp(indirect, indirect * sd.albedoAlpha.rgb, _ShadowMainStrength);

    // lilToon applies _ShadowStrength as lerp(1, s, strength).
    half mixS = lerp(1.0h, s1, _ShadowStrength);

    // IMPORTANT: the shadow colour only scales the DIRECT light - the environment (SH ambient) term is
    // added on top unscaled. sd.lightColor is saturate(env + direct), so multiplying the shadow colour by
    // the whole light would also darken the ambient; in shadow that made materials nearly black
    // (e.g. a shadow colour of 0.2 turned the ambient into 0.2 * ambient).
    half3 ambient = env;
    half3 direct = max(sd.lightColor - ambient, 0.0h);

    half3 lit = sd.col.rgb;                       // already albedo * light
    sd.col.rgb = lerp(indirect * direct + ambient, lit, mixS);
}
