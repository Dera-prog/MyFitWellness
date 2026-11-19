Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class WL {
  public struct R { public int L, T, Rt, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
}
'@
Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | ForEach-Object {
  $r = New-Object WL+R
  [void][WL]::GetWindowRect($_.MainWindowHandle, [ref]$r)
  "PID=$($_.Id) hwnd=$($_.MainWindowHandle) visible=$([WL]::IsWindowVisible($_.MainWindowHandle)) title=$($_.MainWindowTitle) rect=$($r.L),$($r.T),$($r.Rt),$($r.B)"
}
