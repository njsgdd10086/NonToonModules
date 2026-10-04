// NOTE: keep this file ASCII-only.
//
// Ambient colour-cast correction (optional, safe).
//
// Problem (measured, not guessed): in this scene the ambient comes from a BLUE skybox
// (0.212/0.227/0.259) and NonToon accumulates it as the main light in unlit/shadow areas.
// A pink iris therefore renders blue-grey: measured left eye (0.473, 0.552, 0.574), i.e. R-B = -0.101.
// lilToon handles ambient differently and keeps the same eye pale red, which is what the user sees
// side by side in the "no light" preset.
//
// Fix: pull the light colour part-way toward its own luminance - i.e. remove the COLOUR CAST of the
// ambient without changing how bright anything is. Luminance is preserved exactly, so tone/brightness
// are untouched; only the blue bias goes away.
//
// The amount is fixed and deliberately moderate (0.5). Set it to 0.0 to disable entirely.
if (_Enable)
{
    half3 lc = sd.lightColor;
    half lum = dot(lc, half3(0.2126, 0.7152, 0.0722));
    sd.lightColor = lerp(lc, half3(lum, lum, lum), 0.5h);
}
