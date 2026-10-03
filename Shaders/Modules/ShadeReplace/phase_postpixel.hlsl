// NOTE: keep this file ASCII-only.
//
// Intentionally empty.
//
// Self-emission has been REMOVED. The only channel that ever reached this shader was sd.mask.rgb
// (the shared mask), and that mask is a resource shared by every module and every material - writing
// per-material emission data into it tinted the whole avatar (measured: magenta/yellow patches on the
// body; deleting _SharedMask made the render normal again). Shader Core does not deliver module
// properties for modules we add, so there is no per-material alternative inside a phase.
//
// The module stays declared so the shader variants remain valid; it simply does nothing now.
if (_Enable)
{
    // no-op
}
