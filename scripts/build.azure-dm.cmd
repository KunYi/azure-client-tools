:: Copyright (c) Microsoft Corporation. All rights reserved.
:: Licensed under the MIT License.
:: This script runs CMAKE to prepare the Azure SDK then builds the necessary SDK components and DPS app
@echo off

goto START

:Usage
echo Usage: build.azure-dm.cmd x86^|ARM^|x64 Debug^|Release [WinSDKVer]
echo    WinSDKVer............... Default is 10.0.17763.0, specify another version if necessary
echo    [/?].................... Displays this usage string.
echo    Example:
echo        build.azure-dm.cmd x64 Debug 10.0.17763.0
endlocal
exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

if [%1] == [] (
    set TARGETARCH=x64
    set TARGETARCH_ALT=x64
) else (
    set TARGETARCH=%1
    if /I [%1] == [x86] (
        set TARGETARCH_ALT=Win32
    ) else (
        set TARGETARCH_ALT=%1
    )
)

if [%2] == [] (
    set TARGETCONFIG=Debug
) else (
    set TARGETCONFIG=%2
)

if [%3] == [] ( 
    set TARGETPLATVER=10.0.17763.0
) else (
    set TARGETPLATVER=%3
)

set REPO_ROOT=%~dp0..
set DEFAULT_BUILD_PARAMS= /p:SolutionDir=%REPO_ROOT%\code\ /p:Configuration=%TARGETCONFIG% /p:Platform=%TARGETARCH% /p:TargetPlatformVersion=%TARGETPLATVER%
set DEFAULT_BUILD_PARAMS_ALT= /p:SolutionDir=%REPO_ROOT%\code\ /p:Configuration=%TARGETCONFIG% /p:Platform=%TARGETARCH_ALT% /p:TargetPlatformVersion=%TARGETPLATVER%
pushd %~dp0

echo .
echo "Building DM binaries"
echo .

    msbuild %REPO_ROOT%\deps\security\Urchin\Lib\Urchin.vcxproj /p:SolutionDir=%REPO_ROOT%\code\output\ /p:Configuration=%TARGETCONFIG% /p:Platform=%TARGETARCH% /p:TargetPlatformVersion=%TARGETPLATVER%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\deps\security\Urchin\Platform\Platform.vcxproj /p:SolutionDir=%REPO_ROOT%\code\output\ /p:Configuration=%TARGETCONFIG% /p:Platform=%TARGETARCH% /p:TargetPlatformVersion=%TARGETPLATVER%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\Utilities\Utilities.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\LimpetApi\LimpetApi.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\AzureDeviceProvisioningClient\AzureDeviceProvisioningClient.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    msbuild %REPO_ROOT%\code\Limpet\Limpet.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    if /I [%TARGETARCH%] == [arm64] goto Success

    msbuild %REPO_ROOT%\code\device-agent\uwp-bridge-lib\DMBridgeInterface\DMBridgeInterface.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent\uwp-bridge-lib\DMBridge\DMBridge.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent\uwp-bridge-lib\DMBridgeComponent\DMBridgeComponent.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    msbuild %REPO_ROOT%\code\device-agent\common\AzureDeviceManagementCommon.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent\agent\AzureDeviceManagementClient.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    @REM Plugin Infrastructure

    msbuild %REPO_ROOT%\code\device-agent\plugin-common\AzureDeviceManagementPluginCommon.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    msbuild %REPO_ROOT%\code\device-agent\plugin-host\AzureDeviceManagementPluginHost.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    if /I [%TARGETARCH%] NEQ [arm] (
        msbuild %REPO_ROOT%\code\Tools\PluginCreator\PluginCreator.vcxproj  /p:SolutionDir=%REPO_ROOT%\code\ /p:Configuration=%TARGETCONFIG% /p:Platform=%TARGETARCH_ALT% /p:TargetPlatformVersion=%TARGETPLATVER%
        if errorlevel 1 goto BuildError
    )

    @REM Plugins
 
    msbuild %REPO_ROOT%\code\device-agent-plugins\FactoryResetPlugin\FactoryResetPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\RebootPlugin\RebootPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\RemoteWipePlugin\RemoteWipePlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\TimePlugin\TimePlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\WindowsTelemetryPlugin\WindowsTelemetryPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\WindowsUpdatePlugin\WindowsUpdatePlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\DeviceInfoPlugin\DeviceInfoPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\CertificateManagementPlugin\CertificateManagementPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\DiagnosticLogsManagementPlugin\DiagnosticLogsManagementPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError
    msbuild %REPO_ROOT%\code\device-agent-plugins\UwpAppManagementPlugin\UwpAppManagementPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    @REM
    @REM -- Samples --
    @REM

    msbuild %REPO_ROOT%\code\Samples\Plugins\TestPlugin\TestPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

    msbuild %REPO_ROOT%\code\Samples\Plugins\DirectRebootManagementPlugin\DirectRebootManagementPlugin.vcxproj %DEFAULT_BUILD_PARAMS%
    if errorlevel 1 goto BuildError

goto Success

:BuildError
popd
@echo Error building project...
exit /b 1

:Success
popd