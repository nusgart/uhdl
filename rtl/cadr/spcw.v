// SPCW
//
// TK CADR SPC WRITE DATA SEL

module SPCW(destspc, l, spcw, n, wpc, ipc);

   input [13:0] ipc;
   input [13:0] wpc;
   input [31:0] l;
   input destspc;
   input n;
   output [18:0] spcw;

   ////////////////////////////////////////////////////////////////////////////////

   wire [13:0] reta;

   ////////////////////////////////////////////////////////////////////////////////

   assign spcw = destspc ? l[18:0] : {5'b0, reta};
   assign reta = n ? wpc : ipc;

endmodule
