:: Copyright (c) Microsoft Corporation. All rights reserved.
:: Licensed under the MIT License.
@echo off

goto START

:Usage
echo Usage: build.azure-dm.check-in.cmd [WinSDKVer]
echo    WinSDKVer............... Default is 10.0.17763.0, specify another version if necessary
echo    [/?].................... Displays this usage string.
echo    Example:
echo        build.azure-dm.check-in.cmd 10.0.17763.0
endlocal
exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

if [%1] == [] ( 
    set TARGETPLATVER=10.0.17763.0
) else (
    set TARGETPLATVER=%1
)

set LOGFILE=results.dm.check-in.log
echo Build Started: %TIME% > %LOGFILE%
echo. >> %LOGFILE%

for %%Z in (x86 ARM x64 arm64) do (

    for %%Y in (Debug Release) do (

        call build.azure-dm.cmd %%Z %%Y %TARGETPLATVER%
        if errorlevel 1 (
            echo ERROR build.azure-dm.cmd %%Z %%Y %TARGETPLATVER% >> %LOGFILE%
        ) else (
            echo OK build.azure-dm.cmd %%Z %%Y %TARGETPLATVER% >> %LOGFILE%
        )
    )
)

@echo.
@echo.
@echo ----------------------------------------------------------------------
@echo Results:
@echo.
@type %LOGFILE%