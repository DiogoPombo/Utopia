#----------------------------------------------#
# Utopia - Pipeline com destaque apenas ERRO   #
# Author: Diogo Santos Pombo - \Õ/ - @2026     #
#----------------------------------------------#

$esc = [char]27
$skipCmdError = $false

# Configurações vindas do Batch
$APPNM   = $env:UTOPIA_APPNM
if (-not $APPNM) { $APPNM = "GenericApp" }

$APP_URL = $env:UTOPIA_APP_URL
$OPENED  = $false

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
    # 1) ERRO ESTRUTURAL WEBLOGIC (PRIORIDADE TOTAL)
    # -------------------------------------------------
    if ($l -match '(?i)&lt;\s*(ERROR|CRITICAL)\s*&gt;') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 2) STACKTRACE JAVA ESTRUTURAL (ROBUSTO / REDUNDANTE)
    # -------------------------------------------------

    # Linhas "at ..."
    if ($l -match '^\s*at\s+[\w.$<>;&]+\(.*\)') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Caused by:
    if ($l -match '^\s*Caused by\s*:') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Cabeçalho da Exception / Error
    if (
        $l -match '^\s*[\w.$]+Exception[\s\S]*:' -or
        $l -match '^\s*[\w.$]+Error[\s\S]*:'
    ) {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Continuação do stacktrace
    if ($l -match '^\s*\.\.\.\s*\d+\s+more\s*$') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 3) FALLBACK TEXTUAL AGRESSIVO (HERDADO DO UTOPIA)
    # -------------------------------------------------
    if (
        $l -match '(?i)\b(ERROR|FATAL|CRITICAL)\b' -or
        (
            $l -match '(?i)\b(EXCEPTION|EXCEP|EXCECAO)\b' -and
            $l -notmatch '(?i)\bDEBUG\b'
        )
    ) {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 4) TEXTO NORMAL (SEM COR)
    # -------------------------------------------------
    Write-Host $l

    # -------------------------------------------------
    # DETECÇÃO DE SUBIDA COMPLETA DO SERVIDOR
    # -------------------------------------------------
    if (-not $OPENED -and $APP_URL -and (
        $l -match '(?i)\bStarted .*Application in\b' -or
        $l -match '(?i)Server state changed to RUNNING' -or
        $l -match '(?i)Server started in RUNNING mode' -or
        $l -match '(?i)BEA-000360'
    )) {
        try {
            if (Test-Path $APP_URL) {
                Start-Process $APP_URL
            }
            elseif ($APP_URL -match '^(http|https)://') {
                Start-Process "msedge" "--app=$APP_URL"
            }
            else {
                Start-Process $APP_URL
            }
        }
        catch {
            Start-Process $APP_URL
        }

        $OPENED = $true
    }
}