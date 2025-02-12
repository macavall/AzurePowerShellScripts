# AzureFunctionControl.psm1

function Stop-AzFunctionApp {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $FunctionAppName
    )

    # Authenticate and get an access token
    $accessToken = (az account get-access-token --query accessToken --output tsv)
    $apiVersion = "2024-04-01"

    # Get the Function App resource
    $functionApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName
    $resourceId = $functionApp.Id

    # Construct the URL
    $managementUrl = "https://management.azure.com" + $resourceId + "?api-version=$apiVersion"

    # Stop the Function App
    $stopBody = @{
        properties = @{
            state = "Stopped"
            scmSiteAlsoStopped = $true
        }
    } | ConvertTo-Json -Depth 3

    Invoke-RestMethod -Uri $managementUrl -Method PATCH -Body $stopBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }
    Write-Host "Function App '$FunctionAppName' in Resource Group '$ResourceGroupName' has been stopped."
}

function Start-AzFunctionApp {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $FunctionAppName
    )

    # Authenticate and get an access token
    $accessToken = (az account get-access-token --query accessToken --output tsv)
    $apiVersion = "2024-04-01"

    # Get the Function App resource
    $functionApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName
    $resourceId = $functionApp.Id

    # Construct the URL
    $managementUrl = "https://management.azure.com" + $resourceId + "?api-version=$apiVersion"

    # Start the Function App
    $startBody = @{
        properties = @{
            state = "Running"
            scmSiteAlsoStopped = $false
        }
    } | ConvertTo-Json -Depth 3

    Invoke-RestMethod -Uri $managementUrl -Method PATCH -Body $startBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }
    Write-Host "Function App '$FunctionAppName' in Resource Group '$ResourceGroupName' has been started."
}

# Export module functions
Export-ModuleMember -Function Stop-AzFunctionApp, Start-AzFunctionApp
