using System;
using System.Diagnostics;
using System.IO;
using System.Threading;

namespace WD2Launcher;

class Program
{
    static void Main(string[] args)
    {
        Console.Title = "WD2 Launcher - EAC Bypass + Trainer";
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("===========================================");
        Console.WriteLine("  WD2 LAUNCHER v1.0");
        Console.WriteLine("  EAC Bypass + Auto Trainer Install");
        Console.WriteLine("===========================================");
        Console.ResetColor();
        Console.WriteLine();

        try
        {
            var config = Config.Load();
            var steam = new SteamHelper();
            var installer = new TrainerInstaller();

            string? gamePath = steam.FindGamePath();
            if (gamePath == null)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("[ERROR] Watch Dogs 2 not found!");
                Console.WriteLine("Press any key to exit...");
                Console.ResetColor();
                Console.ReadKey();
                return;
            }

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"[OK] Game found: {gamePath}");
            Console.ResetColor();

            string scriptHookPath = Path.Combine(gamePath, "bin", "ScriptHook");
            if (!Directory.Exists(scriptHookPath))
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("[WARN] ScriptHook not found, attempting download...");
                Console.ResetColor();

                if (!ScriptHookDownloader.Download(scriptHookPath))
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("[ERROR] Failed to download ScriptHook!");
                    Console.WriteLine("Press any key to exit...");
                    Console.ResetColor();
                    Console.ReadKey();
                    return;
                }
            }

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("[OK] ScriptHook installed");
            Console.ResetColor();

            installer.InstallTrainer(gamePath);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("[OK] Trainer installed");
            Console.ResetColor();

            steam.SetLaunchOptions("-eac_launcher");
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("[OK] Launch options set: -eac_launcher");
            Console.ResetColor();

            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("[INFO] Launching Watch Dogs 2 via Steam...");
            Console.ResetColor();

            Thread.Sleep(2000);

            steam.LaunchGame();

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("[OK] Game launched! Close this window or press any key.");
            Console.ResetColor();
            Console.ReadKey();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"[FATAL] {ex.Message}");
            Console.WriteLine(ex.StackTrace);
            Console.ResetColor();
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
