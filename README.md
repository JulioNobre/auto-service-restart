# Auto Service Restart - SPXService

Script PowerShell para criar uma tarefa agendada no Windows que reinicia automaticamente o serviço **SPXService** todos os dias úteis às 13:45.

## 📋 Requisitos

- Windows com Task Scheduler
- PowerShell 5.1 ou superior
- Permissões de Administrador

## 🚀 Instalação

### 1. Executar o script de instalação

Abra o **PowerShell como Administrador** e execute:

```powershell
cd "d:\Python\Utils\auto-service-restart"
.\install-restart-SPXService.ps1
```

Ou diretamente:

```powershell
powershell -ExecutionPolicy Bypass -File "d:\Python\Utils\auto-service-restart\install-restart-SPXService.ps1"
```

### 2. Verificar a instalação

A tarefa será criada em:
- **Pasta**: `\Sisgarbe\`
- **Nome**: `Reiniciar Shadow Protect às 13:45`
- **Agendamento**: Segunda a Sexta, às 13:45
- **Conta**: SYSTEM (privilégios elevados)

Para verificar no Task Scheduler:

```powershell
schtasks /Query /TN "\Sisgarbe\Reiniciar Shadow Protect 13h45"
```

## 🧪 Testar manualmente

Para executar a tarefa imediatamente (sem esperar pelo horário agendado):

```powershell
schtasks /Run /TN "\Sisgarbe\Reiniciar Shadow Protect 13h45"
```

## 🗑️ Remoção

Para remover a tarefa agendada:

```powershell
schtasks /Delete /TN "\Sisgarbe\Reiniciar Shadow Protect 13h45" /F
```

## ⚙️ Configuração

O script pode ser personalizado editando as variáveis no início do arquivo `install-restart-SPXService.ps1`:

| Variável | Valor Atual | Descrição |
|----------|-------------|-----------|
| `$taskFolder` | `\Sisgarbe\` | Pasta no Task Scheduler |
| `$taskName` | `Reiniciar Shadow Protect 13h45` | Nome da tarefa |
| `$time` | `13:45` | Horário de execução |
| `$days` | `MON,TUE,WED,THU,FRI` | Dias da semana (segunda a sexta) |
| `$serviceName` | `SPXService` | Nome do serviço a reiniciar |

## 📝 Notas

- O script verifica se você está executando como Administrador
- O serviço é reiniciado com o comando `Restart-Service -Force`
- A tarefa é executada com privilégios SYSTEM (mais alto nível)
- Se o serviço `SPXService` não existir, o script exibirá um aviso mas ainda criará a tarefa

## 🔍 Troubleshooting

### Erro: "Este script precisa ser executado como Administrador"
- Clique com botão direito no PowerShell e selecione "Executar como Administrador"

### A tarefa não executa
- Verifique se o serviço `SPXService` existe: `Get-Service SPXService`
- Verifique os logs do Task Scheduler em: Event Viewer → Windows Logs → Applications and Services Logs → Microsoft → Windows → TaskScheduler

### Ver histórico de execuções
1. Abra Task Scheduler (`taskschd.msc`)
2. Navegue até `\Sisgarbe\`
3. Clique na tarefa e veja a aba "History"
