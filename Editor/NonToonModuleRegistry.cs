// NonToon 模块注册表 —— 模块仓库的公共 API。
//
// 背景（Shader Core 的模块机制）：
//   SCShaderImporter 只会把「白名单里」的模块编进 shader：
//       shaderModules.Contains(m.uniqueID)
//   这份白名单存在 ProjectSettings/jp.lilxyzw.shadercore.asset（类 jp.lilxyzw.shadercore.ProjectSettings，
//   是 internal，所以这里用反射读写）。Shader Core 只会在导入 scshader 时把它**同目录**下的模块补进白名单，
//   外挂包里的模块必须自己登记。
//
// 还有一个坑：改完模块内容后，光 AssetDatabase.ImportAsset 不会让 Shader Core 重新生成 shader
//   （导入器看到 .scshader 内容没变就跳过），所以必须**改动一下 .scshader 的内容**再导入。
//
// 这个类把上面两件事封装成 API，供：
//   · 本仓库的勾选菜单（NonToonModuleManagerWindow）
//   · 外挂插件（LilToNonToon Switcher / NonToon 亮度控制）——它们用反射调用，所以模块仓库没装时插件也能编译
// 使用。

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace NonToonModules
{
    /// <summary>一个可用的模块（.scmodule）。</summary>
    public class ModuleInfo
    {
        public string Id;             // uniqueID，例如 jp.nontoon.switcher.fabric
        public string Name;           // 显示名
        public string Path;           // .scmodule 的工程内路径
        public string Source;         // 来源：Packages/<包名> 或 Assets/...
        public bool Enabled;          // 是否已在 NonToon 的模块列表里

        public override string ToString() => Name + " (" + Id + ")";
    }

    public static class NonToonModuleRegistry
    {
        public const string NonToonShaderName = "NonToon";
        private const string SettingsTypeName = "jp.lilxyzw.shadercore.ProjectSettings";

        /// <summary>被插件默认使用的模块 id（插件通过 EnsureEnabled 自动勾选）。</summary>
        public const string FabricModuleId = "jp.nontoon.switcher.fabric";
        public const string LightLimitModuleId = "com.atrinaxu.nontoon.lightlimit";

        // ------------------------------------------------------------------ 发现模块
        /// <summary>发现工程里所有 .scmodule（Assets/ 与 Packages/ 都扫）。</summary>
        public static List<ModuleInfo> Discover()
        {
            var result = new List<ModuleInfo>();
            var roots = new List<string> { Application.dataPath };
            var projectRoot = Path.GetDirectoryName(Application.dataPath);
            if (!string.IsNullOrEmpty(projectRoot))
            {
                var packages = Path.Combine(projectRoot, "Packages");
                if (Directory.Exists(packages)) roots.Add(packages);
            }

            foreach (var root in roots)
            {
                string[] files;
                try { files = Directory.GetFiles(root, "*.scmodule", SearchOption.AllDirectories); }
                catch (Exception) { continue; }

                foreach (var file in files)
                {
                    var text = ReadTextSafe(file);
                    if (string.IsNullOrEmpty(text)) continue;
                    var id = ExtractJson(text, "uniqueID");
                    if (string.IsNullOrEmpty(id)) continue;
                    var name = ExtractJson(text, "name");
                    var assetPath = ToAssetPath(file);
                    result.Add(new ModuleInfo
                    {
                        Id = id,
                        Name = string.IsNullOrEmpty(name) ? id : name,
                        Path = assetPath,
                        Source = DescribeSource(assetPath),
                        Enabled = false,
                    });
                }
            }

            var enabled = GetEnabledModules();
            foreach (var module in result) module.Enabled = enabled.Contains(module.Id);
            return result.OrderBy(m => m.Id, StringComparer.Ordinal).ToList();
        }

        private static string ReadTextSafe(string path)
        {
            try { return File.ReadAllText(path); }
            catch (Exception) { return null; }
        }

        private static string ExtractJson(string json, string key)
        {
            var match = Regex.Match(json, "\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ToAssetPath(string absolute)
        {
            var normalized = absolute.Replace('\\', '/');
            var dataPath = Application.dataPath.Replace('\\', '/');
            if (normalized.StartsWith(dataPath, StringComparison.Ordinal))
                return "Assets" + normalized.Substring(dataPath.Length);

            var projectRoot = Path.GetDirectoryName(Application.dataPath).Replace('\\', '/');
            if (normalized.StartsWith(projectRoot + "/", StringComparison.Ordinal))
                return normalized.Substring(projectRoot.Length + 1);
            return normalized;
        }

        private static string DescribeSource(string assetPath)
        {
            if (assetPath.StartsWith("Packages/", StringComparison.Ordinal))
            {
                var parts = assetPath.Split('/');
                return parts.Length > 1 ? parts[1] : "Packages";
            }
            return "Assets";
        }

        // ------------------------------------------------------------------ NonToon / Shader Core
        public static Shader FindNonToonShader() => Shader.Find(NonToonShaderName);

        public static string FindNonToonShaderPath()
        {
            var shader = FindNonToonShader();
            return shader != null ? AssetDatabase.GetAssetPath(shader) : null;
        }

        /// <summary>NonToon 的 shader 里有没有这个模块的属性（用来判断"登记了但还没编进去"）。</summary>
        public static bool ModuleCompiledIn(string id, string anyPropertySuffix)
        {
            var shader = FindNonToonShader();
            if (shader == null) return false;
            var token = TokenOf(id);
            for (var i = 0; i < shader.GetPropertyCount(); i++)
            {
                var name = shader.GetPropertyName(i);
                if (name.IndexOf(token, StringComparison.OrdinalIgnoreCase) < 0) continue;
                if (anyPropertySuffix == null || name.EndsWith(anyPropertySuffix, StringComparison.Ordinal)) return true;
            }
            return false;
        }

        /// <summary>把 uniqueID 里的包名部分去掉，留一个能在属性名里出现的片段（jp.nontoon.switcher.fabric -> fabric）。</summary>
        public static string TokenOf(string id)
        {
            if (string.IsNullOrEmpty(id)) return "";
            var parts = id.Split('.');
            return parts[parts.Length - 1];
        }

        /// <summary>当前在 NonToon 模块列表里的模块 id。</summary>
        public static HashSet<string> GetEnabledModules()
        {
            var set = new HashSet<string>(StringComparer.Ordinal);
            var modules = ReadModuleList();
            if (modules != null) foreach (var id in modules) set.Add(id);
            return set;
        }

        public static bool IsEnabled(string moduleId) => GetEnabledModules().Contains(moduleId);

        /// <summary>勾选 / 取消勾选一个模块，并（默认）重新生成 NonToon 的 shader。</summary>
        public static bool SetEnabled(string moduleId, bool enabled, bool regenerate = true)
        {
            var changed = enabled ? AddModule(moduleId) : RemoveModule(moduleId);
            if (changed && regenerate) RegenerateNonToonShader();
            return changed;
        }

        /// <summary>确保模块被勾选（插件在"用到"的时候调用；幂等）。</summary>
        public static bool EnsureEnabled(string moduleId, string label = null)
        {
            if (string.IsNullOrEmpty(moduleId)) return false;
            if (IsEnabled(moduleId))
            {
                // 已登记但可能还没编进 shader（登记之后没重新生成过）
                if (ModuleNeedsRegeneration(moduleId)) RegenerateNonToonShader();
                return true;
            }
            var added = AddModule(moduleId);
            if (!added) return false;
            RegenerateNonToonShader();
            if (!string.IsNullOrEmpty(label)) Debug.Log("[NonToon 模块] 已自动勾选 " + label + "（" + moduleId + "）");
            return true;
        }

        private static bool ModuleNeedsRegeneration(string moduleId)
        {
            var token = TokenOf(moduleId);
            var shader = FindNonToonShader();
            if (shader == null) return false;
            for (var i = 0; i < shader.GetPropertyCount(); i++)
                if (shader.GetPropertyName(i).IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0) return false;
            return true;
        }

        // ------------------------------------------------------------------ Shader Core 侧的读写
        private static Type ProjectSettingsType()
        {
            foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                var type = assembly.GetType(SettingsTypeName, false);
                if (type != null) return type;
            }
            return null;
        }

        private static object Instance(Type settingsType)
        {
            // instance 是 ScriptableSingleton<T> 基类上的静态属性 → 必须带 FlattenHierarchy
            var property = settingsType.GetProperty("instance",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.FlattenHierarchy);
            if (property != null) return property.GetValue(null);
            foreach (var candidate in settingsType.GetProperties(
                         BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.FlattenHierarchy))
            {
                if (candidate.Name.IndexOf("instance", StringComparison.OrdinalIgnoreCase) < 0) continue;
                if (candidate.PropertyType != settingsType) continue;
                return candidate.GetValue(null);
            }
            return null;
        }

        private static IList SettingsList(Type settingsType, object instance)
        {
            var field = settingsType.GetField("shaderSettings", BindingFlags.NonPublic | BindingFlags.Instance);
            return field != null ? field.GetValue(instance) as IList : null;
        }

        private static object FindEntry(Type settingsType, object instance, string shaderName)
        {
            var list = SettingsList(settingsType, instance);
            if (list == null) return null;
            foreach (var entry in list)
            {
                if (entry == null) continue;
                var nameField = entry.GetType().GetField("shadername");
                if (nameField != null && (string)nameField.GetValue(entry) == shaderName) return entry;
            }
            return null;
        }

        private static List<string> ReadModuleList()
        {
            var shaderPath = FindNonToonShaderPath();
            var shaderName = FindNonToonShader() != null ? FindNonToonShader().name : NonToonShaderName;
            var settingsType = ProjectSettingsType();
            if (shaderPath == null || settingsType == null) return null;
            var instance = Instance(settingsType);
            if (instance == null) return null;
            var entry = FindEntry(settingsType, instance, shaderName);
            if (entry == null) return null;
            var field = entry.GetType().GetField("modules");
            return field != null ? field.GetValue(entry) as List<string> : null;
        }

        private static bool AddModule(string moduleId)
        {
            var settingsType = ProjectSettingsType();
            var shader = FindNonToonShader();
            if (settingsType == null || shader == null) return false;
            var instance = Instance(settingsType);
            if (instance == null) return false;

            var entry = FindEntry(settingsType, instance, shader.name);
            if (entry == null)
            {
                // 没有记录：调用 Shader Core 自己的入口按它的规则建立（顺便补齐 NonToon 自带模块）
                TryCallGetShaderModules(settingsType, FindNonToonShaderPath());
                instance = Instance(settingsType);
                entry = FindEntry(settingsType, instance, shader.name);
            }
            if (entry == null) return false;

            var field = entry.GetType().GetField("modules");
            var modules = field != null ? field.GetValue(entry) as List<string> : null;
            if (modules == null) return false;
            if (modules.Contains(moduleId)) return false;
            modules.Add(moduleId);
            Save(settingsType, instance);
            return true;
        }

        private static bool RemoveModule(string moduleId)
        {
            var settingsType = ProjectSettingsType();
            if (settingsType == null) return false;
            var instance = Instance(settingsType);
            if (instance == null) return false;
            var entry = FindEntry(settingsType, instance, NonToonShaderName);
            if (entry == null) return false;
            var field = entry.GetType().GetField("modules");
            var modules = field != null ? field.GetValue(entry) as List<string> : null;
            if (modules == null || !modules.Remove(moduleId)) return false;
            Save(settingsType, instance);
            return true;
        }

        private static void TryCallGetShaderModules(Type settingsType, string shaderPath)
        {
            if (string.IsNullOrEmpty(shaderPath)) return;
            var method = settingsType.GetMethod("GetShaderModules",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
            if (method == null) return;
            try
            {
                var parameters = new object[] { shaderPath, null, null };
                method.Invoke(null, parameters);
            }
            catch (Exception exception)
            {
                Debug.LogWarning("[NonToon 模块] 调用 Shader Core 的 GetShaderModules 失败：" + exception.Message);
            }
        }

        private static void Save(Type settingsType, object instance)
        {
            var save = settingsType.GetMethod("Save",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (save != null) save.Invoke(instance, null);
            else EditorUtility.SetDirty(instance as UnityEngine.Object);
        }

        // ------------------------------------------------------------------ 重新生成 shader
        /// <summary>
        /// 强制 Shader Core 重新生成 NonToon 的 shader。
        /// 导入器看到 .scshader 内容没变会跳过重新生成，所以这里先临时改动文件内容再导入、然后还原。
        /// </summary>
        public static bool RegenerateNonToonShader()
        {
            var shaderPath = FindNonToonShaderPath();
            if (string.IsNullOrEmpty(shaderPath))
            {
                Debug.LogWarning("[NonToon 模块] 找不到 NonToon 的 shader，无法重新生成。");
                return false;
            }
            RegenerateShader(shaderPath);
            return true;
        }

        public static void RegenerateShader(string shaderPath)
        {
            var full = Path.GetFullPath(shaderPath);
            string original = null;
            try
            {
                original = File.ReadAllText(full);
                File.WriteAllText(full, original + "\n");
                AssetDatabase.ImportAsset(shaderPath, ImportAssetOptions.ForceUpdate);
                AssetDatabase.Refresh();
            }
            catch (Exception exception)
            {
                Debug.LogWarning("[NonToon 模块] 重新生成 shader 失败：" + exception.Message +
                                 "\n（如果 NonToon 是通过 VPM 安装的，请确认 Packages 目录可写。）");
            }
            finally
            {
                if (original != null)
                {
                    try
                    {
                        File.WriteAllText(full, original);
                        AssetDatabase.ImportAsset(shaderPath, ImportAssetOptions.ForceUpdate);
                        AssetDatabase.Refresh();
                    }
                    catch (Exception)
                    {
                        // 还原失败不影响功能
                    }
                }
            }
        }
    }
}
