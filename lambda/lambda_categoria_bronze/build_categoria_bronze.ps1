$projectRoot = Resolve-Path "$PSScriptRoot\.."
$packagePath = "$PSScriptRoot\build_categoria_bronze"
$finalZipPath = "$projectRoot\build\lambda_package_categoria_bronze.zip"

if (Test-Path $packagePath) {
    Remove-Item -Recurse -Force $packagePath
}
New-Item -ItemType Directory -Path $packagePath | Out-Null

$finalBuildDir = "$projectRoot\build"
if (!(Test-Path $finalBuildDir)) {
    New-Item -ItemType Directory -Force -Path $finalBuildDir | Out-Null
}

Copy-Item "$PSScriptRoot\lambda_handler.py" -Destination $packagePath -Force
Compress-Archive -Path "$packagePath\*" -DestinationPath $finalZipPath -Force
Remove-Item -Recurse -Force $packagePath

Write-Host "Lambda categoria bronze empacotada em $finalZipPath"
