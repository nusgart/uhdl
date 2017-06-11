module ALU01(aeqm_bits, a, m, aluf, alumode, aeqm, alu, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n, cin4_n, cin8_n, cin0, xout11, xout15, xout19, xout23, xout27, xout3, xout31, xout7, yout11, yout15, yout19, yout23, yout27, yout3, yout31, yout7);

   input [31:0] a;
   input [31:0] m;
   input [3:0] 	aluf;
   output [7:0] aeqm_bits;
   output [32:0] alu;
   output	 aeqm;
   output	 alumode;
   output	 cin0;
   output	 cin12_n;
   output	 cin16_n;
   output	 cin20_n;
   output	 cin24_n;
   output	 cin28_n;
   output	 cin32_n;
   output	 cin4_n;
   output	 cin8_n;
   output	 xout11;
   output	 xout15;
   output	 xout19;
   output	 xout23;
   output	 xout27;
   output	 xout31;
   output	 xout3;
   output	 xout7;
   output	 yout11;
   output	 yout15;
   output	 yout19;
   output	 yout23;
   output	 yout27;
   output	 yout31;
   output	 yout3;
   output	 yout7;

   ////////////////////////////////////////////////////////////////////////////////

   wire [2:0]	 nc_alu;

   // 74181 pulls down AEB if not equal
   // aeqm is the simulated open collector
   assign aeqm = aeqm_bits == { 8'b11111111 } ? 1'b1 : 1'b0;
   //  always @(posedge clk)
   //     if (reset)
   //       aeqm <= 0;
   //     else
   //       aeqm <= aeqm_bits == { 8'b11111111 } ? 1'b1 : 1'b0;

   ic_74S181  i_ALU1_2A03 (
			   .B({3'b0,a[31]}),
			   .A({3'b0,m[31]}),
			   .S(aluf[3:0]),
			   .CIN_N(cin32_n),
			   .M(alumode),
			   .F({nc_alu,alu[32]}),
			   .X(),
			   .Y(),
			   .COUT_N(),
			   .AEB()
			   );

   ic_74S181  i_ALU1_2A08 (
			   .B(a[31:28]),
			   .A(m[31:28]),
			   .S(aluf[3:0]),
			   .CIN_N(cin28_n),
			   .M(alumode),
			   .F(alu[31:28]),
			   .AEB(aeqm_bits[7]),
			   .X(xout31),
			   .Y(yout31),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2B08 (
			   .B(a[27:24]),
			   .A(m[27:24]),
			   .S(aluf[3:0]),
			   .CIN_N(cin24_n),
			   .M(alumode),
			   .F(alu[27:24]),
			   .AEB(aeqm_bits[6]),
			   .X(xout27),
			   .Y(yout27),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2A13 (
			   .B(a[23:20]),
			   .A(m[23:20]),
			   .S(aluf[3:0]),
			   .CIN_N(cin20_n),
			   .M(alumode),
			   .F(alu[23:20]),
			   .AEB(aeqm_bits[5]),
			   .X(xout23),
			   .Y(yout23),
			   .COUT_N()
			   );

   ic_74S181  i_ALU1_2B13 (
			   .B(a[19:16]),
			   .A(m[19:16]),
			   .S(aluf[3:0]),
			   .CIN_N(cin16_n),
			   .M(alumode),
			   .F(alu[19:16]),
			   .AEB(aeqm_bits[4]),
			   .X(xout19),
			   .Y(yout19),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2A23 (
			   .A(m[15:12]),
			   .B(a[15:12]),
			   .S(aluf[3:0]),
			   .CIN_N(cin12_n),
			   .M(alumode),
			   .F({alu[15:12]}),
			   .AEB(aeqm_bits[3]),
			   .X(xout15),
			   .Y(yout15),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2B23 (
			   .A(m[11:8]),
			   .B(a[11:8]),
			   .S(aluf[3:0]),
			   .CIN_N(cin8_n),
			   .M(alumode),
			   .F(alu[11:8]),
			   .AEB(aeqm_bits[2]),
			   .X(xout11),
			   .Y(yout11),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2A28 (
			   .A(m[7:4]),
			   .B(a[7:4]),
			   .S(aluf[3:0]),
			   .CIN_N(cin4_n),
			   .M(alumode),
			   .F(alu[7:4]),
			   .AEB(aeqm_bits[1]),
			   .X(xout7),
			   .Y(yout7),
			   .COUT_N()
			   );

   ic_74S181  i_ALU0_2B28 (
			   .A(m[3:0]),
			   .B(a[3:0]),
			   .S(aluf[3:0]),
			   .CIN_N(~cin0),
			   .M(alumode),
			   .F(alu[3:0]),
			   .AEB(aeqm_bits[0]),
			   .X(xout3),
			   .Y(yout3),
			   .COUT_N()
			   );

endmodule
