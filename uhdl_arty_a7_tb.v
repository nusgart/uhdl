`timescale 1ns/1ns
`default_nettype none

// ISIM: wave add /

`define VCDFILE "uhdl_arty_a7.vcd"

module uhdl_arty_a7_tb;

   reg rs232_rxd;
   reg sysclk;
   reg ps2_clk;
   reg ps2_data;
   wire kb_ps2_clk;
   wire kb_ps2_data;
   reg switch;
   wire rs232_txd;
   wire [4:0] led;
   // vga
   wire vga_out;
   wire vga_hsync;
   wire vga_vsync;
   wire vga_r;
   wire vga_g;
   wire vga_b;
   
   wire [15:0] ddr3_dq;
   wire [1:0] ddr3_dm;
   wire [1:0] ddr3_dqs_p;
   wire [1:0] ddr3_dqs_n;
   wire [13:0] ddr3_addr;
   wire [2:0] ddr3_ba;
   wire ddr3_ck_p; 
   wire ddr3_ck_n;
   wire ddr3_cs_n;
   wire ddr3_cas_n;
   wire ddr3_ras_n;
   wire ddr3_cke;
   wire ddr3_odt;
   wire ddr3_reset_n;
   wire ddr3_we_n;
   
   /// mmc
   wire mmc_cs;
   wire mmc_do;
   wire mmc_sclk;
   wire mmc_di;
   

   uhdl_arty_a7 DUT(
		.ms_ps2_clk(),
		.ms_ps2_data(),
		/*AUTOINST*/
		
		// Outputs
		.rs232_txd		(rs232_txd),
		.led			(led[3:0]),
		.vga_hsync		(vga_hsync),
		.vga_vsync		(vga_vsync),
		.vga_r			(vga_r),
		.vga_g			(vga_g),
		.vga_b			(vga_b),
		.mmc_cs			(mmc_cs),
		.mmc_do			(mmc_do),
		.mmc_sclk		(mmc_sclk),
		
		////
		.ddr3_dq(ddr3_dq), 
		.ddr3_dm(ddr3_dm),
		.ddr3_dqs_p(ddr3_dqs_p),
		.ddr3_dqs_n(ddr3_dqs_n),
		.ddr3_addr(ddr3_addr),
		.ddr3_ba(ddr3_ba),
		.ddr3_ck_p(ddr3_ck_p),
		.ddr3_ck_n(ddr3_ck_n),
		.ddr3_cs_n(ddr3_cs_n),
		.ddr3_cas_n(ddr3_cas_n),
		.ddr3_ras_n(ddr3_ras_n),
		.ddr3_cke(ddr3_cke),
		.ddr3_odt(ddr3_odt),
		.ddr3_reset_n(ddr3_reset_n),
		.ddr3_we_n(ddr3_we_n),
		
		// Inputs
		.rs232_rxd		(rs232_rxd),
		.sysclk			(sysclk),
		.kb_ps2_clk		(kb_ps2_clk),
		.kb_ps2_data		(kb_ps2_data),
		.mmc_di			(mmc_di),
		.switch			(switch));

   lpddr_model_c3 u_mem3(
			 .Dq(ddr3_dq),
			 .Dqs(ddr3_dqs_p),
			 .Addr(ddr3_addr),
			 .Ba(ddr3_ba),
			 .Clk(ddr3_ck_p),
			 .Clk_n(ddr3_ck_n),
			 .Cke(ddr3_cke),
			 .Cs_n(ddr3_cs_n),
			 .Ras_n(ddr3_ras_n),
			 .Cas_n(ddr3_cas_n),
			 .We_n(ddr3_we_n),
			 .Dm(ddr3_dm)
			 );

   //PULLDOWN rzq_pulldown(.O(mcb3_rzq));

   initial begin
      rs232_rxd = 0;
      sysclk = 0;
      ps2_clk = 0;
      ps2_data = 0;
      switch = 0;
   end

   initial begin
      $timeformat(-9, 0, "ns", 7);
      $dumpfile(`VCDFILE);
      $dumpvars(0, uhdl_arty_a7_tb);
   end

   initial begin
      #100000000; $finish;
   end

   always begin
      #10 sysclk = 0;
      #10 sysclk = 1;
   end

   mmc_model mmc_card(
		      .spiClk(mmc_sclk),
		      .spiDataIn(mmc_do),
		      .spiDataOut(mmc_di),
		      .spiCS_n(mmc_cs)
		      );

   integer cycles, faults;

   initial begin
      cycles = 0;
      faults = 0;
   end

   always @(posedge DUT.lm3.cpu.clk) begin
      if (DUT.lm3.cpu.state == 6'b000001)
	cycles = cycles + 1;

      if (DUT.lm3.cpu.state == 6'b000001)
	$display("%0o %o A=%x M=%x N%b MD=%x LC=%x",
		 DUT.lm3.cpu.cadr_lpc.lpc, DUT.lm3.cpu.ir, DUT.lm3.cpu.a, DUT.lm3.cpu.m, DUT.lm3.cpu.n, DUT.lm3.cpu.md, DUT.lm3.cpu.lc);

      if (DUT.lm3.cpu.cadr_lpc.lpc == 14'o26) begin
	 faults = faults + 1;
	 if (faults > 5) begin
	    $display("=== fault ===");
	    $finish;
	 end
      end
   end

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
