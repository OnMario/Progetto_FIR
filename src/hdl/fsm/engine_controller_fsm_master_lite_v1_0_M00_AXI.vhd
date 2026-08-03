library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity engine_controller_fsm_master_lite_v1_0_M00_AXI is
	generic (
		C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"00000000";
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32
	);
	port (
        -- CUSTOM FSM PORTS
		host_start_i  : in std_logic;
		fsm_done_o    : out std_logic;
		bus_sel_o     : out std_logic;
		engine_done_i : in std_logic;

		M_AXI_ACLK	    : in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in std_logic;
		M_AXI_WDATA	    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in std_logic;
		M_AXI_BRESP	    : in std_logic_vector(1 downto 0);
		M_AXI_BVALID	: in std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RDATA	    : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	    : in std_logic_vector(1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic
	);
end engine_controller_fsm_master_lite_v1_0_M00_AXI;

architecture implementation of engine_controller_fsm_master_lite_v1_0_M00_AXI is

    -- fsm states definition 
    type fsm_state_type is (ST_IDLE, ST_ISOLATE, ST_WRITE_AW, ST_WRITE_W, ST_WRITE_B, ST_WAIT_DONE, ST_DONE_STATE);
    signal state : fsm_state_type;
    signal step_count : integer range 0 to 7;
    
    -- Array for 5 commands AXI
    type addr_array is array (0 to 6) of std_logic_vector(31 downto 0);
    type data_array is array (0 to 6) of std_logic_vector(31 downto 0);

    constant WRITE_ADDRS : addr_array := (x"00000014", x"00000010", x"00000020", x"0000001C", x"00000004", x"00000008", x"00000000");
    constant WRITE_DATAS : data_array := (x"00000000", x"C0000000", x"00000000", x"C0000100", x"00000001", x"00000001", x"00000001");
  
    signal axi_awvalid_int : std_logic;
    signal axi_wvalid_int  : std_logic;
    signal axi_bready_int  : std_logic;

begin
    -- internal signals drive the external output
    M_AXI_AWVALID <= axi_awvalid_int;
    M_AXI_WVALID  <= axi_wvalid_int;
    M_AXI_BREADY  <= axi_bready_int;

    -- Disable the READ channel (this FSM performs only WRITE operations to configure the FIR).
	M_AXI_AWPROT	<= "000";
	M_AXI_WSTRB	    <= "1111";
	M_AXI_ARADDR	<= (others => '0');
	M_AXI_ARPROT	<= "001";
	M_AXI_ARVALID	<= '0';
	M_AXI_RREADY	<= '0';

    -- FSM
    process(M_AXI_ACLK)
    begin
        if rising_edge(M_AXI_ACLK) then
            if M_AXI_ARESETN = '0' then
                state <= ST_IDLE;
                bus_sel_o <= '0';
                fsm_done_o <= '0';
                axi_awvalid_int <= '0';
                axi_wvalid_int <= '0';
                axi_bready_int <= '0';
                step_count <= 0;
            else
                case state is
                
                    when ST_IDLE =>
                        fsm_done_o <= '0';
                        bus_sel_o <= '0';
                        step_count <= 0;
                        if host_start_i = '1' then
                            state <= ST_ISOLATE;
                        end if;
                        
                    when ST_ISOLATE =>
                        bus_sel_o <= '1'; -- Remove the host and connect the FIR.
                        state <= ST_WRITE_AW;
                        
                    when ST_WRITE_AW =>
                        -- Address
                        M_AXI_AWADDR <= std_logic_vector(unsigned(C_M_TARGET_SLAVE_BASE_ADDR) + unsigned(WRITE_ADDRS(step_count)));
                        axi_awvalid_int <= '1';
                        if M_AXI_AWREADY = '1' and axi_awvalid_int = '1' then
                            axi_awvalid_int <= '0';
                            state <= ST_WRITE_W;
                        end if;
                        
                    when ST_WRITE_W =>
                        -- Data
                        M_AXI_WDATA <= WRITE_DATAS(step_count);
                        axi_wvalid_int <= '1';
                        if M_AXI_WREADY = '1' and axi_wvalid_int = '1' then
                            axi_wvalid_int <= '0';
                            state <= ST_WRITE_B;
                            axi_bready_int <= '1';
                        end if;
                        
                    when ST_WRITE_B =>
                        -- wait AXI response
                        if M_AXI_BVALID = '1' and axi_bready_int = '1' then
                            axi_bready_int <= '0';
                            if step_count = 6 then
                                state <= ST_WAIT_DONE; -- All commands sent!
                            else
                                step_count <= step_count + 1;
                                state <= ST_WRITE_AW; -- next command
                            end if;
                        end if;
                        
                    when ST_WAIT_DONE =>
                        -- waiting for the FIR to raise the physical signal.
                        if engine_done_i = '1' then
                            state <= ST_DONE_STATE;
                        end if;
                        
                    when ST_DONE_STATE =>
                        bus_sel_o <= '0'; -- Reconnect host
                        fsm_done_o <= '1'; -- Notify host
                        if host_start_i = '0' then -- Handshake 
                            state <= ST_IDLE;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

end implementation;