library verilog;
use verilog.vl_types.all;
entity uart_gen2 is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        clk_div         : in     vl_logic_vector(15 downto 0);
        tx_req          : in     vl_logic;
        tx_data         : in     vl_logic_vector(7 downto 0);
        rx              : in     vl_logic;
        tx              : out    vl_logic;
        rx_data         : out    vl_logic_vector(7 downto 0);
        tx_ready        : out    vl_logic;
        rx_ready        : out    vl_logic
    );
end uart_gen2;
