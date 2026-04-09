param(
  [string]$Proxy = "http://127.0.0.1:7890"
)

$targets = @(
  @{ Name = "OpenAI API"; Url = "https://api.openai.com" },
  @{ Name = "ChatGPT"; Url = "https://chatgpt.com" }
)

Write-Host "Proxy env:" -ForegroundColor Cyan
[pscustomobject]@{
  HTTP_PROXY = $env:HTTP_PROXY
  HTTPS_PROXY = $env:HTTPS_PROXY
  ALL_PROXY = $env:ALL_PROXY
  NO_PROXY = $env:NO_PROXY
} | Format-Table -AutoSize

Write-Host ""
Write-Host "Clash ports:" -ForegroundColor Cyan
Get-NetTCPConnection -State Listen |
  Where-Object { $_.LocalPort -in 7890, 7891, 7892 } |
  Select-Object LocalAddress, LocalPort, OwningProcess, State |
  Sort-Object LocalPort |
  Format-Table -AutoSize

Write-Host ""
Write-Host "HTTP probes:" -ForegroundColor Cyan
foreach ($target in $targets) {
  $savedProxy = @{
    HTTP_PROXY = $env:HTTP_PROXY
    HTTPS_PROXY = $env:HTTPS_PROXY
    ALL_PROXY = $env:ALL_PROXY
    NO_PROXY = $env:NO_PROXY
  }

  Write-Host ("`n[{0}] direct" -f $target.Name) -ForegroundColor Yellow
  Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:NO_PROXY -ErrorAction SilentlyContinue
  & curl.exe -I --max-time 10 $target.Url

  $env:HTTP_PROXY = $savedProxy.HTTP_PROXY
  $env:HTTPS_PROXY = $savedProxy.HTTPS_PROXY
  $env:ALL_PROXY = $savedProxy.ALL_PROXY
  $env:NO_PROXY = $savedProxy.NO_PROXY

  Write-Host ("[{0}] via proxy {1}" -f $target.Name, $Proxy) -ForegroundColor Green
  & curl.exe -I --max-time 10 --proxy $Proxy $target.Url
}

Write-Host ""
Write-Host "Recent Clash warnings:" -ForegroundColor Cyan
$clashLog = "C:\Users\lfj16\AppData\Roaming\mihomo-party\logs\core-2026-04-09.log"
if (Test-Path $clashLog) {
  Get-Content -Tail 30 $clashLog
}
