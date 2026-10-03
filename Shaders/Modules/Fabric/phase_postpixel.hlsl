// NonToon fabric / normal-detail module (provided by LilToNonToon Switcher)
//
// Hooked at __SC_PHASE_postpixel__: sd.col has already been multiplied by sd.lightColor by then, and
// sd.lightColor is saturated - on a lit surface it is constantly 1, so a perturbation routed through the
// light has no output channel at all.
//
// What it does: takes sd.N_detail (the perturbed normal computed by NonToon's own Details module) and
// turns its xy into a small brightness modulation, so the relief shows up everywhere instead of only
// inside a narrow terminator band.
//
// *** Guard (important) ***
// sd.N_detail is only filled in by NonToon's Details module. With that module off (i.e. the material has
// no normal map at all) the value is left uninitialised - NOT zero - and the dot product below then
// produces a constant offset in one fixed direction. Measured symptom: switching Fabric on for a material
// without a normal map painted a hard vertical band down one side of the face instead of doing nothing.
// The whole effect is therefore compiled out unless the Details module is actually active here.
//
// Things that were tried and DID NOT work (kept as a warning for future edits):
//   * dot(N, L): saturated on lit surfaces - measured 0.998 -> 0.998, the effect vanished exactly where
//     it matters;
//   * dot(N, H) specular: a flat test surface missed the lobe and dark meshes had nothing to sample;
//   * a fixed smoothstep window: saturated on lit surfaces and ate the whole variation;
//   * saturate() on the final factor: clamps the brighter half away, leaving only darkening;
//   * adding tangent-space detail xy to the world-space sd.N: meaningless perturbation direction;
//   * declaring SC_Texture2D in this module's properties.hlsl: Shader Core then drops the whole module,
//     so its phase silently stops running.
// NOTE: keep this file ASCII-only.
#if defined(_JP_LILXYZW_NONTOON_DETAILS_ENABLE_1)
if (_Enable)
{
    // Normalise the direction so _FabricStrength means the same thing regardless of the direction values.
    half2 dir = normalize(half2(_FabricDirX, _FabricDirY) + half2(1e-5h, 0.0h));
    half delta = dot(sd.N_detail.xy, dir) * _FabricNormalStrength;

    // Soft compression: keeps the fine relief but kills the large swings. Without this the normal map
    // turns into a harsh cross-hatch grid.
    delta = delta / (1.0h + abs(delta));

    sd.col.rgb *= max(0.0h, 1.0h + delta * _FabricStrength);
}
#endif