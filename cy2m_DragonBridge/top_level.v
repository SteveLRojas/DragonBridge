`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Esteban Looser Rojas (ELR)
// 
// Create Date:    12:27:23 07/12/2023 
// Design Name:	DragonBridge
// Module Name:    dragonbridge_top
// Project Name:	DragonBridge
// Target Devices: XC3S100E, EP2C5T144C8N
// Tool versions: ISE 14.7, Quartus 13.0
// Description: SPI and I2C hosts controlled by a UART
//
// Dependencies: dragonbridge_fsm, uart_gen2, spi_host, I2C_phy_gen2
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dragonbridge_top(
		input wire clk,
		input wire rst_n,
		output wire[2:0] led,
		
		input wire rxd,
		output wire txd,
		
		output wire cs_n,
		output wire sck,
		output wire mosi,
		input wire miso,
		
		inout wire i2c_sda,
		inout wire i2c_scl
	);

//####### IO Control #########################################################
	reg rst_s;
	reg rst;
	
	assign led = {cs_n, txd, rxd};
	
	initial
	begin
		rst_s = 1'b1;
		rst = 1'b0;
	end
	
	always @(posedge clk)
	begin
		rst_s <= ~rst_n;
		rst <= rst_s;
	end
//#############################################################################

//####### Controller FSM ######################################################
	wire[7:0] spi_clk_div;
	wire spi_cpol;
	wire spi_cpha;
	wire spi_transfer_req;
	wire spi_transfer_ready;
	wire spi_transfer_done;
	wire[7:0] spi_to_agent;
	wire[7:0] spi_from_agent;
	
	wire[15:0] i2c_clk_div;
	wire i2c_start_req;
	wire i2c_stop_req;
	wire i2c_write_req;
	wire i2c_read_req;
	wire i2c_ready;
	wire i2c_host_ack;
	wire i2c_agent_ack;
	wire[7:0] i2c_to_agent;
	wire[7:0] i2c_from_agent;
	
	wire[15:0] uart_clk_div;
	wire uart_tx_req;
	wire[7:0] uart_tx_data;
	wire[7:0] uart_rx_data;
	wire uart_tx_ready;
	wire uart_rx_ready;
	
	dragonbridge_fsm dragonbridge_fsm_i(
		.clk(clk),
		.rst(rst),
		
		.spi_cs_n(cs_n),
		.spi_clk_div(spi_clk_div),
		.spi_cpol(spi_cpol),
		.spi_cpha(spi_cpha),
		.spi_transfer_req(spi_transfer_req),
		.spi_transfer_ready(spi_transfer_ready),
		.spi_transfer_done(spi_transfer_done),
		.spi_to_agent(spi_to_agent),
		.spi_from_agent(spi_from_agent),
		
		.i2c_clk_div(i2c_clk_div),
		.i2c_start_req(i2c_start_req),
		.i2c_stop_req(i2c_stop_req),
		.i2c_write_req(i2c_write_req),
		.i2c_read_req(i2c_read_req),
		.i2c_ready(i2c_ready),
		.i2c_host_ack(i2c_host_ack),
		.i2c_agent_ack(i2c_agent_ack),
		.i2c_to_agent(i2c_to_agent),
		.i2c_from_agent(i2c_from_agent),
		
		.uart_clk_div(uart_clk_div),
		.uart_tx_req(uart_tx_req),
		.uart_tx_data(uart_tx_data),
		.uart_rx_data(uart_rx_data),
		.uart_tx_ready(uart_tx_ready),
		.uart_rx_ready(uart_rx_ready),
		
		.cmd_count(),
		.last_tx(),
		.last_rx()
	);
//#############################################################################

//####### UART ################################################################
	uart_gen2 uart_i(
		.clk(clk),
		.reset(rst),
		.clk_div(uart_clk_div),
		.tx_req(uart_tx_req),
		.tx_data(uart_tx_data),
		.rx(rxd),
		.tx(txd),
		.rx_data(uart_rx_data),
		.tx_ready(uart_tx_ready),
		.rx_ready(uart_rx_ready));
//#############################################################################

//####### SPI #################################################################
	spi_host spi_i(
		.clk(clk),
		.rst(rst),

		.clk_div(spi_clk_div),
		.cpol(spi_cpol),
		.cpha(spi_cpha),

		.sck(sck),
		.mosi(mosi),
		.miso(miso),

		.transfer_req(spi_transfer_req),
		.transfer_ready(spi_transfer_ready),
		.transfer_done(spi_transfer_done),
		.to_agent(spi_to_agent),
		.from_agent(spi_from_agent));
//#############################################################################

//####### I2C #################################################################
	I2C_phy_gen2 I2C_phy_i(
		.clk(clk),
		.rst(rst),
		.clk_div(i2c_clk_div),
		.start_req(i2c_start_req),
		.stop_req(i2c_stop_req),
		.write_req(i2c_write_req),
		.read_req(i2c_read_req),
		.ready(i2c_ready),
		.master_ack(i2c_host_ack),
		.slave_ack(i2c_agent_ack),
		.data_from_master(i2c_to_agent),
		.data_from_slave(i2c_from_agent),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl));
//#############################################################################

endmodule
