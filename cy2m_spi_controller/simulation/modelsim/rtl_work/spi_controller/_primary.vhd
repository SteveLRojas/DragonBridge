library verilog;
use verilog.vl_types.all;
entity spi_controller is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        led             : out    vl_logic_vector(2 downto 0);
        rxd             : in     vl_logic;
        txd             : out    vl_logic;
        cs_n            : out    vl_logic;
        sck             : out    vl_logic;
        mosi            : out    vl_logic;
        miso            : in     vl_logic
    );
end spi_controller;
