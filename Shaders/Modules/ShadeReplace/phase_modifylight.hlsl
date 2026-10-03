// NonToon Modules - ShadeReplace phase
//
// CURRENT STATE: intentionally a no-op.
//
// The light restore below is disabled because _LightColor0 in a real scene can be far above 1
// (this one has 13 directional lights): restoring towards it turned a 0.413 render into 0.96 (blown
// white), and a threshold version behaved the same in practice.
//
// The emission is also disabled: Shader Core does not deliver float/color module properties to the
// shader (measured: _EmissionStrength / _EmissionColor / _LightBoost / _ShadeGradientIndex always read 0),
// and _SharedMask carries [SCMask] so Shader Core's own mask system overrides whatever the converter
// writes into it (verified: the mask asset holds 0.048 while the shader reads pure white).
// A dedicated non-SCMask texture slot (_EmissionTexture) is declared in properties.hlsl and is the
// intended route - it still needs the converter side finished and verified.
// NOTE: keep this file ASCII-only.
if (_Enable)
{
    // no-op on purpose
}
