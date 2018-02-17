// vga_display.v --- memory to VGA interface

`include "defines.vh"

module vga_display(clk,
                   pixclk,
                   reset,
                   vram_addr,
                   vram_data,
                   vram_req,
                   vram_ready,
                   vga_red,
                   vga_blu,
                   vga_grn,
                   vga_hsync,
                   vga_vsync,
                   vga_blank
                   );

   input clk;
   input pixclk;
   input reset;

   output [14:0] vram_addr;
   input [31:0] vram_data;
   input vram_ready;
   output vram_req;

   output vga_red;
   output vga_blu;
   output vga_grn;
   output vga_hsync;
   output vga_vsync;
   output vga_blank;

   parameter H_DISP = 1280;
   parameter V_DISP = 1024;

   parameter BOX_WIDTH = 768;
   parameter BOX_HEIGHT = 896;

   parameter H_FPORCH = 16;
   parameter H_SYNC = 100;
   parameter H_BPORCH = 200;

   parameter V_FPORCH = 1;
   parameter V_SYNC = 3;
   parameter V_BPORCH = 38;

   parameter H_BOX_OFFSET = (H_DISP - BOX_WIDTH)/2;
   parameter V_BOX_OFFSET = (V_DISP - BOX_HEIGHT)/2;

   wire hsync;
   wire vsync;
   wire valid;

   wire h_in_box;
   wire v_in_box;
   wire in_box;

   wire h_in_border;
   wire v_in_border;
   wire in_border;

   wire vclk;

   reg [10:0] h_counter;
   reg [10:0] v_counter;

   reg [10:0] h_pos;
   reg [10:0] v_pos;

   reg [14:0] v_addr;

   parameter H_COUNTER_MAX = (H_DISP + H_FPORCH + H_SYNC + H_BPORCH);
   parameter V_COUNTER_MAX = (V_DISP + V_FPORCH + V_SYNC + V_BPORCH);

   assign hsync = h_counter >= (H_DISP+H_FPORCH) &&
                  h_counter < (H_DISP+H_FPORCH+H_SYNC);

   assign vsync = v_counter >= (V_DISP+V_FPORCH) &&
                  v_counter < (V_DISP+V_FPORCH+V_SYNC);

   assign valid = (h_counter <= H_DISP) &&
                  (v_counter <= V_DISP);

   assign h_in_box = h_counter >= H_BOX_OFFSET &&
                     h_counter < (H_BOX_OFFSET + BOX_WIDTH);

   assign v_in_box = v_counter >= V_BOX_OFFSET &&
                     v_counter < (V_BOX_OFFSET + BOX_HEIGHT);

   assign in_box = valid && h_in_box && v_in_box;

   assign h_in_border = (h_counter == H_BOX_OFFSET-1) ||
                        (h_counter == (H_BOX_OFFSET + BOX_WIDTH));

   assign v_in_border = (v_counter == V_BOX_OFFSET-1) ||
                        (v_counter == (V_BOX_OFFSET + BOX_HEIGHT));

   assign in_border = valid && (h_in_border || v_in_border);

   assign vclk = h_counter == H_COUNTER_MAX;

   always @(posedge pixclk)
     if (reset)
       h_counter <= 0;
     else
       if (h_counter >= H_COUNTER_MAX)
         h_counter <= 0;
       else
         h_counter <= h_counter + 1;

   always @(posedge pixclk or posedge reset)
     if (reset)
       v_counter <= 0;
     else
       if (vclk)
         begin
            if (v_counter >= V_COUNTER_MAX)
              v_counter <= 0;
            else
              v_counter <= v_counter + 1;
         end

   always @(posedge pixclk)
     if (reset)
       h_pos <= 0;
     else
       if (h_in_box)
         begin
            if (h_pos >= BOX_WIDTH)
              h_pos <= 0;
            else
              h_pos <= h_pos + 1;
         end
       else
         h_pos <= 0;

   always @(posedge pixclk or posedge reset)
     if (reset)
       v_pos <= 0;
     else
       if (vclk)
         begin
            if (v_in_box)
              begin
                 if (v_pos >= BOX_HEIGHT-1)
                   v_pos <= 0;
                 else
                   v_pos <= v_pos + 1;
              end
            else
              v_pos <= 0;
         end

   // Negative sync. signals.
   assign vga_vsync = ~vsync;
   assign vga_hsync = ~hsync;
   assign vga_blank = ~valid;

   reg [31:0] ram_data_hold;
   reg [31:0] ram_shift;

   reg ram_req;
   reg ram_data_hold_empty;
   wire ram_data_hold_req;

   wire ram_shift_load;
   wire preload, preload1, preload2;
   wire v_addr_inc;

   reg pixel;

   // Grab VRAM_DATA when ready.
   always @(posedge pixclk)
     if (reset)
       ram_data_hold <= 0;
     else
       if (vram_ready && ram_data_hold_empty)
         ram_data_hold <= vram_data;

   // Ask for new VRAM_DATA when hold empty.
   always @(posedge pixclk)
     if (reset)
       ram_req <= 0;
     else
       ram_req <= ram_data_hold_req && ram_data_hold_empty;

   // Pixel shift register.
   always @(posedge pixclk)
     if (reset)
       begin
          ram_shift <= 32'b0;
          ram_data_hold_empty <= 1'b0;
          pixel <= 1'b0;
       end
     else
       if (ram_shift_load)
         begin
            ram_shift <= ram_data_hold;
            ram_data_hold_empty <= 1'b1;
            pixel <= ram_shift[0];
         end
       else
         begin
            ram_shift <= { 1'b0, ram_shift[31:1] };
            pixel <= ram_shift[0];

            if (vram_ready)
              ram_data_hold_empty <= 0;
         end

   // VRAM address.
   always @(posedge pixclk)
     if (reset)
       v_addr <= 0;
     else
       begin
          if (~v_in_box)
            v_addr <= 0;
          else
            if (v_addr_inc)
              v_addr <= v_addr + 1;
       end

   // Increment once before visable, don't increment after last load.
   assign v_addr_inc = ram_shift_load &&
                       (in_box || preload2) &&
                       (h_pos != BOX_WIDTH-2);

   assign preload1 = h_counter == (H_BOX_OFFSET - 33);

   assign preload2 = h_counter == (H_BOX_OFFSET - 2);

   assign preload = preload1 || preload2;

   assign ram_shift_load = (h_pos[4:0] == 5'h1e) || preload;

   assign ram_data_hold_req = (h_pos[4:0] >= 5'h0f) ||
                              (h_counter >= (H_BOX_OFFSET - 16) && h_counter < H_BOX_OFFSET);

   assign vram_addr = v_addr;

   assign vram_req = ram_req;

`ifdef debug_excess_vga_fetches
   reg rs;
   wire rs_next;

   always @(posedge clk)
     if (reset)
       rs <= 0;
     else
       rs <= rs_next;

   assign rs_next =
                   (rs == 0) ? 1 :
                   (rs == 1 && ~vram_ready) ? 1 :
                   (rs == 1 && vram_ready) ? 2 :
                   (rs == 2) ? 0 :
                   0;

   assign vram_req = rs == 1;
`endif

   wire pixel_data;

   assign pixel_data = pixel;

`ifdef debug_load
   assign vga_red = in_box & ram_shift_load;
   assign vga_blu = in_box && ram_data_hold_empty;
   assign vga_grn = in_box & vram_ready;
`else
   assign vga_red = in_box ? pixel_data : in_border;
   assign vga_blu = in_box ? pixel_data : in_border;
   assign vga_grn = in_box ? pixel_data : in_border;
`endif

endmodule
