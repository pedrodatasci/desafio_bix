$projectRoot = Resolve-Path "$PSScriptRoot\.."
$packagePath = "$PSScriptRoot\build_silver"
$finalZipPath = "$projectRoot\build\lambda_package_silver.zip"

# Limpar build temporário
if (Test-Path $packagePath) {
    Remove-Item -Recurse -Force $packagePath
}
New-Item -ItemType Directory -Force -Path $packagePath | Out-Null

# Criar pasta build final se necessário
$finalBuildDir = "$projectRoot\build"
if (!(Test-Path $finalBuildDir)) {
    New-Item -ItemType Directory -Force -Path $finalBuildDir | Out-Null
}

# Copiar handler
Copy-Item "$PSScriptRoot\lambda_handler.py" -Destination $packagePath -Force

# Compactar
Compress-Archive -Path "$packagePath\*" -DestinationPath $finalZipPath -Force

# Limpar temporário
Remove-Item -Recurse -Force $packagePath

Write-Host "Lambda Silver empacotada com sucesso em $finalZipPath"
