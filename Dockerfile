# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

ARG MODULE_VERSION=0.9.0

FROM mcr.microsoft.com/powershell:7.3.0-preview.3-windowsservercore-ltsc2022-20220318
SHELL ["pwsh", "-Command"]
RUN $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue; \
    $Null = New-Item -Path /ps_modules/ -ItemType Directory -Force; \
    Save-Module -Name PSDocs -RequiredVersion ${MODULE_VERSION} -Force -Path /ps_modules/;

COPY LICENSE README.md powershell.ps1 /
CMD ["pwsh", "-File", "/powershell.ps1"]
