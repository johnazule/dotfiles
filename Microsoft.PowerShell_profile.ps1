Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+k -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+j -Function HistorySearchForward

$env:EDITOR = "nvim"

function Invoke-DirChangeHook {
	$lastPath = [System.Environment]::GetEnvironmentVariable("LocationMemory",[System.EnvironmentVariableTarget]::User)
    if ($PWD.Path -ne $lastPath) {
		[System.Environment]::SetEnvironmentVariable("LocationMemory", $PWD.Path, [System.EnvironmentVariableTarget]::User)
    }
}

Register-EngineEvent PowerShell.Exiting -Action {
    Write-Warning "Saving current location"
    Invoke-DirChangeHook
} | Out-Null

$lastPath = [System.Environment]::GetEnvironmentVariable("LocationMemory",[System.EnvironmentVariableTarget]::User)

if (($lastPath -ne $null) -and (Test-Path $lastPath)) {
    Set-Location $lastPath
}

Import-Module posh-git
oh-my-posh init pwsh --config "$Env:CFG\dotfiles\oh-my-posh\config.omp.yaml" | Invoke-Expression

$oldPrompt = $function:prompt
function prompt {
    Invoke-DirChangeHook
    Invoke-Command $oldPrompt
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })



