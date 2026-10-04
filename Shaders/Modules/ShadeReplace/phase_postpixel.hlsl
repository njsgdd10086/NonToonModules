// NOTE: keep this file ASCII-only.
//
// Emission, added at the very end of the chain (sd.col is final only from this phase on).
//
// This is the only way to get a highlight visible in a completely unlit scene: baking the emission
// into the base texture cannot work, because the base texture is multiplied by lighting.
//
// COLOUR: the add uses ONE channel as the intensity and produces a neutral grey highlight.
// Measured reason: the converter writes <material>_Emission.png from _EmissionColor (an HDR
// blue-white, 1.789/1.919/2.119) multiplied by the _EmissionBlendMask shape. Even after desaturating
// the colour, the mask's per-channel detail left the result at R/B = 0.98, G/B = 0.92 on screen -
// the user consistently reported the highlight as "purple". lilToon's highlight reads as a neutral
// white/grey, so taking a single channel removes the possibility of a colour cast entirely.
//
// The gate is the mask VALUE (a black texture - no emission - adds nothing), 0.002 being an 8-bit
// rounding epsilon rather than a tuning value.
if (_Enable)
{
    half emission = sd.mask.r;
    if (emission > 0.002h)
    {
        sd.col.rgb += half3(emission, emission, emission);
    }
}
