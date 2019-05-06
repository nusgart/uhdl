// scancode_rom.v --- mapping between PS/2 and Space Cadet scancodes

/* verilator lint_off COMBDLY */

`timescale 1ns/1ps
`default_nettype none

module scancode_rom(/*AUTOARG*/
   // Outputs
   data,
   // Inputs
   addr
   );

   input [8:0] addr;
   output [7:0] data;

   ////////////////////////////////////////////////////////////////////////////////

   parameter [7:0]
     LM_ROMAN_II	= 8'o001,
     LM_ROMAN_IV	= 8'o002,
     LM_MODELOCK	= 8'o003,
     LM_LEFT_SUPER	= 8'o005,
     LM_ALTLOCK		= 8'o015,
     LM_HAND_RIGHT	= 8'o017,
     LM_LEFT_CONTROL	= 8'o020,
     LM_TAB		= 8'o022,
     LM_RUBOUT		= 8'o023,
     LM_LEFT_SHIFT	= 8'o024,
     LM_RIGHT_SHIFT	= 8'o025,
     LM_RIGHT_CONTROL	= 8'o026,
     LM_HOLD_OUTPUT	= 8'o030,
     LM_RIGHT_GREEK	= 8'o035,
     LM_LINE		= 8'o036,
     LM_TERMINAL	= 8'o040,
     LM_NETWORK		= 8'o042,
     LM_LEFT_GREEK	= 8'o044,
     LM_LEFT_META	= 8'o045,
     LM_STATUS		= 8'o046,
     LM_RESUME		= 8'o047,
     LM_CLEAR_SCREEN	= 8'o050,
     LM_PAGE		= 8'o050,
     LM_RIGHT_SUPER	= 8'o065,
     LM_ABORT		= 8'o067,
     LM_MACRO		= 8'o100,
     LM_ROMAN_I		= 8'o101,
     LM_ROMAN_III	= 8'o102,
     LM_LEFT_TOP	= 8'o104,
     LM_HAND_UP		= 8'o106,
     LM_CALL		= 8'o107,
     LM_CLEAR_INPUT	= 8'o110,
     LM_HELP		= 8'o116,
     LM_HAND_LEFT	= 8'o117,
     LM_QUOTE		= 8'o120,
     LM_CAPSLOCK	= 8'o125,
     LM_RETURN		= 8'o136,
     LM_SYSTEM		= 8'o141,
     LM_LEFT_HYPER	= 8'o145,
     LM_RIGHT_TOP	= 8'o155,
     LM_END		= 8'o156,
     LM_DELETE		= 8'o157,
     LM_OVERSTRIKE	= 8'o160,
     LM_RIGHT_META	= 8'o165,
     LM_BREAK		= 8'o167,
     LM_STOP_OUTPUT	= 8'o170,
     LM_RIGHT_HYPER	= 8'o175,
     LM_HAND_DOWN	= 8'o176;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [7:0]		data;
   // End of automatics

   ////////////////////////////////////////////////////////////////////////////////

   always @addr
     case (addr)
       9'h012: data <= LM_LEFT_SHIFT;    // Left Shift
       9'h059: data <= LM_RIGHT_SHIFT;   // Right Shift
       9'h11f: data <= LM_LEFT_TOP;      // Left GUI
       9'h127: data <= LM_RIGHT_TOP;     // Right GUI
       9'h014: data <= LM_LEFT_CONTROL;  // Left Control
       9'h114: data <= LM_RIGHT_CONTROL; // Right Control
       9'h011: data <= LM_LEFT_META;     // Left Alt
       9'h111: data <= LM_RIGHT_META;    // Right Alt
       9'h058: data <= LM_CAPSLOCK;      // Caps Lock
       9'h005: data <= LM_TERMINAL;      // F1
       9'h006: data <= LM_SYSTEM;	 // F2
       9'h004: data <= LM_NETWORK;	 // F3
       9'h00c: data <= LM_ABORT;	 // F4
       9'h003: data <= LM_CLEAR_INPUT;   // F5
       9'h00b: data <= LM_HELP;		 // F6
       9'h083: data <= LM_CLEAR_SCREEN;  // F7
       9'h007: data <= LM_BREAK;	 // F12
       9'h16c: data <= LM_CALL;		 // Home
       9'h169: data <= LM_END;		 // End
       9'h17d: data <= LM_BREAK;	 // Page Up
       9'h17a: data <= LM_RESUME;	 // Page Down
       9'h170: data <= LM_ABORT;	 // Insert
       9'h171: data <= LM_OVERSTRIKE;    // Delete
       9'h076: data <= LM_TERMINAL;      // Esc
       9'h175: data <= LM_HAND_UP;	 // Up
       9'h172: data <= LM_HAND_DOWN;     // Down
       9'h16b: data <= LM_HAND_LEFT;     // Left
       9'h174: data <= LM_HAND_RIGHT;    // Right
       9'h066: data <= LM_RUBOUT;	 // Backspace
       9'h05a: data <= LM_RETURN;	 // Enter
       9'h00d: data <= LM_TAB;		 // TAB
       9'h01c: data <= 8'o123;		 // A
       9'h032: data <= 8'o114;		 // B
       9'h021: data <= 8'o164;		 // C
       9'h023: data <= 8'o163;		 // D
       9'h024: data <= 8'o162;		 // E
       9'h02b: data <= 8'o013;		 // F
       9'h034: data <= 8'o113;		 // G
       9'h033: data <= 8'o053;		 // H
       9'h043: data <= 8'o032;		 // I
       9'h03b: data <= 8'o153;		 // J
       9'h042: data <= 8'o033;		 // K
       9'h04b: data <= 8'o073;		 // L
       9'h03a: data <= 8'o154;		 // M
       9'h031: data <= 8'o054;		 // N
       9'h044: data <= 8'o072;		 // O
       9'h04d: data <= 8'o172;		 // P
       9'h015: data <= 8'o122;		 // Q
       9'h02d: data <= 8'o012;		 // R
       9'h01b: data <= 8'o063;		 // S
       9'h02c: data <= 8'o112;		 // T
       9'h03c: data <= 8'o152;		 // U
       9'h02a: data <= 8'o014;		 // V
       9'h01d: data <= 8'o062;		 // W
       9'h022: data <= 8'o064;		 // X
       9'h035: data <= 8'o052;		 // Y
       9'h01a: data <= 8'o124;		 // Z
       9'h045: data <= 8'o171;		 // 0
       9'h016: data <= 8'o121;		 // 1
       9'h01e: data <= 8'o061;		 // 2
       9'h026: data <= 8'o161;		 // 3
       9'h025: data <= 8'o011;		 // 4
       9'h02e: data <= 8'o111;		 // 5
       9'h036: data <= 8'o051;		 // 6
       9'h03d: data <= 8'o151;		 // 7
       9'h03e: data <= 8'o031;		 // 8
       9'h046: data <= 8'o071;		 // 9
       9'h00e: data <= 8'o077;		 // `
       9'h04e: data <= 8'o131;		 // -
       9'h055: data <= 8'o126;		 // =
       9'h05d: data <= 8'o037;		 // \
       9'h054: data <= 8'o132;		 // [
       9'h05b: data <= 8'o137;		 // ]
       9'h04c: data <= 8'o173;		 // ;
       9'h052: data <= 8'o133;		 // '
       9'h041: data <= 8'o034;		 // ,
       9'h049: data <= 8'o074;		 //
       9'h04a: data <= 8'o174;		 // /
       9'h029: data <= 8'o134;		 // Space

       // All other keys are undefined.
       default: data <= 0;
     endcase

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
