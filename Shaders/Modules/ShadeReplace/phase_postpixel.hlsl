// NOTE: keep this file ASCII-only.
// Intentionally a no-op for now.
// Adding the emission here (sd.col.rgb += mask.rgb) produced no visible change even with mask R max = 1,
// just like adding to sd.lightColor at modifylight (+5 moved the final pixel by ~0.02) and assigning
// sd.col there. So the live output variable for an additive term has not been identified yet; the next
// step is to read NonToon's birp.hlsl around the phase markers to see how the final colour is assembled.
if (_Enable)
{
    // no-op on purpose
}
