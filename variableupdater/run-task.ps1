Trace-VstsEnteringInvocation $MyInvocation

$VariableName = Get-VstsInput -Name VariableName -Require
$NewValue = Get-VstsInput -Name NewValue -Require

Write-Output "Variable name: $($VariableName)"
Write-Output "New value: $($NewValue)"

$defUri = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/build/definitions/$($env:SYSTEM_DEFINITIONID)?api-version=5.0"
$authHeader = @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}

Write-Host "Build definition URL: $($defUri)"
$definition = Invoke-RestMethod -Uri $defUri -Headers $authHeader
Write-Host "Pipeline = $($definition | ConvertTo-Json -Depth 100)"

if ($definition.variables.$VariableName) {
    Write-Host "Old value: $($definition.variables.$VariableName.Value)"
    
    $definition.variables.$VariableName.Value = "$($NewValue)"

    $definitionJson = $definition | ConvertTo-Json -Depth 100 -Compress

    Write-Verbose "Updating build definition: $($defUri)"
    Invoke-RestMethod -Method Put -Uri $defUri -Headers $authHeader -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($definitionJson)) | Out-Null
}
else {
    Write-Error "The variable can not be found on the definition: $($VariableName)"
}