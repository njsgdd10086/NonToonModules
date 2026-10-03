// NOTE: keep this file ASCII-only.
// Intentionally empty: sd.lightColor is already saturated to 1 internally by the time this phase runs
// (adding +5 to it moved the final pixel by only ~0.02, and assigning sd.col here changes nothing),
// so the emission has to be added AFTER the shade pass - see phase_postpixel.hlsl.
if (_Enable)
{
    // no-op
}
