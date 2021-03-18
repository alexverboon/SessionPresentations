$TenantId = ''
$loggingClientID = ''
$loggingSecret = ''
$logAnalyticsWorkspace = ''
$customLogName = "CountryCodes_CL"

# Get Access Token for Log Analytics to allow KQL Queries to get last ingested events in Custom Logs
$loginURL = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$resource = "https://api.loganalytics.io"
$authbody = @{grant_type = "client_credentials"; resource = $resource; client_id = $loggingClientID; client_secret = $loggingSecret }
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL -Body $authbody
$headerParams = @{'Authorization' = "$($oauth.token_type) $($oauth.access_token)" }
$logAnalyticsBaseURI = "https://api.loganalytics.io/v1/workspaces"

$result = invoke-RestMethod -method Get -uri "$($logAnalyticsBaseURI)/$($logAnalyticsWorkspace)/query?query=$($customLogName)" -Headers $headerParams

# Format Result to PSObject
$headerRow = $null
$headerRow = $result.tables.columns | Select-Object name
$columnsCount = $headerRow.Count
$logData = @()
foreach ($row in $result.tables.rows) {
    $data = new-object PSObject
    for ($i = 0; $i -lt $columnsCount; $i++) {
        $data | add-member -membertype NoteProperty -name $headerRow[$i].name -value $row[$i]
    }
    $logData += $data
    $data = $null
}
$logData