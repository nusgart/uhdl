module Q();

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
