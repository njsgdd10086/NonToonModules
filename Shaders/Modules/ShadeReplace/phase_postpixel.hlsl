// NOTE: keep this file ASCII-only.
//
// Emission, added at the very end of the chain.
//
// `sd.col` is final only from this phase on (birp.hlsl line 152) - a write at modifylight does NOT
// survive. This is the only way to get a highlight that is visible in a completely unlit scene: baking
// the emission into the base texture cannot work, because the base texture is multiplied by lighting
// and therefore goes black when there is no light (measured by the user on the "no light" preset).
//
// The data comes from the shared mask's R/G/B, which the converter fills with <material>_Emission.png.
// That texture is SPARSE - measured mean 0.005 with only ~2.3% of pixels non-zero (the eyes) - so this
// add lights up the eyes only. An earlier version added a mask whose R/G/B was a solid magenta field,
// which is what tinted the whole avatar; that is why the epsilon gate below exists.
//
// 0.002 is a numerical epsilon against 8-bit rounding, not a tuning value.
if (_Enable)
{
    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
