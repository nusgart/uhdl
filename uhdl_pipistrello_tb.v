`timescale 1ns/1ns
`default_nettype none

// ISIM: wave add /

`ifndef VCDFILE
 `define VCDFILE "uhdl_pipistrello_tb.vcd"
`endif

module uhdl_pipistrello_tb;

   reg rs232_rxd;
   reg sysclk;
   reg ps2_clk;
   reg ps2_data;
   reg switch;
   wire rs232_txd;
   wire [4:0] led;
   wire vga_out;
   wire vga_hsync;
   wire vga_vsync;
   wire vga_r;
   wire vga_g;
   wire vga_b;
   wire [15:0] mcb3_dram_dq;
   wire [12:0] mcb3_dram_a;
   wire [1:0] mcb3_dram_ba;
   wire mcb3_dram_cke;
   wire mcb3_dram_ras_n;
   wire mcb3_dram_cas_n;
   wire mcb3_dram_we_n;
   wire mcb3_dram_dm;
   wire mcb3_dram_udqs;
   wire mcb3_rzq;
   wire mcb3_dram_udm;
   wire mcb3_dram_dqs;
   wire mcb3_dram_ck;
   wire mcb3_dram_ck_n;

   uhdl_pipistrello DUT(
			.ms_ps2_clk(),
			.ms_ps2_data(),
			/*AUTOINST*/
			// Outputs
			.rs232_txd	(rs232_txd),
			.led		(led[3:0]),
			.vga_hsync	(vga_hsync),
			.vga_vsync	(vga_vsync),
			.vga_r		(vga_r),
			.vga_g		(vga_g),
			.vga_b		(vga_b),
			.mmc_cs		(mmc_cs),
			.mmc_do		(mmc_do),
			.mmc_sclk	(mmc_sclk),
			.mcb3_dram_a	(mcb3_dram_a[12:0]),
			.mcb3_dram_ba	(mcb3_dram_ba[1:0]),
			.mcb3_dram_cke	(mcb3_dram_cke),
			.mcb3_dram_ras_n(mcb3_dram_ras_n),
			.mcb3_dram_cas_n(mcb3_dram_cas_n),
			.mcb3_dram_we_n	(mcb3_dram_we_n),
			.mcb3_dram_dm	(mcb3_dram_dm),
			.mcb3_dram_reset_n(mcb3_dram_reset_n),
			.mcb3_dram_udm	(mcb3_dram_udm),
			.mcb3_dram_ck	(mcb3_dram_ck),
			.mcb3_dram_ck_n	(mcb3_dram_ck_n),
			// Inouts
			.mcb3_dram_dq	(mcb3_dram_dq[15:0]),
			.mcb3_dram_dqs_n(mcb3_dram_dqs_n[1:0]),
			.mcb3_rzq	(mcb3_rzq),
			.mcb3_dram_dqs	(mcb3_dram_dqs[1:0]),
			// Inputs
			.rs232_rxd	(rs232_rxd),
			.sysclk		(sysclk),
			.kb_ps2_clk	(kb_ps2_clk),
			.kb_ps2_data	(kb_ps2_data),
			.mmc_di		(mmc_di),
			.switch		(switch));

   lpddr_model_c3 u_mem3(
			 .Dq(mcb3_dram_dq),
			 .Dqs({mcb3_dram_udqs, mcb3_dram_dqs}),
			 .Addr(mcb3_dram_a),
			 .Ba(mcb3_dram_ba),
			 .Clk(mcb3_dram_ck),
			 .Clk_n(mcb3_dram_ck_n),
			 .Cke(mcb3_dram_cke),
			 .Cs_n(1'b0),
			 .Ras_n(mcb3_dram_ras_n),
			 .Cas_n(mcb3_dram_cas_n),
			 .We_n(mcb3_dram_we_n),
			 .Dm({mcb3_dram_udm, mcb3_dram_dm})
			 );

   PULLDOWN rzq_pulldown(.O(mcb3_rzq));

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
      $dumpvars(0, uhdl_pipistrello_tb);
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

   always @(posedge DUT.uhdl_common.cpu.clk) begin
      if (DUT.uhdl_common.cpu.state == 6'b000001)
	cycles = cycles + 1;

      if (DUT.uhdl_common.cpu.state == 6'b000001)
	$display("%0o %o A=%x M=%x N%b MD=%x LC=%x",
		 DUT.uhdl_common.cpu.cadr_lpc.lpc, DUT.uhdl_common.cpu.ir, DUT.uhdl_common.cpu.a, DUT.uhdl_common.cpu.m, DUT.uhdl_common.cpu.n, DUT.uhdl_common.cpu.md, DUT.uhdl_common.cpu.lc);

      if (DUT.uhdl_common.cpu.cadr_lpc.lpc == 14'o26) begin
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
