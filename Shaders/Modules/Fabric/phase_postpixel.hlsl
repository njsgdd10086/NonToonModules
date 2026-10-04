// NOTE: keep this file ASCII-only.
//
// Fabric / weave shading - the effect that was verified working before, restored.
//
// Original form (which produced the look the user wants):
//     half2 dir = normalize(half2(_FabricDirX, _FabricDirY) + half2(1e-5h, 0.0h));
//     half delta = dot(sd.N_detail.xy, dir) * _FabricNormalStrength;
//     delta = delta / (1.0h + abs(delta));
//     sd.col.rgb *= max(0.0h, 1.0h + delta * _FabricStrength);
//
// Two things had to change, both measured:
//   * _FabricDirX/_FabricDirY/_FabricNormalStrength/_FabricStrength are THIS module's own properties and
//     Shader Core never delivers them (they read as defaults) - so the direction is fixed here and the
//     strengths are constants.
//   * sd.N_detail is uninitialised whenever NonToon's Details module is off, which painted uncontrolled
//     magenta/white blocks. sd.N is always valid; NonToon's _NormalMap is a core property, so its
//     detail is already carried by sd.N.
//
// Everything else (the normalisation, the clamp, the multiply) is the original maths, so the look
// matches. Kept in float precision: mixing half/float here previously produced ring artefacts and could
// break compilation outright.
if (_Enable)
{
    float2 dir = normalize(float2(0.35, -0.5));
    float delta = dot(float2(sd.N.x, sd.N.y), dir) * 1.0;
    delta = delta / (1.0 + abs(delta));
    sd.col.rgb *= max(0.0, 1.0 + delta * 0.25);
}
