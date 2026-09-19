# NonToon Modules

NonToon 的**扩展模块集合** —— 每个模块都是一个 [Shader Core](https://github.com/lilxyzw/ShaderCore) 模块，以「注入」的方式给 NonToon 加功能，**不改动 NonToon 本体**。

| 模块 | 作用 | 谁会自动勾选它 |
| --- | --- | --- |
| **Fabric（织物 / 法线细节）** | 把 lilToon 那种布料质感补回来。NonToon 原本的受光面是恒定的（`sd.lightColor` 被 saturate 过），法线贴图的细微起伏没有输出通道，布料会显得像塑料；这个模块在光照之后把「法线扰动造成的明暗差」加回去，观感接近 lilToon 的软明暗。 | 装了 **LilToNonToon Switcher**：转换时自动勾选 |
| **LightLimit（亮度上下限 / 亮度倍数）** | Light Limit Changer 式的亮度控制（上下限、亮度倍数）。 | 装了 **NonToon 亮度控制**：用它时自动勾选 |

## 安装

VCC / ALCOM 里添加仓库（总索引，本模块包和上面两个插件都在这一份里）：

```
https://njsgdd10086.github.io/vpm-listing/index.json
```

然后安装 **NonToon Modules** 即可。它会自动带上 NonToon 与 Shader Core（VPM 依赖）。

> 单独用也完全可以：只装这个包 + NonToon，就能在菜单里手动勾选模块用。
> 装了上面两个插件的话，它们**依赖**本包（VPM 会自动装好），并在用到对应功能时**自动勾选**模块 —— 你也可以随时手动取消。

## 用法

**菜单：`Tools/NonToon 模块/`**

- **模块管理…** —— 打开窗口，列出工程里发现的所有 `.scmodule`（含 NonToon 自带的，方便对照），逐项勾选；
- **勾选：织物 / 法线细节（Fabric）** —— 菜单项直接开关，前面带勾；
- **勾选：亮度上下限（LightLimit）** —— 同上；
- **重新生成 NonToon shader** —— 手动触发一次重新生成（改了模块内容、或换过 NonToon 版本之后可以用）。

勾选 = 把模块的 `uniqueID` 加进 NonToon 的 Shader Core 模块白名单，并**重新生成一次 NonToon 的 shader**（几秒钟）。取消勾选就是移除。

## 材质侧参数

勾选之后，材质上会出现对应模块的属性（前缀 `_jp_nontoon_switcher_fabric_` / `_com_atrinaxu_nontoon_lightlimit_`，Shader Core 按包名生成）。

**Fabric**（转换器会自动填好）：

| 属性 | 默认 | 说明 |
| --- | --- | --- |
| `_Enable` | 0 | 模块总开关（勾选模块 ≠ 打开这个，转换时会自动置 1） |
| `_FabricNormalMap` | 空 | 法线贴图（转换器接源材质的 `_BumpMap`） |
| `_FabricNormalStrength` | 1 | 扰动幅度 |
| `_FabricStrength` | 0.25 | 强度（0 = 关闭；实测 0.25 最接近 lilToon，0.5 偏强，1.0 会出现刺眼噪点） |
| `_FabricDirX` / `_FabricDirY` | 0.35 / -0.5 | 织物的「受光方向」 |

## 技术说明（为什么需要一个模块）

NonToon 的片元流程（`birp.hlsl`）大致是：

```
__SC_PHASE_base__         ← Details 模块在这里算 sd.N_detail
__SC_PHASE_shade__        ← Shade 模块（渐变）
__SC_PHASE_reflection__   ← MatCap / Specular
__SC_PHASE_add__          ← 边缘光等
sd.col.rgb *= sd.lightColor;   ← 光照在这个位置乘上去，而且是 saturate 过的
__SC_PHASE_postpixel__    ← 我们把织物调制加在这里
```

两个坑（都踩过，写下来省得以后再踩）：

1. **Shader Core 的模块白名单是按 shader 记录的**，存在 `ProjectSettings/jp.lilxyzw.shadercore.asset`（类是 `internal`，所以本包用反射读写）。Shader Core 只会在导入 `.scshader` 时把它**同目录**下的模块补进白名单，外挂包的模块必须自己登记；
2. **改完模块内容后光 `AssetDatabase.ImportAsset` 不会重新生成 shader** —— 导入器看到 `.scshader` 内容没变就跳过。本包的做法是临时改动一下 `.scshader` 的内容再导入，然后还原。

本包提供的公共 API（`NonToonModules.NonToonModuleRegistry`）：`Discover()` / `IsEnabled(id)` / `SetEnabled(id, on)` / `EnsureEnabled(id)` / `RegenerateNonToonShader()`。外挂插件用**反射**调用它，所以即使本包没装，插件也能正常编译（只会提示需要安装模块包）。

## 许可

MIT
