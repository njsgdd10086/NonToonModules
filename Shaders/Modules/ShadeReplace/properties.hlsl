SC_uint(_Enable, 0, [SCInHeader][SCToggle][SCConstValue(1,pixel)], "", "")

SC_Box
SC_color(_ShadowColor, (1,1,1,1), [SCCache], "", "")
SC_float(_ShadowBorder, 0.5, [SCRange(0,1)], "", "")
SC_float(_ShadowBlur, 0.1, [SCRange(0,1)], "", "")
SC_BoxEnd

SC_Box
SC_color(_Shadow2ndColor, (1,1,1,1), [SCCache], "", "")
SC_float(_Shadow2ndBorder, 0.5, [SCRange(0,1)], "", "")
SC_float(_Shadow2ndBlur, 0.1, [SCRange(0,1)], "", "")
SC_BoxEnd

SC_Box
SC_color(_Shadow3rdColor, (1,1,1,1), [SCCache], "", "")
SC_float(_Shadow3rdBorder, 0.5, [SCRange(0,1)], "", "")
SC_float(_Shadow3rdBlur, 0.1, [SCRange(0,1)], "", "")
SC_BoxEnd

SC_float(_ShadowStrength, 1, [SCRange(0,1)], "", "")
SC_float(_ShadowMainStrength, 0, [SCRange(0,1)], "", "")
SC_float(_MainLightStrength, 1, [SCRange(0,2)], "", "")

SC_Box
SC_color(_EmissionColor, (1,1,1,1), [SCCache], "", "")
SC_float(_EmissionStrength, 0, [SCRange(0,8)], "", "")
SC_uint(_EmissionMaskChannel, 0, [SCMaskChannel], "__MaskChannel", "")
SC_BoxEnd
