#----------------------------------------------#
# Utopia - PowerShell color Pipeline for Batch #
#   Author: Diogo Santos Pombo - \Õ/ - @2026   #
#----------------------------------------------#

$esc = [char]27
$skipCmdError = $false

# Configurações genéricas vindas do Batch
$APPNM   = $env:UTOPIA_APPNM   ; if (-not $APPNM)   { $APPNM   = "GenericApp" }
$APP_URL = $env:UTOPIA_APP_URL # só abre se o Batch passar

$input | ForEach-Object {

    $l = $_.ToString()

    # -------------------------------------------------
    # FILTRO DO ERRO MULTILINHA DO CMD (@REM)
    # -------------------------------------------------
    if ($l -match "^\s*'@REM'") {
        $skipCmdError = $true
        return
    }

    if ($skipCmdError) {
        if (
            $l -match "não é reconhecido como um comando interno" -or
            $l -match "^ou externo, um programa" -or
            $l -match "not recognized as an internal or external command"
        ) {
            return
        }
        $skipCmdError = $false
    }

    # -------------------------------------------------
    # 1) SEVERIDADE ESTRUTURAL DO WEBLOGIC (PRIORIDADE TOTAL)
    # -------------------------------------------------
    if ($l -match '(?i)<\s*(ERROR|CRITICAL)\s*>') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }
    if ($l -match '(?i)<\s*(WARNING|NOTICE)\s*>') {
        Write-Host "$esc[93m$l$esc[0m"
        return
    }
    if ($l -match '(?i)<\s*INFO\s*>') {
        Write-Host "$esc[96m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 2) STACKTRACE JAVA REAL
    # -------------------------------------------------
    if ($l -match '^\s*at\s+[\w.$<>]+\(') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }
    if ($l -match '^\s*Caused by\s*:') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }
    if ($l -match '^\s*[\w.$]+Exception[\s\S]*:' -or $l -match '^\s*[\w.$]+Error[\s\S]*:') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }
    if ($l -match '^\s*\.\.\.\s*\d+\s+more\s*$') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 3) FALLBACK POR TEXTO
    # -------------------------------------------------
    if (
        $l -match '(?i)\b(ERROR|FATAL|CRITICAL)\b' -or
        (
            $l -match '(?i)\b(EXCEPTION|EXCEP|EXCECAO)\b' -and
            $l -notmatch '(?i)\bDEBUG\b'
        )
    ) {
        Write-Host "$esc[91m$l$esc[0m"
    }
    elseif ($l -match '(?i)\b(WARN|WARNING|ALERT|ALERTA|ATENCAO)\b') {
        Write-Host "$esc[93m$l$esc[0m"
    }
    elseif ($l -match '(?i)\b(OK|SUCCESS|SUCESSO|COMPLETE|READY|RUNNING|EXECUTANDO|PRONTO|INICIADO|CRIADO|CRIADA|CREATED|INICIADA|INICIALIZADO|INICIALIZADA|CARREGADO|CARREGADA|SIM|YES|LOADED|STARTED)\b') {
        Write-Host "$esc[92m$l$esc[0m"
    }
    elseif ($l -match '(?i)\b(INFO|DEBUG)\b') {
        Write-Host "$esc[96m$l$esc[0m"
    }
    else {
        Write-Host $l
    }

    # -------------------------------------------------
    # 4) DETECTOR DE SUBIDA COMPLETA (Spring Boot + WebLogic)
    # -------------------------------------------------
    if (-not $env:UTOPIA_OPENED -and $APP_URL -and (
        $l -match '(?i)\bStarted .*Application in\b' -or
        $l -match '(?i)Server state changed to RUNNING' -or
        $l -match '(?i)Server started in RUNNING mode' -or
        $l -match '(?i)BEA-000360'
    )) {
        try {
            Start-Process "msedge" "--app=$APP_URL" -WindowStyle Normal -ErrorAction Stop
        } catch {
            Start-Process $APP_URL
        }
        $env:UTOPIA_OPENED = "1"
    }
}
