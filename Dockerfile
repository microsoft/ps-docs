# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

ARG MODULE_VERSION=0.9.0

# NOTE: Use pre-release version with -AllowPrerelease.

FROM mcr.microsoft.com/powershell:7.1.3-alpine-3.12-20210603
SHELL ["pwsh", "-Command"]
RUN $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue; \
    $Null = New-Item -Path /ps_modules/ -ItemType Directory -Force; \
    Save-Module -Name PSDocs -RequiredVersion ${MODULE_VERSION} -Force -Path /ps_modules/ -AllowPrerelease;

COPY LICENSE README.md powershell.ps1 /
CMD ["pwsh", "-File", "/powershell.ps1"]
