// NOTE: keep this file ASCII-only.
//
// Fabric / weave shading - runtime, no baking.
//
// WHY THIS SHAPE (all measured, do not "simplify" it back):
//   * Shader Core does NOT deliver this module's own properties (float/color/texture) to the shader,
//     so the phase must not read _FabricNormalStrength / _FabricStrength / _FabricDir. Reading them
//     gave garbage (the module then painted uncontrolled magenta/white blocks on a real avatar).
//   * sd.N_detail is uninitialised whenever NonToon's own Details module is off - also garbage.
//   * What IS always valid and always arrives: sd.N (the shading normal) and sd.mask (the shared mask).
//     NonToon's _NormalMap is a CORE property, so the normal-map detail is already contained in sd.N.
//
// An earlier attempt used a high-frequency sin() on sd.N.xy with mixed half/float precision; on a real
// model that produced strong ring artefacts (and can break compilation outright). This version is
// deliberately:
//   * float precision throughout (no half/float mixing),
//   * low frequency (8.0, not 40.0) so no moire on a 1024+ texture or at distance,
//   * very small amplitude (0.04) so it can never dominate or tint anything,
//   * strictly a brightness modulation (multiplied greyscale), so it cannot introduce a colour cast.
if (_Enable)
{
    float2 weaveUv = float2(sd.N.x, sd.N.y) * 8.0;
    float weave = sin(weaveUv.x * 3.1 + weaveUv.y * 5.7);
    sd.col.rgb *= (1.0 + weave * 0.04);
}
