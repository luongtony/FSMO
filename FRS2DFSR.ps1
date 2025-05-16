function Wait-ForDFSState {
    param (
        [int]$targetState,
        [int]$timeoutSeconds = 600
    )

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    while ($true) {
        $output = dfsrmig /getmigrationstate
        $outputString = $output -join "`n"

        if ($outputString -match "The migration has reached a consistent state on all Domain Controllers") {
            Write-Host "✅ State $targetState reached on all DCs." -ForegroundColor Green
            break
        }

        if ($stopWatch.Elapsed.TotalSeconds -gt $timeoutSeconds) {
            Write-Host "❌ Timeout waiting for state $targetState to complete. Please check replication health." -ForegroundColor Red
            break
        }

        Write-Host "⏳ Waiting for state $targetState to complete..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}

# Stage 1 - Prepared
Write-Host "`n➡️  Stage 1: PREPARED" -ForegroundColor Cyan
dfsrmig /setglobalstate 1
Wait-ForDFSState -targetState 1

# Stage 2 - Redirected
Write-Host "`n➡️  Stage 2: REDIRECTED" -ForegroundColor Cyan
dfsrmig /setglobalstate 2
Wait-ForDFSState -targetState 2

# Stage 3 - Eliminated
Write-Host "`n➡️  Stage 3: ELIMINATED" -ForegroundColor Cyan
dfsrmig /setglobalstate 3
Wait-ForDFSState -targetState 3

Write-Host "`n🎉 SYSVOL successfully migrated to DFS-R!" -ForegroundColor Green
