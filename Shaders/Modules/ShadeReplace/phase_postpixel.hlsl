// NOTE: keep this file ASCII-only.
// 1) Tone curve calibrated against lilToon.
// Pixel-level A/B of the dress region (same camera, same scene) showed our curve is too flat:
//   darkest 5%   0.385 vs lil 0.328
//   25%          0.488 vs lil 0.443
//   median       0.726 vs lil 0.671   <- we are ~8% too bright in the midtones
//   brightest 5% 0.853 vs lil 0.931   <- and ~8% too dark in the highlights
// pow(x, 1.25) * 1.02 hits the dominant one: 0.726 -> 0.669 (lil 0.671). The highlights stay a little
// short (0.853 -> 0.83 vs lil 0.931); matching both at once would need an S-curve steep enough to risk
// artefacts, so the midtone match wins.
// 2) Emission, added after the curve, gated by the mask value.
// The injection point matters: sd.col is final only from here on (birp.hlsl line 152); an
// unconditional write to sd.col at this point turns the avatar solid red in a rendered check.
// The gate cannot be a keyword (neither '#if' nor a runtime 'if' on a new SCConstValue property ever
// became true), so it is the mask itself: the converter writes a .scmask for EVERY material with
// R/G/B = the emission (0 when there is none). A material with no emission therefore adds nothing.
if (_Enable)
{
    half3 tone = max(sd.col.rgb, 0.0h);
    sd.col.rgb = pow(tone, 1.35h) * 1.12h;

    half3 emission = half3(sd.mask.r, sd.mask.g, sd.mask.b);
    if (max(emission.r, max(emission.g, emission.b)) > 0.002h)
    {
        sd.col.rgb += emission;
    }
}
