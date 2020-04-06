// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <memory>
#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING

#include "..\..\Utilities\Utils.h"
namespace DMUtils = Microsoft::Azure::DeviceManagement::Utils;

#include "..\..\AzureDeviceManagementCommon\DMCommon.h"
namespace DMCommon = Microsoft::Azure::DeviceManagement::Common;
