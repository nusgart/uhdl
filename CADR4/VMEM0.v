// VMEM0 --- VIRTUAL MEMORY MAP STAGE 0
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-22 11:29:05 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VMEM0(/*AUTOARG*/
   // Outputs
   vmap,
   // Inputs
   clk, reset, mapi, vma, memstart, srcmap, vm0rp, vm0wp
   );

   input clk;
   input reset;

   input [23:8] mapi;
   input [31:0] vma;
   input memstart;
   input srcmap;
   input vm0rp;
   input vm0wp;
   output [4:0] vmap;

   ////////////////////////////////////////////////////////////////////////////////

   localparam ADDR_WIDTH = 11;
   localparam DATA_WIDTH = 5;
   localparam MEM_DEPTH = 2048;

   wire [10:0] vmem0_adr;
   wire use_map;

   ////////////////////////////////////////////////////////////////////////////////

   assign vmem0_adr = mapi[23:13];

`ifdef SIMULATION
   reg [4:0] ram [0:2047];
   reg [4:0] out_a;
   reg [4:0] out_b;

   assign vmap = out_a;


   always @(posedge clk)
     if (1'b0) begin
	ram[vmem0_adr] <= 5'b0;
     end else if (vm0wp) begin
	ram[vmem0_adr] <= vma[31:27];
     end

   always @(posedge clk)
     if (reset)
       out_a <= 0;
     else if (vm0rp && ~vm0wp) begin
	out_a <= ram[vmem0_adr];
     end

   always @(posedge clk)
     if (reset)
       out_b <= 0;
     else if (1'b0) begin
	out_b <= ram[vmem0_adr];
     end
`else
   wire ena_a = vm0rp && ~vm0wp | 1'b0;
   wire ena_b = 1'b0 | vm0wp;

   ise_VMEM0 inst
     (
      .clka(clk),
      .ena(ena_a),
      .wea(1'b0),
      .addra(vmem0_adr),
      .dina(5'b0),
      .douta(vmap),
      .clkb(clk),
      .enb(ena_b),
      .web(vm0wp),
      .addrb(vmem0_adr),
      .dinb(vma[31:27]),
      .doutb()
      /*AUTOINST*/);
`endif

   assign use_map = srcmap | memstart;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".." "../cores/xilinx")
// End:
