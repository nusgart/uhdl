// part_512x49prom.v --- 512x49 ROM
//
// Used by PROM.

`include "defines.vh"

module part_512x49prom(clk, addr, q);

   input clk;
   input [8:0] addr;
   output [48:0] q;

   ////////////////////////////////////////////////////////////////////////////////

   reg [48:0] q;

   ////////////////////////////////////////////////////////////////////////////////

`ifdef empty_prom
   always @(posedge clk)
     q = 49'o0000000000000000;
`else
   always @(posedge clk)
     begin
        case (addr)
          // Boot PROM version 9, see SYS: UCADR; PROMH LISP.
          ~9'o000 & 9'o777: q = 49'o0200000000450247; // (jump) a=0 m=m[0] pc 45, !next jump-always
          ~9'o001 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o002 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o003 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o004 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o005 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o006 & 9'o777: q = 49'o4200123400060143; // (jump) a=2 m=Q pc 6, !jump M-src = A-src
          ~9'o007 & 9'o777: q = 49'o4000163400010313; // (alu) M+A [ADD] a=3 m=47 Q C=0 alu-> Q-R -><none>,m[0]
          ~9'o010 & 9'o777: q = 49'o4200000000102247; // (jump) a=0 m=m[0] pc 10, !next jump-always
          ~9'o011 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o012 & 9'o777: q = 49'o0200000000122247; // (jump) a=0 m=m[0] pc 12, !next jump-always
          ~9'o013 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o014 & 9'o777: q = 49'o0200000000142247; // (jump) a=0 m=m[0] pc 14, !next jump-always
          ~9'o015 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o016 & 9'o777: q = 49'o4200000000162247; // (jump) a=0 m=m[0] pc 16, !next jump-always
          ~9'o017 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o020 & 9'o777: q = 49'o4200000000202247; // (jump) a=0 m=m[0] pc 20, !next jump-always
          ~9'o021 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o022 & 9'o777: q = 49'o0200000000222247; // (jump) a=0 m=m[0] pc 22, !next jump-always
          ~9'o023 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o024 & 9'o777: q = 49'o0200000000242247; // (jump) a=0 m=m[0] pc 24, !next jump-always
          ~9'o025 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o026 & 9'o777: q = 49'o4200000000262247; // (jump) a=0 m=m[0] pc 26, !next jump-always
          ~9'o027 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o030 & 9'o777: q = 49'o0200000000302247; // (jump) a=0 m=m[0] pc 30, !next jump-always
          ~9'o031 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o032 & 9'o777: q = 49'o4200000000322247; // (jump) a=0 m=m[0] pc 32, !next jump-always
          ~9'o033 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o034 & 9'o777: q = 49'o4200000000342247; // (jump) a=0 m=m[0] pc 34, !next jump-always
          ~9'o035 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o036 & 9'o777: q = 49'o0200000000362247; // (jump) a=0 m=m[0] pc 36, !next jump-always
          ~9'o037 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o040 & 9'o777: q = 49'o4200000000402247; // (jump) a=0 m=m[0] pc 40, !next jump-always
          ~9'o041 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o042 & 9'o777: q = 49'o0200000000422247; // (jump) a=0 m=m[0] pc 42, !next jump-always
          ~9'o043 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o044 & 9'o777: q = 49'o0200000000442247; // (jump) a=0 m=m[0] pc 44, !next jump-always
          // GO
          ~9'o045 & 9'o777: q = 49'o4000000000110003; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[2]
          ~9'o046 & 9'o777: q = 49'o4200023400120200; // (jump) a=0 m=Q pc 12, !next m-rot<< 0
          ~9'o047 & 9'o777: q = 49'o0200023400120237; // (jump) a=0 m=Q pc 12, !next m-rot<< 31
          ~9'o050 & 9'o777: q = 49'o4200023400120236; // (jump) a=0 m=Q pc 12, !next m-rot<< 30
          ~9'o051 & 9'o777: q = 49'o4200023400120235; // (jump) a=0 m=Q pc 12, !next m-rot<< 29
          ~9'o052 & 9'o777: q = 49'o0200023400120234; // (jump) a=0 m=Q pc 12, !next m-rot<< 28
          ~9'o053 & 9'o777: q = 49'o4200023400120233; // (jump) a=0 m=Q pc 12, !next m-rot<< 27
          ~9'o054 & 9'o777: q = 49'o0200023400120232; // (jump) a=0 m=Q pc 12, !next m-rot<< 26
          ~9'o055 & 9'o777: q = 49'o0200023400120231; // (jump) a=0 m=Q pc 12, !next m-rot<< 25
          ~9'o056 & 9'o777: q = 49'o4200023400120230; // (jump) a=0 m=Q pc 12, !next m-rot<< 24
          ~9'o057 & 9'o777: q = 49'o4200023400120227; // (jump) a=0 m=Q pc 12, !next m-rot<< 23
          ~9'o060 & 9'o777: q = 49'o0200023400120226; // (jump) a=0 m=Q pc 12, !next m-rot<< 22
          ~9'o061 & 9'o777: q = 49'o0200023400120225; // (jump) a=0 m=Q pc 12, !next m-rot<< 21
          ~9'o062 & 9'o777: q = 49'o4200023400120224; // (jump) a=0 m=Q pc 12, !next m-rot<< 20
          ~9'o063 & 9'o777: q = 49'o0200023400120223; // (jump) a=0 m=Q pc 12, !next m-rot<< 19
          ~9'o064 & 9'o777: q = 49'o4200023400120222; // (jump) a=0 m=Q pc 12, !next m-rot<< 18
          ~9'o065 & 9'o777: q = 49'o4200023400120221; // (jump) a=0 m=Q pc 12, !next m-rot<< 17
          ~9'o066 & 9'o777: q = 49'o0200023400120220; // (jump) a=0 m=Q pc 12, !next m-rot<< 16
          ~9'o067 & 9'o777: q = 49'o4200023400120217; // (jump) a=0 m=Q pc 12, !next m-rot<< 15
          ~9'o070 & 9'o777: q = 49'o0200023400120216; // (jump) a=0 m=Q pc 12, !next m-rot<< 14
          ~9'o071 & 9'o777: q = 49'o0200023400120215; // (jump) a=0 m=Q pc 12, !next m-rot<< 13
          ~9'o072 & 9'o777: q = 49'o4200023400120214; // (jump) a=0 m=Q pc 12, !next m-rot<< 12
          ~9'o073 & 9'o777: q = 49'o0200023400120213; // (jump) a=0 m=Q pc 12, !next m-rot<< 11
          ~9'o074 & 9'o777: q = 49'o4200023400120212; // (jump) a=0 m=Q pc 12, !next m-rot<< 10
          ~9'o075 & 9'o777: q = 49'o4200023400120211; // (jump) a=0 m=Q pc 12, !next m-rot<< 9
          ~9'o076 & 9'o777: q = 49'o0200023400120210; // (jump) a=0 m=Q pc 12, !next m-rot<< 8
          ~9'o077 & 9'o777: q = 49'o0200023400120207; // (jump) a=0 m=Q pc 12, !next m-rot<< 7
          ~9'o100 & 9'o777: q = 49'o4200023400120206; // (jump) a=0 m=Q pc 12, !next m-rot<< 6
          ~9'o101 & 9'o777: q = 49'o4200023400120205; // (jump) a=0 m=Q pc 12, !next m-rot<< 5
          ~9'o102 & 9'o777: q = 49'o0200023400120204; // (jump) a=0 m=Q pc 12, !next m-rot<< 4
          ~9'o103 & 9'o777: q = 49'o4200023400120203; // (jump) a=0 m=Q pc 12, !next m-rot<< 3
          ~9'o104 & 9'o777: q = 49'o0200023400120202; // (jump) a=0 m=Q pc 12, !next m-rot<< 2
          ~9'o105 & 9'o777: q = 49'o0200023400120201; // (jump) a=0 m=Q pc 12, !next m-rot<< 1
          ~9'o106 & 9'o777: q = 49'o0000000000150173; // (alu) SETO a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[3]
          ~9'o107 & 9'o777: q = 49'o0200023400120300; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 0
          ~9'o110 & 9'o777: q = 49'o4200023400120337; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 31
          ~9'o111 & 9'o777: q = 49'o0200023400120336; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 30
          ~9'o112 & 9'o777: q = 49'o0200023400120335; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 29
          ~9'o113 & 9'o777: q = 49'o4200023400120334; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 28
          ~9'o114 & 9'o777: q = 49'o0200023400120333; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 27
          ~9'o115 & 9'o777: q = 49'o4200023400120332; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 26
          ~9'o116 & 9'o777: q = 49'o4200023400120331; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 25
          ~9'o117 & 9'o777: q = 49'o0200023400120330; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 24
          ~9'o120 & 9'o777: q = 49'o0200023400120327; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 23
          ~9'o121 & 9'o777: q = 49'o4200023400120326; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 22
          ~9'o122 & 9'o777: q = 49'o4200023400120325; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 21
          ~9'o123 & 9'o777: q = 49'o0200023400120324; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 20
          ~9'o124 & 9'o777: q = 49'o4200023400120323; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 19
          ~9'o125 & 9'o777: q = 49'o0200023400120322; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 18
          ~9'o126 & 9'o777: q = 49'o0200023400120321; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 17
          ~9'o127 & 9'o777: q = 49'o4200023400120320; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 16
          ~9'o130 & 9'o777: q = 49'o0200023400120317; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 15
          ~9'o131 & 9'o777: q = 49'o4200023400120316; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 14
          ~9'o132 & 9'o777: q = 49'o4200023400120315; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 13
          ~9'o133 & 9'o777: q = 49'o0200023400120314; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 12
          ~9'o134 & 9'o777: q = 49'o4200023400120313; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 11
          ~9'o135 & 9'o777: q = 49'o0200023400120312; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 10
          ~9'o136 & 9'o777: q = 49'o0200023400120311; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 9
          ~9'o137 & 9'o777: q = 49'o4200023400120310; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 8
          ~9'o140 & 9'o777: q = 49'o4200023400120307; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 7
          ~9'o141 & 9'o777: q = 49'o0200023400120306; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 6
          ~9'o142 & 9'o777: q = 49'o0200023400120305; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 5
          ~9'o143 & 9'o777: q = 49'o4200023400120304; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 4
          ~9'o144 & 9'o777: q = 49'o0200023400120303; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 3
          ~9'o145 & 9'o777: q = 49'o4200023400120302; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 2
          ~9'o146 & 9'o777: q = 49'o4200023400120301; // (jump) a=0 m=Q pc 12, !next !jump m-rot<< 1
          ~9'o147 & 9'o777: q = 49'o0200163400160343; // (jump) a=3 m=Q pc 16, !next !jump M-src = A-src
          ~9'o150 & 9'o777: q = 49'o0200141400200343; // (jump) a=3 m=m[3] pc 20, !next !jump M-src = A-src
          ~9'o151 & 9'o777: q = 49'o0000000000010003; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[0]
          ~9'o152 & 9'o777: q = 49'o4200123400160343; // (jump) a=2 m=Q pc 16, !next !jump M-src = A-src
          ~9'o153 & 9'o777: q = 49'o0200101000200343; // (jump) a=2 m=m[2] pc 20, !next !jump M-src = A-src
          ~9'o154 & 9'o777: q = 49'o4000101400010317; // (alu) M+A [ADD] a=2 m=3 m[3] C=1 alu-> Q-R -><none>,m[0]
          ~9'o155 & 9'o777: q = 49'o0200123400140343; // (jump) a=2 m=Q pc 14, !next !jump M-src = A-src
          ~9'o156 & 9'o777: q = 49'o4000141400010313; // (alu) M+A [ADD] a=3 m=3 m[3] C=0 alu-> Q-R -><none>,m[0]
          ~9'o157 & 9'o777: q = 49'o4200023400140200; // (jump) a=0 m=Q pc 14, !next m-rot<< 0
          ~9'o160 & 9'o777: q = 49'o4200023400140337; // (jump) a=0 m=Q pc 14, !next !jump m-rot<< 31
          ~9'o161 & 9'o777: q = 49'o4200023400140301; // (jump) a=0 m=Q pc 14, !next !jump m-rot<< 1
          ~9'o162 & 9'o777: q = 49'o4000001022010030; // (alu) SETM a=0 m=2 m[2] C=0 alu-> ->PDL[ptr],push ,m[0]
          ~9'o163 & 9'o777: q = 49'o0000001422010030; // (alu) SETM a=0 m=3 m[3] C=0 alu-> ->PDL[ptr],push ,m[0]
          ~9'o164 & 9'o777: q = 49'o4600163460011737; // (byte) a=3 m=Q ldb pos=37, width=37 ->MD ,m[0]
          ~9'o165 & 9'o777: q = 49'o0200165000140343; // (jump) a=3 m=MD pc 14, !next !jump M-src = A-src
          ~9'o166 & 9'o777: q = 49'o0200172000440343; // (jump) a=3 m=PDL[Pointer], pop pc 44, !next !jump M-src = A-src
          ~9'o167 & 9'o777: q = 49'o4200132000440343; // (jump) a=2 m=PDL[Pointer], pop pc 44, !next !jump M-src = A-src
          ~9'o170 & 9'o777: q = 49'o4600101400070005; // (byte) a=2 m=m[3] dpb pos=5, width=1 -><none>,m[1]
          ~9'o171 & 9'o777: q = 49'o4600101460030002; // (byte) a=2 m=m[3] dpb pos=2, width=1 ->MD ,m[0]
          // CLEAR-M-MEMORY
          ~9'o172 & 9'o777: q = 49'o4000140400050310; // (alu) M+A [ADD] a=3 m=1 m[1] C=0 alu-> -><none>,m[1]
          ~9'o173 & 9'o777: q = 49'o0600100434030216; // (byte) a=2 m=m[1] dpb pos=16, width=5 ->OA-reg-lo ,m[0]
          ~9'o174 & 9'o777: q = 49'o4000001000010030; // (alu) SETM a=0 m=2 m[2] C=0 alu-> -><none>,m[0]
          ~9'o175 & 9'o777: q = 49'o0200065001720343; // (jump) a=1 m=MD pc 172, !next !jump M-src = A-src
          ~9'o176 & 9'o777: q = 49'o4600101400070005; // (byte) a=2 m=m[3] dpb pos=5, width=1 -><none>,m[1]
          // CLEAR-A-MEMORY
          ~9'o177 & 9'o777: q = 49'o4600100434030456; // (byte) a=2 m=m[1] dpb pos=16, width=12 ->OA-reg-lo ,m[0]
          ~9'o200 & 9'o777: q = 49'o0000001200010030; // (alu) SETM a=0 m=2 m[2] C=0 alu-> ->a_mem[0]
          ~9'o201 & 9'o777: q = 49'o4000100400050314; // (alu) M+A [ADD] a=2 m=1 m[1] C=1 alu-> -><none>,m[1]
          ~9'o202 & 9'o777: q = 49'o4200000401770326; // (jump) a=0 m=m[1] pc 177, !next !jump m-rot<< 22
          // MAKE-CONSTANTS
          ~9'o203 & 9'o777: q = 49'o0600101602030000; // (byte) a=2 m=m[3] dpb pos=0, width=1 ->a_mem[40]
          ~9'o204 & 9'o777: q = 49'o0600101602070001; // (byte) a=2 m=m[3] dpb pos=1, width=1 ->a_mem[41]
          ~9'o205 & 9'o777: q = 49'o0600101602130040; // (byte) a=2 m=m[3] dpb pos=0, width=2 ->a_mem[42]
          ~9'o206 & 9'o777: q = 49'o4600101602170002; // (byte) a=2 m=m[3] dpb pos=2, width=1 ->a_mem[43]
          ~9'o207 & 9'o777: q = 49'o0602001602230002; // (byte) a=40 m=m[3] dpb pos=2, width=1 ->a_mem[44]
          ~9'o210 & 9'o777: q = 49'o0602001602270003; // (byte) a=40 m=m[3] dpb pos=3, width=1 ->a_mem[45]
          ~9'o211 & 9'o777: q = 49'o0600101602330005; // (byte) a=2 m=m[3] dpb pos=5, width=1 ->a_mem[46]
          ~9'o212 & 9'o777: q = 49'o0600101602370010; // (byte) a=2 m=m[3] dpb pos=10, width=1 ->a_mem[47]
          ~9'o213 & 9'o777: q = 49'o0600101602430015; // (byte) a=2 m=m[3] dpb pos=15, width=1 ->a_mem[50]
          ~9'o214 & 9'o777: q = 49'o0600101602470104; // (byte) a=2 m=m[3] dpb pos=4, width=3 ->a_mem[51]
          ~9'o215 & 9'o777: q = 49'o0602441602470110; // (byte) a=51 m=m[3] dpb pos=10, width=3 ->a_mem[51]
          ~9'o216 & 9'o777: q = 49'o0602201602570011; // (byte) a=44 m=m[3] dpb pos=11, width=1 ->a_mem[53]
          ~9'o217 & 9'o777: q = 49'o4602541602570025; // (byte) a=53 m=m[3] dpb pos=25, width=1 ->a_mem[53]
          ~9'o220 & 9'o777: q = 49'o4600101602530144; // (byte) a=2 m=m[3] dpb pos=4, width=4 ->a_mem[52]
          ~9'o221 & 9'o777: q = 49'o4602501602530551; // (byte) a=52 m=m[3] dpb pos=11, width=14 ->a_mem[52]
          ~9'o222 & 9'o777: q = 49'o0602501602530027; // (byte) a=52 m=m[3] dpb pos=27, width=1 ->a_mem[52]
          ~9'o223 & 9'o777: q = 49'o4600101430230012; // (byte) a=2 m=m[3] dpb pos=12, width=1 ->PDL ptr ,m[4]
          // CLEAR-PDL-BUFFER
          ~9'o224 & 9'o777: q = 49'o4000001022010030; // (alu) SETM a=0 m=2 m[2] C=0 alu-> ->PDL[ptr],push ,m[0]
          ~9'o225 & 9'o777: q = 49'o4000142000210310; // (alu) M+A [ADD] a=3 m=4 m[4] C=0 alu-> -><none>,m[4]
          ~9'o226 & 9'o777: q = 49'o0200102002240343; // (jump) a=2 m=m[4] pc 224, !next !jump M-src = A-src
          ~9'o227 & 9'o777: q = 49'o0002300000210050; // (alu) SETA a=46 m=0 m[0] C=0 alu-> -><none>,m[4]
          // CLEAR-SPC-MEMORY
          ~9'o230 & 9'o777: q = 49'o4000000032010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->SPC data,push ,m[0]
          ~9'o231 & 9'o777: q = 49'o4000142000210310; // (alu) M+A [ADD] a=3 m=4 m[4] C=0 alu-> -><none>,m[4]
          ~9'o232 & 9'o777: q = 49'o0200102002300343; // (jump) a=2 m=m[4] pc 230, !next !jump M-src = A-src
          ~9'o233 & 9'o777: q = 49'o0000000060010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->MD ,m[0]
          // CLEAR-LEVEL-1-MAP
          ~9'o234 & 9'o777: q = 49'o0600101446270032; // (byte) a=2 m=m[3] dpb pos=32, width=1 ->VMA,write-map ,m[5]
          ~9'o235 & 9'o777: q = 49'o0002425060010310; // (alu) M+A [ADD] a=50 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o236 & 9'o777: q = 49'o0200025002340310; // (jump) a=0 m=MD pc 234, !next !jump m-rot<< 8
          ~9'o237 & 9'o777: q = 49'o0000000060010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->MD ,m[0]
          // CLEAR-LEVEL-2-MAP
          ~9'o240 & 9'o777: q = 49'o4600125000210223; // (byte) a=2 m=MD ldb pos=23, width=5 -><none>,m[4]
          ~9'o241 & 9'o777: q = 49'o0600242046030233; // (byte) a=5 m=m[4] dpb pos=33, width=5 ->VMA,write-map ,m[0]
          ~9'o242 & 9'o777: q = 49'o0600101446030031; // (byte) a=2 m=m[3] dpb pos=31, width=1 ->VMA,write-map ,m[0]
          ~9'o243 & 9'o777: q = 49'o0002365060010310; // (alu) M+A [ADD] a=47 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o244 & 9'o777: q = 49'o0200025002400310; // (jump) a=0 m=MD pc 240, !next !jump m-rot<< 8
          ~9'o245 & 9'o777: q = 49'o4000000060210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->MD ,m[4]
          // CLEAR-I-MEMORY
          ~9'o246 & 9'o777: q = 49'o4600125034030654; // (byte) a=2 m=MD dpb pos=14, width=16 ->OA-reg-lo ,m[0]
          ~9'o247 & 9'o777: q = 49'o4200202000001647; // (jump) a=4 m=m[4] pc 0, R P !next jump-always
          ~9'o250 & 9'o777: q = 49'o4002025060010310; // (alu) M+A [ADD] a=40 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o251 & 9'o777: q = 49'o4200025002460322; // (jump) a=0 m=MD pc 246, !next !jump m-rot<< 18
          ~9'o252 & 9'o777: q = 49'o4600101460230021; // (byte) a=2 m=m[3] dpb pos=21, width=1 ->MD ,m[4]
          // CLEAR-D-MEMORY
          ~9'o253 & 9'o777: q = 49'o0600125034030514; // (byte) a=2 m=MD dpb pos=14, width=13 ->OA-reg-lo ,m[0]
          ~9'o254 & 9'o777: q = 49'o5400200000004000; // (dispatch) disp const 4, disp addr 0, map 0, len 0, rot 0
          ~9'o255 & 9'o777: q = 49'o4002025060010310; // (alu) M+A [ADD] a=40 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o256 & 9'o777: q = 49'o4200025002530325; // (jump) a=0 m=MD pc 253, !next !jump m-rot<< 21
          // FUDGE-INITIAL-DISK-PARAMETERS
          ~9'o257 & 9'o777: q = 49'o4002100202710050; // (alu) SETA a=42 m=0 m[0] C=0 alu-> ->a_mem[56]
          ~9'o260 & 9'o777: q = 49'o0002100202750050; // (alu) SETA a=42 m=0 m[0] C=0 alu-> ->a_mem[57]
          ~9'o261 & 9'o777: q = 49'o0600101404030034; // (byte) a=2 m=m[3] dpb pos=34, width=1 ->IC ,m[0]
          ~9'o262 & 9'o777: q = 49'o0002300000210050; // (alu) SETA a=46 m=0 m[0] C=0 alu-> -><none>,m[4]
          // RST
          ~9'o263 & 9'o777: q = 49'o4200102002630143; // (jump) a=2 m=m[4] pc 263, !jump M-src = A-src
          ~9'o264 & 9'o777: q = 49'o4002002000210264; // (alu) M-A-1 [M-A-1] a=40 m=4 m[4] C=1 alu-> -><none>,m[4]
          ~9'o265 & 9'o777: q = 49'o4600101404030033; // (byte) a=2 m=m[3] dpb pos=33, width=1 ->IC ,m[0]
          // SET-UP-THE-MAP
          ~9'o266 & 9'o777: q = 49'o0000000060010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o267 & 9'o777: q = 49'o0600101446030032; // (byte) a=2 m=m[3] dpb pos=32, width=1 ->VMA,write-map ,m[0]
          ~9'o270 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o271 & 9'o777: q = 49'o0000024400210030; // (alu) SETM a=0 m=51 MAP[MD] C=0 alu-> -><none>,m[4]
          ~9'o272 & 9'o777: q = 49'o0600102000250210; // (byte) a=2 m=m[4] ldb pos=10, width=5 -><none>,m[5]
          ~9'o273 & 9'o777: q = 49'o0200102400220343; // (jump) a=2 m=m[5] pc 22, !next !jump M-src = A-src
          // SET-UP-FOUR-PAGES
          ~9'o274 & 9'o777: q = 49'o4600101446230166; // (byte) a=2 m=m[3] dpb pos=26, width=4 ->VMA,write-map ,m[4]
          ~9'o275 & 9'o777: q = 49'o4600201400270400; // (byte) a=4 m=m[3] dpb pos=0, width=11 -><none>,m[5]
          ~9'o276 & 9'o777: q = 49'o0002340060010050; // (alu) SETA a=47 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o277 & 9'o777: q = 49'o0600241446030152; // (byte) a=5 m=m[3] dpb pos=12, width=4 ->VMA,write-map ,m[0]
          ~9'o300 & 9'o777: q = 49'o0600101603030302; // (byte) a=2 m=m[3] dpb pos=2, width=7 ->a_mem[60]
          ~9'o301 & 9'o777: q = 49'o0002365060010310; // (alu) M+A [ADD] a=47 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o302 & 9'o777: q = 49'o0600201400270041; // (byte) a=4 m=m[3] dpb pos=1, width=2 -><none>,m[5]
          ~9'o303 & 9'o777: q = 49'o4600241446030444; // (byte) a=5 m=m[3] dpb pos=4, width=12 ->VMA,write-map ,m[0]
          ~9'o304 & 9'o777: q = 49'o0002365060010310; // (alu) M+A [ADD] a=47 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o305 & 9'o777: q = 49'o4600201446030000; // (byte) a=4 m=m[3] dpb pos=0, width=1 ->VMA,write-map ,m[0]
          ~9'o306 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o307 & 9'o777: q = 49'o4000000040010170; // (alu) SETO a=0 m=0 m[0] C=0 alu-> ->VMA ,m[0]
          // PAGE-0-PARITY-FIX
          ~9'o310 & 9'o777: q = 49'o0002024042010310; // (alu) M+A [ADD] a=40 m=50 VMA C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o311 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o312 & 9'o777: q = 49'o0000025064010030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->MD,start-write ,m[0]
          ~9'o313 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o314 & 9'o777: q = 49'o0202364003100241; // (jump) a=47 m=VMA pc 310, !next M-src < A-src
          ~9'o315 & 9'o777: q = 49'o4002140060010050; // (alu) SETA a=43 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o316 & 9'o777: q = 49'o4602201444030011; // (byte) a=44 m=m[3] dpb pos=11, width=1 ->VMA,start-write ,m[0]
          ~9'o317 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o320 & 9'o777: q = 49'o0200000005300647; // (jump) a=0 m=m[0] pc 530, P !next jump-always
          // SAVE-A-PAGE
          ~9'o321 & 9'o777: q = 49'o0002000000410050; // (alu) SETA a=40 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o322 & 9'o777: q = 49'o0200000005610447; // (jump) a=0 m=m[0] pc 561, P jump-always
          ~9'o323 & 9'o777: q = 49'o4000000000210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[4]
          // READ-LABEL
          ~9'o324 & 9'o777: q = 49'o4000000000410000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o325 & 9'o777: q = 49'o0200000005570447; // (jump) a=0 m=m[0] pc 557, P jump-always
          ~9'o326 & 9'o777: q = 49'o4000000000210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[4]
          ~9'o327 & 9'o777: q = 49'o0600101400270042; // (byte) a=2 m=m[3] dpb pos=2, width=2 -><none>,m[5]
          ~9'o330 & 9'o777: q = 49'o4600241400270006; // (byte) a=5 m=m[3] dpb pos=6, width=1 -><none>,m[5]
          ~9'o331 & 9'o777: q = 49'o0600241400270010; // (byte) a=5 m=m[3] dpb pos=10, width=1 -><none>,m[5]
          ~9'o332 & 9'o777: q = 49'o0600241400270016; // (byte) a=5 m=m[3] dpb pos=16, width=1 -><none>,m[5]
          ~9'o333 & 9'o777: q = 49'o4600241400270021; // (byte) a=5 m=m[3] dpb pos=21, width=1 -><none>,m[5]
          ~9'o334 & 9'o777: q = 49'o0600241400270026; // (byte) a=5 m=m[3] dpb pos=26, width=1 -><none>,m[5]
          ~9'o335 & 9'o777: q = 49'o4600241400270072; // (byte) a=5 m=m[3] dpb pos=32, width=2 -><none>,m[5]
          ~9'o336 & 9'o777: q = 49'o4600241400270036; // (byte) a=5 m=m[3] dpb pos=36, width=1 -><none>,m[5]
          // DECODE-LABEL
          ~9'o337 & 9'o777: q = 49'o4000100042310050; // (alu) SETA a=2 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o340 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o341 & 9'o777: q = 49'o4200265000260343; // (jump) a=5 m=MD pc 26, !next !jump M-src = A-src
          ~9'o342 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o343 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o344 & 9'o777: q = 49'o0202025000260343; // (jump) a=40 m=MD pc 26, !next !jump M-src = A-src
          ~9'o345 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o346 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o347 & 9'o777: q = 49'o4000025202610030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[54]
          ~9'o350 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o351 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o352 & 9'o777: q = 49'o0000025202650030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[55]
          ~9'o353 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o354 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o355 & 9'o777: q = 49'o0000025202710030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[56]
          ~9'o356 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o357 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o360 & 9'o777: q = 49'o4000025202750030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[57]
          ~9'o361 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o362 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o363 & 9'o777: q = 49'o4000025000250030; // (alu) SETM a=0 m=52 MD C=0 alu-> -><none>,m[5]
          ~9'o364 & 9'o777: q = 49'o4600101442330007; // (byte) a=2 m=m[3] dpb pos=7, width=1 ->VMA,start-read ,m[6]
          ~9'o365 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o366 & 9'o777: q = 49'o0000025000350030; // (alu) SETM a=0 m=52 MD C=0 alu-> -><none>,m[7]
          ~9'o367 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o370 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o371 & 9'o777: q = 49'o0000025000210030; // (alu) SETM a=0 m=52 MD C=0 alu-> -><none>,m[4]
          ~9'o372 & 9'o777: q = 49'o0002003000310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> -><none>,m[6]
          // SEARCH-LABEL
          ~9'o373 & 9'o777: q = 49'o0200103400300243; // (jump) a=2 m=m[7] pc 30, !next M-src = A-src
          ~9'o374 & 9'o777: q = 49'o0000003042010030; // (alu) SETM a=0 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o375 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o376 & 9'o777: q = 49'o4200265004020243; // (jump) a=5 m=MD pc 402, !next M-src = A-src
          ~9'o377 & 9'o777: q = 49'o0000203000310310; // (alu) M+A [ADD] a=4 m=6 m[6] C=0 alu-> -><none>,m[6]
          ~9'o400 & 9'o777: q = 49'o4200000003730047; // (jump) a=0 m=m[0] pc 373, jump-always
          ~9'o401 & 9'o777: q = 49'o4002003400350264; // (alu) M-A-1 [M-A-1] a=40 m=7 m[7] C=1 alu-> -><none>,m[7]
          // FOUND-PARTITION
          ~9'o402 & 9'o777: q = 49'o0002003042310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[6]
          ~9'o403 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o404 & 9'o777: q = 49'o4000025203110030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[62]
          ~9'o405 & 9'o777: q = 49'o4003100203050050; // (alu) SETA a=62 m=0 m[0] C=0 alu-> ->a_mem[61]
          ~9'o406 & 9'o777: q = 49'o0002003042010310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o407 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o410 & 9'o777: q = 49'o0000025203150030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->a_mem[63]
          ~9'o411 & 9'o777: q = 49'o0002340000510050; // (alu) SETA a=47 m=0 m[0] C=0 alu-> -><none>,m[12]
          // PROCESS-SECTION
          ~9'o412 & 9'o777: q = 49'o4200000005130647; // (jump) a=0 m=m[0] pc 513, P !next jump-always
          ~9'o413 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o414 & 9'o777: q = 49'o4000002000250030; // (alu) SETM a=0 m=4 m[4] C=0 alu-> -><none>,m[5]
          ~9'o415 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o416 & 9'o777: q = 49'o4000002000310030; // (alu) SETM a=0 m=4 m[4] C=0 alu-> -><none>,m[6]
          ~9'o417 & 9'o777: q = 49'o0000002000350030; // (alu) SETM a=0 m=4 m[4] C=0 alu-> -><none>,m[7]
          ~9'o420 & 9'o777: q = 49'o4202002404250243; // (jump) a=40 m=m[5] pc 425, !next M-src = A-src
          ~9'o421 & 9'o777: q = 49'o0202042404400243; // (jump) a=41 m=m[5] pc 440, !next M-src = A-src
          ~9'o422 & 9'o777: q = 49'o0202102404510243; // (jump) a=42 m=m[5] pc 451, !next M-src = A-src
          ~9'o423 & 9'o777: q = 49'o4202142404620243; // (jump) a=43 m=m[5] pc 462, !next M-src = A-src
          ~9'o424 & 9'o777: q = 49'o0200000000320247; // (jump) a=0 m=m[0] pc 32, !next jump-always
          // PROCESS-I-MEM-SECTION
          ~9'o425 & 9'o777: q = 49'o4200103404120243; // (jump) a=2 m=m[7] pc 412, !next M-src = A-src
          ~9'o426 & 9'o777: q = 49'o0600103000211062; // (byte) a=2 m=m[6] ldb pos=22, width=22 -><none>,m[4]
          ~9'o427 & 9'o777: q = 49'o0200102000340343; // (jump) a=2 m=m[4] pc 34, !next !jump M-src = A-src
          ~9'o430 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o431 & 9'o777: q = 49'o4002003400350264; // (alu) M-A-1 [M-A-1] a=40 m=7 m[7] C=1 alu-> -><none>,m[7]
          ~9'o432 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o433 & 9'o777: q = 49'o4000002000250030; // (alu) SETM a=0 m=4 m[4] C=0 alu-> -><none>,m[5]
          ~9'o434 & 9'o777: q = 49'o0600103034030654; // (byte) a=2 m=m[6] dpb pos=14, width=16 ->OA-reg-lo ,m[0]
          ~9'o435 & 9'o777: q = 49'o0200242000001647; // (jump) a=5 m=m[4] pc 0, R P !next jump-always
          ~9'o436 & 9'o777: q = 49'o0200000004250047; // (jump) a=0 m=m[0] pc 425, jump-always
          ~9'o437 & 9'o777: q = 49'o0002003000310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> -><none>,m[6]
          // PROCESS-D-MEM-SECTION
          ~9'o440 & 9'o777: q = 49'o4200103404120243; // (jump) a=2 m=m[7] pc 412, !next M-src = A-src
          ~9'o441 & 9'o777: q = 49'o4600103000211225; // (byte) a=2 m=m[6] ldb pos=25, width=25 -><none>,m[4]
          ~9'o442 & 9'o777: q = 49'o0200102000340343; // (jump) a=2 m=m[4] pc 34, !next !jump M-src = A-src
          ~9'o443 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o444 & 9'o777: q = 49'o4002003400350264; // (alu) M-A-1 [M-A-1] a=40 m=7 m[7] C=1 alu-> -><none>,m[7]
          ~9'o445 & 9'o777: q = 49'o4600103034030514; // (byte) a=2 m=m[6] dpb pos=14, width=13 ->OA-reg-lo ,m[0]
          ~9'o446 & 9'o777: q = 49'o5400200000004000; // (dispatch) disp const 4, disp addr 0, map 0, len 0, rot 0
          ~9'o447 & 9'o777: q = 49'o0200000004400047; // (jump) a=0 m=m[0] pc 440, jump-always
          ~9'o450 & 9'o777: q = 49'o0002003000310310; // (alu) M+A [ADD] a=40 m=6 m[6] C=0 alu-> -><none>,m[6]
          // PROCESS-MAIN-MEM-SECTION
          ~9'o451 & 9'o777: q = 49'o4200000005130647; // (jump) a=0 m=m[0] pc 513, P !next jump-always
          ~9'o452 & 9'o777: q = 49'o4003043400250310; // (alu) M+A [ADD] a=61 m=7 m[7] C=0 alu-> -><none>,m[5]
          // MAIN-MEM-LOOP
          ~9'o453 & 9'o777: q = 49'o0200103004120243; // (jump) a=2 m=m[6] pc 412, !next M-src = A-src
          ~9'o454 & 9'o777: q = 49'o0200000005570447; // (jump) a=0 m=m[0] pc 557, P jump-always
          ~9'o455 & 9'o777: q = 49'o4000002400410030; // (alu) SETM a=0 m=5 m[5] C=0 alu-> -><none>,m[10]
          ~9'o456 & 9'o777: q = 49'o0002002400250310; // (alu) M+A [ADD] a=40 m=5 m[5] C=0 alu-> -><none>,m[5]
          ~9'o457 & 9'o777: q = 49'o4002342000210310; // (alu) M+A [ADD] a=47 m=4 m[4] C=0 alu-> -><none>,m[4]
          ~9'o460 & 9'o777: q = 49'o4200000004530047; // (jump) a=0 m=m[0] pc 453, jump-always
          ~9'o461 & 9'o777: q = 49'o4002003000310264; // (alu) M-A-1 [M-A-1] a=40 m=6 m[6] C=1 alu-> -><none>,m[6]
          // PROCESS-A-MEM-SECTION
          ~9'o462 & 9'o777: q = 49'o4002003030010264; // (alu) M-A-1 [M-A-1] a=40 m=6 m[6] C=1 alu-> ->PDL ptr ,m[0]
          // A-MEM-LOOP
          ~9'o463 & 9'o777: q = 49'o4200103404720243; // (jump) a=2 m=m[7] pc 472, !next M-src = A-src
          ~9'o464 & 9'o777: q = 49'o0600103000211266; // (byte) a=2 m=m[6] ldb pos=26, width=26 -><none>,m[4]
          ~9'o465 & 9'o777: q = 49'o0200102000340343; // (jump) a=2 m=m[4] pc 34, !next !jump M-src = A-src
          ~9'o466 & 9'o777: q = 49'o0200000005130447; // (jump) a=0 m=m[0] pc 513, P jump-always
          ~9'o467 & 9'o777: q = 49'o4002003400350264; // (alu) M-A-1 [M-A-1] a=40 m=7 m[7] C=1 alu-> -><none>,m[7]
          ~9'o470 & 9'o777: q = 49'o4200000004630047; // (jump) a=0 m=m[0] pc 463, jump-always
          ~9'o471 & 9'o777: q = 49'o4000002022010030; // (alu) SETM a=0 m=4 m[4] C=0 alu-> ->PDL[ptr],push ,m[0]
          // DONE-LOADING
          ~9'o472 & 9'o777: q = 49'o0002000000410050; // (alu) SETA a=40 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o473 & 9'o777: q = 49'o0200000005570447; // (jump) a=0 m=m[0] pc 557, P jump-always
          ~9'o474 & 9'o777: q = 49'o4000000000210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[4]
          ~9'o475 & 9'o777: q = 49'o0002340000010053; // (alu) SETA a=47 m=0 m[0] C=0 alu-> Q-R -><none>,m[0]
          ~9'o476 & 9'o777: q = 49'o0602141460030005; // (byte) a=43 m=m[3] dpb pos=5, width=1 ->MD ,m[0]
          ~9'o477 & 9'o777: q = 49'o0602201440030011; // (byte) a=44 m=m[3] dpb pos=11, width=1 ->VMA ,m[0]
          ~9'o500 & 9'o777: q = 49'o4000000026010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->PDL index ,m[0]
          // FILL-M-LOOP
          ~9'o501 & 9'o777: q = 49'o0600121434030216; // (byte) a=2 m=PDL-index 216 dpb pos=16, width=5 ->OA-reg-lo ,m[0]
          ~9'o502 & 9'o777: q = 49'o4000022400010030; // (alu) SETM a=0 m=45 PDL-buffer C=0 alu-> -><none>,m[0]
          ~9'o503 & 9'o777: q = 49'o0000021426010344; // (alu) M a=0 m=43 PDL-index 344 C=1 alu-> ->PDL index ,m[0]
          ~9'o504 & 9'o777: q = 49'o0200021405010333; // (jump) a=0 m=PDL-index 333 pc 501, !next !jump m-rot<< 27
          // FILL-A-LOOP
          ~9'o505 & 9'o777: q = 49'o4600121434030456; // (byte) a=2 m=PDL-index 456 dpb pos=16, width=12 ->OA-reg-lo ,m[0]
          ~9'o506 & 9'o777: q = 49'o0000022600010030; // (alu) SETM a=0 m=45 PDL-buffer C=0 alu-> ->a_mem[0]
          ~9'o507 & 9'o777: q = 49'o0000021426010344; // (alu) M a=0 m=43 PDL-index 344 C=1 alu-> ->PDL index ,m[0]
          ~9'o510 & 9'o777: q = 49'o4200121405050343; // (jump) a=2 m=PDL-index 343 pc 505, !next !jump M-src = A-src
          // JUMP-TO-6
          ~9'o511 & 9'o777: q = 49'o0200000000060047; // (jump) a=0 m=m[0] pc 6, jump-always
          ~9'o512 & 9'o777: q = 49'o0000024044010030; // (alu) SETM a=0 m=50 VMA C=0 alu-> ->VMA,start-write ,m[0]
          // GET-NEXT-WORD
          ~9'o513 & 9'o777: q = 49'o4202345005200341; // (jump) a=47 m=m[12] pc 520, !next !jump M-src < A-src
          ~9'o514 & 9'o777: q = 49'o0000005042010030; // (alu) SETM a=0 m=12 m[12] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o515 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o516 & 9'o777: q = 49'o4100025000210030; // popj; (alu) SETM a=0 m=52 MD C=0 alu-> -><none>,m[4]
          ~9'o517 & 9'o777: q = 49'o0002005000510310; // (alu) M+A [ADD] a=40 m=12 m[12] C=0 alu-> -><none>,m[12]
          // GET-NEXT-PAGE
          ~9'o520 & 9'o777: q = 49'o0000000000510000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[12]
          ~9'o521 & 9'o777: q = 49'o4203141000360341; // (jump) a=63 m=m[2] pc 36, !next !jump M-src < A-src
          ~9'o522 & 9'o777: q = 49'o0003141603150310; // (alu) M+A [ADD] a=63 m=3 m[3] C=0 alu-> ->a_mem[63]
          ~9'o523 & 9'o777: q = 49'o0003100000410050; // (alu) SETA a=62 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o524 & 9'o777: q = 49'o0200000005570447; // (jump) a=0 m=m[0] pc 557, P jump-always
          ~9'o525 & 9'o777: q = 49'o4000000000210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[4]
          ~9'o526 & 9'o777: q = 49'o4200000005130047; // (jump) a=0 m=m[0] pc 513, jump-always
          ~9'o527 & 9'o777: q = 49'o0003101203110314; // (alu) M+A [ADD] a=62 m=2 m[2] C=1 alu-> ->a_mem[62]
          // DISK-RECALIBRATE
          ~9'o530 & 9'o777: q = 49'o0003000042010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o531 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o532 & 9'o777: q = 49'o4200025005300300; // (jump) a=0 m=MD pc 530, !next !jump m-rot<< 0
          ~9'o533 & 9'o777: q = 49'o4000100060010050; // (alu) SETA a=2 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o534 & 9'o777: q = 49'o4003000040010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA ,m[0]
          ~9'o535 & 9'o777: q = 49'o4002064044010310; // (alu) M+A [ADD] a=41 m=50 VMA C=0 alu-> ->VMA,start-write ,m[0]
          ~9'o536 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o537 & 9'o777: q = 49'o0003000042010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o540 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o541 & 9'o777: q = 49'o0200025005300227; // (jump) a=0 m=MD pc 530, !next m-rot<< 23
          ~9'o542 & 9'o777: q = 49'o4000000000210000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[4]
          ~9'o543 & 9'o777: q = 49'o4000000000410000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o544 & 9'o777: q = 49'o0002200000450050; // (alu) SETA a=44 m=0 m[0] C=0 alu-> -><none>,m[11]
          ~9'o545 & 9'o777: q = 49'o0200000005620447; // (jump) a=0 m=m[0] pc 562, P jump-always
          ~9'o546 & 9'o777: q = 49'o0600441400470010; // (byte) a=11 m=m[3] dpb pos=10, width=1 -><none>,m[11]
          ~9'o547 & 9'o777: q = 49'o4000000000410000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[10]
          ~9'o550 & 9'o777: q = 49'o0200000005620447; // (jump) a=0 m=m[0] pc 562, P jump-always
          ~9'o551 & 9'o777: q = 49'o0002540000450050; // (alu) SETA a=53 m=0 m[0] C=0 alu-> -><none>,m[11]
          // AWAIT-DRIVE-READY
          ~9'o552 & 9'o777: q = 49'o0003000042010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o553 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o554 & 9'o777: q = 49'o4002465000450010; // (alu) AND a=51 m=52 MD C=0 alu-> -><none>,m[11]
          ~9'o555 & 9'o777: q = 49'o4200104405520343; // (jump) a=2 m=m[11] pc 552, !next !jump M-src = A-src
          ~9'o556 & 9'o777: q = 49'o0200000000001247; // (jump) a=0 m=m[0] pc 0, R !next jump-always
          // DISK-READ
          ~9'o557 & 9'o777: q = 49'o4200000005620047; // (jump) a=0 m=m[0] pc 562, jump-always
          ~9'o560 & 9'o777: q = 49'o0000000000450000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[11]
          // DISK-WRITE
          ~9'o561 & 9'o777: q = 49'o4002240000450050; // (alu) SETA a=45 m=0 m[0] C=0 alu-> -><none>,m[11]
          // DISK-OP
          ~9'o562 & 9'o777: q = 49'o0003000042010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o563 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o564 & 9'o777: q = 49'o0200025005620300; // (jump) a=0 m=MD pc 562, !next !jump m-rot<< 0
          ~9'o565 & 9'o777: q = 49'o4600102060020750; // (byte) a=2 m=m[4] sel dep (a<-m&mask) pos=10, width=20 ->MD ,m[0]
          ~9'o566 & 9'o777: q = 49'o0600101444030440; // (byte) a=2 m=m[3] dpb pos=0, width=12 ->VMA,start-write ,m[0]
          ~9'o567 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o570 & 9'o777: q = 49'o0000004460010030; // (alu) SETM a=0 m=11 m[11] C=0 alu-> ->MD ,m[0]
          ~9'o571 & 9'o777: q = 49'o0003000044010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-write ,m[0]
          ~9'o572 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o573 & 9'o777: q = 49'o4600101460030400; // (byte) a=2 m=m[3] dpb pos=0, width=11 ->MD ,m[0]
          ~9'o574 & 9'o777: q = 49'o0002024044010310; // (alu) M+A [ADD] a=40 m=50 VMA C=0 alu-> ->VMA,start-write ,m[0]
          ~9'o575 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o576 & 9'o777: q = 49'o4200000006170447; // (jump) a=0 m=m[0] pc 617, P jump-always
          ~9'o577 & 9'o777: q = 49'o4002740000450050; // (alu) SETA a=57 m=0 m[0] C=0 alu-> -><none>,m[11]
          ~9'o600 & 9'o777: q = 49'o0600123460030560; // (byte) a=2 m=Q dpb pos=20, width=14 ->MD ,m[0]
          ~9'o601 & 9'o777: q = 49'o4200000006170447; // (jump) a=0 m=m[0] pc 617, P jump-always
          ~9'o602 & 9'o777: q = 49'o0002700000450050; // (alu) SETA a=56 m=0 m[0] C=0 alu-> -><none>,m[11]
          ~9'o603 & 9'o777: q = 49'o4600423400430350; // (byte) a=10 m=Q dpb pos=10, width=10 -><none>,m[10]
          ~9'o604 & 9'o777: q = 49'o4000425060010070; // (alu) IOR a=10 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o605 & 9'o777: q = 49'o0002024044010310; // (alu) M+A [ADD] a=40 m=50 VMA C=0 alu-> ->VMA,start-write ,m[0]
          ~9'o606 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o607 & 9'o777: q = 49'o0002024044010310; // (alu) M+A [ADD] a=40 m=50 VMA C=0 alu-> ->VMA,start-write ,m[0]
          ~9'o610 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          // DISK-WAIT
          ~9'o611 & 9'o777: q = 49'o0003000042010050; // (alu) SETA a=60 m=0 m[0] C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o612 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o613 & 9'o777: q = 49'o4200025006110300; // (jump) a=0 m=MD pc 611, !next !jump m-rot<< 0
          ~9'o614 & 9'o777: q = 49'o0002525000410010; // (alu) AND a=52 m=52 MD C=0 alu-> -><none>,m[10]
          ~9'o615 & 9'o777: q = 49'o0200104000400343; // (jump) a=2 m=m[10] pc 40, !next !jump M-src = A-src
          ~9'o616 & 9'o777: q = 49'o0200000000001247; // (jump) a=0 m=m[0] pc 0, R !next jump-always
          // DIV
          ~9'o617 & 9'o777: q = 49'o4200104006220141; // (jump) a=2 m=m[10] pc 622, !jump M-src < A-src
          ~9'o620 & 9'o777: q = 49'o4000004203210033; // (alu) SETM a=0 m=10 m[10] C=0 alu-> Q-R ->a_mem[64]
          ~9'o621 & 9'o777: q = 49'o0003201000010267; // (alu) M-A-1 [M-A-1] a=64 m=2 m[2] C=1 alu-> Q-R -><none>,m[0]
          ~9'o622 & 9'o777: q = 49'o4000441000430511; // (alu) init-div-step a=11 m=2 m[2] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o623 & 9'o777: q = 49'o4200023400420200; // (jump) a=0 m=Q pc 42, !next m-rot<< 0
          ~9'o624 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o625 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o626 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o627 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o630 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o631 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o632 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o633 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o634 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o635 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o636 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o637 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o640 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o641 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o642 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o643 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o644 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o645 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o646 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o647 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o650 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o651 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o652 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o653 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o654 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o655 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o656 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o657 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o660 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o661 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o662 & 9'o777: q = 49'o0000444000430411; // (alu) div-step a=11 m=10 m[10] C=0 alu<<+q31 <<Q -><none>,m[10]
          ~9'o663 & 9'o777: q = 49'o4000444000410411; // (alu) div-step a=11 m=10 m[10] C=0 alu-> <<Q -><none>,m[10]
          ~9'o664 & 9'o777: q = 49'o4203201006670042; // (jump) a=64 m=m[2] pc 667, M-src <= A-src
          ~9'o665 & 9'o777: q = 49'o4000444000410450; // (alu) rem-corr a=11 m=10 m[10] C=0 alu-> -><none>,m[10]
          ~9'o666 & 9'o777: q = 49'o4000401000410264; // (alu) M-A-1 [M-A-1] a=10 m=2 m[2] C=1 alu-> -><none>,m[10]
          ~9'o667 & 9'o777: q = 49'o4003204603210060; // (alu) XOR a=64 m=11 m[11] C=0 alu-> ->a_mem[64]
          ~9'o670 & 9'o777: q = 49'o0203201000001242; // (jump) a=64 m=m[2] pc 0, R !next M-src <= A-src
          ~9'o671 & 9'o777: q = 49'o4100023603210030; // popj; (alu) SETM a=0 m=47 Q C=0 alu-> ->a_mem[64]
          ~9'o672 & 9'o777: q = 49'o0003201000010267; // (alu) M-A-1 [M-A-1] a=64 m=2 m[2] C=1 alu-> Q-R -><none>,m[0]
          ~9'o673 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o674 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o675 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o676 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o677 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o700 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o701 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o702 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o703 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o704 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o705 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o706 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o707 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o710 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o711 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o712 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o713 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o714 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o715 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o716 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o717 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o720 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o721 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o722 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o723 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o724 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o725 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o726 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o727 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o730 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o731 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o732 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o733 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o734 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o735 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o736 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o737 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o740 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o741 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o742 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o743 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o744 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o745 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o746 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o747 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o750 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o751 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o752 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o753 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o754 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o755 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o756 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o757 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o760 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o761 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o762 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o763 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o764 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o765 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o766 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o767 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o770 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o771 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o772 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o773 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o774 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o775 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o776 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
          ~9'o777 & 9'o777: q = 49'o4000000000000000; // (alu) no-op
        endcase

 `ifdef debug_patch_rom
        case (addr)
          // Clear local memories in FPGA.
          ~9'o175 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o202 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o226 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o232 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o236 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o244 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o251 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o256 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o263 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o314 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
        endcase
 `endif

 `ifdef debug_sdram_rom
        case (addr)
          ~9'o000 & 9'o777: q = 49'o0000000000150173; // (alu) SETO a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[3]
          ~9'o001 & 9'o777: q = 49'o0200000000450247; // (jump) a=0 m=m[0] pc 45, !next jump-always
          ~9'o045 & 9'o777: q = 49'o4000000000110003; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[2]
          ~9'o046 & 9'o777: q = 49'o0000000000010003; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> Q-R -><none>,m[0]
          ~9'o047 & 9'o777: q = 49'o0600101602030000; // (byte) a=2 m=m[3] dpb pos=0, width=1 ->a_mem[40]
          ~9'o050 & 9'o777: q = 49'o0600101602070001; // (byte) a=2 m=m[3] dpb pos=1, width=1 ->a_mem[41]
          ~9'o051 & 9'o777: q = 49'o0600101602130040; // (byte) a=2 m=m[3] dpb pos=0, width=2 ->a_mem[42]
          ~9'o052 & 9'o777: q = 49'o4600101602170002; // (byte) a=2 m=m[3] dpb pos=2, width=1 ->a_mem[43]
          ~9'o053 & 9'o777: q = 49'o0602001602230002; // (byte) a=40 m=m[3] dpb pos=2, width=1 ->a_mem[44]
          ~9'o054 & 9'o777: q = 49'o0602001602270003; // (byte) a=40 m=m[3] dpb pos=3, width=1 ->a_mem[45]
          ~9'o055 & 9'o777: q = 49'o0600101602330005; // (byte) a=2 m=m[3] dpb pos=5, width=1 ->a_mem[46]
          ~9'o056 & 9'o777: q = 49'o0600101602370010; // (byte) a=2 m=m[3] dpb pos=10, width=1 ->a_mem[47]
          ~9'o057 & 9'o777: q = 49'o0600101602430015; // (byte) a=2 m=m[3] dpb pos=15, width=1 ->a_mem[50]
          ~9'o060 & 9'o777: q = 49'o0600101602470104; // (byte) a=2 m=m[3] dpb pos=4, width=3 ->a_mem[51]
          ~9'o061 & 9'o777: q = 49'o0602441602470110; // (byte) a=51 m=m[3] dpb pos=10, width=3 ->a_mem[51]
          ~9'o062 & 9'o777: q = 49'o0602201602570011; // (byte) a=44 m=m[3] dpb pos=11, width=1 ->a_mem[53]
          ~9'o063 & 9'o777: q = 49'o4602541602570025; // (byte) a=53 m=m[3] dpb pos=25, width=1 ->a_mem[53]
          ~9'o064 & 9'o777: q = 49'o4600101602530144; // (byte) a=2 m=m[3] dpb pos=4, width=4 ->a_mem[52]
          ~9'o065 & 9'o777: q = 49'o4602501602530551; // (byte) a=52 m=m[3] dpb pos=11, width=14 ->a_mem[52]
          ~9'o066 & 9'o777: q = 49'o0602501602530027; // (byte) a=52 m=m[3] dpb pos=27, width=1 ->a_mem[52]
          ~9'o067 & 9'o777: q = 49'o0000000060010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o070 & 9'o777: q = 49'o0600101446030032; // (byte) a=2 m=m[3] dpb pos=32, width=1 ->VMA,write-map ,m[0]
          ~9'o071 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o072 & 9'o777: q = 49'o0000024400210030; // (alu) SETM a=0 m=51 MAP[MD] C=0 alu-> -><none>,m[4]
          ~9'o073 & 9'o777: q = 49'o0600102000250210; // (byte) a=2 m=m[4] ldb pos=10, width=5 -><none>,m[5]
          ~9'o074 & 9'o777: q = 49'o0200102400220343; // (jump) a=2 m=m[5] pc 22, !next !jump M-src = A-src
          ~9'o075 & 9'o777: q = 49'o4600101446230166; // (byte) a=2 m=m[3] dpb pos=26, width=4 ->VMA,write-map ,m[4]
          ~9'o076 & 9'o777: q = 49'o4600201400270400; // (byte) a=4 m=m[3] dpb pos=0, width=11 -><none>,m[5]
          ~9'o077 & 9'o777: q = 49'o0002340060010050; // (alu) SETA a=47 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o100 & 9'o777: q = 49'o0600241446030152; // (byte) a=5 m=m[3] dpb pos=12, width=4 ->VMA,write-map ,m[0]
          ~9'o101 & 9'o777: q = 49'o0600101603030302; // (byte) a=2 m=m[3] dpb pos=2, width=7 ->a_mem[60]
          ~9'o102 & 9'o777: q = 49'o0002365060010310; // (alu) M+A [ADD] a=47 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o103 & 9'o777: q = 49'o0600201400270041; // (byte) a=4 m=m[3] dpb pos=1, width=2 -><none>,m[5]
          ~9'o104 & 9'o777: q = 49'o4600241446030444; // (byte) a=5 m=m[3] dpb pos=4, width=12 ->VMA,write-map ,m[0]
          ~9'o105 & 9'o777: q = 49'o0002365060010310; // (alu) M+A [ADD] a=47 m=52 MD C=0 alu-> ->MD ,m[0]
          ~9'o106 & 9'o777: q = 49'o4600201446030000; // (byte) a=4 m=m[3] dpb pos=0, width=1 ->VMA,write-map ,m[0]
          ~9'o107 & 9'o777: q = 49'o0000000000010000; // (alu) SETZ a=0 m=0 m[0] C=0 alu-> -><none>,m[0]
          ~9'o110 & 9'o777: q = 49'o4000000040010170; // (alu) SETO a=0 m=0 m[0] C=0 alu-> ->VMA ,m[0]
          ~9'o111 & 9'o777: q = 49'o0002024042010310; // (alu) M+A [ADD] a=40 m=50 VMA C=0 alu-> ->VMA,start-read ,m[0]
          ~9'o112 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o113 & 9'o777: q = 49'o0000025064010030; // (alu) SETM a=0 m=52 MD C=0 alu-> ->MD,start-write ,m[0]
          ~9'o114 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o115 & 9'o777: q = 49'o0202364001110241; // (jump) a=47 m=VMA pc 111, !next M-src < A-src
          ~9'o116 & 9'o777: q = 49'o4002140060010050; // (alu) SETA a=43 m=0 m[0] C=0 alu-> ->MD ,m[0]
          ~9'o117 & 9'o777: q = 49'o4602201444030011; // (byte) a=44 m=m[3] dpb pos=11, width=1 ->VMA,start-write ,m[0]
          ~9'o120 & 9'o777: q = 49'o4200000000240244; // (jump) a=0 m=m[0] pc 24, !next pf
          ~9'o121 & 9'o777: q = 49'o0200000001110247; // (jump) a=0 m=m[0] pc 111, !next jump-always
          ~9'o122 & 9'o777: q = 49'o0000000000000000;
        endcase
 `endif
     end
`endif

`ifdef debug_prom
   always @(posedge clk)
     begin
        $display("prom: prom addr %o val 0x%x %o; @%t",
                 addr, q, q, $time);
     end
`endif

endmodule
