Trace-VstsEnteringInvocation $MyInvocation

$VariableGroupId = Get-VstsInput -Name VariableGroupId -Require
$VariableName = Get-VstsInput -Name VariableName -Require
$NewValue = Get-VstsInput -Name NewValue -Require

Write-Output "Variable name: $($VariableName)"

$variableGroupUri = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/distributedtask/variablegroups/$($VariableGroupId)?api-version=4.1-preview.1"
$authHeader = @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"}

Write-Verbose "Variable group URI: $($variableGroupUri)"
$definition = Invoke-RestMethod -Uri $variableGroupUri -Headers $authHeader
Write-Verbose "Variable group = $($definition | ConvertTo-Json -Depth 100)"

if ($definition -and $definition.variables.$VariableName) {
    Write-Output "Old value: $($definition.variables.$VariableName.Value)"
    Write-Output "New value: $($NewValue)"

    $definition.variables.$VariableName.Value = "$($NewValue)"

    $definitionJson = $definition | ConvertTo-Json -Depth 100 -Compress

    Write-Verbose "Updating variable group: $($variableGroupUri)"
    Invoke-RestMethod -Method Put -Uri $variableGroupUri -Headers $authHeader -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($definitionJson)) | Out-Null
}
else {
    Write-Error "The variable group or variable name can not be found..."
}