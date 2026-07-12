# 构建已签名 HAP（entry-default-signed.hap），可直接 hdc install 装机。
# 依赖 build-profile.json5 里已配置 signingConfigs。该配置由 DevEco
# 「签名配置 → 自动生成签名」写入。若签名段为空，请先在 DevEco 里生成签名再跑本脚本。

$ErrorActionPreference = "Stop"

# 配置
$ProjectDir  = $PSScriptRoot
$DevEcoTools = "D:\DevDisk\DevTools\DevEco"
$Hvigorw     = "$DevEcoTools\tools\hvigor\bin\hvigorw.bat"
$BuildProfile = "$ProjectDir\build-profile.json5"
$HapOutput   = "$ProjectDir\entry\build\default\outputs\default\entry-default-signed.hap"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "纤语输入法 构建已签名 HAP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 0. 预检查：signingConfigs 是否已配置
Write-Host "[1/3] 检查签名配置..." -ForegroundColor Yellow
if (!(Test-Path $BuildProfile)) {
    Write-Host "  ✗ 未找到 build-profile.json5：$BuildProfile" -ForegroundColor Red
    exit 1
}
$profileText = Get-Content $BuildProfile -Raw
# 空数组 "signingConfigs": [ ] 视为未配置
if ($profileText -match '"signingConfigs"\s*:\s*\[\s*\]') {
    Write-Host "  ✗ signingConfigs 为空，无法产出签名 HAP" -ForegroundColor Red
    Write-Host ""
    Write-Host "  请先在 DevEco Studio 生成签名：" -ForegroundColor Yellow
    Write-Host "    项目结构 → 签名配置 → 勾选“自动生成签名”（需登录华为账号）" -ForegroundColor Gray
    Write-Host "  生成后会写回 build-profile.json5，再重跑本脚本。" -ForegroundColor Gray
    exit 1
}
Write-Host "  ✓ signingConfigs 已配置" -ForegroundColor Green
Write-Host ""

# 环境变量（三个缺一不可）
#   DEVECO_SDK_HOME   : 不设 → Invalid value of 'DEVECO_SDK_HOME'
#   JAVA_HOME         : hvigor 依赖的 JDK
#   JAVA_TOOL_OPTIONS : 关掉 JDK 21 的 ZIP64 严格校验，否则 SignHap 阶段会误报
$env:DEVECO_SDK_HOME   = "$DevEcoTools\sdk"
$env:JAVA_HOME         = "$DevEcoTools\jbr"
$env:JAVA_TOOL_OPTIONS = "-Djdk.util.zip.disableZip64ExtraFieldValidation=true"

Write-Host "[2/3] 执行 hvigorw assembleHap..." -ForegroundColor Yellow
Write-Host "  项目: $ProjectDir" -ForegroundColor Gray
Write-Host ""

Push-Location $ProjectDir
try {
    & $Hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

Write-Host ""
if ($exitCode -ne 0) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "构建失败（退出码 $exitCode）" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit $exitCode
}

# 检查产物
Write-Host "[3/3] 检查产物..." -ForegroundColor Yellow
if (!(Test-Path $HapOutput)) {
    Write-Host "  ✗ 构建报成功但未找到签名产物：$HapOutput" -ForegroundColor Red
    Write-Host "  可能签名被跳过，请检查 build-profile.json5 的 signingConfigs。" -ForegroundColor Yellow
    exit 1
}

$hap = Get-Item $HapOutput
$sizeKB = [math]::Round($hap.Length / 1KB, 1)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建成功！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  产物: $HapOutput" -ForegroundColor Gray
Write-Host "  大小: $sizeKB KB" -ForegroundColor Gray
Write-Host "  时间: $($hap.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host ""
Write-Host "已签名 HAP 可直接装机：" -ForegroundColor Yellow
Write-Host "  方式1、hdc -t <target> install `"$HapOutput`"" -ForegroundColor Gray
Write-Host "  方式2、直接运行 deploy.ps1 一键部署。" -ForegroundColor Gray
