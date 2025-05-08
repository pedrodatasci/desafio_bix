$projectRoot = Resolve-Path "$PSScriptRoot\.."
$finalZipPath = "$projectRoot\build\lambda_package_api.zip"

# Criar pasta build se necessário
$finalBuildDir = "$projectRoot\build"
if (!(Test-Path $finalBuildDir)) {
    New-Item -ItemType Directory -Force -Path $finalBuildDir | Out-Null
}

# Apagar pacote anterior se existir
Remove-Item -Force $finalZipPath -ErrorAction Ignore

# Compactar handler
Compress-Archive -Path "$PSScriptRoot\lambda_handler.py" -DestinationPath $finalZipPath -Force

Write-Host "Lambda API empacotada com sucesso em $finalZipPath"