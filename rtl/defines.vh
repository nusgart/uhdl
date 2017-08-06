// Notes on defines:
//   - ISE: Defined during synthesizing under Xilinx ISE.
//   - SIMULATION: Defined during simulations.
//
//   - CHIPSCOPE_CADDR: Enable Chipscope for caddr module.
//   - CHIPSCOPE_MMC: Likewise, but for mmc module.
//   - CHIPSCOPE_MMC_BD: Likewise, but for mmc_block_dev module.
  
// Default behaviour.
`define ISE
`undef SIMULATION

// When running under Xilinx ISim, XILINX_ISIM is defined.
`ifdef XILINX_ISIM
 `undef ISE
 `define SIMULATION
`endif

// When simulating use the LPDDR model, otherwise the real thing.
`ifdef SIMULATION
 `undef lx45_real_sdram
 `define lx45_fake_sdram
`else 
  `define lx45_real_sdram
 `undef lx45_fake_sdram
`endif

// For LPDDR model.
`define x512Mb
`define FULL_MEM
`define sg5
`define x16
