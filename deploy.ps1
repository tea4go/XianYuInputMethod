$ErrorActionPreference = "Stop"

# 配置
$ProjectDir = $PSScriptRoot
$DevEcoTools = "D:\DevDisk\DevTools\DevEco"
$HapOutput = "$ProjectDir\entry\build\default\outputs\default\entry-default-signed.hap"
$DevEcoCLI = "$DevEcoTools\devecostudio.exe"

# 检查参数
$SkipBuild = $args -contains "--skip-build"
$ForceBuild = $args -contains "--build"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "纤语输入法 智能部署" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 构建检查
if (-not $SkipBuild) {
    Write-Host "[1/4] 检查构建状态..." -ForegroundColor Yellow

    # 检查 HAP 文件是否存在
    $needBuild = $false
    if (!(Test-Path $HapOutput)) {
        Write-Host "  ✗ HAP 文件不存在" -ForegroundColor Red
        $needBuild = $true
    } else {
        # 检查文件时间
        $hapTime = (Get-Item $HapOutput).LastWriteTime
        $now = Get-Date
        $timeDiff = ($now - $hapTime).TotalMinutes

        Write-Host "  HAP 文件时间: $($hapTime.ToString('MM-dd HH:mm'))" -ForegroundColor Gray

        if ($timeDiff -gt 60) {
            Write-Host "  ⚠ HAP 文件超过 1 小时，建议重新编译" -ForegroundColor Yellow
            $needBuild = $true
        } else {
            Write-Host "  ✓ HAP 文件较新" -ForegroundColor Green
        }
    }

    if ($needBuild -or $ForceBuild) {
        Write-Host ""
        Write-Host "[2/4] 尝试构建 HAP..." -ForegroundColor Yellow

        # 设置环境变量
        $env:DEVECO_SDK_HOME = "$DevEcoTools\sdk"
        $env:JAVA_HOME = "$DevEcoTools\jbr"
        $env:JAVA_TOOL_OPTIONS = "-Djdk.util.zip.disableZip64ExtraFieldValidation=true"

        Push-Location $ProjectDir
        try {
            # 尝试使用 DevEco CLI
            if (Test-Path $DevEcoCLI) {
                Write-Host "  使用 DevEco CLI 编译..." -ForegroundColor Gray
                & $DevEcoCLI build --project $ProjectDir --product default --module entry 2>$null
            } else {
                Write-Host "  使用 hvigorw 编译..." -ForegroundColor Gray
                & "$DevEcoTools\tools\hvigor\bin\hvigorw.bat" --mode module -p product=default -p module=entry@default assembleHap --no-daemon 2>$null
            }

            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Red
                Write-Host "命令行编译失败（预期行为）" -ForegroundColor Red
                Write-Host "========================================" -ForegroundColor Red
                Write-Host ""
                Write-Host "请在 DevEco Studio 中编译：" -ForegroundColor Yellow
                Write-Host "  1. 打开项目：$ProjectDir" -ForegroundColor Gray
                Write-Host "  2. 按 Shift+F10 运行并部署" -ForegroundColor Gray
                Write-Host "  3. 或按 Ctrl+F9 编译后运行此脚本" -ForegroundColor Gray
                Write-Host ""
                Write-Host "编译完成后，按回车继续安装..." -ForegroundColor Cyan
                Read-Host
                $SkipBuild = $true
            } else {
                Write-Host "  ✓ 编译成功" -ForegroundColor Green
            }
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  ✓ 跳过构建" -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "[1/4] 跳过构建（用户指定）" -ForegroundColor Gray
    Write-Host ""
}

# 2. 检查产物
if (!(Test-Path $HapOutput)) {
    Write-Host "✗ HAP 文件未找到：$HapOutput" -ForegroundColor Red
    Write-Host ""
    Write-Host "请在 DevEco Studio 中编译后再运行此脚本" -ForegroundColor Yellow
    exit 1
}

Write-Host "  HAP: $HapOutput" -ForegroundColor Gray
Write-Host ""

# 3. 枚举设备
Write-Host "[3/4] 枚举已连接设备..." -ForegroundColor Yellow

# 枚举所有已连接的 harmony 设备（过滤空行和 [Empty]）
$targets = & hdc list targets
$devices = @($targets | Where-Object { $_.Trim() -match '\S' -and $_ -notmatch '\[Empty\]' } | ForEach-Object { $_.Trim() })
if ($devices.Count -eq 0) {
    Write-Host "  ✗ 未检测到任何已连接的 harmony 设备" -ForegroundColor Red
    exit 1
}
Write-Host "  当前已连接设备（$($devices.Count) 台）：" -ForegroundColor Gray
foreach ($dev in $devices) {
    Write-Host "    - $dev" -ForegroundColor Green
}
Write-Host ""

# 4. 逐台安装并启动
Write-Host "[4/4] 安装并启动（全部设备）..." -ForegroundColor Yellow
$okCount = 0
foreach ($dev in $devices) {
    Write-Host "  ▶ $dev" -ForegroundColor Cyan
    # 安装
    & hdc -t $dev install $HapOutput 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ⚠ 标准安装失败，尝试替换安装..." -ForegroundColor Yellow
        & hdc -t $dev install -r $HapOutput 2>$null | Out-Null
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ✗ 安装失败，跳过此设备" -ForegroundColor Red
        continue
    }
    Write-Host "    ✓ 安装完成" -ForegroundColor Green
    # 启动设置页（输入法本体由系统按需拉起，此处拉起 App 的 EntryAbility 便于配置）
    & hdc -t $dev shell aa start -a EntryAbility -b com.lonwan.input.method 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✓ 应用已启动" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ 启动失败，请在该设备手动打开应用" -ForegroundColor Yellow
    }
    $okCount++
}
Write-Host ""
Write-Host "  部署结果：$okCount/$($devices.Count) 台成功" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "启用步骤：" -ForegroundColor Gray
Write-Host "1. 打开设备「设置 → 系统 → 输入法」" -ForegroundColor Gray
Write-Host "2. 启用「纤语输入法」并设为默认" -ForegroundColor Gray
Write-Host "3. 在任意输入框调出键盘验证" -ForegroundColor Gray
