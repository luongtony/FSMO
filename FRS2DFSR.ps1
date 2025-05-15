# Step 1: Check Current State
Write-Host "`nChecking current SYSVOL migration state..." -ForegroundColor Cyan
dfsrmig /getglobalstate
dfsrmig /getmigrationstate

# Step 2: Set to 'Prepared' state
Write-Host "`nStage 1: PREPARED - Migrating to Prepared state..." -ForegroundColor Yellow
dfsrmig /setglobalstate 1

do {
    Start-Sleep -Seconds 60
    $state = (dfsrmig /getmigrationstate) -join "`n"
    Write-Host $state
} until ($state -like "*The migration has reached a consistent state on all Domain Controllers.*")

# Step 3: Set to 'Redirected' state
Write-Host "`nStage 2: REDIRECTED - Migrating to Redirected state..." -ForegroundColor Yellow
dfsrmig /setglobalstate 2

do {
    Start-Sleep -Seconds 60
    $state = (dfsrmig /getmigrationstate) -join "`n"
    Write-Host $state
} until ($state -like "*The migration has reached a consistent state on all Domain Controllers.*")

# Step 4: Set to 'Eliminated' state (removes FRS)
Write-Host "`nStage 3: ELIMINATED - Migrating to Eliminated state..." -ForegroundColor Yellow
dfsrmig /setglobalstate 3

do {
    Start-Sleep -Seconds 60
    $state = (dfsrmig /getmigrationstate) -join "`n"
    Write-Host $state
} until ($state -like "*The migration has reached a consistent state on all Domain Controllers.*")

Write-Host "`n✅ SYSVOL replication has successfully migrated from FRS to DFS-R." -ForegroundColor Green
