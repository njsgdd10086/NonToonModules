// NOTE: keep this file ASCII-only.
//
// ShadeReplace - lighting stage.
//
// Deliberately EMPTY.
//
// History (kept so nobody re-adds a "compensation" here):
//   * A previous version tried to restore brightness with max(sd.lightColor, _LightColor0 * atten).
//     A Shader Core phase cannot receive shadow coordinates (SHADOW_COORDS cannot be forwarded),
//     so UNITY_LIGHT_ATTENUATION returns ~1 for the main directional light - that expression threw
//     the shadows away and made every material look unlit. Reverted.
//   * A later version pulled sd.lightColor toward its own luminance by a fixed 0.5 to remove a blue
//     ambient cast. That is a magic number describing one scene's skybox, not a conversion rule.
//     Removed: the plugin must not bake scene-specific corrections into a shader.
//
// The emission that this module does implement lives in phase_postpixel.hlsl, and the shadow colour
// work is done on the texture side (Shade gradients baked per material) - neither needs this stage.
if (_Enable)
{
}
