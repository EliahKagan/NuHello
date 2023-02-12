#!/usr/bin/env pwsh

# Copyright (c) 2023 Eliah Kagan
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptName = $MyInvocation.MyCommand.Name
$Escape = [char]27

function Write-Message($Text) {
    if ([Console]::IsOutputRedirected) {
        Write-Output "$Text"
    } else {
        Write-Output "${Escape}[1m${Text}${Escape}[0m"
    }
}

function Write-Divider {
    Write-Output ''
}

function Write-ErrorMessage($Text) {
    [Console]::Error.WriteLine("${ScriptName}: error: $Text")
}

# Refuse to run if we are not in the correct directory.
if (-not (Test-Path NuHello.sln -PathType Leaf)) {
    Write-ErrorMessage 'not in top-level solution directory'
    exit 1
}

Write-Message 'Deleting built package files and clearing NuGet cache.'
Remove-Item -Recurse -Force src/*/bin,src/*/obj,test/*/bin,test/*/obj,publish/*
Remove-Item -Force src/Goodbye/*.nupkg
dotnet nuget locals all --clear || exit $LASTEXITCODE
Write-Divider

Write-Message 'Rebuilding and locally publishing Hello.'
Push-Location src/Hello
dotnet build || exit $LASTEXITCODE
nuget add bin/Debug/Ekgn.NuHello.1.0.0.nupkg -source ../../publish ||
    exit $LASTEXITCODE
Pop-Location
Write-Divider

Write-Message 'Rebuilding and locally publishing Goodbye.'
Push-Location src/Goodbye
nuget pack || exit $LASTEXITCODE
nuget add Ekgn.NuHello.Goodbye.1.0.0.nupkg -source ../../publish ||
    exit $LASTEXITCODE
Pop-Location
Write-Divider

Write-Message `
    'Packages rebuilt and locally republished. Run "dotnet test" to test.'
