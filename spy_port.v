// spy_port.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module spy_port(/*AUTOARG*/
   // Outputs
   spy_out, eadr, dbread, dbwrite, rs232_txd,
   // Inputs
   spy_in, clk, reset, rs232_rxd, sysclk
   );

   input [15:0] spy_in;
   input clk;
   input reset;
   input rs232_rxd;
   input sysclk;
   output [15:0] spy_out;
   output [4:0] eadr;
   output dbread;
   output dbwrite;
   output rs232_txd;

   ////////////////////////////////////////////////////////////////////////////////

   parameter SPYU_IDLE = 4'd0,
     SPYU_RX1 = 4'd1,
     SPYU_RX2 = 4'd2,
     SPYU_OP = 4'd3,
     SPYU_OPR = 4'd4,
     SPYU_OPW1 = 4'd5,
     SPYU_OPW2 = 4'd6,
     SPYU_TX1 = 4'd7,
     SPYU_TX2 = 4'd8,
     SPYU_TX3 = 4'd9,
     SPYU_TX4 = 4'd10,
     SPYU_TX5 = 4'd11,
     SPYU_TX6 = 4'd12,
     SPYU_TX7 = 4'd13,
     SPYU_TX8 = 4'd14;

   reg [15:0] data;
   reg [15:0] response;
   reg [15:0] spy_bd_reg, spy_bd_data;
   reg [15:0] spy_out;
   reg [2:0] tx_state;
   reg [3:0] spyu_state;
   reg [4:0] eadr;
   reg [4:0] reg_addr;
   reg [7:0] rx_data;
   reg dbread;
   reg dbwrite;
   reg respond;

   wire [2:0] tx_next_state;
   wire [3:0] spyu_next_state;
   wire [7:0] rx_out;
   wire [7:0] tx_data;
   wire ld_tx_req, ld_tx_ack;

   wire rx_req, rx_ack;
   wire start_bd_read;
   wire start_bd_write;
   wire start_read;
   wire start_write;
   wire tx_delay_done;
   wire tx_done;
   wire tx_enable, tx_empty;
   wire tx_start;
   wire rs232_txd;
   
   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   wire rx_enable = 1;
   wire rx_empty;
   uart spy_uart(.reset(reset),
		 .tx_out(rs232_txd),
		 .rx_data(rx_out),
		 .rx_in(rs232_rxd),
		 /*AUTOINST*/
		 // Outputs
		 .ld_tx_ack		(ld_tx_ack),
		 .rx_ack		(rx_ack),
		 .rx_empty		(rx_empty),
		 .tx_empty		(tx_empty),
		 // Inputs
		 .tx_data		(tx_data[7:0]),
		 .clk			(clk),
		 .ld_tx_req		(ld_tx_req),
		 .rx_enable		(rx_enable),
		 .rx_req		(rx_req),
		 .tx_enable		(tx_enable));

   assign spyu_next_state =
			   (spyu_state == SPYU_IDLE && ~rx_empty) ? SPYU_RX1 :
			   (spyu_state == SPYU_IDLE && respond) ? SPYU_TX1 :
			   (spyu_state == SPYU_RX1 && rx_ack) ? SPYU_RX2 :
			   (spyu_state == SPYU_RX2 && ~rx_ack) ? SPYU_OP :
			   (spyu_state == SPYU_OP && start_read) ? SPYU_OPR:
			   (spyu_state == SPYU_OP && start_write) ? SPYU_OPW1 :
			   (spyu_state == SPYU_OP) ? SPYU_IDLE :
			   (spyu_state == SPYU_OPR) ? SPYU_IDLE :
			   (spyu_state == SPYU_OPW1) ? SPYU_OPW2 :
			   (spyu_state == SPYU_OPW2) ? SPYU_IDLE :
			   (spyu_state == SPYU_TX1) ? SPYU_TX2 :
			   (spyu_state == SPYU_TX2 && tx_done) ? SPYU_TX3 :
			   (spyu_state == SPYU_TX3) ? SPYU_TX4 :
			   (spyu_state == SPYU_TX4 && tx_done) ? SPYU_TX5 :
			   (spyu_state == SPYU_TX5) ? SPYU_TX6 :
			   (spyu_state == SPYU_TX6 && tx_done) ? SPYU_TX7 :
			   (spyu_state == SPYU_TX7) ? SPYU_TX8 :
			   (spyu_state == SPYU_TX8 && tx_done) ? SPYU_IDLE :
			   spyu_state;

   always @(posedge clk)
     if (reset) begin
	spyu_state <= 0;
     end else
       spyu_state <= spyu_next_state;

   assign start_read = (spyu_state == SPYU_OP) && ((rx_data[7:4] == 8) || (rx_data[7:4] == 9) || (rx_data[7:4] == 2));
   assign start_write = (spyu_state == SPYU_OP) && ((rx_data[7:4] == 4'ha) || (rx_data[7:4] == 4'hb));
   assign rx_req = spyu_state == SPYU_RX1;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rx_data <= 8'h0;
	// End of automatics
     end else if (rx_req)
       rx_data <= rx_out;

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	data <= 16'h0;
	reg_addr <= 5'h0;
	// End of automatics
     end else if (spyu_state == SPYU_RX2) begin
	case (rx_data[7:4])
	  4'h0: ;
	  4'h1: ;
	  4'h2: ;
	  4'h3: data[15:12] <= rx_data[3:0];
	  4'h4: data[11:8] <= rx_data[3:0];
	  4'h5: data[7:4] <= rx_data[3:0];
	  4'h6: data[3:0] <= rx_data[3:0];
	  4'h7: ;
	  4'h8: reg_addr <= rx_data[4:0];
	  4'h9: reg_addr <= rx_data[4:0];
	  4'ha: reg_addr <= rx_data[4:0];
	  4'hb: reg_addr <= rx_data[4:0];
	  4'hc: ;
	  4'hd: ;
	  4'he: ;
	  4'hf: ;
	endcase
     end

   always @(negedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dbwrite <= 1'h0;
	// End of automatics
     end else begin
	dbwrite <= (spyu_state == SPYU_OPW1);
     end

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dbread <= 1'h0;
	eadr <= 5'h0;
	respond <= 1'h0;
	spy_out <= 16'h0;
	// End of automatics
     end else begin
	dbread <= start_read || (spyu_state == SPYU_OPR);
	if (start_write)
	  spy_out <= data;
	if (start_read || start_write)
	  eadr <= reg_addr;
	respond <= dbread;
     end

   assign tx_start =
		    (spyu_state == SPYU_TX1) ||
		    (spyu_state == SPYU_TX3) ||
		    (spyu_state == SPYU_TX5) ||
		    (spyu_state == SPYU_TX7);
   assign tx_data =
		   (spyu_state == SPYU_TX1 || spyu_state == SPYU_TX2 ) ? { 4'h3, response[15:12] } :
		   (spyu_state == SPYU_TX3 || spyu_state == SPYU_TX4 ) ? { 4'h4, response[11: 8] } :
		   (spyu_state == SPYU_TX5 || spyu_state == SPYU_TX6 ) ? { 4'h5, response[ 7: 4] } :
		   (spyu_state == SPYU_TX7 || spyu_state == SPYU_TX8 ) ? { 4'h6, response[ 3: 0] } :
		   8'h00;
   assign ld_tx_req = tx_state == 1;
   assign tx_done = tx_state == 7;
   assign tx_delay_done = 1;
   assign tx_next_state =
			 (tx_state == 0 && tx_start) ? 3'd1 :
			 (tx_state == 1 && ld_tx_ack) ? 3'd2 :
			 (tx_state == 2 && ~ld_tx_ack) ? 3'd3 :
			 (tx_state == 3) ? 3'd4 :
			 (tx_state == 4 && tx_empty) ? 3'd5 :
			 (tx_state == 5) ? 3'd6 :
			 (tx_state == 6 && tx_delay_done) ? 3'd7 :
			 (tx_state == 7) ? 3'd0 :
			 tx_state;

   always @(posedge clk)
     if (reset)
       tx_state <= 0;
     else
       tx_state <= tx_next_state;

   assign start_bd_read = (spyu_state == SPYU_OP) && (rx_data[7:4] == 4'hc);
   assign start_bd_write = (spyu_state == SPYU_OP) && (rx_data[7:4] == 4'hd);

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	spy_bd_reg <= 16'h0;
	// End of automatics
     end else begin
	if (start_bd_write)
	  spy_bd_reg <= data;
	else
	  spy_bd_reg[2] <= 0;
     end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
