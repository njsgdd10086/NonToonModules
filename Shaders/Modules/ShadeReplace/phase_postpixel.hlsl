// NOTE: keep this file ASCII-only.
//
// Emission - added at the very end of the chain, WITH COLOUR.
//
// WHY THERE IS NO `if (_Enable)` WRAPPER HERE (measured, do not re-add it):
//   The module declares `SC_uint(_Enable, 0, [SCInHeader][SCToggle][SCConstValue(1,pixel)] ...)`
//   i.e. the default is 0, and SCConstValue makes it a COMPILE-TIME constant. Shader Core folds
//   `if (_Enable) {...}` into `if (0) {...}` so the whole phase disappears from the compiled shader
//   even though it IS present in the generated source. Verified: the generated source contains
//   `if(_com_nontoon_modules_shadereplace_Enable){ half3 emission=half3(sd.mask.r,...); ... }`
//   yet the render shows no emission, and setting the material property to 1 changes nothing.
//
//   The PER-MATERIAL gate that actually works is the mask itself: the converter zeroes the shared
//   mask's R/G/B for every material that has no emission (measured: Shinano_face has _EmissionBlend=0
//   by the author's design, so it bakes an all-zero emission, and its mask stays zero), while the 14
//   Shinano_face_eye_* materials have _EmissionBlend=1 and bake real data. That makes this phase a
//   no-op for non-emissive materials without any constant folding.
//
// The 0.002 threshold is an 8-bit rounding epsilon (1/512), not a tuning value.
half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
{
    sd.col.rgb += emission;
}
