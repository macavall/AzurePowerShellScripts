# Authenticate and get an access token
$accessToken = (az account get-access-token --query accessToken --output tsv)

$resourceGroupName = ""
$functionAppName = ""
$apiVersion = "2024-04-01"

# Get the Function App resource
$functionApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionAppName

# Retrieve the Resource ID
$resourceId = $functionApp.Id

# Construct the URL
$managementUrl = "https://management.azure.com" + $resourceId + "?api-version=$apiVersion"

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