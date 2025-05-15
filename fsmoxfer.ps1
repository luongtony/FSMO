# Prompt for target DC
$targetDC = Read-Host "Enter the name of the DC to hold FSMO roles"

# Import AD module
Import-Module ActiveDirectory

# FSMO Roles List
$roles = @(
    "SchemaMaster",
    "DomainNamingMaster",
    "PDCEmulator",
    "RIDMaster",
    "InfrastructureMaster"
)

# Attempt Transfer
Write-Host "`nAttempting FSMO role transfer to $targetDC..." -ForegroundColor Cyan
foreach ($role in $roles) {
    try {
        Move-ADDirectoryServerOperationMasterRole -Identity $targetDC -OperationMasterRole $role -Confirm:$false -ErrorAction Stop
        Write-Host "✔ Successfully transferred $role" -ForegroundColor Green
    }
    catch {
        Write-Warning "❌ Transfer failed for $role: $($_.Exception.Message)"
        $failedRoles += $role
    }
}

# Seize failed roles
if ($failedRoles.Count -gt 0) {
    Write-Host "`nAttempting to seize failed FSMO roles..." -ForegroundColor Yellow
    foreach ($role in $failedRoles) {
        try {
            Move-ADDirectoryServerOperationMasterRole -Identity $targetDC -OperationMasterRole $role -Force -Confirm:$false
            Write-Host "⚠ Seized $role" -ForegroundColor DarkYellow
        }
        catch {
            Write-Host "❌ Could not seize $role: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "`nAll roles transferred successfully. No need to seize." -ForegroundColor Green
}
