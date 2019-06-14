Trace-VstsEnteringInvocation $MyInvocation

$VariableGroupId = Get-VstsInput -Name VariableGroupId -Require
$VariableName = Get-VstsInput -Name VariableName -Require
$NewValue = Get-VstsInput -Name NewValue -Require

Write-Output "Variable name: $($VariableName)"
Write-Output "New value: $($NewValue)"

$variableGroupUri = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/distributedtask/variablegroups/$($VariableGroupId)?api-version=5.0-preview.1"
$authHeader = @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}

Write-Host "Variable group URI: $($variableGroupUri)"
$definition = Invoke-RestMethod -Uri $variableGroupUri -Headers $authHeader
Write-Host "Variable group = $($definition | ConvertTo-Json -Depth 100)"

if ($definition -and $definition.variables.$VariableName) {
    Write-Host "Old value: $($definition.variables.$VariableName.Value)"
    
    $definition.variables.$VariableName.Value = "$($NewValue)"

    $definitionJson = $definition | ConvertTo-Json -Depth 100 -Compress

    Write-Verbose "Updating variable group: $($variableGroupUri)"
    Invoke-RestMethod -Method Put -Uri $variableGroupUri -Headers $authHeader -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($definitionJson)) | Out-Null
}
else {
    Write-Error "The variable group or variable name can not be found..."
}