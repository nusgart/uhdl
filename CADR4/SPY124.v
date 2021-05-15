`timescale 1ns/1ps
`default_nettype none

module SPY124
  (input wire	      state_write,

   input wire [11:0]  bd_state_in,
   input wire [13:0]  opc,
   input wire [13:0]  pc,
   input wire [15:0]  scratch,
   input wire [31:0]  a,
   input wire [31:0]  m,
   input wire [31:0]  md,
   input wire [31:0]  ob,
   input wire [31:0]  vma,
   input wire [48:0]  ir,
   input wire [4:0]   disk_state_in,
   input wire	      boot,
   input wire	      dbread,
   input wire	      destspc,
   input wire	      err,
   input wire	      imod,
   input wire	      iwrited,
   input wire	      jcond,
   input wire	      nop,
   input wire	      pcs0,
   input wire	      pcs1,
   input wire	      pdlwrite,
   input wire	      promdisable,
   input wire	      spush,
   input wire	      spy_ah,
   input wire	      spy_al,
   input wire	      spy_bd,
   input wire	      spy_disk,
   input wire	      spy_flag1,
   input wire	      spy_flag2,
   input wire	      spy_irh,
   input wire	      spy_irl,
   input wire	      spy_irm,
   input wire	      spy_mdh,
   input wire	      spy_mdl,
   input wire	      spy_mh,
   input wire	      spy_ml,
   input wire	      spy_obh,
   input wire	      spy_obh_,
   input wire	      spy_obl,
   input wire	      spy_obl_,
   input wire	      spy_opc,
   input wire	      spy_pc,
   input wire	      spy_scratch,
   input wire	      spy_sth,
   input wire	      spy_stl,
   input wire	      spy_vmah,
   input wire	      spy_vmal,
   input wire	      srun,
   input wire	      ssdone,
   input wire	      stathalt,
   input wire	      vmaok,
   input wire	      waiting,
   input wire	      wmap,
   output wire [15:0] spy_out,

   input wire	      clk,
   input wire	      reset);

   reg [31:0]	      ob_last;
   wire [15:0]	      spy_mux;

   ////////////////////////////////////////////////////////////////////////////////

   // Grab OB from last cycle for Spy bus.
   always @(posedge clk)
     if (reset)
       ob_last <= 0;
     else if (state_write)
       ob_last <= ob;

   assign spy_out = dbread ? spy_mux : 16'b1111111111111111;
   assign spy_mux
     = spy_irh ? ir[47:32] :
       spy_irm ? ir[31:16] :
       spy_irl ? ir[15:0] :
       spy_obh ? ob_last[31:16] :
       spy_obl ? ob_last[15:0] :
       spy_obh_ ? ob[31:16] :
       spy_obl_ ? ob[15:0] :
       spy_disk ? {11'b0, disk_state_in} :
       spy_bd ? {4'b0, bd_state_in} :
       spy_ah ? a[31:16] :
       spy_al ? a[15:0] :
       spy_mh ? m[31:16] :
       spy_ml ? m[15:0] :
       spy_mdh ? md[31:16] :
       spy_mdl ? md[15:0] :
       spy_vmah ? vma[31:16] :
       spy_vmal ? vma[15:0] :
       spy_flag2 ? {2'b0, wmap, destspc, iwrited, imod, pdlwrite, spush, 2'b0, ir[48], nop, vmaok, jcond, pcs1, pcs0} :
       spy_opc ? {2'b0, opc} :
       spy_flag1 ? {waiting, 1'b0, boot, promdisable, stathalt, err, ssdone, srun, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0} :
       spy_pc ? {2'b0, pc} :
       spy_scratch ? scratch :
       16'b1111111111111111;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
