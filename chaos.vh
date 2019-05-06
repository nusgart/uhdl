`ifndef MY_ADDR
 `define MY_ADDR 16'o4401
`endif

`define CHAOS_CSR_TIMER_INTERRUPT_ENABLE 16'o1	  // read/write
`define CHAOS_CSR_LOOP_BACK              16'o2	  // read/write
`define CHAOS_CSR_RECEIVE_ALL            16'o4	  // read/write
`define CHAOS_CSR_RECEIVER_CLEAR         16'o10	  // write only
`define CHAOS_CSR_RECEIVE_ENABLE         16'o20	  // read/write
`define CHAOS_CSR_TRANSMIT_ENABLE        16'o40	  // read/write
`define CHAOS_CSR_TRANSMIT_ABORT         16'o100	  // read only
`define CHAOS_CSR_TRANSMIT_DONE          16'o200	  // read only
`define CHAOS_CSR_TRANSMITTER_CLEAR      16'o400	  // write only
`define CHAOS_CSR_LOST_COUNT             16'o17000  // read only
`define CHAOS_CSR_RESET                  16'o20000  // write only
`define CHAOS_CSR_CRC_ERROR              16'o40000  // read only
`define CHAOS_CSR_RECEIVE_DONE           16'o100000 // read only
