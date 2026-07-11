using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Net.Http;

namespace WD2Launcher;

class ScriptHookDownloader
{
    private const string INSTALLER_URL = "https://cdn.nomad-group.net/nomadapps/wd2sh/build_depot/prod/installer/Watch_Dogs2-ScriptHook-Installer_r185.exe";
    private const string ZIP_URL = "https://cdn.nomad-group.net/nomadapps/wd2sh/build_depot/prod/zip/Win64ShippingPublic_r185.zip";
    private const string INSTRUCTIONS_URL = "https://db.nomad-group.net/page/WD2_ScriptHook:_Instructions";

    private static readonly HttpClient _httpClient = new();

    public static bool Download(string installPath)
    {
        try
        {
            Console.WriteLine("[INFO] ScriptHook not found.");
            Console.WriteLine();
            Console.WriteLine("[INFO] ScriptHook must be installed manually (CDN requires browser).");
            Console.WriteLine();
            Console.WriteLine("===========================================");
            Console.WriteLine("  MANUAL INSTALLATION STEPS:");
            Console.WriteLine("===========================================");
            Console.WriteLine();
            Console.WriteLine("1. Download Installer (recommended):");
            Console.WriteLine($"   {INSTALLER_URL}");
            Console.WriteLine();
            Console.WriteLine("   OR Download ZIP archive:");
            Console.WriteLine($"   {ZIP_URL}");
            Console.WriteLine();
            Console.WriteLine("2. Run the installer or extract ZIP to:");
            Console.WriteLine($"   {installPath}");
            Console.WriteLine();
            Console.WriteLine("3. Make sure VC Redistributable 2015-2019 (x64) is installed:");
            Console.WriteLine("   https://aka.ms/vs/16/release/vc_redist.x64.exe");
            Console.WriteLine();
            Console.WriteLine("4. Instructions page:");
            Console.WriteLine($"   {INSTRUCTIONS_URL}");
            Console.WriteLine();
            Console.WriteLine("===========================================");
            Console.WriteLine();

            Console.Write("Open download page in browser? (Y/n): ");
            string? input = Console.ReadLine()?.Trim().ToLower();

            if (input != "n" && input != "no")
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = INSTRUCTIONS_URL,
                    UseShellExecute = true
                });
            }

            Console.WriteLine();
            Console.Write("Press Enter after ScriptHook is installed, or 'q' to quit: ");
            input = Console.ReadLine()?.Trim().ToLower();

            if (input == "q" || input == "quit")
                return false;

            if (Directory.Exists(installPath) && Directory.GetFiles(installPath, "*.dll").Length > 0)
            {
                Console.WriteLine("[OK] ScriptHook detected!");
                return true;
            }

            Console.WriteLine("[WARN] ScriptHook still not found at expected path.");
            Console.WriteLine($"Expected: {installPath}");
            return false;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ERROR] {ex.Message}");
            return false;
        }
    }
}
