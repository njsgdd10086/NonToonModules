// 混合式补光：乘法保留环境光的冷色染色（实测 R-B 由 +0.055 变为 -0.035，方向与 lil 一致），
// 再补少量中性直接光把整体亮度顶到 lil 的水平。
if (_Enable)
{
    sd.lightColor = saturate(sd.lightColor * 2.3h + _LightColor0.rgb * 0.30h);
}
