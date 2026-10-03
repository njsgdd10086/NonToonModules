// NOTE: keep this file ASCII-only.
// Main-light restore. No tuning constants live here on purpose.
//
// NonToon's own accumulation can leave sd.lightColor far below the direct light, which renders the
// avatar too dark; this takes whichever is brighter. saturate() keeps multi-light scenes safe
// (this scene's _LightColor0 is 0.84, but a scene can easily exceed 1 and an unbounded restore blew
// the avatar out before).
//
// Any tonal compensation (how bright the result should be) is a CONVERTER setting applied to the baked
// base texture and the shade gradient, not a magic number here: Shader Core never delivers this
// module's own properties to the shader, so a constant in this file would be unconfigurable.
if (_Enable)
{
    sd.lightColor = max(sd.lightColor, saturate(_LightColor0.rgb));
}
