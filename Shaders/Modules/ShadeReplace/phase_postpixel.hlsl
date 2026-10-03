// NOTE: keep this file ASCII-only.
// Emission, added at the very end of the chain: sd.col is final only from here on (birp.hlsl line 152),
// and an unconditional write at this point turns the avatar solid red in a rendered check.
//
// The gate is the mask VALUE, not a keyword: neither '#if' nor a runtime 'if' on a new SCConstValue
// property ever became true for this module, while the mask works - the converter writes a .scmask for
// EVERY material with R/G/B = the emission (0 when there is none), so a material without emission adds
// nothing here. 0.002 is a numerical epsilon against 8-bit rounding, not a tuning value.
//
// No tone curve here either: tonal compensation is a converter setting applied to the baked textures,
// because this module's own properties never reach the shader (see phase_modifylight.hlsl).
if (_Enable)
{
    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
