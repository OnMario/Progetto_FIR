`timescale 1ns / 1ps

import axi_vip_pkg::*;
import sim_top_axi_vip_0_0_pkg::*; 

module tb_axi_system_fsm();

    // =========================================================
    // PHYSICAL SIGNALS
    // =========================================================
    logic clk_100MHz;
    logic aresetn_0; 
    logic led_pronto_2; // <--- DONE SIGNAL from FSM

    // Clock Generation
    initial begin
        clk_100MHz = 0;
        forever #5 clk_100MHz = ~clk_100MHz;
    end

    // Reset Generation (Active Low)
    initial begin
        aresetn_0 = 0; 
        #200; // At least 16 clock cycles
        aresetn_0 = 1; 
    end

    // =========================================================
    // INSTANTIATION OF SIM_TOP_WRAPPER
    // =========================================================
    sim_top_wrapper UUT (
        .aclk_0(clk_100MHz),
        .aresetn_0(aresetn_0),
        .led_pronto_2(led_pronto_2) 
    );

    // =========================================================
    // PARAMETERS & MEMORY MAP
    // =========================================================
    localparam int M = 11;                             // Number of Taps
    localparam int VALID_SAMPLES = 16;                 // Input samples
    localparam int N = VALID_SAMPLES + M - 1;          // Output samples (26)
    localparam int WORDS = (N + 1) / 2;                // 32-bit words (13)

    // BRAM Address (Data)
    localparam logic [31:0] BRAM_BASE_ADDR  = 32'hC000_0000;
    localparam logic [31:0] BRAM_OUT_ADDR   = 32'hC000_0100;
    
    // Slave FSM Address
    localparam logic [31:0] FSM_START_REG   = 32'h44A0_0000;

    // =========================================================
    // VIP & VARIABLES DECLARATION
    // =========================================================
    sim_top_axi_vip_0_0_mst_t master_agent;
    xil_axi_resp_t resp; 

    int coefficienti [0:M-1] = '{0, -10, -9, 23, 56, 74, 56, 23, -9, -10, 0};
    int campioni_in [0:N-1];    
    int risultati_attesi [0:N-1]; 
    int errori;

    // =========================================================
    // MAIN TEST EXECUTION
    // =========================================================
    initial begin
        // ---------------------------------------------------------
        // PHASE 0: Random Initialization
        // ---------------------------------------------------------
        $display("--- Random Inputs Generation ---");
        for (int i = 0; i < N; i++) begin
            if (i < VALID_SAMPLES) begin
                campioni_in[i] = $urandom_range(0, 20) - 10; 
            end else begin
                campioni_in[i] = 0; // Padding
            end
        end
        
        for (int n = 0; n < N; n++) begin
            risultati_attesi[n] = 0;
            for (int k = 0; k < M; k++) begin
                if ((n - k) >= 0) begin
                    risultati_attesi[n] += coefficienti[k] * campioni_in[n - k];
                end
            end
        end
        $display("--- Golden Model successfully calculated. ---");

        // ---------------------------------------------------------
        // PHASE 1: AXI VIP Initialization & BRAM Write
        // ---------------------------------------------------------
        master_agent = new("master_vip", UUT.sim_top_i.axi_vip_0.inst.IF);
        master_agent.start_master();
        #250;
        
        $display("1. Writing %0d Words (16-bit packed) into BRAM...", WORDS);
        for (int i = 0; i < WORDS; i++) begin
            logic [31:0] word_data;
            int sample_a = campioni_in[i*2];
            int sample_b = ((i*2)+1 < N) ? campioni_in[(i*2)+1] : 0; 
            
            word_data[15:0]  = sample_a & 16'hFFFF;
            word_data[31:16] = sample_b & 16'hFFFF;
            
            master_agent.AXI4LITE_WRITE_BURST(BRAM_BASE_ADDR + (i*4), 0, word_data, resp);
        end

        // ---------------------------------------------------------
        // PHASE 2: Start FSM 
        // ---------------------------------------------------------
        $display("2. Sending START command to Custom FSM (Address: %h)...", FSM_START_REG);
        master_agent.AXI4LITE_WRITE_BURST(FSM_START_REG, 0, 32'h0000_0001, resp);

        // ---------------------------------------------------------
        // PHASE 3: Hardware Synchronization
        // ---------------------------------------------------------
        $display("3. Waiting for DONE signal from FSM...");
        @(posedge led_pronto_2); 
        $display(">>> DONE signal received! FSM successfully orchestrated the FIR. <<<");
        
        // Reset the FSM Start register 
        master_agent.AXI4LITE_WRITE_BURST(FSM_START_REG, 0, 32'h0000_0000, resp);

        // ---------------------------------------------------------
        // PHASE 4: Read and Assertions (Validation)
        // ---------------------------------------------------------
        $display("4. Reading BRAM and Verifying results...");
        begin
            logic [31:0] read_data;
            errori = 0;
            
            for (int i = 0; i < WORDS; i++) begin
                shortint hw_out_a, hw_out_b;
                int expected_a, expected_b;

                master_agent.AXI4LITE_READ_BURST(BRAM_OUT_ADDR + (i*4), 0, read_data, resp);
                
                // Unpack and sign-extend
                hw_out_a = $signed(read_data[15:0]);
                hw_out_b = $signed(read_data[31:16]);
                
                expected_a = risultati_attesi[i*2];
                expected_b = ((i*2)+1 < N) ? risultati_attesi[(i*2)+1] : 0;
                
                assert(hw_out_a == expected_a) else begin 
                    $error("MISMATCH on OUT_A at Word %0d! Expected: %0d, Read: %0d", i, expected_a, hw_out_a); 
                    errori++; 
                end
                
                if (((i*2)+1) < N) begin
                    assert(hw_out_b == expected_b) else begin 
                        $error("MISMATCH on OUT_B at Word %0d! Expected: %0d, Read: %0d", i, expected_b, hw_out_b); 
                        errori++; 
                    end
                end
            end
            
            if (errori == 0) begin
                $display("======================================================");
                $display("              >>> TEST PASSED! <<<                    ");
                $display("   FSM and FIR Hardware match Golden Model 100%%!    ");
                $display("======================================================");
            end else begin
                $display("======================================================");
                $display("              >>> TEST FAILED! <<<                    ");
                $display("       Found %0d errors in FSM/HW execution!         ", errori);
                $display("======================================================");
            end
        end
        
        $finish;
    end
 
endmodule