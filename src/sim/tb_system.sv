`timescale 1ns / 1ps

module tb_system();

    // =========================================================
    // SYSTEM SIGNALS
    // =========================================================
    logic clk;
    logic aresetn;
    logic led_pronto;

    // AXI4-Lite Slave Interface Signals
    logic [31:0] s_axi_awaddr  = 0;
    logic [2:0]  s_axi_awprot  = 0;
    logic        s_axi_awvalid = 0;
    logic        s_axi_awready;

    logic [31:0] s_axi_wdata   = 0;
    logic [3:0]  s_axi_wstrb   = 4'hF;
    logic        s_axi_wvalid  = 0;
    logic        s_axi_wready;

    logic [1:0]  s_axi_bresp;
    logic        s_axi_bvalid;
    logic        s_axi_bready   = 1'b1; // Always ready for write response

    logic [31:0] s_axi_araddr  = 0;
    logic [2:0]  s_axi_arprot  = 0;
    logic        s_axi_arvalid = 0;
    logic        s_axi_arready;

    logic [31:0] s_axi_rdata;
    logic [1:0]  s_axi_rresp;
    logic        s_axi_rvalid;
    logic        s_axi_rready   = 1'b1;

    // =========================================================
    // CLOCK GENERATION (100 MHz)
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // BLOCK DESIGN WRAPPER INSTANTIATION
    // =========================================================
    design_1_wrapper BD_UUT (
        .aclk_0            (clk),
        .aresetn_0         (aresetn),
        .led_pronto_2      (led_pronto),

        // AXI Full/Lite Slave Bus Mapping
        .S00_AXI_0_araddr  (s_axi_araddr),
        .S00_AXI_0_arburst (2'b01),
        .S00_AXI_0_arcache (4'b0000),
        .S00_AXI_0_arid    (1'b0),
        .S00_AXI_0_arlen   (8'd0),
        .S00_AXI_0_arlock  (1'b0),
        .S00_AXI_0_arprot  (s_axi_arprot),
        .S00_AXI_0_arqos   (4'b0000),
        .S00_AXI_0_arready (s_axi_arready),
        .S00_AXI_0_arsize  (3'b010),
        .S00_AXI_0_arvalid (s_axi_arvalid),

        .S00_AXI_0_awaddr  (s_axi_awaddr),
        .S00_AXI_0_awburst (2'b01),
        .S00_AXI_0_awcache (4'b0000),
        .S00_AXI_0_awid    (1'b0),
        .S00_AXI_0_awlen   (8'd0),
        .S00_AXI_0_awlock  (1'b0),
        .S00_AXI_0_awprot  (s_axi_awprot),
        .S00_AXI_0_awqos   (4'b0000),
        .S00_AXI_0_awready (s_axi_awready),
        .S00_AXI_0_awsize  (3'b010),
        .S00_AXI_0_awvalid (s_axi_awvalid),

        .S00_AXI_0_bid     (),
        .S00_AXI_0_bready  (s_axi_bready),
        .S00_AXI_0_bresp   (s_axi_bresp),
        .S00_AXI_0_bvalid  (s_axi_bvalid),

        .S00_AXI_0_rdata   (s_axi_rdata),
        .S00_AXI_0_rid     (),
        .S00_AXI_0_rlast   (),
        .S00_AXI_0_rready  (s_axi_rready),
        .S00_AXI_0_rresp   (s_axi_rresp),
        .S00_AXI_0_rvalid  (s_axi_rvalid),

        .S00_AXI_0_wdata   (s_axi_wdata),
        .S00_AXI_0_wlast   (1'b1),
        .S00_AXI_0_wready  (s_axi_wready),
        .S00_AXI_0_wstrb   (s_axi_wstrb),
        .S00_AXI_0_wvalid  (s_axi_wvalid)
    );

    // =========================================================
    // AXI WRITE TASK (Simulates Host writing a Register)
    // =========================================================
    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            s_axi_wdata   <= data;
            s_axi_wvalid  <= 1'b1;

            fork
                begin
                    wait(s_axi_awready);
                    @(posedge clk);
                    s_axi_awvalid <= 1'b0;
                end
                begin
                    wait(s_axi_wready);
                    @(posedge clk);
                    s_axi_wvalid  <= 1'b0;
                end
            join

            wait(s_axi_bvalid);
            @(posedge clk);
            $display("[TIME: %0t ns] AXI WRITE Done: Addr=0x%h, Data=0x%h", $time, addr, data);
        end
    endtask

    // =========================================================
    // MAIN TEST SEQUENCE
    // =========================================================
    initial begin
        $display("--------------------------------------------------");
        $display("--- Starting Full AXI System Integration Test ----");
        $display("--------------------------------------------------");

        // 1. Reset Phase
        aresetn = 0;
        #100;
        
        // 2. Release Reset
        $display("[TIME: %0t ns] Releasing Reset...", $time);
        aresetn = 1;
        #50;

        // 3. Send START Command from Host via AXI Write (e.g. Write 1 to Reg 0)
        $display("[TIME: %0t ns] Host sending START command over AXI...", $time);
        axi_write(32'h44A00000, 32'h00000001);

        $display("[TIME: %0t ns] FSM should now isolate bus, configure FIR via AXI and wait...", $time);

        // 4. Wait for Real System Completion (LED PRONTO)
        fork
            begin
                @(posedge led_pronto);
                $display("--------------------------------------------------");
                $display("[TIME: %0t ns] >>> FULL SYSTEM TEST PASSED! <<<", $time);
                $display("               LED PRONTO asserted (FIR Done).    ");
                $display("--------------------------------------------------");
            end
            begin
                #10000;
                $display("--------------------------------------------------");
                $display("[ERROR] TIMEOUT: led_pronto_2 was never asserted!");
                $display("--------------------------------------------------");
            end
        join_any

        $finish;
    end

endmodule