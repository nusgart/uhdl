// IRAM
//
// TK		CADR	RAM 0K-4K, 0-11
// TK		CADR	RAM 4K-8K, 0-11
// TK		CADR	RAM 8K-12K, 0-11
// TK		CADR	RAM 12K-16K, 0-11
// TK		CADR	RAM 0K-4K, 12-24
// TK		CADR	RAM 4K-8K 12-23
// TK		CADR	RAM 8K-12K, 12-23
// TK		CADR	RAM 12K-16K, 12-23
// TK		CADR	RAM 0K-4K, 24-35
// TK		CADR	RAM 4K-8K, 24-35
// TK		CADR	RAM 8K-12K, 24-35
// TK		CADR	RAM 12K-16K, 24-35
// TK		CADR	RAM 0K-4K, 36-48
// TK		CADR	RAM 4K-8K, 36-48
// TK		CADR	RAM 8K-12K, 36-48
// TK		CADR	RAM 12K-16K, 36-48

module IRAM(clk, reset, pc, pc_out, state_out, iwr, iwe, iram, fetch_out, prefetch_out, machrun_out, mcr_data_in, state_fetch, machrun, state, need_mmu_state, state_mmu, state_write, state_prefetch, promdisabled);

   input clk;
   input reset;

   input state_fetch;
   input state_mmu;
   input state_prefetch;
   input state_write;

   input [13:0] pc;
   input [48:0] iwr;
   input [48:0] mcr_data_in;
   input [5:0]	state;
   input	iwe;
   input	machrun;
   input	need_mmu_state;
   input	promdisabled;
   output [13:0] pc_out;
   output [48:0] iram;
   output [5:0]  state_out;
   output	 fetch_out;
   output	 machrun_out;
   output	 prefetch_out;

   ////////////////////////////////////////////////////////////////////////////////

`define use_ucode_ram
`ifdef use_ucode_ram
   part_16kx49ram i_IRAM(
			 .clk_a(clk),
			 .reset(reset),
			 .address_a(pc),
			 .q_a(iram),
			 .data_a(iwr),
			 .wren_a(iwe),
			 .rden_a(1'b1) // ice
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
