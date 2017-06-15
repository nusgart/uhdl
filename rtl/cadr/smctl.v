// SMCTL
//
// TK	CONS	SHIFT/MASK CONTROL

module SMCTL(mskr, s0, s1, s2, s3, s4, sh3, sh4, mskl, irbyte, ir);

   input [48:0] ir;
   input	irbyte;
   input	sh3;
   input	sh4;
   output [4:0] mskl;
   output [4:0] mskr;
   output	s0;
   output	s1;
   output	s2;
   output	s3;
   output	s4;

   ////////////////////////////////////////////////////////////////////////////////

   wire		mr;
   wire		sr;

   assign mr = ~irbyte | ir[13];
   assign sr = ~irbyte | ir[12];

   assign mskr[4] = mr & sh4;
   assign mskr[3] = mr & sh3;
   assign mskr[2] = mr & ir[2];
   assign mskr[1] = mr & ir[1];
   assign mskr[0] = mr & ir[0];

   assign s4 = sr & sh4;
   assign s3 = sr & sh3;
   assign s2 = sr & ir[2];
   assign s1 = sr & ir[1];
   assign s0 = sr & ir[0];

   assign mskl = mskr + ir[9:5];

endmodule
