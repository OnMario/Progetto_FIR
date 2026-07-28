# Automated SoC FIR Filter on Xilinx Arty FPGA

This repository contains the hardware design, simulation testbenches, and Hardware-in-the-Loop (HIL) automation scripts for a System-on-Chip (SoC) FIR Filter, targeted for the Xilinx Arty FPGA board.

The project is designed to be fully automated, allowing users to recreate the Vivado project from a clean clone, run RTL simulations, and execute physical hardware tests seamlessly.

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
This method runs the entire pipeline in background (batch mode) providing clean terminal outputs.

1. Open the **Vivado Tcl Shell** (or Vivado Command Prompt) from your OS application menu.
2. Navigate to the cloned repository folder:
   ```cmd
   cd path/to/your/cloned/repo