module uart_gen2
	#(
		parameter ENABLE_SYNC = 1'b1,
		parameter ENABLE_FILTER = 1'b0,
		parameter ENABLE_DESKEW = 1'b0
	)
	(
		input wire clk,
		input wire rst,
		input wire[15:0] clk_div,
		input wire tx_req,
		input wire[7:0] tx_data,
		input wire rx,
		output wire tx,
		output wire[7:0] rx_data,
		output reg tx_ready,
		output reg rx_ready
	);
	
	wire rx_sync;
	wire rx_filt;
	wire rx_deskew;
	wire rx_edge;
	
	generate
		if(ENABLE_SYNC)
		begin: generate_sync
			reg rx_s;
			reg rx_s2;
			
			always @(posedge clk or posedge rst)
			begin
				if(rst)
				begin
					rx_s <= 1'b0;
					rx_s2 <= 1'b0;
				end
				else
				begin
					rx_s <= ~rx;
					rx_s2 <= rx_s;
				end
			end
			assign rx_sync = rx_s2;
		end
		else
		begin: generate_no_sync
			assign rx_sync = ~rx;
		end
		
		if(ENABLE_FILTER)
		begin: generate_filter
			reg[1:0] rx_filt_count;
			reg rx_filt_ff;
			
			always @(posedge clk or posedge rst)
			begin
				if(rst)
				begin
					rx_filt_count <= 2'b00;
					rx_filt_ff <= 1'b0;
				end
				else
				begin
					if((rx_sync & ~&rx_filt_count) | (~rx_sync & |rx_filt_count))
						rx_filt_count <= rx_filt_count + {~rx_sync, 1'b1};
					rx_filt_ff <= &rx_filt_count | (rx_filt_ff & |rx_filt_count);
				end
			end
			assign rx_filt = rx_filt_ff;
		end
		else
		begin: generate_no_filter
			assign rx_filt = rx_sync;
		end
		
		if(ENABLE_DESKEW)
		begin: generate_deskew
			reg rx_deskew1_ff;
			reg rx_deskew2_ff;
			
			always @(posedge clk or posedge rst)
			begin
				if(rst)
				begin
					rx_deskew1_ff <= 1'b0;
					rx_deskew2_ff <= 1'b0;
				end
				else
				begin
					rx_deskew1_ff <= rx_filt;
					rx_deskew2_ff <= rx_deskew1_ff;
				end
			end
			assign rx_deskew = rx_deskew2_ff;
			assign rx_edge = rx_filt & ~rx_deskew1_ff;
		end
		else
		begin: generate_no_deskew
			reg prev_rx_filt;
			
			always @(posedge clk or posedge rst)
			begin
				if(rst)
					prev_rx_filt <= 1'b0;
				else
					prev_rx_filt <= rx_filt;
			end
			assign rx_deskew = rx_filt;
			assign rx_edge = rx_filt & ~prev_rx_filt;
		end
	endgenerate

	reg[15:0] rx_timer;
	reg[7:0] rx_frame;
	reg rx_active;
	reg[15:0] tx_timer;
	reg[9:0] tx_frame;
	reg tx_active;
	reg prev_tx_req;
	wire rx_time;
	wire tx_time;
	wire rx_last_sample;
	wire tx_frame_nz;
	wire tx_last_shift;
	wire tx_req_edge;

	assign tx_time = (tx_timer == clk_div);
	assign rx_time = (rx_timer == clk_div);
	assign rx_last_sample = ~rx_frame[0] & rx_active & rx_time;
	assign tx_frame_nz = |tx_frame[9:1];
	assign tx_last_shift = ~tx_frame_nz & tx_time;
	assign tx_req_edge = tx_req & ~prev_tx_req;
	
	assign tx = tx_frame[0];
	assign rx_data = rx_frame;

	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			tx_ready <= 1'b0;
			rx_ready <= 1'b0;
			rx_timer <= 16'h0000;
			rx_frame <= 8'h00;
			rx_active <= 1'b0;
			tx_timer <= 16'h0000;
			tx_frame <= 10'h001;
			tx_active <= 1'b0;
			prev_tx_req <= 1'b0;
		end
		else
		begin
			prev_tx_req <= tx_req;
			rx_ready <= rx_last_sample;
			tx_ready <= tx_last_shift;
			
			if(rx_active)
				rx_timer <= (rx_timer + 16'h01) & {16{~rx_time}};
			else
				rx_timer <= {1'b0, clk_div[15:1]};	//half period
				
			if((rx_active & rx_time) | (rx_edge & ~rx_active))
				rx_frame <= {~rx_deskew, rx_frame[7:1]} | {8{~rx_active}};
			
			if(rx_edge | rx_last_sample)
				rx_active <= rx_edge;
				
			tx_timer <= (tx_timer + 16'h01) & {16{tx_active & ~tx_time}};
			
			if((tx_time & tx_frame_nz) | ~tx_active)
				tx_frame <= tx_active ? {1'b0, tx_frame[9:1]} : {1'b1, tx_data, ~tx_req_edge};
			
			if(tx_req_edge | tx_last_shift)
				tx_active <= tx_req_edge;
		end
	end

endmodule
