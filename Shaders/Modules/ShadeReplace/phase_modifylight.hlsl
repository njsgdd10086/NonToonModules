// NOTE: keep this file ASCII-only.
//
// Main-light restore.
//
// This is what supplies the base lighting NonToon's own accumulation misses. Evidence (measured by the
// user on Shinano): ticking this module in the NonToon module window makes the face read correctly and
// the eye highlight appear; unticking it darkens the face noticeably (worst under the 3-spotlight
// preset) and the highlight disappears entirely. The eyes are simply bright albedo that reads as a
// highlight once the face is lit.
//
// The factor 1.6 is NOT a tuning guess: it is the value this phase has always used (it used to come
// from _MainLightStrength, whose module default was 1.6 and whose migration in the converter set the
// material value to 1). An intermediate edit dropped it to 1.0, which made the whole expression a no-op
// - the module then had no visible effect at all, which is exactly what the user reported.
//
// saturate() keeps multi-light scenes safe, and taking the BRIGHTER of the two (instead of adding)
// avoids the blow-out measured earlier (saturate(0.284 + 0.73) = 1.0 turned every lit surface into raw
// albedo). `atten` is the main-light attenuation lilToon itself uses: clamp(_LightColor0 * atten, ...).
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    sd.lightColor = saturate(max(sd.lightColor, _LightColor0.rgb * atten * 1.6h));
}
