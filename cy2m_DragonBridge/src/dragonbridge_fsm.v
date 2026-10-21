`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Esteban Looser Rojas (ELR)
// 
// Create Date:    17:33:18 07/23/2023 
// Design Name: 
// Module Name:    dragonbridge_fsm 
// Project Name:	DragonBridge
// Target Devices: EP2C5T144C8N
// Tool versions: Quartus 13.0
// Description: Control I2C and SPI hosts over UART
//
// Dependencies: None
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dragonbridge_fsm(
		input wire clk,
		input wire rst,
		
		output reg spi_cs_n,
		output reg[7:0] spi_clk_div,
		output reg spi_cpol,
		output reg spi_cpha,
		output reg spi_transfer_req,
		input wire spi_transfer_ready,
		input wire spi_transfer_done,
		output reg[7:0] spi_to_agent,
		input wire[7:0] spi_from_agent,
		
		output reg[15:0] i2c_clk_div,
		output reg i2c_start_req,
		output reg i2c_stop_req,
		output reg i2c_write_req,
		output reg i2c_read_req,
		input wire i2c_ready,
		output reg i2c_host_ack,
		input wire i2c_agent_ack,
		output reg[7:0] i2c_to_agent,
		input wire[7:0] i2c_from_agent,
		
		output reg[15:0] uart_clk_div,
		output reg uart_tx_req,
		output reg[7:0] uart_tx_data,
		input wire[7:0] uart_rx_data,
		input wire uart_tx_ready,
		input wire uart_rx_ready,
		
		output reg[7:0] cmd_count,
		output reg[7:0] last_tx,
		output reg[7:0] last_rx
	);

	//HINT: Commands
	localparam[7:0] CMD_NOP = 8'h00;		//Expects 0 bytes, returns 0
	localparam[7:0] CMD_TEST = 8'h01;	//Expects 1 byte, returns 1
	localparam[7:0] CMD_BAUD = 8'h02;	//Expects 2 bytes, returns 0
	
	localparam[7:0] CMD_SPI_SPEED = 8'h03;	//Expects 1 byte, returns 0
	localparam[7:0] CMD_SPI_MODE = 8'h04;	//Expects 1 byte, returns 0
	localparam[7:0] CMD_SPI_CHIPSEL = 8'h05;	//Expects 1 byte, returns 0
	localparam[7:0] CMD_SPI_TRANSFER = 8'h06;	//Expects 1 byte, returns 1
	
	localparam[7:0] CMD_I2C_SPEED = 8'h07;	//Expects 2 bytes, returns 0
	localparam[7:0] CMD_I2C_START = 8'h08;	//Expects 0 bytes, returns 0
	localparam[7:0] CMD_I2C_STOP = 8'h09;	//Expects 0 bytes, returns 0
	localparam[7:0] CMD_I2C_WRITE = 8'h0A;	//Expects 1 byte, returns 0
	localparam[7:0] CMD_I2C_READ = 8'h0B;	//Expects 0 bytes, returns 1
	localparam[7:0] CMD_I2C_HOST_ACK = 8'h0C;	//Expects 1 byte, returns 0
	localparam[7:0] CMD_I2C_AGENT_ACK = 8'h0D;	//Expects 0 bytes, returns 1
	
	//HINT: States
	localparam[7:0] S_IDLE = 8'h00;
	localparam[7:0] S_TEST = 8'h01;
	localparam[7:0] S_TEST_REQ = 8'h02;
	localparam[7:0] S_BAUD_H = 8'h03;
	localparam[7:0] S_BAUD_L = 8'h04;
	
	localparam[7:0] S_SPI_SPEED = 8'h05;
	localparam[7:0] S_SPI_MODE = 8'h06;
	localparam[7:0] S_SPI_CHIPSEL = 8'h07;
	localparam[7:0] S_SPI_TRANSFER_GET = 8'h08;
	localparam[7:0] S_SPI_TRANSFER_SRQ = 8'h09;
	localparam[7:0] S_SPI_TRANSFER_SGT = 8'h0A;
	localparam[7:0] S_SPI_TRANSFER_URQ = 8'h0B;
	
	localparam[7:0] S_I2C_SPEED_H = 8'h0C;
	localparam[7:0] S_I2C_SPEED_L = 8'h0D;
	localparam[7:0] S_I2C_START_R = 8'h0E;
	localparam[7:0] S_I2C_START_W = 8'h0F;
	localparam[7:0] S_I2C_STOP_R = 8'h10;
	localparam[7:0] S_I2C_STOP_W = 8'h11;
	localparam[7:0] S_I2C_WRITE_GET = 8'h12;
	localparam[7:0] S_I2C_WRITE_W = 8'h13;
	localparam[7:0] S_I2C_READ_IGT = 8'h14;
	localparam[7:0] S_I2C_READ_URQ = 8'h15;
	localparam[7:0] S_I2C_HOST_ACK = 8'h16;
	localparam[7:0] S_I2C_AGENT_ACK = 8'h17;
	
	reg[7:0] state;
	reg[7:0] baud_buf;
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			spi_cs_n <= 1'b0;
			spi_clk_div <= 8'h00;	//max speed
			spi_cpol <= 1'b0;
			spi_cpha <= 1'b0;
			spi_transfer_req <= 1'b0;
			spi_to_agent <= 8'h00;
			
			i2c_clk_div <= 16'h0000;
			i2c_start_req <= 1'b0;
			i2c_stop_req <= 1'b0;
			i2c_write_req <= 1'b0;
			i2c_read_req <= 1'b0;
			i2c_host_ack <= 1'b0;
			i2c_to_agent <= 8'h00;
			
			uart_clk_div <= 16'd433;	//115200 baud
			uart_tx_req <= 1'b0;
			uart_tx_data <= 8'h00;
			
			cmd_count <= 8'h00;
			last_tx <= 8'h00;
			last_rx <= 8'h00;
			
			state <= S_IDLE;
			baud_buf <= 8'h00;
		end
		else
		begin
			case(state)
			S_IDLE:
			begin
				if(uart_rx_ready)
				begin
					cmd_count <= cmd_count + 8'h01;
					case(uart_rx_data)
					CMD_NOP: ;
					CMD_TEST: state <= S_TEST;
					CMD_BAUD: state <= S_BAUD_H;
					
					CMD_SPI_SPEED: state <= S_SPI_SPEED;
					CMD_SPI_MODE: state <= S_SPI_MODE;
					CMD_SPI_CHIPSEL: state <= S_SPI_CHIPSEL;
					CMD_SPI_TRANSFER: state <= S_SPI_TRANSFER_GET;
					
					CMD_I2C_SPEED: state <= S_I2C_SPEED_H;
					CMD_I2C_START: state <= S_I2C_START_R;
					CMD_I2C_STOP: state <= S_I2C_STOP_R;
					CMD_I2C_WRITE: state <= S_I2C_WRITE_GET;
					CMD_I2C_READ: state <= S_I2C_READ_IGT;
					CMD_I2C_HOST_ACK: state <= S_I2C_HOST_ACK;
					CMD_I2C_AGENT_ACK: state <= S_I2C_AGENT_ACK;
					
					default: ;
					endcase
				end
			end
			S_TEST:
			begin
				if(uart_rx_ready)
				begin
					uart_tx_data <= uart_rx_data;
					uart_tx_req <= 1'b1;
					state <= S_TEST_REQ;
				end
			end
			S_TEST_REQ:
			begin
				if(uart_tx_ready)
				begin
					uart_tx_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			S_BAUD_H:
			begin
				if(uart_rx_ready)
				begin
					baud_buf <= uart_rx_data;
					state <= S_BAUD_L;
				end
			end
			S_BAUD_L:
			begin
				if(uart_rx_ready)
				begin
					uart_clk_div <= {baud_buf, uart_rx_data};
					state <= S_IDLE;
				end
			end
			
			
			S_SPI_SPEED:
			begin
				if(uart_rx_ready)
				begin
					spi_clk_div <= uart_rx_data;
					state <= S_IDLE;
				end
			end
			S_SPI_MODE:
			begin
				if(uart_rx_ready)
				begin
					spi_cpha <= uart_rx_data[0];
					spi_cpol <= uart_rx_data[1];
					state <= S_IDLE;
				end
			end
			S_SPI_CHIPSEL:
			begin
				if(uart_rx_ready)
				begin
					spi_cs_n <= uart_rx_data[0];
					state <= S_IDLE;
				end
			end
			S_SPI_TRANSFER_GET:
			begin
				if(uart_rx_ready)
				begin
					spi_to_agent <= uart_rx_data;
					last_tx <= uart_rx_data;
					spi_transfer_req <= 1'b1;
					state <= S_SPI_TRANSFER_SRQ;
				end
			end
			S_SPI_TRANSFER_SRQ:
			begin
				if(spi_transfer_ready)
				begin
					spi_transfer_req <= 1'b0;
					state <= S_SPI_TRANSFER_SGT;
				end
			end
			S_SPI_TRANSFER_SGT:
			begin
				if(spi_transfer_done)
				begin
					uart_tx_data <= spi_from_agent;
					last_rx <= spi_from_agent;
					uart_tx_req <= 1'b1;
					state <= S_SPI_TRANSFER_URQ;
				end
			end
			S_SPI_TRANSFER_URQ:
			begin
				if(uart_tx_ready)
				begin
					uart_tx_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			
			
			S_I2C_SPEED_H:
			begin
				if(uart_rx_ready)
				begin
					i2c_clk_div[15:8] <= uart_rx_data;
					state <= S_I2C_SPEED_L;
				end
			end
			S_I2C_SPEED_L:
			begin
				if(uart_rx_ready)
				begin
					i2c_clk_div[7:0] <= uart_rx_data;
					state <= S_IDLE;
				end
			end
			S_I2C_START_R:
			begin
				i2c_start_req <= 1'b1;
				state <= S_I2C_START_W;
			end
			S_I2C_START_W:
			begin
				if(i2c_ready)
				begin
					i2c_start_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			S_I2C_STOP_R:
			begin
				i2c_stop_req <= 1'b1;
				state <= S_I2C_STOP_W;
			end
			S_I2C_STOP_W:
			begin
				if(i2c_ready)
				begin
					i2c_stop_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			S_I2C_WRITE_GET:
			begin
				if(uart_rx_ready)
				begin
					i2c_to_agent <= uart_rx_data;
					last_tx <= uart_rx_data;
					i2c_write_req <= 1'b1;
					state <= S_I2C_WRITE_W;
				end
			end
			S_I2C_WRITE_W:
			begin
				if(i2c_ready)
				begin
					i2c_write_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			S_I2C_READ_IGT:
			begin
				i2c_read_req <= 1'b1;
				if(i2c_ready)
				begin
					i2c_read_req <= 1'b0;
					uart_tx_data <= i2c_from_agent;
					last_rx <= i2c_from_agent;
					uart_tx_req <= 1'b1;
					state <= S_I2C_READ_URQ;
				end
			end
			S_I2C_READ_URQ:
			begin
				if(uart_tx_ready)
				begin
					uart_tx_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			S_I2C_HOST_ACK:
			begin
				if(uart_rx_ready)
				begin
					i2c_host_ack <= uart_rx_data[0];
					state <= S_IDLE;
				end
			end
			S_I2C_AGENT_ACK:
			begin
				uart_tx_data <= {7'h00, i2c_agent_ack};
				uart_tx_req <= 1'b1;
				if(uart_tx_ready)
				begin
					uart_tx_req <= 1'b0;
					state <= S_IDLE;
				end
			end
			
			default: ;
			endcase
		end
	end

endmodule
