// IOR --- INST. MODIFY OR

module IOR(iob, i, ob);

   input [31:0] ob;
   input [48:0] i;
   output [47:0] iob;

   ////////////////////////////////////////////////////////////////////////////////

   assign iob = i[47:0] | {ob[21:0], ob[25:0]};

endmodule
