// NOTE: keep this file ASCII-only.
// Intentionally a no-op for now: Shader Core does not deliver MODULE properties to the shader in this
// project (measured: module floats, colours AND textures all fail - _EmissionStrength / _EmissionColor /
// _EmissionTexture / _LightBoost / _ShadeGradientIndex never arrive, while SCConstValue keywords and
// NonToon's own core properties do work). Any arithmetic here therefore either reads 0 or a white
// default texture, which blew the avatar out to 0.96 (from 0.41). Re-enable once the delivery works.
if (_Enable)
{
    // no-op on purpose
}
