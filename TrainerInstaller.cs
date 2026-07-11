using System;
using System.IO;
using System.Reflection;

namespace WD2Launcher;

class TrainerInstaller
{
    private readonly string _trainerSourcePath;

    public TrainerInstaller()
    {
        string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? ".";
        _trainerSourcePath = Path.Combine(assemblyDir, "Tools", "trainer");
    }

    public void InstallTrainer(string gamePath)
    {
        string targetDir = Path.Combine(gamePath, "bin", "ScriptHook", "data", "scripts", "trainer");

        if (!Directory.Exists(_trainerSourcePath))
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"[WARN] Trainer source not found: {_trainerSourcePath}");
            Console.WriteLine("[INFO] Skipping trainer installation - place Tools/trainer folder next to exe");
            Console.ResetColor();
            return;
        }

        Directory.CreateDirectory(targetDir);

        CopyDirectory(_trainerSourcePath, targetDir);

        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine($"[OK] Trainer copied to: {targetDir}");
        Console.ResetColor();
    }

    private void CopyDirectory(string source, string destination)
    {
        Directory.CreateDirectory(destination);

        foreach (string file in Directory.GetFiles(source))
        {
            string destFile = Path.Combine(destination, Path.GetFileName(file));
            File.Copy(file, destFile, true);
        }

        foreach (string dir in Directory.GetDirectories(source))
        {
            string destDir = Path.Combine(destination, Path.GetFileName(dir));
            CopyDirectory(dir, destDir);
        }
    }
}
