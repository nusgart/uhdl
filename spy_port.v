// spy_port.v --- UART interface into SPY0
//
// SPYTX<7-4>	= Operation
//		      0-1	Unused.
//		      2		Read content of spy register. [??? Is this used?]
//		      3		Set DATA<15-12>.
//		      4		Set DATA<11-8>.
//		      5		Set DATA<7-4>.
//		      6		Set DATA<3-0>.
//		      7		Unused.
//		      10	Read content of spy register.
//		      11	Read content of spy register.
//		      12	Write DATA into spy register.
//		      13	Write DATA into spy register.
//		      14	Read spy block-device register.
//		      15	Write DATA into spy block-device register.
//		      16-17	Unused.
// SPYTX<3-0>	= Data source.  When reading or writing the spy register
//		  (operations 10-13), this is the EADR signal used in SPY0.
//
// The response when reading (operation 10 and 11) will be split into
// four octets (same format when setting DATA):
//
// SPYRX<7-4>	= What part of the DATA register that was read:
//		      0-2	Unused.
//		      3		DATA<15-12>.
//		      4		DATA<11-8>.
//		      5		DATA<7-4>.
//		      6		DATA<3-0>.
//		      7-17	Unused.
// SPYRX<3-0>	= Data that was read.
//
// N.B., When communicating, err on the safe side by sending commands slowly,
//
// * Protocol for writing a value to a spy register.
//
//     DATA is data to write.  SPY is a spy register (see SPY0).
//
//	 1) Set DATA<15-12> by sending { DATA[15:12], 0x30 }.
//	 2) Set DATA<11-8> by sending { DATA[11:8], 0x40 }.
//	 3) Set DATA<7-4> by sending { DATA[7:4], 0x50 }.
//	 4) Set DATA<3-0> by sending { DATA[3:0], 0x60 }.
//	 5) Issue write command for the specified spy register:
//		{ SPY[3:0], 0xa0 }
//
// * Protocol for reading a value from a spy register.
//
//     DATA is data that has been read.  SPY is a spy register (see
//     SPY0).  The same response _maybe_ occur multiple times, so take
//     care to drop any duplicate octets.
//
//       1) Issue read command for the specified spy register by
//       sending:
//		{ SPY[3:0], 0x80 }
//       2) There response will be four octets:
//		{ DATA<15-12>, 0x3 }
//		{ DATA<11-8>, 0x4 }
//		{ DATA<7-4>, 0x5 }
//		{ DATA<3-0>, 0x6 }

`timescale 1ns/1ps
`default_nettype none

module spy_port
  (input wire [15:0] spy_in,
   input wire 	     rs232_rxd,
   output reg [15:0] spy_out,
   output reg [4:0]  eadr,
   output reg 	     dbread,
   output reg 	     dbwrite,
   output wire 	     rs232_txd,
   input wire 	     clk,
   input wire 	     reset);
   
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
   reg [2:0] tx_state;
   reg [3:0] spyu_state;
   reg [4:0] reg_addr;
   reg [7:0] rx_data;
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
   wire tx_start;


   ////////////////////////////////////////////////////////////////////////////////

   wire rx_enable = 1;
   wire rx_empty;
   wire tx_enable = 1;
   wire tx_empty;
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
		 .ld_tx_req		(ld_tx_req),
		 .rx_enable		(rx_enable),
		 .rx_req		(rx_req),
		 .tx_enable		(tx_enable),
		 .clk			(clk));

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

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	response <= 16'h0;
	// End of automatics
     end else begin
	if (dbread)
	  response <= spy_in;
	else if (start_bd_read)
	  response <= spy_bd_reg;
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
// verilog-library-directories: ("." "cores")
// End:
