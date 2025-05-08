$projectRoot = Resolve-Path "$PSScriptRoot\.."
$packagePath = "$PSScriptRoot\build_db"
$finalZipPath = "$projectRoot\build\lambda_package_db.zip"

# Remover build anterior (temporário)
if (Test-Path $packagePath) {
    Remove-Item -Recurse -Force $packagePath
}
New-Item -ItemType Directory -Force -Path $packagePath | Out-Null

# Criar pasta de destino final
$finalBuildDir = "$projectRoot\build"
if (!(Test-Path $finalBuildDir)) {
    New-Item -ItemType Directory -Force -Path $finalBuildDir | Out-Null
}

# Copiar apenas o handler
Copy-Item "$PSScriptRoot\lambda_handler.py" -Destination $packagePath -Force

# Compactar apenas o código
Compress-Archive -Path "$packagePath\*" -DestinationPath $finalZipPath -Force

# Remover a pasta temporária
Remove-Item -Recurse -Force $packagePath

Write-Host "Lambda DB empacotada com sucesso em $finalZipPath"
