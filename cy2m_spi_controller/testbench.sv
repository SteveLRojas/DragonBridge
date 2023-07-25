`timescale 10ns/1ns
module testbench();

	//External signals
	reg clk;
	reg rst;
	reg[7:0] clk_div;
	reg cpol;
	reg cpha;
	reg transfer_req;
	reg[7:0] to_agent;
	
	wire sck;
	wire mosi;
	wire transfer_ready;
	wire transfer_done;
	wire[7:0] from_agent;
	
	reg[7:0] received_data;

	spi_master dut(
		.clk(clk),
		.rst(rst),

		.clk_div(clk_div),
		.cpol(cpol),
		.cpha(cpha),

		.sck(sck),
		.mosi(mosi),
		.miso(mosi),

		.transfer_req(transfer_req),
		.transfer_ready(transfer_ready),
		.transfer_done(transfer_done),
		.to_agent(to_agent),
		.from_agent(from_agent));

	always @(posedge clk)
	begin
		if(rst)
		begin
			to_agent <= 8'h00;
			received_data <= 8'h00;
		end
		else
		begin
			if(transfer_ready & transfer_req)
				to_agent <= to_agent + 8'h01;
			if(transfer_done)
				received_data <= from_agent;
		end
	end

	always
	begin: CLOCK_GENERATION
		#1 clk =  ~clk;
	end

	initial
	begin: CLOCK_INITIALIZATION
		clk = 0;
	end

	initial
	begin: TEST_VECTORS
		//initial conditions
		rst = 1'b1;
		clk_div = 8'h0F;
		cpol = 1'b0;
		cpha = 1'b0;
		transfer_req = 1'b0;
		
		// test spi mode 0
		#20 rst = 1'b0;	//release reset
		#20 transfer_req = 1'b1;
		#2000 transfer_req = 1'b0;
		//test spi mode 1
		#100 cpha = 1'b1;
		#20 transfer_req = 1'b1;
		#2000 transfer_req = 1'b0;
		//test spi mode 2
		#100 cpha = 1'b0;
		#20 cpol = 1'b1;
		#20 transfer_req = 1'b1;
		#2000 transfer_req = 1'b0;
		//test spi mode 3
		#100 cpha = 1'b1;
		#20 transfer_req = 1'b1;
		#2000 transfer_req = 1'b0;
	end
endmodule
