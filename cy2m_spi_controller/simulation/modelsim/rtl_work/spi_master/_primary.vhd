library verilog;
use verilog.vl_types.all;
entity spi_master is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        clk_div         : in     vl_logic_vector(7 downto 0);
        cpol            : in     vl_logic;
        cpha            : in     vl_logic;
        sck             : out    vl_logic;
        mosi            : out    vl_logic;
        miso            : in     vl_logic;
        transfer_req    : in     vl_logic;
        transfer_ready  : out    vl_logic;
        transfer_done   : out    vl_logic;
        to_agent        : in     vl_logic_vector(7 downto 0);
        from_agent      : out    vl_logic_vector(7 downto 0)
    );
end spi_master;
