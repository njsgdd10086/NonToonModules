// NOTE: keep this file ASCII-only.
// Intentionally a no-op for now.
// Shader Core 0.2.0 does not deliver module properties to the shader in this project - module floats,
// colours AND textures all fail (verified with a red 8x8 probe assigned to the module's own
// _EmissionTexture slot: the shader still samples the white default). Only SCConstValue keywords work.
// The working delivery route is a .scmask asset (that is how NonToon's own _SharedMask reaches shaders).
if (_Enable)
{
    // no-op on purpose
}
