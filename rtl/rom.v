/*
 * $Id$
 */

`define ROM_DELAY 10

/* dmask prom */

module part_32x8prom ( A, O, CE_N );

  input[4:0] A;
  input CE_N;
  output[7:0] O;
  reg [7:0] O;

  always @(A)
    case (A)
     5'h00: O <= 8'h00;
     5'h01: O <= 8'h01;
     5'h02: O <= 8'h03;
     5'h03: O <= 8'h07;
     5'h04: O <= 8'h0f;
     5'h05: O <= 8'h1f;
     5'h06: O <= 8'h3f;
     5'h07: O <= 8'h7f;
     default: O <= 8'h00;
    endcase
endmodule

/* left mask prom */

module part_32x32prom_maskleft( A, O, CE_N );

  input[4:0] A;
  input CE_N;
  output[31:0] O;
  reg[31:0] O;

  always @(A)
    case (A)
      5'h00: O <= 32'h00000001;
      5'h01: O <= 32'h00000003;
      5'h02: O <= 32'h00000007;
      5'h03: O <= 32'h0000000f;
      5'h04: O <= 32'h0000001f;
      5'h05: O <= 32'h0000003f;
      5'h06: O <= 32'h0000007f;
      5'h07: O <= 32'h000000ff;
      5'h08: O <= 32'h000001ff;
      5'h09: O <= 32'h000003ff;
      5'h0a: O <= 32'h000007ff;
      5'h0b: O <= 32'h00000fff;
      5'h0c: O <= 32'h00001fff;
      5'h0d: O <= 32'h00003fff;
      5'h0e: O <= 32'h00007fff;
      5'h0f: O <= 32'h0000ffff;
      5'h10: O <= 32'h0001ffff;
      5'h11: O <= 32'h0003ffff;
      5'h12: O <= 32'h0007ffff;
      5'h13: O <= 32'h000fffff;
      5'h14: O <= 32'h001fffff;
      5'h15: O <= 32'h003fffff;
      5'h16: O <= 32'h007fffff;
      5'h17: O <= 32'h00ffffff;
      5'h18: O <= 32'h01ffffff;
      5'h19: O <= 32'h03ffffff;
      5'h1a: O <= 32'h07ffffff;
      5'h1b: O <= 32'h0fffffff;
      5'h1c: O <= 32'h1fffffff;
      5'h1d: O <= 32'h3fffffff;
      5'h1e: O <= 32'h7fffffff;
      5'h1f: O <= 32'hffffffff;
  endcase

//always @(A or CE_N)
//  begin
//    $display("mask: %t mask-l addr %o val 0x%x, CE_N %d", $time, A, O, CE_N);
//  end

endmodule

/* right mask prom */

module part_32x32prom_maskright( A, O, CE_N );

  input[4:0] A;
  input CE_N;
  output[31:0] O;
  reg[31:0] O;

  always @(A)
    case (A)
      5'h00: O <= 32'hffffffff;
      5'h01: O <= 32'hfffffffe;
      5'h02: O <= 32'hfffffffc;
      5'h03: O <= 32'hfffffff8;
      5'h04: O <= 32'hfffffff0;
      5'h05: O <= 32'hffffffe0;
      5'h06: O <= 32'hffffffc0;
      5'h07: O <= 32'hffffff80;
      5'h08: O <= 32'hffffff00;
      5'h09: O <= 32'hfffffe00;
      5'h0a: O <= 32'hfffffc00;
      5'h0b: O <= 32'hfffff800;
      5'h0c: O <= 32'hfffff000;
      5'h0d: O <= 32'hffffe000;
      5'h0e: O <= 32'hffffc000;
      5'h0f: O <= 32'hffff8000;
      5'h10: O <= 32'hffff0000;
      5'h11: O <= 32'hfffe0000;
      5'h12: O <= 32'hfffc0000;
      5'h13: O <= 32'hfff80000;
      5'h14: O <= 32'hfff00000;
      5'h15: O <= 32'hffe00000;
      5'h16: O <= 32'hffc00000;
      5'h17: O <= 32'hff800000;
      5'h18: O <= 32'hff000000;
      5'h19: O <= 32'hfe000000;
      5'h1a: O <= 32'hfc000000;
      5'h1b: O <= 32'hf8000000;
      5'h1c: O <= 32'hf0000000;
      5'h1d: O <= 32'he0000000;
      5'h1e: O <= 32'hc0000000;
      5'h1f: O <= 32'h80000000;
    endcase

endmodule

/* boot prom */

module part_512x49prom( A, D, CE_N );

  input[8:0] A;
  input CE_N;
  output[48:0] D;

/*
  reg[48:0] prom[0:512];
  assign D = prom[A];
*/
//reg[48:0] D;
//always @(A) D <= 49'h000000000000;

  reg[48:0] D;

  always @(A)
   begin
    case (A)
      9'h000: D <= 49'h800000000000;
      9'h001: D <= 49'h800000000000;
      9'h002: D <= 49'h800000000000;
      9'h003: D <= 49'h800000000000;
      9'h004: D <= 49'h800000000000;
      9'h005: D <= 49'h800000000000;
      9'h006: D <= 49'h800000000000;
      9'h007: D <= 49'h800000000000;
      9'h008: D <= 49'h800000000000;
      9'h009: D <= 49'h800000000000;
      9'h00a: D <= 49'h800000000000;
      9'h00b: D <= 49'h800000000000;
      9'h00c: D <= 49'h800000000000;
      9'h00d: D <= 49'h800000000000;
      9'h00e: D <= 49'h800000000000;
      9'h00f: D <= 49'h800000000000;
      9'h010: D <= 49'h800000000000;
      9'h011: D <= 49'h800000000000;
      9'h012: D <= 49'h800000000000;
      9'h013: D <= 49'h800000000000;
      9'h014: D <= 49'h800000000000;
      9'h015: D <= 49'h800000000000;
      9'h016: D <= 49'h800000000000;
      9'h017: D <= 49'h800000000000;
      9'h018: D <= 49'h800000000000;
      9'h019: D <= 49'h800000000000;
      9'h01a: D <= 49'h800000000000;
      9'h01b: D <= 49'h800000000000;
      9'h01c: D <= 49'h800000000000;
      9'h01d: D <= 49'h800000000000;
      9'h01e: D <= 49'h800000000000;
      9'h01f: D <= 49'h800000000000;
      9'h020: D <= 49'h800000000000;
      9'h021: D <= 49'h800000000000;
      9'h022: D <= 49'h800000000000;
      9'h023: D <= 49'h800000000000;
      9'h024: D <= 49'h800000000000;
      9'h025: D <= 49'h800000000000;
      9'h026: D <= 49'h800000000000;
      9'h027: D <= 49'h800000000000;
      9'h028: D <= 49'h800000000000;
      9'h029: D <= 49'h800000000000;
      9'h02a: D <= 49'h800000000000;
      9'h02b: D <= 49'h800000000000;
      9'h02c: D <= 49'h800000000000;
      9'h02d: D <= 49'h800000000000;
      9'h02e: D <= 49'h800000000000;
      9'h02f: D <= 49'h800000000000;
      9'h030: D <= 49'h800000000000;
      9'h031: D <= 49'h800000000000;
      9'h032: D <= 49'h800000000000;
      9'h033: D <= 49'h800000000000;
      9'h034: D <= 49'h800000000000;
      9'h035: D <= 49'h800000000000;
      9'h036: D <= 49'h800000000000;
      9'h037: D <= 49'h800000000000;
      9'h038: D <= 49'h800000000000;
      9'h039: D <= 49'h800000000000;
      9'h03a: D <= 49'h800000000000;
      9'h03b: D <= 49'h800000000000;
      9'h03c: D <= 49'h800000000000;
      9'h03d: D <= 49'h800000000000;
      9'h03e: D <= 49'h800000000000;
      9'h03f: D <= 49'h800000000000;
      9'h040: D <= 49'h800000000000;
      9'h041: D <= 49'h800000000000;
      9'h042: D <= 49'h800000000000;
      9'h043: D <= 49'h800000000000;
      9'h044: D <= 49'h800000000000;
      9'h045: D <= 49'h0034080010b7;
      9'h046: D <= 49'h84009e0d1018;
      9'h047: D <= 49'h0834080002a2;
      9'h048: D <= 49'h8034260d1030;
      9'h049: D <= 49'h8008080210b4;
      9'h04a: D <= 49'h800920021128;
      9'h04b: D <= 49'h8834081b7022;
      9'h04c: D <= 49'h800920021109;
      9'h04d: D <= 49'h000920023109;
      9'h04e: D <= 49'h000920023109;
      9'h04f: D <= 49'h000920023109;
      9'h050: D <= 49'h000920023109;
      9'h051: D <= 49'h000920023109;
      9'h052: D <= 49'h000920023109;
      9'h053: D <= 49'h000920023109;
      9'h054: D <= 49'h000920023109;
      9'h055: D <= 49'h000920023109;
      9'h056: D <= 49'h000920023109;
      9'h057: D <= 49'h000920023109;
      9'h058: D <= 49'h000920023109;
      9'h059: D <= 49'h000920023109;
      9'h05a: D <= 49'h000920023109;
      9'h05b: D <= 49'h000920023109;
      9'h05c: D <= 49'h000920023109;
      9'h05d: D <= 49'h000920023109;
      9'h05e: D <= 49'h000920023109;
      9'h05f: D <= 49'h000920023109;
      9'h060: D <= 49'h000920023109;
      9'h061: D <= 49'h000920023109;
      9'h062: D <= 49'h000920023109;
      9'h063: D <= 49'h000920023109;
      9'h064: D <= 49'h000920023109;
      9'h065: D <= 49'h000920023109;
      9'h066: D <= 49'h000920023109;
      9'h067: D <= 49'h000920023109;
      9'h068: D <= 49'h000920023109;
      9'h069: D <= 49'h000920023109;
      9'h06a: D <= 49'h000920023109;
      9'h06b: D <= 49'h000920023109;
      9'h06c: D <= 49'h88009c022080;
      9'h06d: D <= 49'h800908023149;
      9'h06e: D <= 49'h0034080010b7;
      9'h06f: D <= 49'h8000220d101b;
      9'h070: D <= 49'h880220192061;
      9'h071: D <= 49'h0800000002a7;
      9'h072: D <= 49'h0802200200e3;
      9'h073: D <= 49'h002aa8021008;
      9'h074: D <= 49'h8800a81890c0;
      9'h075: D <= 49'h8800000140a4;
      9'h076: D <= 49'h003000881028;
      9'h077: D <= 49'h8800000140a4;
      9'h078: D <= 49'h0020a09010c8;
      9'h079: D <= 49'h8800000140a4;
      9'h07a: D <= 49'h0020a09010c8;
      9'h07b: D <= 49'h8008a8c01038;
      9'h07c: D <= 49'h98089c0230e8;
      9'h07d: D <= 49'h002e00025028;
      9'h07e: D <= 49'h88000018f127;
      9'h07f: D <= 49'h18029cc03170;
      9'h080: D <= 49'h802f00025028;
      9'h081: D <= 49'h88000018f127;
      9'h082: D <= 49'h8800000140a4;
      9'h083: D <= 49'h0020a09010c8;
      9'h084: D <= 49'h98020cc03100;
      9'h085: D <= 49'h8800000140a4;
      9'h086: D <= 49'h003000901028;
      9'h087: D <= 49'h000024c01018;
      9'h088: D <= 49'h8800000140a4;
      9'h089: D <= 49'h18020c903120;
      9'h08a: D <= 49'h980210c021e8;
      9'h08b: D <= 49'h0800a81720c0;
      9'h08c: D <= 49'h8800000140a4;
      9'h08d: D <= 49'h003000881028;
      9'h08e: D <= 49'h802500025028;
      9'h08f: D <= 49'h000000025000;
      9'h090: D <= 49'h880000172027;
      9'h091: D <= 49'h0800000002a7;
      9'h092: D <= 49'h88022416a0e3;
      9'h093: D <= 49'h8029a8025008;
      9'h094: D <= 49'h8800000140a4;
      9'h095: D <= 49'h003000881028;
      9'h096: D <= 49'h002b00025028;
      9'h097: D <= 49'h080000172127;
      9'h098: D <= 49'h800000021000;
      9'h099: D <= 49'h18090c027008;
      9'h09a: D <= 49'h080000172127;
      9'h09b: D <= 49'h002400025028;
      9'h09c: D <= 49'h800000021000;
      9'h09d: D <= 49'h800000011000;
      9'h09e: D <= 49'h0800a8158097;
      9'h09f: D <= 49'h8800000140a4;
      9'h0a0: D <= 49'h003000881028;
      9'h0a1: D <= 49'h8800000140a4;
      9'h0a2: D <= 49'h8021a09010c8;
      9'h0a3: D <= 49'h803000801028;
      9'h0a4: D <= 49'h800200c01028;
      9'h0a5: D <= 49'h8800a81580c0;
      9'h0a6: D <= 49'h8800000140a4;
      9'h0a7: D <= 49'h003000881028;
      9'h0a8: D <= 49'h00320a0c90cc;
      9'h0a9: D <= 49'h88000014b027;
      9'h0aa: D <= 49'h800000011000;
      9'h0ab: D <= 49'h08000016f127;
      9'h0ac: D <= 49'h003200021028;
      9'h0ad: D <= 49'h00330e0cd0c8;
      9'h0ae: D <= 49'h88330801e0e1;
      9'h0af: D <= 49'h000000029000;
      9'h0b0: D <= 49'h0020280290c8;
      9'h0b1: D <= 49'h8400a8011018;
      9'h0b2: D <= 49'h8800000140a4;
      9'h0b3: D <= 49'h000028881018;
      9'h0b4: D <= 49'h8827281500e1;
      9'h0b5: D <= 49'h0000a0901018;
      9'h0b6: D <= 49'h080000006027;
      9'h0b7: D <= 49'h88028c1450e3;
      9'h0b8: D <= 49'h00008c5810e4;
      9'h0b9: D <= 49'h000096001018;
      9'h0ba: D <= 49'h98028c70312e;
      9'h0bb: D <= 49'h08008c1410db;
      9'h0bc: D <= 49'h00008c5810e4;
      9'h0bd: D <= 49'h800094001018;
      9'h0be: D <= 49'h18028c70308e;
      9'h0bf: D <= 49'h800000581000;
      9'h0c0: D <= 49'h18240c803009;
      9'h0c1: D <= 49'h18230cc03005;
      9'h0c2: D <= 49'h00270000102b;
      9'h0c3: D <= 49'h800000011000;
      9'h0c4: D <= 49'h08000016f127;
      9'h0c5: D <= 49'h002000021028;
      9'h0c6: D <= 49'h800010481018;
      9'h0c7: D <= 49'h880000133027;
      9'h0c8: D <= 49'h80201c01d0b4;
      9'h0c9: D <= 49'h08000014b127;
      9'h0ca: D <= 49'h08021001c0e3;
      9'h0cb: D <= 49'h1802180112b6;
      9'h0cc: D <= 49'h88021c13a0a3;
      9'h0cd: D <= 49'h8020186010b4;
      9'h0ce: D <= 49'h8020180190b4;
      9'h0cf: D <= 49'h88000012b027;
      9'h0d0: D <= 49'h8027100110c8;
      9'h0d1: D <= 49'h0020140150c8;
      9'h0d2: D <= 49'h800014021018;
      9'h0d3: D <= 49'h08000016f127;
      9'h0d4: D <= 49'h08021810a0a3;
      9'h0d5: D <= 49'h80311c0150c8;
      9'h0d6: D <= 49'h88000014b1a7;
      9'h0d7: D <= 49'h0020180190c8;
      9'h0d8: D <= 49'h080000120027;
      9'h0d9: D <= 49'hb00400000800;
      9'h0da: D <= 49'h98021870314c;
      9'h0db: D <= 49'h80201c01d0b4;
      9'h0dc: D <= 49'h08000014b127;
      9'h0dd: D <= 49'h08021001c0e3;
      9'h0de: D <= 49'h980218011295;
      9'h0df: D <= 49'h88021c10a0a3;
      9'h0e0: D <= 49'h0020180190c8;
      9'h0e1: D <= 49'h080000115027;
      9'h0e2: D <= 49'h0805100003a7;
      9'h0e3: D <= 49'h1802187031ac;
      9'h0e4: D <= 49'h800010015018;
      9'h0e5: D <= 49'h08000014b127;
      9'h0e6: D <= 49'h80201c01d0b4;
      9'h0e7: D <= 49'h08000014b127;
      9'h0e8: D <= 49'h08021001c0e3;
      9'h0e9: D <= 49'h180218011232;
      9'h0ea: D <= 49'h88021c10a0a3;
      9'h0eb: D <= 49'h08000001a0a7;
      9'h0ec: D <= 49'h8823141320a3;
      9'h0ed: D <= 49'h0822141290a3;
      9'h0ee: D <= 49'h0821141200a3;
      9'h0ef: D <= 49'h8820141150a3;
      9'h0f0: D <= 49'h00001001d018;
      9'h0f1: D <= 49'h800010019018;
      9'h0f2: D <= 49'h08000014b127;
      9'h0f3: D <= 49'h800010015018;
      9'h0f4: D <= 49'h08000014b127;
      9'h0f5: D <= 49'h88000014b1a7;
      9'h0f6: D <= 49'h002700029028;
      9'h0f7: D <= 49'h0000aa0cd018;
      9'h0f8: D <= 49'h8800000140a4;
      9'h0f9: D <= 49'h0020188810c8;
      9'h0fa: D <= 49'h8032020c5028;
      9'h0fb: D <= 49'h8000aa0c9018;
      9'h0fc: D <= 49'h8800000140a4;
      9'h0fd: D <= 49'h0020188990c8;
      9'h0fe: D <= 49'h80201c01d0b4;
      9'h0ff: D <= 49'h8800000fb027;
      9'h100: D <= 49'h0004180190c8;
      9'h101: D <= 49'h8805a81020a3;
      9'h102: D <= 49'h8800000140a4;
      9'h103: D <= 49'h000018881018;
      9'h104: D <= 49'h08021c0180a3;
      9'h105: D <= 49'h0020180190c8;
      9'h106: D <= 49'h0000a8011018;
      9'h107: D <= 49'h8800000140a4;
      9'h108: D <= 49'h0020188990c8;
      9'h109: D <= 49'h0000a801d018;
      9'h10a: D <= 49'h8800000140a4;
      9'h10b: D <= 49'h98020c89b007;
      9'h10c: D <= 49'h8000a8015018;
      9'h10d: D <= 49'h8800000140a4;
      9'h10e: D <= 49'h0020188990c8;
      9'h10f: D <= 49'h8000aa0bd018;
      9'h110: D <= 49'h8800000140a4;
      9'h111: D <= 49'h0020188990c8;
      9'h112: D <= 49'h0000aa0b9018;
      9'h113: D <= 49'h8800000140a4;
      9'h114: D <= 49'h0020188990c8;
      9'h115: D <= 49'h0000aa0b5018;
      9'h116: D <= 49'h8800000140a4;
      9'h117: D <= 49'h0020188990c8;
      9'h118: D <= 49'h8000aa0b1018;
      9'h119: D <= 49'h8800000140a4;
      9'h11a: D <= 49'h0020188990c8;
      9'h11b: D <= 49'h0820a80160e3;
      9'h11c: D <= 49'h8800000140a4;
      9'h11d: D <= 49'h0020188990c8;
      9'h11e: D <= 49'h8805a80160e3;
      9'h11f: D <= 49'h8800000140a4;
      9'h120: D <= 49'h800200899028;
      9'h121: D <= 49'h98050c01701e;
      9'h122: D <= 49'h98050c01703a;
      9'h123: D <= 49'h18050c017016;
      9'h124: D <= 49'h98050c017011;
      9'h125: D <= 49'h18050c01700e;
      9'h126: D <= 49'h18050c017008;
      9'h127: D <= 49'h98050c017006;
      9'h128: D <= 49'h18020c017022;
      9'h129: D <= 49'h800000011000;
      9'h12a: D <= 49'h08000016f127;
      9'h12b: D <= 49'h800000021000;
      9'h12c: D <= 49'h800000011000;
      9'h12d: D <= 49'h080000171127;
      9'h12e: D <= 49'h002000021028;
      9'h12f: D <= 49'h0800001581a7;
      9'h130: D <= 49'h8800000140a4;
      9'h131: D <= 49'h98240c903009;
      9'h132: D <= 49'h802300c01028;
      9'h133: D <= 49'h0827a00c80a1;
      9'h134: D <= 49'h8800000140a4;
      9'h135: D <= 49'h0000a8d01018;
      9'h136: D <= 49'h8800000140a4;
      9'h137: D <= 49'h0020a08810c8;
      9'h138: D <= 49'h800000801078;
      9'h139: D <= 49'h000000001000;
      9'h13a: D <= 49'h98040c983000;
      9'h13b: D <= 49'h0027a8c010c8;
      9'h13c: D <= 49'h98050c983124;
      9'h13d: D <= 49'h18040c017021;
      9'h13e: D <= 49'h0027a8c010c8;
      9'h13f: D <= 49'h18020e0c30c2;
      9'h140: D <= 49'h18050c98306a;
      9'h141: D <= 49'h002700c01028;
      9'h142: D <= 49'h98040c017100;
      9'h143: D <= 49'h98020c993076;
      9'h144: D <= 49'h0802140120e3;
      9'h145: D <= 49'h180210015088;
      9'h146: D <= 49'h0000a4011018;
      9'h147: D <= 49'h000000001000;
      9'h148: D <= 49'h18020c98301a;
      9'h149: D <= 49'h000000c01000;
      9'h14a: D <= 49'h98020c10301b;
      9'h14b: D <= 49'h8020100110b4;
      9'h14c: D <= 49'h8802100b3063;
      9'h14d: D <= 49'h002600011028;
      9'h14e: D <= 49'h18020c10301c;
      9'h14f: D <= 49'h0022020bd028;
      9'h150: D <= 49'h8022020b9028;
      9'h151: D <= 49'h8800a80ab0d5;
      9'h152: D <= 49'h8020a8c010c8;
      9'h153: D <= 49'hb00400000800;
      9'h154: D <= 49'h1802a870314c;
      9'h155: D <= 49'h98020cc13011;
      9'h156: D <= 49'h8800a80a60d2;
      9'h157: D <= 49'h8020a8c010c8;
      9'h158: D <= 49'h8804100003a7;
      9'h159: D <= 49'h9802a87031ac;
      9'h15a: D <= 49'h800000c11000;
      9'h15b: D <= 49'h0800a80a00c8;
      9'h15c: D <= 49'h0027a8c010c8;
      9'h15d: D <= 49'h18020c983019;
      9'h15e: D <= 49'h18051098309b;
      9'h15f: D <= 49'h9802a8011093;
      9'h160: D <= 49'h000000c01000;
      9'h161: D <= 49'h0800a809c0c8;
      9'h162: D <= 49'h0028a8c010c8;
      9'h163: D <= 49'h18020c99701a;
      9'h164: D <= 49'h000000c01000;
      9'h165: D <= 49'h0802100980e3;
      9'h166: D <= 49'h8003100110c8;
      9'h167: D <= 49'h800000681000;
      9'h168: D <= 49'h002600011028;
      9'h169: D <= 49'h0802100940e3;
      9'h16a: D <= 49'h8003100110c8;
      9'h16b: D <= 49'h800008481018;
      9'h16c: D <= 49'h98020c61300a;
      9'h16d: D <= 49'h182a0e0ab017;
      9'h16e: D <= 49'h982a0e0ab169;
      9'h16f: D <= 49'h98020e0ab064;
      9'h170: D <= 49'h982b0e0af015;
      9'h171: D <= 49'h18240e0af009;
      9'h172: D <= 49'h18290e0a7048;
      9'h173: D <= 49'h18020e0a7044;
      9'h174: D <= 49'h18020e0a300d;
      9'h175: D <= 49'h18020e09f008;
      9'h176: D <= 49'h18020e09b005;
      9'h177: D <= 49'h18200e097003;
      9'h178: D <= 49'h18200e093002;
      9'h179: D <= 49'h98020e08f002;
      9'h17a: D <= 49'h18020e08b020;
      9'h17b: D <= 49'h18020e087001;
      9'h17c: D <= 49'h18020e083000;
      9'h17d: D <= 49'h88000407f0d6;
      9'h17e: D <= 49'h8002040050cc;
      9'h17f: D <= 49'h00000a001018;
      9'h180: D <= 49'h98020470312e;
      9'h181: D <= 49'h98020c007005;
      9'h182: D <= 49'h0801a807a0e3;
      9'h183: D <= 49'h800008001018;
      9'h184: D <= 49'h18020470308e;
      9'h185: D <= 49'h8003040050c8;
      9'h186: D <= 49'h98020cc03002;
      9'h187: D <= 49'h98020c007005;
      9'h188: D <= 49'h8802d00240e3;
      9'h189: D <= 49'h0803d00240e3;
      9'h18a: D <= 49'h0803a800c0e3;
      9'h18b: D <= 49'h98039cc013df;
      9'h18c: D <= 49'h00000c481018;
      9'h18d: D <= 49'h800008481018;
      9'h18e: D <= 49'h88009c00c0c1;
      9'h18f: D <= 49'h88009c00c0df;
      9'h190: D <= 49'h88009c00c080;
      9'h191: D <= 49'h80030c0010cb;
      9'h192: D <= 49'h08029c00c0e3;
      9'h193: D <= 49'h80020c0010cf;
      9'h194: D <= 49'h0802080100e3;
      9'h195: D <= 49'h88029c00e0e3;
      9'h196: D <= 49'h000000001003;
      9'h197: D <= 49'h08030c0100e3;
      9'h198: D <= 49'h08039c00e0e3;
      9'h199: D <= 49'h88009c00a0c1;
      9'h19a: D <= 49'h88009c00a0c2;
      9'h19b: D <= 49'h08009c00a0c3;
      9'h19c: D <= 49'h88009c00a0c4;
      9'h19d: D <= 49'h08009c00a0c5;
      9'h19e: D <= 49'h08009c00a0c6;
      9'h19f: D <= 49'h88009c00a0c7;
      9'h1a0: D <= 49'h88009c00a0c8;
      9'h1a1: D <= 49'h08009c00a0c9;
      9'h1a2: D <= 49'h08009c00a0ca;
      9'h1a3: D <= 49'h88009c00a0cb;
      9'h1a4: D <= 49'h08009c00a0cc;
      9'h1a5: D <= 49'h88009c00a0cd;
      9'h1a6: D <= 49'h88009c00a0ce;
      9'h1a7: D <= 49'h08009c00a0cf;
      9'h1a8: D <= 49'h88009c00a0d0;
      9'h1a9: D <= 49'h08009c00a0d1;
      9'h1aa: D <= 49'h08009c00a0d2;
      9'h1ab: D <= 49'h88009c00a0d3;
      9'h1ac: D <= 49'h08009c00a0d4;
      9'h1ad: D <= 49'h88009c00a0d5;
      9'h1ae: D <= 49'h88009c00a0d6;
      9'h1af: D <= 49'h08009c00a0d7;
      9'h1b0: D <= 49'h08009c00a0d8;
      9'h1b1: D <= 49'h88009c00a0d9;
      9'h1b2: D <= 49'h88009c00a0da;
      9'h1b3: D <= 49'h08009c00a0db;
      9'h1b4: D <= 49'h88009c00a0dc;
      9'h1b5: D <= 49'h08009c00a0dd;
      9'h1b6: D <= 49'h08009c00a0de;
      9'h1b7: D <= 49'h88009c00a0df;
      9'h1b8: D <= 49'h08009c00a0c0;
      9'h1b9: D <= 49'h00000000d07b;
      9'h1ba: D <= 49'h08009c00a081;
      9'h1bb: D <= 49'h08009c00a082;
      9'h1bc: D <= 49'h88009c00a083;
      9'h1bd: D <= 49'h08009c00a084;
      9'h1be: D <= 49'h88009c00a085;
      9'h1bf: D <= 49'h88009c00a086;
      9'h1c0: D <= 49'h08009c00a087;
      9'h1c1: D <= 49'h08009c00a088;
      9'h1c2: D <= 49'h88009c00a089;
      9'h1c3: D <= 49'h88009c00a08a;
      9'h1c4: D <= 49'h08009c00a08b;
      9'h1c5: D <= 49'h88009c00a08c;
      9'h1c6: D <= 49'h08009c00a08d;
      9'h1c7: D <= 49'h08009c00a08e;
      9'h1c8: D <= 49'h88009c00a08f;
      9'h1c9: D <= 49'h08009c00a090;
      9'h1ca: D <= 49'h88009c00a091;
      9'h1cb: D <= 49'h88009c00a092;
      9'h1cc: D <= 49'h08009c00a093;
      9'h1cd: D <= 49'h88009c00a094;
      9'h1ce: D <= 49'h08009c00a095;
      9'h1cf: D <= 49'h08009c00a096;
      9'h1d0: D <= 49'h88009c00a097;
      9'h1d1: D <= 49'h88009c00a098;
      9'h1d2: D <= 49'h08009c00a099;
      9'h1d3: D <= 49'h08009c00a09a;
      9'h1d4: D <= 49'h88009c00a09b;
      9'h1d5: D <= 49'h08009c00a09c;
      9'h1d6: D <= 49'h88009c00a09d;
      9'h1d7: D <= 49'h88009c00a09e;
      9'h1d8: D <= 49'h08009c00a09f;
      9'h1d9: D <= 49'h88009c00a080;
      9'h1da: D <= 49'h800000009003;
      9'h1db: D <= 49'h0800000244a7;
      9'h1dc: D <= 49'h000000001000;
      9'h1dd: D <= 49'h0800000224a7;
      9'h1de: D <= 49'h000000001000;
      9'h1df: D <= 49'h8800000204a7;
      9'h1e0: D <= 49'h000000001000;
      9'h1e1: D <= 49'h08000001e4a7;
      9'h1e2: D <= 49'h000000001000;
      9'h1e3: D <= 49'h88000001c4a7;
      9'h1e4: D <= 49'h000000001000;
      9'h1e5: D <= 49'h88000001a4a7;
      9'h1e6: D <= 49'h000000001000;
      9'h1e7: D <= 49'h0800000184a7;
      9'h1e8: D <= 49'h000000001000;
      9'h1e9: D <= 49'h8800000164a7;
      9'h1ea: D <= 49'h000000001000;
      9'h1eb: D <= 49'h0800000144a7;
      9'h1ec: D <= 49'h000000001000;
      9'h1ed: D <= 49'h0800000124a7;
      9'h1ee: D <= 49'h000000001000;
      9'h1ef: D <= 49'h8800000104a7;
      9'h1f0: D <= 49'h000000001000;
      9'h1f1: D <= 49'h88000000e4a7;
      9'h1f2: D <= 49'h000000001000;
      9'h1f3: D <= 49'h08000000c4a7;
      9'h1f4: D <= 49'h000000001000;
      9'h1f5: D <= 49'h08000000a4a7;
      9'h1f6: D <= 49'h000000001000;
      9'h1f7: D <= 49'h8800000084a7;
      9'h1f8: D <= 49'h80039c0010cb;
      9'h1f9: D <= 49'h88029c006063;
      9'h1fa: D <= 49'h800000000000;
      9'h1fb: D <= 49'h800000000000;
      9'h1fc: D <= 49'h800000000000;
      9'h1fd: D <= 49'h800000000000;
      9'h1fe: D <= 49'h800000000000;
      9'h1ff: D <= 49'h0800000250a7;
    endcase

`define patch_rom
`ifdef patch_rom
    // patches for debugging
    case (A)
     ~9'o175 & 9'h1ff: D <= 49'h000000001000;
     ~9'o202 & 9'h1ff: D <= 49'h000000001000;
     ~9'o226 & 9'h1ff: D <= 49'h000000001000;
     ~9'o232 & 9'h1ff: D <= 49'h000000001000;
     ~9'o236 & 9'h1ff: D <= 49'h000000001000;
     ~9'o244 & 9'h1ff: D <= 49'h000000001000;
     ~9'o251 & 9'h1ff: D <= 49'h000000001000;
     ~9'o256 & 9'h1ff: D <= 49'h000000001000;
     ~9'o263 & 9'h1ff: D <= 49'h000000001000;
     ~9'o314 & 9'h1ff: D <= 49'h000000001000;
    endcase // case(A)
`endif
   end

//  always @(A or CE_N)
//    begin
//      $display("prom: %t prom addr %o val 0x%x, CE_N %d", $time, A, D, CE_N);
//    end

endmodule


