`define sim_ns

`define debug
`define DBG_DLY #0
`define SIMULATION

`define mmc_model

`ifdef sim_ns
 `timescale 1ns / 1ns
`endif

`ifdef sim_ps
`endif

module run_top;

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

   top uut(
           .usb_txd(rs232_txd),
           .usb_rxd(rs232_rxd),
           .sysclk(sysclk),
           .led(led),
           .switch(switch),
           .ps2_clk(ps2_clk),
           .ps2_data(ps2_data),
           .ms_ps2_clk(),
           .ms_ps2_data(),
           .vga_hsync(vga_hsync),
           .vga_vsync(vga_vsync),
           .vga_r(vga_r),
           .vga_g(vga_g),
           .vga_b(vga_b),
           .mmc_cs(mmc_cs),
           .mmc_di(mmc_di),
           .mmc_do(mmc_do),
           .mmc_sclk(mmc_sclk),

           .mcb3_dram_dq(mcb3_dram_dq),
           .mcb3_dram_a(mcb3_dram_a),
           .mcb3_dram_ba(mcb3_dram_ba),
           .mcb3_dram_cke(mcb3_dram_cke),
           .mcb3_dram_ras_n(mcb3_dram_ras_n),
           .mcb3_dram_cas_n(mcb3_dram_cas_n),
           .mcb3_dram_we_n(mcb3_dram_we_n),
           .mcb3_dram_dm(mcb3_dram_dm),
           .mcb3_dram_udqs(mcb3_dram_udqs),
           .mcb3_rzq(mcb3_rzq),
           .mcb3_dram_udm(mcb3_dram_udm),
           .mcb3_dram_dqs(mcb3_dram_dqs),
           .mcb3_dram_ck(mcb3_dram_ck),
           .mcb3_dram_ck_n(mcb3_dram_ck_n)
           );

`ifdef lpddr_model
   lpddr_model_c3 u_mem3(
                         .Dq(mcb3_dram_dq),
                         .Dqs({mcb3_dram_udqs,mcb3_dram_dqs}),
                         .Addr(mcb3_dram_a),
                         .Ba(mcb3_dram_ba),
                         .Clk(mcb3_dram_ck),
                         .Clk_n(mcb3_dram_ck_n),
                         .Cke(mcb3_dram_cke),
                         .Cs_n(1'b0),
                         .Ras_n(mcb3_dram_ras_n),
                         .Cas_n(mcb3_dram_cas_n),
                         .We_n(mcb3_dram_we_n),
                         .Dm({mcb3_dram_udm,mcb3_dram_dm})
                         );

   PULLDOWN rzq_pulldown(.O(mcb3_rzq));
`endif

   initial begin
      rs232_rxd = 0;
      sysclk = 0;
      ps2_clk = 0;
      ps2_data = 0;
      switch = 0;
   end

`ifdef waves
   initial
     begin
        $timeformat(-9, 0, "ns", 7);
        $dumpfile("run_top_lx45_test.vcd");
        $dumpvars(0, run_top);
     end
`endif

`ifdef sim_finish
   initial
     begin
        #100000000; $finish;
     end
`endif

`ifdef sim_ps
   always
     begin
        #10000 sysclk = 0;
        #10000 sysclk = 1;
     end
`endif

`ifdef sim_ns
   always
     begin
        #10 sysclk = 0;
        #10 sysclk = 1;
     end
`endif

`ifdef mmc_pli
   always @(posedge sysclk)
     begin
        $pli_mmc(mmc_cs, mmc_sclk, mmc_di, mmc_do);
     end
`endif

`ifdef mmc_model
   mmc_model mmc_card(
                      .spiClk(mmc_sclk),
                      .spiDataIn(mmc_do),
                      .spiDataOut(mmc_di),
                      .spiCS_n(mmc_cs)
                      );
`endif

   integer cycles, faults;

   initial
     begin
        cycles = 0;
        faults = 0;
     end

   always @(posedge uut.cpu.clk)
     begin
        if (uut.cpu.state == 6'b000001)
          cycles = cycles + 1;

        if (uut.cpu.state == 6'b000001)
          $display("%0o %o A=%x M=%x N%b MD=%x LC=%x",
                   uut.cpu.cadr_lpc.lpc, uut.cpu.ir, uut.cpu.a, uut.cpu.m, uut.cpu.n, uut.cpu.md, uut.cpu.lc);

        if (uut.cpu.cadr_lpc.lpc == 14'o26)
          begin
             faults = faults + 1;

             if (faults > 5)
               begin
                  $display("=== fault ===");
                  $finish;
               end
          end
     end

endmodule
