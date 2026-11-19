param(
  [string]$Out = "qa\win.png",
  [int]$ProcId = 0
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PW {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

[void][PW]::SetProcessDPIAware()

if ($ProcId -gt 0) {
  $proc = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
} else {
  $proc = Get-Process msedge -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -eq 'MyFitWellness' } |
    Select-Object -First 1
}
if (-not $proc) { Write-Output "NO_WINDOW"; exit 1 }

$rect = New-Object PW+RECT
[void][PW]::GetWindowRect($proc.MainWindowHandle, [ref]$rect)
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top

Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$hdc = $g.GetHdc()
$ok = [PW]::PrintWindow($proc.MainWindowHandle, $hdc, 2)
$g.ReleaseHdc($hdc)
$g.Dispose()
$dir = [System.IO.Path]::GetFullPath((Split-Path -Parent $Out))
$bmp.Save("$dir\" + (Split-Path -Leaf $Out), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "PRINT=$ok ${w}x${h} title=$($proc.MainWindowTitle)"
