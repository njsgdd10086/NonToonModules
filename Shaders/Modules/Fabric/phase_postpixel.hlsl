// NOTE: keep this file ASCII-only.
//
// Fabric / weave shading - DISABLED (no-op) on purpose.
//
// History: the original version read module properties (_FabricNormalStrength / _FabricStrength /
// _FabricDir) which Shader Core never delivers for modules we add ourselves, plus sd.N_detail which is
// left uninitialised when NonToon Details is off. That produced uncontrolled colour patches.
// A rewrite using sd.N and a sin() weave instead produced visible ring artefacts on the whole body,
// which is far worse than no effect at all.
//
// Until there is a version that is verifiably safe on real models, this phase does nothing. The module
// toggle is left in place so the shader variant stays valid.
if (_Enable)
{
    // intentionally empty
}
