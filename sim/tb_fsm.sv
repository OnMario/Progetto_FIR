`timescale 1ns / 1ps

module tb_fsm();

    // =========================================================
    // TESTBENCH SIGNALS
    // =========================================================
    // Shared Clock and Reset
    logic clk;
    logic aresetn;
    
    // Custom FSM Inputs
    logic engine_done_i;
    logic m00_axi_init_axi_txn;
    
    // Custom FSM Outputs
    logic bus_sel_o;
    logic m00_axi_error;
    logic m00_axi_txn_done;

    // --- NEW WIRES FOR AXI SMART LOOPBACK ---
    // These wires connect the Master's READY outputs back to its VALID inputs
    // to simulate a zero-latency ideal memory and respect the AXI protocol.
    logic m00_axi_bready_wire;
    logic m00_axi_rready_wire;

    // =========================================================
    // CLOCK GENERATION (100 MHz -> 10ns period)
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // UNIT UNDER TEST (UUT) INSTANTIATION
    // =========================================================
    engine_controller_fsm UUT (
        // -----------------------------------------------------
        // Clocks & Resets
        // -----------------------------------------------------
        .s00_axi_aclk(clk),
        .s00_axi_aresetn(aresetn),
        .m00_axi_aclk(clk),
        .m00_axi_aresetn(aresetn),
        
        // -----------------------------------------------------
        // Custom Control Ports
        // -----------------------------------------------------
        .engine_done_i(engine_done_i),
        .m00_axi_init_axi_txn(m00_axi_init_axi_txn),
        .bus_sel_o(bus_sel_o),
        .m00_axi_error(m00_axi_error),
        .m00_axi_txn_done(m00_axi_txn_done),
        
        // -----------------------------------------------------
        // AXI MASTER (M00) SMART LOOPBACK CONNECTIONS
        // -----------------------------------------------------
        // Connecting the READY outputs to our internal wires
        .m00_axi_bready (m00_axi_bready_wire),
        .m00_axi_rready (m00_axi_rready_wire),

        // Telling the FSM that the Slave is always ready to accept Address and Data
        .m00_axi_awready (1'b1),
        .m00_axi_wready  (1'b1),
        .m00_axi_bresp   (2'b00), // OKAY response
        
        // AXI Protocol Fix: VALID signal asserts only when READY is asserted
        .m00_axi_bvalid  (m00_axi_bready_wire), 
        
        .m00_axi_arready (1'b1),
        .m00_axi_rdata   (32'd0),
        .m00_axi_rresp   (2'b00), // OKAY response
        
        // AXI Protocol Fix: VALID signal asserts only when READY is asserted
        .m00_axi_rvalid  (m00_axi_rready_wire), 

        // -----------------------------------------------------
        // AXI SLAVE (S00) TIE-OFFS
        // -----------------------------------------------------
        // Keeping the Host interface idle (no commands received)
        .s00_axi_awaddr  (4'd0),
        .s00_axi_awprot  (3'd0),
        .s00_axi_awvalid (1'b0),
        .s00_axi_wdata   (32'd0),
        .s00_axi_wstrb   (4'd0),
        .s00_axi_wvalid  (1'b0),
        .s00_axi_bready  (1'b1),
        .s00_axi_araddr  (4'd0),
        .s00_axi_arprot  (3'd0),
        .s00_axi_arvalid (1'b0),
        .s00_axi_rready  (1'b1)
    );

    // =========================================================
    // MAIN TEST SEQUENCE
    // =========================================================
    initial begin
        $display("--------------------------------------------------");
        $display("--- Starting Isolated FSM Unit Test (RTL) --------");
        $display("--------------------------------------------------");
        
        // ---------------------------------------------------------
        // 1. Initial State & Reset Assertion
        // ---------------------------------------------------------
        aresetn = 0;
        engine_done_i = 0;
        m00_axi_init_axi_txn = 0;
        
        #50; // Hold reset for 5 clock cycles
        
        // ---------------------------------------------------------
        // 2. Release Reset
        // ---------------------------------------------------------
        $display("[TIME: %0t ns] Releasing system reset...", $time);
        aresetn = 1; 
        
        #30; // Wait for the system to stabilize
        
        // ---------------------------------------------------------
        // 3. Send INIT Command (Start FSM)
        // ---------------------------------------------------------
        $display("[TIME: %0t ns] Sending INIT_AXI_TXN command to FSM...", $time);
        m00_axi_init_axi_txn = 1;
        
        #10; // Pulse duration: 1 clock cycle
        m00_axi_init_axi_txn = 0;
        
        // ---------------------------------------------------------
        // 4. Simulate Engine Elaboration Time
        // ---------------------------------------------------------
        $display("[TIME: %0t ns] FSM is running... waiting for Engine to finish...", $time);
        
        #500; // Simulating the FIR engine taking time to process data
        
        // ---------------------------------------------------------
        // 5. Assert Engine Done
        // ---------------------------------------------------------
        $display("[TIME: %0t ns] Engine finished! Asserting engine_done_i...", $time);
        engine_done_i = 1;
        
        #10;
        engine_done_i = 0;
        
        // ---------------------------------------------------------
        // 6. Polling / Waiting for TXN_DONE Flag with Timeout
        // ---------------------------------------------------------
        $display("[TIME: %0t ns] Waiting for FSM to assert m00_axi_txn_done...", $time);
        
        // Safety timeout block to prevent infinite simulation hangs
        fork
            begin
                @(posedge m00_axi_txn_done);
                $display("--------------------------------------------------");
                $display("[TIME: %0t ns] >>> TEST COMPLETED SUCCESSFULLY! <<<", $time);
                $display("               FSM reached the DONE state.        ");
                $display("--------------------------------------------------");
            end
            begin
                #500;
                $display("--------------------------------------------------");
                $display("[ERROR] TIMEOUT: m00_axi_txn_done never asserted!");
                $display("--------------------------------------------------");
            end
        join_any
        
        $finish; // End the simulation
    end

endmodule