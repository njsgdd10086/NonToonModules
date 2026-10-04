// NOTE: keep this file ASCII-only.
//
// Fabric / weave shading.
//
// The per-material gate is the material's own _jp_nontoon_switcher_fabric_Enable value
// (the converter sets it to 1 only for materials whose source had a _BumpMap).
//
// KNOWN LIMITATION (measured, 2026-04): on NonToon this phase can only modulate brightness by a
// few percent, because the normal map's world-space perturbation is small: _NormalScale 0 / 1.2 / 8
// produced renders that differ by less than 1% (5% percentile 0.1589 in all three cases) on
// 'carde paleblue_nontoon'. The normal IS delivered (sd.N changes measurably when _NormalScale
// changes) - the weak response comes from NonToon's core, whose main lighting is
// `sd.lightColor = saturate(env + lightSum.color)` and therefore independent of the normal; the
// normal can only shift the Shade module's ramp lookup, and a near-white ramp makes that invisible.
if (_Enable)
{
    float2 dir = normalize(float2(0.35, -0.5));
    float delta = dot(float2(sd.N.x, sd.N.y), dir) * 1.0;
    delta = delta / (1.0 + abs(delta));
    sd.col.rgb *= max(0.0, 1.0 + delta * 0.25);
}
