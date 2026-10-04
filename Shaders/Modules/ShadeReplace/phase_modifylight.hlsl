// NOTE: keep this file ASCII-only.
//
// Main-light restore, restored to the form that was verified working on a real avatar.
//
// Why it matters (measured by the user): toggling this module off makes the face visibly darker and
// removes the eye highlight entirely; toggling it on brings both back. So this phase is what supplies
// the "base" lighting that NonToon's own accumulation misses - the eyes are simply bright albedo that
// reads as a highlight once the face is lit.
//
// History: an intermediate version dropped `atten` and used saturate(_LightColor0.rgb) directly, which
// measurably darkened the face (especially under the 3-spotlight preset) and lost the highlight.
// `atten` is the light attenuation for the main directional light (1.0 in the common case) and is what
// lilToon itself uses: clamp(_LightColor0 * atten, Min, Max).
//
// Takes the BRIGHTER of the two rather than adding them: adding was measured to blow the avatar out
// (saturate(0.284 + 0.73) = 1.0 => every lit surface rendered as raw albedo).
//
// No tuning constants here on purpose. Any tonal compensation is a CONVERTER setting applied to the
// baked textures, because Shader Core never delivers this module's own properties to the shader.
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    sd.lightColor = saturate(max(sd.lightColor, _LightColor0.rgb * atten));
}
