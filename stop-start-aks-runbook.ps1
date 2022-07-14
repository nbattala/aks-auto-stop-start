<#
.SYNOPSIS 
    This sample automation runbook is designed to manage the start and stop of aks clusterson a given schedule.

.DESCRIPTION
    This sample automation runbook is designed to manage the start and stop of aks clusters on a given schedule. You need to provide some parameters. This runbook requires also 
    the following modules to be imported in the modules section of the Automation Account in the Azure Portal:

    - Az.Account

.PARAMETERS
    aksclustername: This REQUIRED string parameter represents the cluster name to perform the required operation.

    aksresourcegroupname: This REQUIRED string parameter represents the resource groupt that containt the AKS cluster in subject

    operation: This REQUIRED string parameter represents the operations to be performed on the AKS cluster. It can only contain 2 values: Start or Stop

.EXAMPLE
    .\stop-start-aks-runbook.ps1

.NOTES
    AUTHOR:  Naveen Battala
    LASTEDIT: July 12th, 2022
    INSPIRED BY: https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/azure-kubernetes-services-start-amp-stop-your-aks-cluster-on/ba-p/2589995
    CHANGELOG:

        VERSION:  1.0
        - Initial version
#>

Param(
    [Parameter(Mandatory=$True,
                ValueFromPipelineByPropertyName=$false,
                HelpMessage='Specify the AKS cluster name.',
                Position=1)]
                [String]
                $aksclustername,
                
    [Parameter(Mandatory=$True,
                ValueFromPipelineByPropertyName=$false,
                HelpMessage='Specify the name of the resoure group containing the AKS cluster.',
                Position=2)]
                [String]
                $aksresourcegroupname,

    [Parameter(Mandatory=$True,
                ValueFromPipelineByPropertyName=$false,
                HelpMessage='Specify the operation to be performed on the AKS cluster name (Start/Stop).',
                Position=2)]
                [ValidateSet('Start','Stop')]
                [String]
                $operation
    )

#Inizialiting connection to the AutomationAccount
try
{
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    # Connect to Azure with system-assigned managed identity
    $AzureContext = (Connect-AzAccount -Identity).context

    # set and store context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
    
    #Setting REST API Authentication token
    $resource= "?resource=https://management.azure.com/" 
    $url = $env:IDENTITY_ENDPOINT + $resource 
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
    $Headers.Add("X-IDENTITY-HEADER", $env:IDENTITY_HEADER) 
    $Headers.Add("Metadata", "True") 
    $accessToken = Invoke-RestMethod -Uri $url -Method 'GET' -Headers $Headers
	$accToken = $accessToken.access_token
    $headers_Auth = @{'Authorization'="Bearer $accToken"}

    #Setting GET RestAPI Uri
    $getRestUri = "https://management.azure.com/subscriptions/$($AzureContext.Subscription)/resourceGroups/$aksresourcegroupname/providers/Microsoft.ContainerService/managedClusters/$($aksclustername)?api-version=2022-04-01"

    #Setting POST RestAPI Uri
    $postRestUri = "https://management.azure.com/subscriptions/$($AzureContext.Subscription)/resourceGroups/$aksresourcegroupname/providers/Microsoft.ContainerService/managedClusters/$aksclustername/$($operation.ToLower())?api-version=2022-04-01"

    try
    {
        #Getting the cluster state
        Write-Output "Invoking RestAPI method to get the cluster state. The request Uri is ==$getRestUri==."
        $getResponse = Invoke-WebRequest -UseBasicParsing -Method Get -Headers $headers_Auth -Uri $getRestUri
        $getResponseJson = $getResponse.Content | ConvertFrom-Json
		Write-Output $getResponseJson
        $clusterState = $getResponseJson.properties.powerState.code
        Write-Output "AKS Cluster ==$aksclustername== is currently ==$clusterState=="

        #Checking if the requested operation can be performed based on the current state
        Switch ($operation)
        {
            "Start"
            {
                If ($clusterState -eq "Running")
                {
                    Write-Output "The AKS Cluster ==$aksclustername== is already ==$clusterState== and cannot be started again."
                }
                else
                {
                    Write-Output "Invoking RestAPI method to perform the requested ==$operation== operation on AKS Cluster ==$aksclustername==. The request Uri is ==$postRestUri==."
                    $postResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Headers $headers_Auth -Uri $postRestUri
                    $StatusCode = $postResponse.StatusCode
                }
            }
            
            "Stop"
            {
                If ($clusterState -eq "Stopped")
                {
                    Write-Output "The AKS Cluster ==$aksclustername== is already ==$clusterState== and cannot be stopped again."
                }
                else
                {
                    Write-Output "Invoking RestAPI method to perform the requested ==$operation== operation on AKS Cluster ==$aksclustername==. The request Uri is ==$postRestUri==."
                    $postResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Headers $headers_Auth -Uri $postRestUri
                    $StatusCode = $postResponse.StatusCode
                }
            }

            Default
            {
                Write-Output "Unexpected scenario. The requested operation ==$operation== was not matching any of the managed cases."
            }
        }
    }
    catch
    {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        $exMsg = $_.Exception.Message
        Write-Output "Response Code == $StatusCode"
        Write-Output "Exception Message == $exMsg"
    }

    if (($StatusCode -ge 200) -and ($StatusCode -lt 300))
    {
        Write-Output "The ==$operation== operation on AKS Cluster ==$aksclustername== has been completed succesfully."
    }
    else
    {
        Write-Output "The ==$operation== operation on AKS Cluster ==$aksclustername== was not completed succesfully."
    }

}
catch
{
    if (!$AzureContext)
    {
        $ErrorMessage = "Connection to azure using system-assigned managed identity failed."
        throw $ErrorMessage
    }
    else
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}