// VMEM1 --- VIRTUAL MEMORY MAP STAGE 1
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog; merge of VMEM0,
//   and VMEM1.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 06:50:02 TK) VMEM2: Initial.
//   (1978-02-03 00:13:26 TK) VMEM1: Initial.

`timescale 1ns/1ps
`default_nettype none

module VMEM1(/*AUTOARG*/
   // Outputs
   vmo,
   // Inputs
   clk, reset, mapi, vma, vmap, vm1rp, vm1wp
   );

   input clk;
   input reset;

   input [23:8] mapi;
   input [31:0] vma;
   input [4:0] vmap;
   input vm1rp;
   input vm1wp;
   output [23:0] vmo;

   ////////////////////////////////////////////////////////////////////////////////

   localparam ADDR_WIDTH = 10;
   localparam DATA_WIDTH = 24;
   localparam MEM_DEPTH = 1024;

   wire [9:0] vmem1_adr;

   ////////////////////////////////////////////////////////////////////////////////

   assign vmem1_adr = {vmap[4:0], mapi[12:8]};

`ifdef SIMULATION
   reg [23:0] ram [0:1023];
   reg [23:0] out_a;
   reg [23:0] out_b;

   assign vmo = out_a;


   always @(posedge clk)
     if (1'b0) begin
	ram[vmem1_adr] <= 24'b0;
     end
     else if (vm1wp) begin
	ram[vmem1_adr] <= vma[23:0];
     end

   always @(posedge clk)
     if (reset)
       out_a <= 0;
     else if (vm1rp && ~vm1wp) begin
	out_a <= ram[vmem1_adr];
     end

   always @(posedge clk)
     if (reset)
       out_b <= 0;
     else if (1'b0) begin
	out_b <= ram[vmem1_adr];
     end
`else
   wire ena_a = vm1rp && ~vm1wp | 1'b0;
   wire ena_b = 1'b0 | vm1wp;

   ise_VMEM1 inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(1'b0),
      .addra(vmem1_adr),
      .dina(24'b0),
      .douta(vmo),
      .clkb(clk),
      .enb(ena_b),
      .web(vm1wp),
      .addrb(vmem1_adr),
      .dinb(vma[23:0]),
      .doutb()
      /*AUTOINST*/);
`endif

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".." "../cores/xilinx")
// End:
