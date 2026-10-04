// NOTE: keep this file ASCII-only.
//
// Emission - added at the end of the chain, WITH COLOUR.
//
// An earlier version forced the add to a single channel:
//     half emission = sd.mask.r;  sd.col.rgb += half3(emission, emission, emission);
// which is mathematically greyscale - so changing _EmissionColor had NO visible effect at all
// (the user set it to red, reconverted, and the highlight stayed grey). That was wrong.
//
// The colour-cast problem it was trying to avoid came from the mask's R/G/B being non-zero on
// materials that have no emission at all. The converter now zeroes R/G/B for every such material
// (only real emitters keep data), so adding the mask per channel is safe again.
//
// Gate: the mask VALUE. 0.002 is an 8-bit rounding epsilon, not a tuning value.
// sd.col is final only from this phase on, so this is the one place the add survives.
if (_Enable)
{
    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
