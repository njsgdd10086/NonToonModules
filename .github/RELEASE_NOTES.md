**NonToon Modules 0.1.1** —— 放宽依赖范围，兼容 NonToon 0.2.0 / Shader Core 0.2.0

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
