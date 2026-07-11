using System;
using System.IO;
using System.Text.Json;

namespace WD2Launcher;

class Config
{
    public string? CustomGamePath { get; set; }
    public bool AutoLaunch { get; set; } = true;
    public bool InstallTrainer { get; set; } = true;

    private static readonly string ConfigPath = Path.Combine(
        AppDomain.CurrentDomain.BaseDirectory,
        "config.json"
    );

    public static Config Load()
    {
        if (!File.Exists(ConfigPath))
        {
            var config = new Config();
            config.Save();
            return config;
        }

        try
        {
            string json = File.ReadAllText(ConfigPath);
            return JsonSerializer.Deserialize<Config>(json) ?? new Config();
        }
        catch
        {
            return new Config();
        }
    }

    public void Save()
    {
        try
        {
            var options = new JsonSerializerOptions { WriteIndented = true };
            string json = JsonSerializer.Serialize(this, options);
            File.WriteAllText(ConfigPath, json);
        }
        catch { }
    }
}
