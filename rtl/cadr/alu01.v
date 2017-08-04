// ALU0, ALU1
//
// TK CADR ALU0
// TK CADR ALU1

module ALU01(
             aluf, alumode,
             a, m,
             alu, aeqm,
             cin0, cin4_n, cin8_n, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n,
             xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31,
             yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31
             );

   input [3:0] aluf;
   input alumode;

   input [31:0] a;
   input [31:0] m;

   output [32:0] alu;
   output aeqm;

   input cin0, cin4_n, cin8_n, cin12_n, cin16_n, cin20_n, cin24_n, cin28_n, cin32_n;

   output xout3, xout7, xout11, xout15, xout19, xout23, xout27, xout31;
   output yout3, yout7, yout11, yout15, yout19, yout23, yout27, yout31;

   ////////////////////////////////////////////////////////////////////////////////

   wire [2:0] nc_alu;
   wire [7:0] aeqm_bits;

   ////////////////////////////////////////////////////////////////////////////////

   // The 74181 pulls down AEB if not equal, AEQM is the simulated
   // open collector.
   assign aeqm = aeqm_bits == {8'b11111111} ? 1'b1 : 1'b0;

   ic_74S181 i_ALU0_2B28(.S(aluf[3:0]), .M(alumode),
                         .A(m[3:0]), .B(a[3:0]), .CIN_N(~cin0),
                         .F(alu[3:0]),
                         .X(xout3), .Y(yout3), .AEB(aeqm_bits[0]));
   ic_74S181 i_ALU0_2A28(.S(aluf[3:0]), .M(alumode),
                         .A(m[7:4]), .B(a[7:4]), .CIN_N(cin4_n),
                         .F(alu[7:4]),
                         .X(xout7), .Y(yout7), .AEB(aeqm_bits[1]));
   ic_74S181 i_ALU0_2B23(.S(aluf[3:0]), .M(alumode),
                         .A(m[11:8]), .B(a[11:8]), .CIN_N(cin8_n),
                         .F(alu[11:8]),
                         .X(xout11), .Y(yout11), .AEB(aeqm_bits[2]));
   ic_74S181 i_ALU0_2A23(.S(aluf[3:0]), .M(alumode),
                         .A(m[15:12]), .B(a[15:12]), .CIN_N(cin12_n),
                         .F({alu[15:12]}),
                         .X(xout15), .Y(yout15), .AEB(aeqm_bits[3]));
   ic_74S181 i_ALU1_2B13(.S(aluf[3:0]), .M(alumode),
                         .A(m[19:16]), .B(a[19:16]), .CIN_N(cin16_n),
                         .F(alu[19:16]),
                         .X(xout19), .Y(yout19), .AEB(aeqm_bits[4]));
   ic_74S181 i_ALU1_2A13(.S(aluf[3:0]), .M(alumode),
                         .A(m[23:20]), .B(a[23:20]), .CIN_N(cin20_n),
                         .F(alu[23:20]),
                         .X(xout23), .Y(yout23), .AEB(aeqm_bits[5]));
   ic_74S181 i_ALU1_2B08(.S(aluf[3:0]), .M(alumode),
                         .A(m[27:24]), .B(a[27:24]), .CIN_N(cin24_n),
                         .F(alu[27:24]),
                         .X(xout27), .Y(yout27), .AEB(aeqm_bits[6]));
   ic_74S181 i_ALU1_2A08(.S(aluf[3:0]), .M(alumode),
                         .A(m[31:28]), .B(a[31:28]), .CIN_N(cin28_n),
                         .F(alu[31:28]),
                         .X(xout31), .Y(yout31), .AEB(aeqm_bits[7]));
   ic_74S181 i_ALU1_2A03(.S(aluf[3:0]), .M(alumode),
                         .A({3'b0, m[31]}), .B({3'b0, a[31]}), .CIN_N(cin32_n),
                         .F({nc_alu, alu[32]}));

endmodule
