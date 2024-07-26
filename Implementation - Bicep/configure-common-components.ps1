# Uninstall Azure CLI
Remove-Item -Recurse -Force "C:\Program Files\Microsoft SDKs\Azure\CLI2"
# Reinstall Azure CLI
Install-Module -Name Az -AllowClobber -Scope CurrentUsera

Install-Module -Name Az -AllowClobber -Scope CurrentUser
import-module azurecli
import-module az


# Check and install Azure CLI if needed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Installing Azure CLI..."
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -ArgumentList "/I AzureCLI.msi /quiet" -Wait
    Remove-Item .\AzureCLI.msi
    Write-Host "Azure CLI installed successfully."
} else {
    Write-Host "Azure CLI is already installed."
}

# Install Bicep CLI if needed
$bicepVersion = (az bicep version --query "version" --output tsv) 2>$null
if (-not $bicepVersion) {
    Write-Host "Bicep CLI is not installed. Installing Bicep CLI..."
    az bicep install
    Write-Host "Bicep CLI installed successfully."
} else {
    Write-Host "Bicep CLI is already installed."
}

# Check and install Python if needed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python is not installed. Installing Python..."
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.9.5/python-3.9.5-amd64.exe -OutFile .\python-installer.exe
    Start-Process .\python-installer.exe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item .\python-installer.exe
    Write-Host "Python installed successfully."
} else {
    Write-Host "Python is already installed."
}

Write-Host "Installing Azure CLI..."
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList "/I AzureCLI.msi /quiet" -Wait
Remove-Item .\AzureCLI.msi
Write-Host "Azure CLI installed successfully."