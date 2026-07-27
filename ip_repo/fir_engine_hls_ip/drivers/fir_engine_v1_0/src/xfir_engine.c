// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xfir_engine.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFir_engine_CfgInitialize(XFir_engine *InstancePtr, XFir_engine_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Ctrl_BaseAddress = ConfigPtr->Ctrl_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFir_engine_Start(XFir_engine *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL) & 0x80;
    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XFir_engine_IsDone(XFir_engine *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XFir_engine_IsIdle(XFir_engine *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XFir_engine_IsReady(XFir_engine *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XFir_engine_EnableAutoRestart(XFir_engine *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL, 0x80);
}

void XFir_engine_DisableAutoRestart(XFir_engine *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_AP_CTRL, 0);
}

void XFir_engine_Set_in_buffer(XFir_engine *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IN_BUFFER_DATA, (u32)(Data));
    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IN_BUFFER_DATA + 4, (u32)(Data >> 32));
}

u64 XFir_engine_Get_in_buffer(XFir_engine *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IN_BUFFER_DATA);
    Data += (u64)XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IN_BUFFER_DATA + 4) << 32;
    return Data;
}

void XFir_engine_Set_out_buffer(XFir_engine *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_OUT_BUFFER_DATA, (u32)(Data));
    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_OUT_BUFFER_DATA + 4, (u32)(Data >> 32));
}

u64 XFir_engine_Get_out_buffer(XFir_engine *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_OUT_BUFFER_DATA);
    Data += (u64)XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_OUT_BUFFER_DATA + 4) << 32;
    return Data;
}

void XFir_engine_InterruptGlobalEnable(XFir_engine *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_GIE, 1);
}

void XFir_engine_InterruptGlobalDisable(XFir_engine *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_GIE, 0);
}

void XFir_engine_InterruptEnable(XFir_engine *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IER);
    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IER, Register | Mask);
}

void XFir_engine_InterruptDisable(XFir_engine *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IER);
    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IER, Register & (~Mask));
}

void XFir_engine_InterruptClear(XFir_engine *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_engine_WriteReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_ISR, Mask);
}

u32 XFir_engine_InterruptGetEnabled(XFir_engine *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_IER);
}

u32 XFir_engine_InterruptGetStatus(XFir_engine *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFir_engine_ReadReg(InstancePtr->Ctrl_BaseAddress, XFIR_ENGINE_CTRL_ADDR_ISR);
}

