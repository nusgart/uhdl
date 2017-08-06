// Notes on defines:
//   - ISE: Defined during synthesizing under Xilinx ISE.
//   - SIMULATION: Defined during simulations.
//
//   - lx45_real_sdram: Use real LPDDR (for synthesis).
//   - lx45_fake_sdram: Use fake LPDDR model (for simulation).

// Default behaviour.
`define ISE
`undef SIMULATION

// When running under Xilinx ISim, XILINX_ISIM is defined.
`ifdef XLINX_ISIM
 `undef ISE
 `define SIMULATION
`endif

`ifdef ISE
 `define lx45_real_sdram
 `undef lx45_fake_sdram
`elsif XILINX_ISIM
 `undef lx45_real_sdram
 `define lx45_fake_sdram
`endif

// For LPDDR model.
`define x512Mb
`define FULL_MEM
`define sg5
`define x16
