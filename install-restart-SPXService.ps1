# Install scheduled task to restart the SPXService on weekdays at 13:45
# Task will be placed under folder \Sisgarbe in Task Scheduler

# Configuration
$taskFolder = '\Sisgarbe\'
$taskName = 'Reiniciar Shadow Protect 13h45'
$fullTaskName = "$taskFolder$taskName"
$time = '13:45'
$days = 'MON,TUE,WED,THU,FRI'
$serviceName = 'SPXService'

function Ensure-RunningAsAdmin {
    $current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $current.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Error 'Este script precisa ser executado como Administrador. Reexecute numa sessão elevada.'
        exit 1
    }
}

Ensure-RunningAsAdmin

# Check service existence (not strictly required to create the task, but helpful)
$svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if (-not $svc) {
    Write-Warning "Serviço '$serviceName' não encontrado no sistema. A tarefa ainda pode ser criada, mas a reinicialização falhará até o serviço existir."
}

Write-Host "Criando/atualizando tarefa agendada: $fullTaskName" -ForegroundColor Cyan

# Build the action using PowerShell cmdlets
$actionCommand = "powershell.exe"
$actionArgs = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"Restart-Service -Name '$serviceName' -Force`""
$action = New-ScheduledTaskAction -Execute $actionCommand -Argument $actionArgs

# Create trigger for weekdays at specified time
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At $time

# Create principal to run as SYSTEM with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Create settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Check if task already exists and unregister it
$existingTask = Get-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Tarefa existente encontrada. Atualizando..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -Confirm:$false
}

# Register the task
try {
    Register-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -ErrorAction Stop | Out-Null
    Write-Host "Tarefa criada/atualizada com sucesso em $taskFolder" -ForegroundColor Green
    Write-Host "Nome da tarefa: $taskName" -ForegroundColor Green
    Write-Host "Horário: $time (Segunda a Sexta)" -ForegroundColor Green
} catch {
    Write-Error "Falha ao criar a tarefa: $_"
    Write-Host "Prima qualquer tecla para sair..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "`nPrima qualquer tecla para sair..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
