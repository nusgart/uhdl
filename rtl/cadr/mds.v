// MDS
//
// TK		CADR	MEMORY DATA SELECTOR

module MDS(mds, mdsel, ob, memdrive, loadmd, busint_bus, md);

   input [31:0] busint_bus;
   input [31:0] md;
   input [31:0] ob;
   input	loadmd;
   input	mdsel;
   input	memdrive;
   output [31:0] mds;

   ////////////////////////////////////////////////////////////////////////////////

 wire [31:0] mem;

   assign mds = mdsel ? ob : mem;

   // mux MEM
   assign mem =
	       memdrive ? md :
	       loadmd ? busint_bus :
	       32'b0;

endmodule
