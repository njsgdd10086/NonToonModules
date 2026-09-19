// NonToon 模块管理菜单 / 窗口。
//
// 菜单（Tools/NonToon 模块/…）：
//   · 模块管理…                  打开窗口，逐项勾选
//   · 勾选：<每个模块>            菜单项直接开关，前面带勾
//   · 重新生成 NonToon shader     手动触发一次 Shader Core 重新生成
//
// 勾选 = 把模块的 uniqueID 加进 NonToon 的 Shader Core 模块白名单并重新生成 shader；
// 取消勾选 = 从白名单移除。NonToon 自带的模块也会列出来（方便对照），但不会被移除。

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace NonToonModules
{
    internal class NonToonModuleManagerWindow : EditorWindow
    {
        private List<ModuleInfo> _modules = new List<ModuleInfo>();
        private Vector2 _scroll;
        private string _status = "";

        [MenuItem("Tools/NonToon 模块/模块管理…", false, 1000)]
        private static void Open()
        {
            var window = GetWindow<NonToonModuleManagerWindow>(false, "NonToon 模块", true);
            window.minSize = new Vector2(460, 320);
            window.Refresh();
            window.Show();
        }

        [MenuItem("Tools/NonToon 模块/重新生成 NonToon shader", false, 1100)]
        private static void RegenerateFromMenu()
        {
            var ok = NonToonModuleRegistry.RegenerateNonToonShader();
            Debug.Log(ok ? "[NonToon 模块] 已重新生成 NonToon 的 shader。" : "[NonToon 模块] 重新生成失败，请看上面的警告。");
        }

        [MenuItem("Tools/NonToon 模块/刷新列表", false, 1101)]
        private static void RefreshFromMenu()
        {
            var window = GetWindow<NonToonModuleManagerWindow>(false, "NonToon 模块", true);
            window.Refresh();
        }

        private void OnEnable() => Refresh();

        private void Refresh()
        {
            _modules = NonToonModuleRegistry.Discover();
            var shaderPath = NonToonModuleRegistry.FindNonToonShaderPath();
            _status = shaderPath == null
                ? "没找到 NonToon 的 shader —— 请先安装 NonToon。"
                : "NonToon: " + shaderPath + "    共发现 " + _modules.Count + " 个模块，已勾选 " + _modules.Count(m => m.Enabled) + " 个";
            Repaint();
        }

        private void OnGUI()
        {
            EditorGUILayout.Space(4);
            EditorGUILayout.LabelField(_status, EditorStyles.wordWrappedLabel);
            EditorGUILayout.Space(4);

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("刷新", GUILayout.Width(80))) Refresh();
                if (GUILayout.Button("重新生成 shader", GUILayout.Width(140)))
                {
                    NonToonModuleRegistry.RegenerateNonToonShader();
                    Refresh();
                }
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("全部启用", GUILayout.Width(80))) SetAll(true);
                if (GUILayout.Button("全部停用", GUILayout.Width(80))) SetAll(false);
            }

            EditorGUILayout.Space(6);
            _scroll = EditorGUILayout.BeginScrollView(_scroll);

            foreach (var group in _modules.GroupBy(m => m.Source).OrderBy(g => g.Key, StringComparer.Ordinal))
            {
                EditorGUILayout.LabelField(group.Key == "Assets" ? "工程内（Assets）" : "来自 " + group.Key,
                    EditorStyles.boldLabel);
                EditorGUI.indentLevel++;
                foreach (var module in group)
                {
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        var now = EditorGUILayout.ToggleLeft(
                            module.Name + "    " + module.Id, module.Enabled, GUILayout.ExpandWidth(true));
                        if (now != module.Enabled)
                        {
                            NonToonModuleRegistry.SetEnabled(module.Id, now);
                            Refresh();
                            GUIUtility.ExitGUI();
                        }
                    }
                    EditorGUILayout.LabelField("     " + module.Path, EditorStyles.miniLabel);
                }
                EditorGUI.indentLevel--;
                EditorGUILayout.Space(4);
            }

            EditorGUILayout.EndScrollView();
            EditorGUILayout.HelpBox(
                "勾选后 NonToon 的 shader 会被重新生成一次（几秒钟）。\n" +
                "· 装了 LilToNonToon Switcher：转换时自动勾选「织物」模块；\n" +
                "· 装了 NonToon 亮度控制：用它时会自动勾选「亮度」模块。\n" +
                "这两个插件都依赖本模块包，所以不用手动装。",
                MessageType.Info);
        }

        private void SetAll(bool enabled)
        {
            foreach (var module in _modules)
                if (module.Enabled != enabled)
                    NonToonModuleRegistry.SetEnabled(module.Id, enabled, false);
            NonToonModuleRegistry.RegenerateNonToonShader();
            Refresh();
        }
    }

    /// <summary>
    /// 菜单里的快捷勾选项。Unity 不支持运行时动态菜单，所以每个模块写一个 MenuItem +
    /// Validate 里用 Menu.SetChecked 显示勾选状态（这是官方推荐做法）。
    /// </summary>
    internal static class NonToonModuleMenu
    {
        private const string FabricItem = "Tools/NonToon 模块/勾选：织物 / 法线细节（Fabric）";
        private const string LightItem = "Tools/NonToon 模块/勾选：亮度上下限（LightLimit）";

        [MenuItem(FabricItem, false, 1200)]
        private static void ToggleFabric() => Toggle(NonToonModuleRegistry.FabricModuleId, FabricItem);

        [MenuItem(FabricItem, true)]
        private static bool ValidateFabric()
        {
            Menu.SetChecked(FabricItem, NonToonModuleRegistry.IsEnabled(NonToonModuleRegistry.FabricModuleId));
            return true;
        }

        [MenuItem(LightItem, false, 1201)]
        private static void ToggleLight() => Toggle(NonToonModuleRegistry.LightLimitModuleId, LightItem);

        [MenuItem(LightItem, true)]
        private static bool ValidateLight()
        {
            Menu.SetChecked(LightItem, NonToonModuleRegistry.IsEnabled(NonToonModuleRegistry.LightLimitModuleId));
            return true;
        }

        private static void Toggle(string moduleId, string item)
        {
            var now = NonToonModuleRegistry.IsEnabled(moduleId);
            NonToonModuleRegistry.SetEnabled(moduleId, !now);
            Menu.SetChecked(item, !now);
            Debug.Log("[NonToon 模块] " + moduleId + " " + (!now ? "已勾选" : "已取消") +
                      "（NonToon 的 shader 已重新生成）");
        }
    }
}
