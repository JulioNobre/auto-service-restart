# Install scheduled task to restart the SPXService on weekdays at 13:45
# Task will be placed under folder \Sisgarbe in Task Scheduler

# Configuration
$taskFolder = '\Sisgarbe\'
$taskName = 'Reiniciar Shadow Protect às 13:45'
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

# Build the action - use powershell.exe to run Restart-Service silently
# Use single quotes inside the command to avoid escaping issues
$action = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"Restart-Service -Name '$serviceName' -Force`""

# Build command line with proper quoting for arguments with spaces
$cmdLine = "/Create /TN `"$fullTaskName`" /TR `"$action`" /SC WEEKLY /D $days /ST $time /RU SYSTEM /RL HIGHEST /F"

Write-Host "Criando/atualizando tarefa agendada: $fullTaskName" -ForegroundColor Cyan
Write-Host "Comando: schtasks.exe $cmdLine" -ForegroundColor DarkGray
$proc = Start-Process -FilePath schtasks.exe -ArgumentList $cmdLine -Wait -NoNewWindow -PassThru
if ($proc.ExitCode -eq 0) {
    Write-Host "Tarefa criada/atualizada com sucesso em $taskFolder" -ForegroundColor Green
    Write-Host "Nome da tarefa: $taskName"
} else {
    Write-Error "Falha ao criar a tarefa. ExitCode: $($proc.ExitCode)"
}

Write-Host "Detalhes da ação: $action" -ForegroundColor DarkGray

# Example: To run the task immediately (optional)
# schtasks /Run /TN "\Sisgarbe\Reiniciar Shadow Protect às 13:45"
