// NOTE: keep this file ASCII-only.
//
// Main-light restore - a SAFETY NET, not a brightener.
//
// It supplies light only where NonToon's own accumulation came up short. Taking the brighter of the two
// means it is a no-op wherever NonToon already accumulates properly.
//
// History / measured reasons for the current form:
//   * Adding instead of max() blew the avatar out: saturate(0.284 + 0.73) = 1.0 turned every lit
//     surface into raw albedo.
//   * A version with a fixed 1.6x boost was removed because it FIGHTS scene lighting: the user measured
//     that the face kept glowing on the "in shadow" preset, i.e. the boost pulled back light the scene
//     had deliberately dimmed. Brightness must not be hard-coded here - the converter's "baked exposure"
//     (advanced options) is the configurable place for it.
//   * A version without `atten` was measurably darker under multi-light presets; `atten` is what lilToon
//     itself uses (clamp(_LightColor0 * atten, Min, Max)).
if (_Enable)
{
    UNITY_LIGHT_ATTENUATION(atten, i, vertex.position);
    sd.lightColor = saturate(max(sd.lightColor, _LightColor0.rgb * atten));
}
