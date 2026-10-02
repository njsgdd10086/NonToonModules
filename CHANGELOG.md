# 更新日志

## [0.1.1] - 2026-10-02

### 变更

- **放宽对 NonToon / Shader Core 的依赖范围**：由 `^0.1.3` / `^0.1.5` 改成 `>=0.1.3` / `>=0.1.5` ✓ ——
  caret 在 0.x 上等价于 `<0.2.0`，所以 NonToon 0.2.0 一发布，本包就会因为版本冲突装不上 ✗。

### 兼容性说明（对 NonToon 0.2.0 + Shader Core 0.2.0 做的核对）

逐文件对比了 0.1.3 → 0.2.0 与 Shader Core 0.1.12 → 0.2.0，模块机制相关的东西**没有变化** ✓：

- NonToon 的 `__SC_PHASE_*` 钩子 17 处 → 17 处（含本包 Fabric 模块用的 `__SC_PHASE_postpixel__`）✓
- `sd.N_detail` / `sd.L` / `sd.mask` / `_SharedGradients` / `_SharedMask` / `_NormalMap` 用法不变 ✓
- Shader Core 的 `Editor/ProjectSettings.cs`（模块白名单 API）**完全一致** ✓
- Shader Core 的 `SCShaderImporter.cs` **diff 0 行** ✓（"触碰 .scshader 强制重新生成"的做法继续有效）
- `SCConstValue` → `EnableKeyword` 的开关关键字机制不变 ✓

所以本包代码没有改动，只改了依赖范围。

## [0.1.0] - 2026-09-17

首个版本。把 NonToon 的扩展做成**独立可复用**的 Shader Core 模块包，可以单独安装使用，
也可以被 LilToNonToon Switcher / NonToon 亮度控制当作依赖自动带上。

### 新增

- **模块管理菜单**（`Tools/NonToon 模块/`）：
  - `模块管理…` —— 列出工程里发现的所有 `.scmodule`（含 NonToon 自带的，方便对照），逐项勾选；
  - `勾选：织物 / 法线细节（Fabric）`、`勾选：亮度上下限（LightLimit）` —— 菜单项直接开关，前面带勾；
  - `重新生成 NonToon shader`、`刷新列表`。
- **公共 API**（`NonToonModules.NonToonModuleRegistry`）：`Discover()` / `IsEnabled(id)` /
  `SetEnabled(id, on)` / `EnsureEnabled(id)` / `RegenerateNonToonShader()` ——
  插件用反射调用它，所以模块包没装时插件仍能编译。
- **织物 / 法线细节模块（Fabric）**：NonToon 的受光面是恒定的（`sd.lightColor` 被 saturate 过），
  法线贴图的细微起伏没有输出通道，布料会显得像塑料；本模块在光照之后
  （`__SC_PHASE_postpixel__`）把「法线扰动造成的明暗差」加回去，观感接近 lilToon 的软明暗。
  默认强度 0.25（实测扫描：0 = 平得像塑料、0.25 最接近源、0.5 偏强、1.0 出现刺眼噪点）。
- **亮度上下限模块（LightLimit）**：Light Limit Changer 式的亮度上下限与亮度倍数（自 1.1.9 起的内容）。

### 技术说明

- Shader Core 的模块白名单按 shader 记录在 `ProjectSettings/jp.lilxyzw.shadercore.asset`
  （类是 internal，用反射读写 ✓）；外挂包的模块必须自己登记 ✓；
- 改完模块内容后光 `AssetDatabase.ImportAsset` **不会**重新生成 shader ✗ ——
  需要临时改动 `.scshader` 的内容再导入 ✓（本包已封装 ✓）；
- 同一模块 id 出现两份会被 Shader Core 重复编入导致编译错误 ✗ —— 勾选界面会去重并在 Console 提示 ✓。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN)。
