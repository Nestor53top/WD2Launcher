using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;

namespace WD2Launcher;

class SteamHelper
{
    private const int WD2_APP_ID = 447040;

    private string? _steamPath;
    private string? _gamePath;

    public string? FindSteamPath()
    {
        if (_steamPath != null) return _steamPath;

        string[] possiblePaths = new[]
        {
            @"C:\Program Files (x86)\Steam",
            @"C:\Program Files\Steam",
            @"D:\Steam",
            @"D:\SteamLibrary",
            @"E:\Steam",
            @"E:\SteamLibrary",
            @"F:\Steam",
            @"F:\SteamLibrary",
        };

        foreach (var path in possiblePaths)
        {
            if (File.Exists(Path.Combine(path, "steam.exe")))
            {
                _steamPath = path;
                return _steamPath;
            }
        }

        try
        {
            using var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Valve\Steam");
            if (key != null)
            {
                var installPath = key.GetValue("InstallPath") as string;
                if (installPath != null && File.Exists(Path.Combine(installPath, "steam.exe")))
                {
                    _steamPath = installPath;
                    return _steamPath;
                }
            }
        }
        catch { }

        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Valve\Steam");
            if (key != null)
            {
                var installPath = key.GetValue("SteamPath") as string;
                if (installPath != null)
                {
                    installPath = installPath.Replace('/', '\\');
                    if (File.Exists(Path.Combine(installPath, "steam.exe")))
                    {
                        _steamPath = installPath;
                        return _steamPath;
                    }
                }
            }
        }
        catch { }

        return null;
    }

    public string? FindGamePath()
    {
        if (_gamePath != null) return _gamePath;

        string? steamPath = FindSteamPath();
        if (steamPath == null) return null;

        string libraryFoldersPath = Path.Combine(steamPath, "steamapps", "libraryfolders.json");
        if (File.Exists(libraryFoldersPath))
        {
            string json = File.ReadAllText(libraryFoldersPath);
            var libraries = ParseLibraryFolders(json);

            foreach (var lib in libraries)
            {
                string appPath = Path.Combine(lib, "steamapps", $"appmanifest_{WD2_APP_ID}.acf");
                if (File.Exists(appPath))
                {
                    string? installDir = ParseInstallDir(appPath);
                    if (installDir != null)
                    {
                        string fullPath = Path.Combine(lib, "steamapps", "common", installDir);
                        if (Directory.Exists(fullPath))
                        {
                            _gamePath = fullPath;
                            return _gamePath;
                        }
                    }
                }
            }
        }

        string defaultPath = Path.Combine(steamPath, "steamapps", "common", "Watch_Dogs 2");
        if (Directory.Exists(defaultPath))
        {
            _gamePath = defaultPath;
            return _gamePath;
        }

        return null;
    }

    private List<string> ParseLibraryFolders(string json)
    {
        var libraries = new List<string>();

        var steamPath = FindSteamPath();
        if (steamPath != null)
        {
            libraries.Add(steamPath);
        }

        int contentIdx = json.IndexOf("\"contentstatsid\"");
        int idx = 0;
        while (true)
        {
            int pathIdx = json.IndexOf("\"path\"", idx);
            if (pathIdx == -1) break;

            int startQuote = json.IndexOf('"', pathIdx + 6);
            if (startQuote == -1) break;

            int endQuote = json.IndexOf('"', startQuote + 1);
            if (endQuote == -1) break;

            string path = json.Substring(startQuote + 1, endQuote - startQuote - 1);
            path = path.Replace("\\\\", "\\").Replace("/", "\\");

            if (!libraries.Contains(path))
            {
                libraries.Add(path);
            }

            idx = endQuote + 1;
        }

        return libraries;
    }

    private string? ParseInstallDir(string acfPath)
    {
        try
        {
            string[] lines = File.ReadAllLines(acfPath);
            foreach (var line in lines)
            {
                string trimmed = line.Trim();
                if (trimmed.StartsWith("\"installdir\""))
                {
                    int start = trimmed.IndexOf('"', trimmed.IndexOf('"') + 1);
                    int end = trimmed.IndexOf('"', start + 1);
                    if (start != -1 && end != -1)
                    {
                        return trimmed.Substring(start + 1, end - start - 1);
                    }
                }
            }
        }
        catch { }

        return null;
    }

    public void SetLaunchOptions(string options)
    {
        string? steamPath = FindSteamPath();
        if (steamPath == null) return;

        string configPath = Path.Combine(steamPath, "config", "config.vdf");
        if (!File.Exists(configPath))
        {
            string userDataPath = Path.Combine(steamPath, "userdata");
            if (Directory.Exists(userDataPath))
            {
                var dirs = Directory.GetDirectories(userDataPath);
                if (dirs.Length > 0)
                {
                    string localConfigPath = Path.Combine(dirs[0], "config", "localconfig.vdf");
                    if (File.Exists(localConfigPath))
                    {
                        SetLaunchOptionsInVdf(localConfigPath, options);
                    }
                }
            }
            return;
        }

        SetLaunchOptionsInVdf(configPath, options);
    }

    private void SetLaunchOptionsInVdf(string vdfPath, string options)
    {
        try
        {
            string content = File.ReadAllText(vdfPath);
            string launchKey = $"\"{WD2_APP_ID}\"";

            int appIdx = content.IndexOf(launchKey);
            if (appIdx == -1)
            {
                File.Copy(vdfPath, vdfPath + ".bak");
                Console.WriteLine("[INFO] VDF backup created");
                return;
            }

            int launchOptionsIdx = content.IndexOf("\"LaunchOptions\"", appIdx);
            if (launchOptionsIdx != -1)
            {
                int startQuote = content.IndexOf('"', launchOptionsIdx + 15);
                int endQuote = content.IndexOf('"', startQuote + 1);
                if (startQuote != -1 && endQuote != -1)
                {
                    string currentOptions = content.Substring(startQuote + 1, endQuote - startQuote - 1);
                    if (currentOptions.Contains("-eac_launcher"))
                    {
                        Console.WriteLine("[INFO] Launch options already set");
                        return;
                    }

                    string newOptions = currentOptions + " " + options;
                    content = content.Substring(0, startQuote + 1) + newOptions + content.Substring(endQuote);
                    File.WriteAllText(vdfPath, content);
                    Console.WriteLine("[OK] Launch options updated in VDF");
                    return;
                }
            }

            Console.WriteLine("[WARN] Could not find LaunchOptions in VDF, Steam will handle it");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[WARN] VDF edit failed: {ex.Message}");
            Console.WriteLine("[INFO] Using Steam protocol fallback");
        }
    }

    public void LaunchGame()
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "steam://rungameid/" + WD2_APP_ID,
                UseShellExecute = true
            });
        }
        catch
        {
            try
            {
                string? steamPath = FindSteamPath();
                if (steamPath != null)
                {
                    Process.Start(new ProcessStartInfo
                    {
                        FileName = Path.Combine(steamPath, "steam.exe"),
                        Arguments = $"steam://rungameid/{WD2_APP_ID}",
                        UseShellExecute = true
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] Failed to launch: {ex.Message}");
            }
        }
    }
}
