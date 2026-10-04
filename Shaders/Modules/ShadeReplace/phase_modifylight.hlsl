// NOTE: keep this file ASCII-only.
//
// Main-light restore - REMOVED. This phase is now intentionally empty.
//
// Why it had to go (measured in game by the user): the restore read
//
//     sd.lightColor = saturate(max(sd.lightColor, _LightColor0.rgb * atten));
//
// but sd.lightColor already contains the shadow term while `_LightColor0.rgb * atten` is the main
// light WITHOUT shadowing (inside a Shader Core phase there are no shadow coords to transfer, so
// `atten` is effectively 1). Taking max() therefore discards the shadow entirely - the user reported
// the face staying bright and "not receiving shadows at all". That is exactly this line.
//
// Overall brightness must not be fought for here: it belongs to the converter's "baked exposure"
// advanced option, which changes the baked textures and never touches lighting.
//
// Do NOT reintroduce any light manipulation in this phase without verifying shadows in game.
if (_Enable)
{
    // intentionally empty
}
