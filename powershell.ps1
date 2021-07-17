# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# PSDocs
#

# See details at: https://github.com/Microsoft/ps-docs

[CmdletBinding()]
param (
    # The working directory PSDocs is run from.
    [Parameter(Mandatory = $False)]
    [String]$Path = $Env:INPUT_PATH,

     # The path PSDocs will look for files to input files.
     [Parameter(Mandatory = $False)]
     [String]$InputPath = $Env:INPUT_INPUTPATH,

    # An path containing definitions to use for generating documentation.
    [Parameter(Mandatory = $False)]
    [String]$Source = $Env:INPUT_SOURCE,

    # A comma separated list of modules to use containing document definitions.
    [Parameter(Mandatory = $False)]
    [String]$Modules = $Env:INPUT_MODULES,

    [Parameter(Mandatory = $False)]
    [String]$Conventions = $ENV:INPUT_CONVENTIONS,

    # The path to write documentation to.
    [Parameter(Mandatory = $False)]
    [String]$OutputPath = $Env:INPUT_OUTPUTPATH,

    # Determine if a pre-release module version is installed.
    [Parameter(Mandatory = $False)]
    [String]$PreRelease = $Env:INPUT_PRERELEASE
)

$workspacePath = $Env:GITHUB_WORKSPACE;
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue;
if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue;
}

# Set workspace
if ([String]::IsNullOrEmpty($workspacePath)) {
    $workspacePath = $PWD;
}

# Set Path
if ([String]::IsNullOrEmpty($Path)) {
    $Path = $workspacePath;
}
else {
    $Path = Join-Path -Path $workspacePath -ChildPath $Path;
}

# Set InputPath
if ([String]::IsNullOrEmpty($InputPath)) {
    $InputPath = $Path;
}
else {
    $InputPath = Join-Path -Path $Path -ChildPath $InputPath;
}

# Set Source
if ([String]::IsNullOrEmpty($Source)) {
    $Source = Join-Path -Path $Path -ChildPath '.ps-docs/';
}
else {
    $Source = Join-Path -Path $Path -ChildPath $Source;
}

function WriteDebug {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $True)]
        [String]$Message
    )
    process {
        if ($Env:SYSTEM_DEBUG -eq 'true' -or $Env:ACTIONS_STEP_DEBUG -eq 'true') {
            Write-Host "::debug::$Message";
        }
    }
}

# Setup paths for importing modules
$modulesPath = '/ps_modules/';
if ((Get-Variable -Name IsMacOS -ErrorAction Ignore) -or (Get-Variable -Name IsLinux -ErrorAction Ignore)) {
    $moduleSearchPaths = $Env:PSModulePath.Split(':', [System.StringSplitOptions]::RemoveEmptyEntries);
    if ($modulesPath -notin $moduleSearchPaths) {
        $Env:PSModulePath += [String]::Concat($Env:PSModulePath, ':', $modulesPath);
    }
}
else {
    $moduleSearchPaths = $Env:PSModulePath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries);
    if ($modulesPath -notin $moduleSearchPaths) {
        $Env:PSModulePath += [String]::Concat($Env:PSModulePath, ';', $modulesPath);
    }
}

$moduleNames = @()
if (![String]::IsNullOrEmpty($Modules)) {
    $moduleNames = $Modules.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries);
}
$moduleParams = @{
    Scope = 'CurrentUser'
    Force = $True
}
if ($PreRelease -eq 'true') {
    $moduleParams['AllowPrerelease'] = $True;
}

try {
    # Install each module if not already installed
    foreach ($m in $moduleNames) {
        $m = $m.Trim();
        Write-Host "> Checking module: $m";
        if ($Null -eq (Get-InstalledModule -Name $m -ErrorAction Ignore)) {
            Write-Host '  - Installing module';
            $Null = Install-Module -Name $m @moduleParams -AllowClobber -ErrorAction Stop;
        }
        else {
            Write-Host '  - Already installed';
        }
        # Check
        if ($Null -eq (Get-InstalledModule -Name $m)) {
            Write-Host "::error::Failed to install $m.";
        }
        else {
            Write-Host "  - Using version: $((Get-InstalledModule -Name $m).Version)";
        }
    }
}
catch {
    Write-Host "::error::An error occured installing a dependency module.";
    $Host.SetShouldExit(1);
}

$Null = Import-Module PSDocs -ErrorAction Stop;
$version = (Get-InstalledModule PSDocs).Version;

Write-Host '';
Write-Host "[info] Using Version: $version";
Write-Host "[info] Using Action: $Env:GITHUB_ACTION";
Write-Host "[info] Using PWD: $PWD";
Write-Host "[info] Using Path: $Path";
Write-Host "[info] Using Source: $Source";
Write-Host "[info] Using Conventions: $Conventions";
Write-Host "[info] Using InputPath: $InputPath";
Write-Host "[info] Using OutputPath: $OutputPath";

try {
    Push-Location -Path $Path;
    $invokeParams = @{
        Path = $Source
        ErrorAction = 'Stop'
    }
    WriteDebug "Preparing command-line:";
    WriteDebug ([String]::Concat('-Path ''', $Source, ''''));
    if (![String]::IsNullOrEmpty($Modules)) {
        $moduleNames = $Modules.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries);
        $invokeParams['Module'] = $moduleNames;
        WriteDebug ([String]::Concat('-Module ', [String]::Join(', ', $moduleNames)));
    }
    if (![String]::IsNullOrEmpty($Conventions)) {
        $conventionNames = $Conventions.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries);
        $invokeParams['Convention'] = $conventionNames;
        WriteDebug ([String]::Concat('-Convention ', [String]::Join(', ', $conventionNames)));
    }
    if (![String]::IsNullOrEmpty($OutputPath)) {
        $invokeParams['OutputPath'] = $OutputPath;
        WriteDebug ([String]::Concat('-OutputPath ''', $OutputPath, ''''));
    }

    WriteDebug 'Running ''Invoke-PSDocument''.';
    Write-Host '';
    Write-Host '---';
    Invoke-PSDocument @invokeParams -InputPath $InputPath;
}
catch {
    Write-Host "::error::An error occured generating documentation. $($_.Exception.Message)";
    if ($Null -ne $_.ScriptStackTrace) {
        $_.ScriptStackTrace;
    }
    $Host.SetShouldExit(1);
}
finally {
    Pop-Location;
}
Write-Host '---';
