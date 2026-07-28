# Automated SoC FIR Filter on Xilinx Arty A7-100T FPGA

This repository contains the hardware design, simulation testbenches, and Hardware-in-the-Loop (HIL) automation scripts for a System-on-Chip (SoC) FIR Filter, targeted for the **Xilinx Arty A7-100T** FPGA board.

The project is designed to be fully automated, allowing users to recreate the Vivado project from a clean clone, run RTL simulations, and execute physical hardware tests seamlessly.

## 🛠️ Prerequisites
*   **Xilinx Vivado 2025.2** (or newer)
*   Digilent Arty A7-100T FPGA Board
*   Micro-USB cable for JTAG programming and AXI communication

## 📂 Repository Structure

To keep the version control clean and lightweight, the Vivado project directory (`project_3`) is purposefully ignored. The project is dynamically generated using TCL scripts.

*   **`ip_repo/`**: Contains the custom Intellectual Property (IP) blocks, including the Custom FSM Controller and the HLS FIR Engine.
*   **`sim/`**: Contains the SystemVerilog/VHDL testbenches, including the AXI VIP (Verification IP) golden models.
*   **`xdc/`**: Contains the physical constraint files (pinout and timing) for the Xilinx Arty board.
*   **`precompiled/`**: Contains the *Golden Bitstream* (`.bit`) and the Probes file (`.ltx`). This allows skipping the lengthy synthesis/implementation steps during quick live demonstrations.
*   **`*.tcl`**: Modular automation scripts to generate the project, run simulations, build the bitstream, and execute HIL tests.

---

## 🚀 How to Run the Automated Demo

First, ensure that your Xilinx Arty board is connected to your PC via USB and turned on. 
Depending on your preferred workflow, you can launch the demo using one of the following two methods:

### Method 1: Using Vivado Tcl Shell (Recommended)

This method runs the entire pipeline in the background (batch mode), providing clean terminal outputs and saving a significant amount of time.

1. Open the **Vivado Tcl Shell** (or Vivado Command Prompt) from your OS application menu.
2. Navigate to the cloned repository folder:
   ```cmd
   cd path/to/your/cloned/repo
   ```
3. Run the master batch script:
   ```cmd
   run_demo.bat
   ```

### Method 2: Using Vivado GUI (Tcl Console)

If you already have the Vivado Graphical User Interface open and prefer to see the project block design and waveforms, use this method.

1. Open Vivado.
2. In the bottom **Tcl Console**, navigate to the repository folder:
   ```tcl
   cd path/to/your/cloned/repo
   ```
3. Source the master TCL script:
   ```tcl
   source run_demo.tcl
   ```

---

## ⚙️ Pipeline Breakdown

When you run either of the master scripts (`run_demo.bat` or `run_demo.tcl`), the following automated steps are executed sequentially:

1. **Project Reconstruction (`recreate_project.tcl`)**: Creates a fresh Vivado project, imports the IPs, and stitches the Block Design together.
2. **RTL Simulation (`run_sim.tcl`)**: Launches the system-level behavioral simulation using the AXI VIP to mathematically verify the Golden Model.
3. **Hardware-in-the-Loop Test (`hil_test.tcl`)**: Bypasses the 30-minute local build by fetching the Golden Bitstream from `/precompiled/`, programs the physical FPGA, and sends real AXI transactions via USB (JTAG-to-AXI Master) to validate the hardware. Check the `led_pronto_2` on your board for the success signal!

> **Note on Custom Builds:** If you modify the HDL code or the Block Design and wish to generate a new bitstream, you can manually source `run_build.tcl` in the Tcl Console before running the HIL test.