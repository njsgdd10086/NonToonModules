// NOTE: keep this file ASCII-only.
// Emission is intentionally OFF until it can be gated per material.
// The mask is a [SCMask] texture that Shader Core itself generates from a .scmask asset. A material
// WITHOUT that asset samples the white default, so "+= sd.mask.rgb" adds about +2 to every pixel and
// blows the whole avatar out (measured: pure NonToon 0.414, with the ungated emission 0.90).
// The gate must be a keyword (SCConstValue), because module floats/colors/textures do not reach the
// shader in this project at all.
if (_Enable)
{
    // no-op on purpose
}
