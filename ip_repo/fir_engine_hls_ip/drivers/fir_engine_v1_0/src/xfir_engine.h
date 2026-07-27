// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XFIR_ENGINE_H
#define XFIR_ENGINE_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xfir_engine_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Ctrl_BaseAddress;
} XFir_engine_Config;
#endif

typedef struct {
    u64 Ctrl_BaseAddress;
    u32 IsReady;
} XFir_engine;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFir_engine_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFir_engine_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFir_engine_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFir_engine_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XFir_engine_Initialize(XFir_engine *InstancePtr, UINTPTR BaseAddress);
XFir_engine_Config* XFir_engine_LookupConfig(UINTPTR BaseAddress);
#else
int XFir_engine_Initialize(XFir_engine *InstancePtr, u16 DeviceId);
XFir_engine_Config* XFir_engine_LookupConfig(u16 DeviceId);
#endif
int XFir_engine_CfgInitialize(XFir_engine *InstancePtr, XFir_engine_Config *ConfigPtr);
#else
int XFir_engine_Initialize(XFir_engine *InstancePtr, const char* InstanceName);
int XFir_engine_Release(XFir_engine *InstancePtr);
#endif

void XFir_engine_Start(XFir_engine *InstancePtr);
u32 XFir_engine_IsDone(XFir_engine *InstancePtr);
u32 XFir_engine_IsIdle(XFir_engine *InstancePtr);
u32 XFir_engine_IsReady(XFir_engine *InstancePtr);
void XFir_engine_EnableAutoRestart(XFir_engine *InstancePtr);
void XFir_engine_DisableAutoRestart(XFir_engine *InstancePtr);

void XFir_engine_Set_in_buffer(XFir_engine *InstancePtr, u64 Data);
u64 XFir_engine_Get_in_buffer(XFir_engine *InstancePtr);
void XFir_engine_Set_out_buffer(XFir_engine *InstancePtr, u64 Data);
u64 XFir_engine_Get_out_buffer(XFir_engine *InstancePtr);

void XFir_engine_InterruptGlobalEnable(XFir_engine *InstancePtr);
void XFir_engine_InterruptGlobalDisable(XFir_engine *InstancePtr);
void XFir_engine_InterruptEnable(XFir_engine *InstancePtr, u32 Mask);
void XFir_engine_InterruptDisable(XFir_engine *InstancePtr, u32 Mask);
void XFir_engine_InterruptClear(XFir_engine *InstancePtr, u32 Mask);
u32 XFir_engine_InterruptGetEnabled(XFir_engine *InstancePtr);
u32 XFir_engine_InterruptGetStatus(XFir_engine *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
