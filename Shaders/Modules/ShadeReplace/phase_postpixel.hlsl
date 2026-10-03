// NOTE: keep this file ASCII-only.
// Emission, added at the very end of the chain (sd.col is final from here on - see birp.hlsl line 152;
// an unconditional write here turned the avatar solid red in a rendered check).
//
// The gate is the mask VALUE itself, not a keyword:
//  - Shader Core delivers no module floats/colours/textures to the shader here, and neither '#if' nor a
//    runtime 'if' on the SCConstValue property ever became true for this new property.
//  - What does work is the mask: the converter now writes a .scmask for EVERY material, with R/G/B = the
//    emission (0 when there is none) and A = the shared mask. So a material with no emission simply has
//    black R/G/B and this branch adds nothing; previously such a material had no .scmask at all and
//    sampled the white default, which is what blew the avatar out (0.414 -> 0.908).
if (_Enable)
{
    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
