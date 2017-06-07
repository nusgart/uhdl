module IRAM ();

`ifdef use_ucode_ram
   part_16kx49ram i_IRAM(
			 .clk_a(clk),
			 .reset(reset),
			 .address_a(pc),
			 .q_a(iram),
			 .data_a(iwr),
			 .wren_a(iwe),
			 .rden_a(1'b1/*ice*/)
			 );

   assign fetch_out = 0;
   assign prefetch_out = 0;
`else
   // use top level ram controller
   assign mcr_addr = pc;
   assign iram = mcr_data_in;
   assign mcr_data_out = iwr;
   assign mcr_write = iwe;

   // for externals
   assign fetch_out = state_fetch && promdisabled;
   assign prefetch_out = ((need_mmu_state ? state_mmu : state_write) || state_prefetch) &&
			 promdisabled;
`endif

   assign pc_out = pc;
   assign state_out = state;
   assign machrun_out = machrun;

endmodule
