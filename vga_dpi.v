// vga_dpi.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

module vga_dpi(/*AUTOARG*/
   // Inputs
   clk, vsync, hsync, r, g, b
   );

   input clk;

   input vsync;
   input hsync;
   input r;
   input g;
   input b;

   ////////////////////////////////////////////////////////////////////////////////

   import "DPI-C" function void vga_dpi_init(input int h,
					     input int v);
   import "DPI-C" function void vga_dpi_display(input int vsync,
						input int hsync,
						input int pixel);

   initial
     vga_dpi_init(1280, 1024);

   wire [31:0] pxd = { 24'b0,
		       r, r, r,
		       b, b,
		       g, g, g };

   always @(posedge clk)
     vga_dpi_display({31'b0, vsync}, {31'b0, hsync}, pxd);

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
