# windows-claude-setup.ps1
# Bootstrap script: installs WSL + Ansible, clones env-setup, runs the Claude playbook.
# Run from PowerShell as Administrator:
#   powershell -ExecutionPolicy Bypass -File windows-claude-setup.ps1

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/stockhausenj/env-setup.git"
$WslRepoPath = "/home/$env:USERNAME/env-setup"

# --- WSL ---
Write-Host "Checking WSL..." -ForegroundColor Cyan
$wslCheck = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing WSL (this may require a reboot)..." -ForegroundColor Yellow
    wsl --install --no-launch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "WSL install failed. If a reboot is needed, reboot and re-run this script."
        exit 1
    }
    Write-Host "WSL installed. If this is a first-time install, please reboot and re-run this script." -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}
Write-Host "WSL is available." -ForegroundColor Green

# --- Ensure Ubuntu is the default distro ---
Write-Host "Ensuring Ubuntu distro is set up..." -ForegroundColor Cyan
$distros = wsl --list --quiet 2>&1
if ($distros -notmatch "Ubuntu") {
    Write-Host "Installing Ubuntu distro..." -ForegroundColor Yellow
    wsl --install -d Ubuntu --no-launch
    Write-Host "Ubuntu installed. You may need to launch it once to set up your user, then re-run this script." -ForegroundColor Yellow
    wsl -d Ubuntu -- echo "Ubuntu ready"
}
Write-Host "Ubuntu distro available." -ForegroundColor Green

# --- Ansible ---
Write-Host "Installing Ansible in WSL..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    if command -v ansible-playbook &>/dev/null; then
        echo 'Ansible already installed.'
    else
        sudo apt-get update -qq
        sudo apt-get install -y -qq ansible git
        echo 'Ansible installed.'
    fi
"
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to install Ansible in WSL."; exit 1 }

# --- Clone repo ---
Write-Host "Cloning env-setup repo..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    if [ -d '$WslRepoPath' ]; then
        cd '$WslRepoPath' && git pull --ff-only
        echo 'Repo updated.'
    else
        git clone '$RepoUrl' '$WslRepoPath'
        echo 'Repo cloned.'
    fi
"
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to clone repo."; exit 1 }

# --- Run playbook ---
Write-Host "Running Claude playbook..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    cd '$WslRepoPath'
    ansible-playbook -i 'localhost,' -c local windows-claude.yml
"
if ($LASTEXITCODE -ne 0) { Write-Error "Playbook failed."; exit 1 }

Write-Host "" -ForegroundColor Green
Write-Host "Done! Claude CLI is installed." -ForegroundColor Green
Write-Host "Open a new terminal and run 'claude login' to authenticate." -ForegroundColor Yellow
