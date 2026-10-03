// NOTE: keep this file ASCII-only.
// Emission, added at the very end of the chain (sd.col is final from here on - birp.hlsl line 152).
// Verified by rendering: an unconditional write to sd.col here turns the avatar solid red, and with real
// emission data the mouth glows.
//
// The gate is the mask VALUE:
//  - no module floats/colours/textures reach the shader here, and neither '#if' nor a runtime 'if' on a
//    new SCConstValue property ever became true;
//  - the converter now writes a .scmask for EVERY material, with R/G/B = the emission (0 when there is
//    none) and A = the shared mask, so a material without emission simply adds nothing here. Before that,
//    such a material had no .scmask at all and sampled the white default (+2 per pixel, the 0.414 -> 0.908
//    blow-out).
if (_Enable)
{
    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
