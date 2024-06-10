Write-Error "This script is not meant to be executed directly. It is a helper script for other scripts."
exit 1

New-AzDeployment `
  -TemplateFile '..\alz\generic\main.bicep' `
  -TemplateParameterFile '.\generic-spokes\example-dev.bicepparam' `
  -Location 'germanywestcentral' `
  -Verbose `
  -Confirm

New-AzDeployment `
  -TemplateFile '..\alz\webapp-sql\main.bicep' `
  -TemplateParameterFile '.\webapp-sql-spokes\appx-prod.bicepparam' `
  -Location 'germanywestcentral' `
  -Verbose `
  -Confirm