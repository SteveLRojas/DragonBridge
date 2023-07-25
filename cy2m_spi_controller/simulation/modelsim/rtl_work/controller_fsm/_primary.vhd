library verilog;
use verilog.vl_types.all;
entity controller_fsm is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        spi_clk_div     : out    vl_logic_vector(7 downto 0);
        cpol            : out    vl_logic;
        cpha            : out    vl_logic;
        transfer_req    : out    vl_logic;
        transfer_ready  : in     vl_logic;
        transfer_done   : in     vl_logic;
        to_agent        : out    vl_logic_vector(7 downto 0);
        from_agent      : in     vl_logic_vector(7 downto 0);
        uart_clk_div    : out    vl_logic_vector(15 downto 0);
        tx_req          : out    vl_logic;
        tx_data         : out    vl_logic_vector(7 downto 0);
        rx_data         : in     vl_logic_vector(7 downto 0);
        tx_ready        : in     vl_logic;
        rx_ready        : in     vl_logic;
        led             : out    vl_logic_vector(7 downto 0);
        cs_n            : out    vl_logic;
        hex_data        : out    vl_logic_vector(15 downto 0)
    );
end controller_fsm;
