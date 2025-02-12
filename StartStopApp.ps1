# Authenticate and get an access token
$accessToken = (az account get-access-token --query accessToken --output tsv)

$resourceGroupName = "testfunc12356rg"
$functionAppName = "testfunc12356fa"
$apiVersion = "2024-04-01"

# Get the Function App resource
$functionApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionAppName

# Retrieve the Resource ID
$resourceId = $functionApp.Id

# Construct the URL
$managementUrl = "https://management.azure.com" + $resourceId + "?api-version=$apiVersion"

# Define API URLs
# $functionAppUrl = "https://management.azure.com/subscriptions/2fd64258-83d0-456d-8559-4461579559d5/resourceGroups/testfunc12356rg/providers/Microsoft.Web/sites/testfunc12356fa?api-version=2024-04-01"

# Stop the Function App (State = "Stopped")
$stopBody = @{
    properties = @{
        state = "Stopped"
        scmSiteAlsoStopped = "True"
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri $managementUrl -Method PATCH -Body $stopBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }

sleep -Seconds 30

# Stop the Function App (State = "Stopped")
$stopBody = @{
    properties = @{
        state = "Running"
        scmSiteAlsoStopped = "False"
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri $managementUrl -Method PATCH -Body $stopBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }

Write-Host "Function App Stopped."

# Set ScmSiteAlsoStopped = true
$scmSiteConfigUrl = "testfunc1256fa2/config/web?api-version=2024-04-01"

# Retrieve current site config
$currentConfig = Invoke-RestMethod -Uri $scmSiteConfigUrl -Method GET -Headers @{ Authorization = "Bearer $accessToken" }

# Modify ScmSiteAlsoStopped
$currentConfig.properties.scmSiteAlsoStopped = $true

# Convert to JSON and PATCH request
$updatedConfig = $currentConfig | ConvertTo-Json -Depth 3
Invoke-RestMethod -Uri $scmSiteConfigUrl -Method PATCH -Body $updatedConfig -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }

Write-Host "scmSiteAlsoStopped set to true."
