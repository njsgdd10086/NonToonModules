// NOTE: keep this file ASCII-only.
// Main-light restore.
//
// NonToon's own accumulate leaves sd.lightColor at ~0.54 on this avatar (measured by displaying the
// variable itself at postpixel), while lilToon lands the face at 0.775. Forcing sd.lightColor to 1 here
// puts the face at 0.717 - almost exactly lilToon - which also proves this is the phase that controls
// the light (an earlier '+5' test wrongly appeared to do nothing because it sat inside a '#if' that never
// compiled).
// saturate() keeps it safe in scenes with very bright lights: _LightColor0 here is 0.84, but a scene can
// easily have several directional lights and exceed 1 - an unbounded restore blew the avatar out before.
if (_Enable)
{
    half3 directLight = saturate(_LightColor0.rgb * 1.3h);
    sd.lightColor = max(sd.lightColor, directLight);
}
