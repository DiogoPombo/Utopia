#----------------------------------------------#
# Utopia - PowerShell color Pipeline for Batch #
#   Author: Diogo Santos Pombo - \Õ/ - @2026   #
#--------------------------------------------- #

$esc = [char]27
$skipCmdError = $false

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

    # ERRO WebLogic
    if ($l -match '(?i)<\s*(ERROR|CRITICAL)\s*>') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # WARNING / NOTICE WebLogic
    if ($l -match '(?i)<\s*(WARNING|NOTICE)\s*>') {
        Write-Host "$esc[93m$l$esc[0m"
        return
    }

    # INFO WebLogic
    if ($l -match '(?i)<\s*INFO\s*>') {
        Write-Host "$esc[96m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 2) STACKTRACE JAVA REAL (INDEPENDENTE DE TEXTO)
    # -------------------------------------------------

    # Linha "at pacote.Classe.metodo(...)" — inclui <init>, <clinit>, etc.
    if ($l -match '^\s*at\s+[\w.$<>]+\(') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Linha "Caused by: ..."
    if ($l -match '^\s*Caused by\s*:') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Linha da exception raiz: "pacote.XxxException: mensagem"
    if ($l -match '^\s*[\w.$]+Exception[\s\S]*:' -or $l -match '^\s*[\w.$]+Error[\s\S]*:') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # Linhas "... N more"
    if ($l -match '^\s*\.\.\.\s*\d+\s+more\s*$') {
        Write-Host "$esc[91m$l$esc[0m"
        return
    }

    # -------------------------------------------------
    # 3) FALLBACK POR TEXTO (FORA DO WEBLOGIC)
    # -------------------------------------------------

    # ERRO textual explícito
    if (
        $l -match '(?i)\b(ERROR|FATAL|CRITICAL)\b' -or
        (
            $l -match '(?i)\b(EXCEPTION|EXCEP|EXCECAO)\b' -and
            $l -notmatch '(?i)\bDEBUG\b'
        )
    ) {
        Write-Host "$esc[91m$l$esc[0m"
    }

    # WARNING textual
    elseif ($l -match '(?i)\b(WARN|WARNING|ALERT|ALERTA|ATENCAO)\b') {
        Write-Host "$esc[93m$l$esc[0m"
    }

    # SUCESSO
    elseif ($l -match '(?i)\b(OK|SUCCESS|SUCESSO|COMPLETE|READY|RUNNING|EXECUTANDO|PRONTO|INICIADO|CRIADO|CRIADA|CREATED|INICIADA|INICIALIZADO|INICIALIZADA|CARREGADO|CARREGADA|SIM|YES|LOADED|STARTED)\b') {
        Write-Host "$esc[92m$l$esc[0m"
    }

    # INFO / DEBUG
    elseif ($l -match '(?i)\b(INFO|DEBUG)\b') {
        Write-Host "$esc[96m$l$esc[0m"
    }

    # TEXTO NEUTRO
    else {
        Write-Host $l
    }
}