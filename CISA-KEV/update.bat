@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "URL=https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
set "OUTPUT=%~dp0known_exploited_vulnerabilities.json"
set MAX_RETRIES=10
set RETRY_DELAY=5

for /l %%i in (1,1,%MAX_RETRIES%) do (
    echo [%%i/%MAX_RETRIES%] 下载中...
    powershell -NoProfile -Command "try { (New-Object System.Net.WebClient).DownloadFile('%URL%', '%OUTPUT%'); exit 0 } catch { Write-Host '失败: ' $_.Exception.Message; exit 1 }"
    if !ERRORLEVEL! equ 0 (
        echo 完成 - 已保存到 %OUTPUT%
        exit /b 0
    )
    if %%i lss %MAX_RETRIES% (
        echo %RETRY_DELAY% 秒后重试...
        timeout /t %RETRY_DELAY% /nobreak >nul
    )
)

echo 重试 %MAX_RETRIES% 次后仍失败。 
exit /b 1
