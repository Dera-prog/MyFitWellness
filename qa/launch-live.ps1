param(
  [string]$Url = "https://myfitwellness.vercel.app",
  [string]$Profile = "$env:TEMP\mfw-live",
  [int]$Port = 9758
)
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) { $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }
$cmdline = "`"$edge`" --user-data-dir=`"$Profile`" --no-first-run --no-default-browser-check --app=$Url --window-size=588,963 --window-position=1300,80 --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --disable-background-timer-throttling --disable-features=CalculateNativeWinOcclusion --remote-debugging-port=$Port"
$res = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmdline }
"PID=$($res.ProcessId) RETURN=$($res.ReturnValue)"
