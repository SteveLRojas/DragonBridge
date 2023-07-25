`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Esteban Looser Rojas (ELR)
// 
// Create Date:    12:27:23 07/12/2023 
// Design Name:	spi_controller
// Module Name:    top_level 
// Project Name:	basys2_spi_controller
// Target Devices: XC3S100E
// Tool versions: ISE 14.7
// Description: SPI master controlled by a UART
//
// Dependencies: spi_master, uart_gen2
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_controller(
		input wire clk,
		input wire rst_n,
		output wire[2:0] led,
		
		input wire rxd,
		output wire txd,
		
		output wire cs_n,
		output wire sck,
		output wire mosi,
		input wire miso
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
	wire cpol;
	wire cpha;
	wire transfer_req;
	wire transfer_ready;
	wire transfer_done;
	wire[7:0] to_agent;
	wire[7:0] from_agent;
	
	wire[15:0] uart_clk_div;
	wire tx_req;
	wire[7:0] tx_data;
	wire[7:0] rx_data;
	wire tx_ready;
	wire rx_ready;
	
	controller_fsm controller_i(
		.clk(clk),
		.rst(rst),
		
		.spi_clk_div(spi_clk_div),
		.cpol(cpol),
		.cpha(cpha),
		.transfer_req(transfer_req),
		.transfer_ready(transfer_ready),
		.transfer_done(transfer_done),
		.to_agent(to_agent),
		.from_agent(from_agent),
		
		.uart_clk_div(uart_clk_div),
		.tx_req(tx_req),
		.tx_data(tx_data),
		.rx_data(rx_data),
		.tx_ready(tx_ready),
		.rx_ready(rx_ready),
		
		.led(),
		.cs_n(cs_n),
		.hex_data()
	);
//#############################################################################

//####### UART ################################################################
	uart_gen2 uart_i(
		.clk(clk),
		.reset(rst),
		.clk_div(uart_clk_div),
		.tx_req(tx_req),
		.tx_data(tx_data),
		.rx(rxd),
		.tx(txd),
		.rx_data(rx_data),
		.tx_ready(tx_ready),
		.rx_ready(rx_ready));
//#############################################################################

//####### SPI #################################################################
	spi_host spi_i(
		.clk(clk),
		.rst(rst),

		.clk_div(spi_clk_div),
		.cpol(cpol),
		.cpha(cpha),

		.sck(sck),
		.mosi(mosi),
		.miso(miso),

		.transfer_req(transfer_req),
		.transfer_ready(transfer_ready),
		.transfer_done(transfer_done),
		.to_agent(to_agent),
		.from_agent(from_agent));
//#############################################################################

endmodule
