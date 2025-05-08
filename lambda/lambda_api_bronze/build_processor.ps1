$projectRoot = Resolve-Path "$PSScriptRoot\.."
$packagePath = "$PSScriptRoot\build_processor"
$finalZipPath = "$projectRoot\build\lambda_api_bronze.zip"

# Remover build anterior
if (Test-Path $packagePath) {
    Remove-Item -Recurse -Force $packagePath
}
New-Item -ItemType Directory -Force -Path $packagePath | Out-Null

# Criar pasta build final se necessário
$finalBuildDir = "$projectRoot\build"
if (!(Test-Path $finalBuildDir)) {
    New-Item -ItemType Directory -Force -Path $finalBuildDir | Out-Null
}

# Copiar somente o lambda_handler.py
Copy-Item "$PSScriptRoot\lambda_handler.py" -Destination $packagePath -Force

# Compactar o conteúdo
Compress-Archive -Path "$packagePath\*" -DestinationPath $finalZipPath -Force

# Remover pasta temporária
Remove-Item -Recurse -Force $packagePath

Write-Host "Lambda Processor empacotada com sucesso em $finalZipPath"
