// Notes on defines:
//   - ISE: Defined during synthesizing under Xilinx ISE.
//   - SIMULATION: Defined during simulations.

// Default behaviour.
`define ISE
`undef SIMULATION

// When running under Xilinx ISim, XILINX_ISIM is defined.
`ifdef XLINX_ISIM
 `undef ISE
 `define SIMULATION
`endif

// For LPDDR model.
`define x512Mb
`define FULL_MEM
`define sg5
`define x16
