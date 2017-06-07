module Q(clk, reset, state_alu, state_write, state_mmu, state_fetch, alu, srcq, qs1, qs0, qdrive, q, ir, iralu);
   input [48:0] ir;
   input 	iralu;
   input 	clk, reset, state_alu, state_write, state_mmu, state_fetch;
   input [32:0] alu;
   input 	srcq;
   output 	qs1, qs0, qdrive;
   output reg [31:0] q;
   
   assign qs1 = ir[1] & iralu;
   assign qs0 = ir[0] & iralu;

   assign qdrive = srcq &
		   (state_alu || state_write || state_mmu || state_fetch);

   always @(posedge clk)
     if (reset)
       q <= 0;
     else
       if (state_fetch && (qs1 | qs0))
	 begin
	    case ( {qs1,qs0} )
	      2'b00: q <= q;
	      2'b01: q <= { q[30:0], ~alu[31] };
	      2'b10: q <= { alu[0], q[31:1] };
	      2'b11: q <= alu[31:0];
	    endcase
	 end

endmodule
