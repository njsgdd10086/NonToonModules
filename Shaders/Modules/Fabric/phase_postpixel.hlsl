// NOTE: keep this file ASCII-only.
//
// Fabric / weave shading.
//
// This module deliberately reads NO material properties. Reason (measured, not guessed):
// Shader Core does not deliver module properties to the shader for modules we add ourselves, so any
// parameter read here comes back as its default - and the old version also read sd.N_detail, which is
// left uninitialised whenever NonToon's own Details module is off. The result was uncontrolled colour
// blocks on the body (magenta) and shoulders (white/yellow).
//
// It now uses only data that is always valid and always arrives:
//   sd.N   - the geometric normal (core)
//   sd.mask - the shared mask (core, .scmask-generated)
// and applies a small, fixed weave modulation. No tuning constants that a user cannot reach:
// the amount is a single documented constant below, chosen small enough to be safe on every material.
if (_Enable)
{
    // Weave direction: a stable diagonal in tangent-ish space derived from the normal, so it varies
    // across the surface without needing any texture or parameter.
    half weave = sin(dot(sd.N.xy, half2(37.0h, 53.0h)) * 40.0h);
    // 0.06 = the whole effect. Small enough that it can never turn into a colour patch on any material.
    sd.col.rgb *= (1.0h + weave * 0.06h);
}
