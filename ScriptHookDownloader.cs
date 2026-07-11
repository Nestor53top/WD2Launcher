using System;
using System.IO;
using System.IO.Compression;
using System.Net.Http;

namespace WD2Launcher;

class ScriptHookDownloader
{
    private const string SCRIPTHOOK_URL = "https://github.com/Nomad-Group/WD2-ScriptHook/releases/latest/download/ScriptHook.zip";

    private static readonly HttpClient _httpClient = new();

    public static bool Download(string installPath)
    {
        try
        {
            Console.WriteLine("[INFO] Downloading ScriptHook...");

            string tempZip = Path.Combine(Path.GetTempPath(), "wd2_scripthook.zip");

            var response = _httpClient.GetAsync(SCRIPTHOOK_URL).Result;
            if (!response.IsSuccessStatusCode)
            {
                Console.WriteLine($"[ERROR] Download failed: {response.StatusCode}");
                return false;
            }

            byte[] data = response.Content.ReadAsByteArrayAsync().Result;
            File.WriteAllBytes(tempZip, data);

            Console.WriteLine("[INFO] Extracting...");

            string tempExtract = Path.Combine(Path.GetTempPath(), "wd2_scripthook_extract");
            if (Directory.Exists(tempExtract))
                Directory.Delete(tempExtract, true);

            ZipFile.ExtractToDirectory(tempZip, tempExtract);

            string? extractedDir = Directory.GetDirectories(tempExtract).FirstOrDefault();
            if (extractedDir == null)
            {
                extractedDir = tempExtract;
            }

            Directory.CreateDirectory(installPath);
            CopyDirectory(extractedDir, installPath);

            File.Delete(tempZip);
            Directory.Delete(tempExtract, true);

            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ERROR] Download failed: {ex.Message}");
            return false;
        }
    }

    private static void CopyDirectory(string source, string destination)
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
