// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xfir_engine.h"

extern XFir_engine_Config XFir_engine_ConfigTable[];

#ifdef SDT
XFir_engine_Config *XFir_engine_LookupConfig(UINTPTR BaseAddress) {
	XFir_engine_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XFir_engine_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XFir_engine_ConfigTable[Index].Ctrl_BaseAddress == BaseAddress) {
			ConfigPtr = &XFir_engine_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFir_engine_Initialize(XFir_engine *InstancePtr, UINTPTR BaseAddress) {
	XFir_engine_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFir_engine_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFir_engine_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XFir_engine_Config *XFir_engine_LookupConfig(u16 DeviceId) {
	XFir_engine_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFIR_ENGINE_NUM_INSTANCES; Index++) {
		if (XFir_engine_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFir_engine_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFir_engine_Initialize(XFir_engine *InstancePtr, u16 DeviceId) {
	XFir_engine_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFir_engine_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFir_engine_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

