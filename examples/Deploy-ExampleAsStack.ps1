param (
    [Parameter(Mandatory=$true)]
    [string]
    $Example,
    $DeploymentLocation = "germanywestcentral"
)

Write-Output "Example: $Example"

$templatePath = ".\$Example\main.bicep"

if (-not (Test-Path $templatePath)) {
    Write-Error "Template not found: $templatePath"
    exit 1
}

#New-AzDeployment -TemplateFile $templatePath -Location $DeploymentLocation -Verbose -Confirm
New-AzSubscriptionDeploymentStack `
  -Name "example-$Example" `
  -TemplateFile $templatePath `
  -Location $DeploymentLocation `
  -ActionOnUnmanage DeleteAll `
  -DenySettingsMode DenyDelete `
  -Verbose `
  -Confirm