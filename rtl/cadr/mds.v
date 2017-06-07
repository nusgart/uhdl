module MDS (mds, mdsel, ob, memdrive, loadmd, busint_bus,md);

   input mdsel;
   input [31:0] ob;
   input	memdrive, loadmd;
   input [31:0] busint_bus;
   input [31:0] md;
   output [31:0] mds;

   wire [31:0]	 mem;

   assign mds = mdsel ? ob : mem;

   // mux MEM
   assign mem =
	       memdrive ? md :
	       loadmd ? busint_bus :
	       32'b0;

endmodule
