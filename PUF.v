module top_level(
  input enable,
  input clk,
  input orred,

  input wire  [7:0] challenge,
  output wire [7:0] response,

  input ck_io0,
  output ck_io8
  );

  wire [31:0] enables;
  wire done;

  assign enables = {32{enable}};
  assign ck_io8 = orred | done;

  puf_parallel parallel_scheme(enables, challenge, response, done, clk, ck_io0);    // ck_io0 is computer_ack for reset

endmodule

module puf_parallel_subblock(
    enable,
    challenge,
    out,
    done,
    clock,
    reset
    );
  output out, done;
  input [7:0] challenge;
  input [31:0] enable;
  input clock, reset;

   wire [31:0] ro_out;  // a 32 bit bus: each stems from the output of each ro
   wire first_mux_out, second_mux_out;  // output of muxes that go into the counters
   wire fin1, fin2;     // outputs of the counters that go into the race arbiter
   wire [21:0] pmc1_out, pmc2_out;  // for debug, output of the counters

   ring_osc first_ro[15:0] (enable[15:0], ro_out[15:0]);    // An array of 16 ring oscillators that go into the first mux
   ring_osc second_ro[15:0] (enable[31:16], ro_out[31:16]); // An array of 16 ring oscillators that go into the second mux

   mux_16to1 first_mux(ro_out[0], ro_out[1], ro_out[2], ro_out[3], ro_out[4], ro_out[5], ro_out[6], ro_out[7], ro_out[8], ro_out[9], ro_out[10], ro_out[11], ro_out[12], ro_out[13], ro_out[14], ro_out[15], challenge[3:0], first_mux_out);
   mux_16to1 second_mux(ro_out[16], ro_out[17], ro_out[18], ro_out[19], ro_out[20], ro_out[21], ro_out[22], ro_out[23], ro_out[24], ro_out[25], ro_out[26], ro_out[27], ro_out[28], ro_out[29], ro_out[30], ro_out[31], challenge[7:4], second_mux_out);

   post_mux_counter pmc1(pmc1_out, fin1, enable[0], first_mux_out, reset);

   post_mux_counter pmc2(pmc2_out, fin2, enable[0], second_mux_out, reset);

   race_arbiter arb(fin1, fin2, reset, out, done);

endmodule

module ring_osc(enable, out);
  output out;
  input enable;

   wire w1;
   wire w2;
   wire w3;
   wire w4;
   wire w5;
   wire w6;
   wire w7;
   wire w8;
   wire w9;
   wire w10;
   wire w11;
   wire w12;
   wire w13;
   wire w14;
   wire w15;

  assign w15 = ~(enable & w14);
  assign w14 = ~ w13;  // w14 is the output we are interested in
  assign w13 = ~ w12;
  assign w12 = ~ w11;
  assign w11 = ~ w10;
  assign w10 = ~ w9;
  assign w9 = ~ w8;
  assign w8 = ~ w7;
  assign w7 = ~ w6;
  assign w6 = ~ w5;
  assign w5 = ~ w4;
  assign w4 = ~ w3;
  assign w3 = ~ w2;
  assign w2 = ~ w1;
  assign w1 = ~ w15;

  assign out = w14;

endmodule

module up_counter    (
  out     ,  // Output of the counter
  enable  ,  // enable for counter
  start   ,  // starting value of counter
  clk     ,  // clock Input
  reset      // reset Input
  );

  output reg [7:0] out;
  input enable, clk, reset;
  input [7:0] start;

  always @(posedge clk) begin
    if (reset) begin
      out <= start;
    end else if (enable) begin
      out <= out + 1;
    end
  end

endmodule

module shift_register (clk, in, out);
  input clk, in;
  output [7:0] out;
  reg [7:0] tmp;

  always @(posedge clk) begin
    //tmp = tmp << 1;
    //tmp[0] = SI;
    tmp = {tmp[6:0],in};
  end

  assign out  = tmp;

endmodule

module race_arbiter (
  input finished1,
  input finished2,
  input reset,
  output reg out,
  output reg done
  );
  wire cnt1_done, cnt2_done, winner;

  assign cnt1_done = (finished1 & ~cnt2_done) === 1'b1;
  assign cnt2_done = (finished2 & ~cnt1_done) === 1'b1;
  assign winner = cnt1_done | ~cnt2_done;
  assign done = (finished1 | finished2) ? 1'b1 : 1'b0;

  always @(finished1, finished2, reset) begin
    if (reset == 1'b1) begin
      out <= 1'bX;
    end
    else begin
      out <= winner;
    end
  end
endmodule

module mux_16to1(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, sel, out);

  input a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p;
  input [3:0] sel;
  output reg out;

  always@(*) begin
    case (sel)
      4'b0000: out = a;
      4'b0001: out = b;
      4'b0010: out = c;
      4'b0011: out = d;
      4'b0100: out = e;
      4'b0101: out = f;
      4'b0110: out = g;
      4'b0111: out = h;
      4'b1000: out = i;
      4'b1001: out = j;
      4'b1010: out = k;
      4'b1011: out = l;
      4'b1100: out = m;
      4'b1101: out = n;
      4'b1110: out = o;
      4'b1111: out = p;
    endcase
  end

endmodule

module post_mux_counter    (
  out     ,  // Output of the counter
  finished,  // Output finished signal
  enable  ,  // enable for counter
  clk     ,  // clock Input
  reset      // reset Input
  );

  output reg finished;
  output reg [21:0] out;
  input enable, clk, reset;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out <= 28'd0;
      finished <= 0;
    end
    else if (out[21]==1) begin
        finished <= 1'b1;
    end
    else if (enable) begin
      out <= out + 1;
    end
  end

endmodule

module puf_parallel(
    enable,
    challenge,
    out,
    all_done,
    clock,
    computer_reset
    );
  output [7:0] out;
  wire [7:0] done;
  output all_done;
  input [7:0] challenge;
  input [31:0] enable;
  input clock,computer_reset;

  assign all_done = done[0] && done[1] && done[2] && done[3] && done[4] && done[5] && done[6] && done[7];

   puf_parallel_subblock block0(enable[31:0], challenge[7:0], out[0], done[0], clock, computer_reset);
   puf_parallel_subblock block1(enable[31:0], challenge[7:0], out[1], done[1], clock, computer_reset);
   puf_parallel_subblock block2(enable[31:0], challenge[7:0], out[2], done[2], clock, computer_reset);
   puf_parallel_subblock block3(enable[31:0], challenge[7:0], out[3], done[3], clock, computer_reset);
   puf_parallel_subblock block4(enable[31:0], challenge[7:0], out[4], done[4], clock, computer_reset);
   puf_parallel_subblock block5(enable[31:0], challenge[7:0], out[5], done[5], clock, computer_reset);
   puf_parallel_subblock block6(enable[31:0], challenge[7:0], out[6], done[6], clock, computer_reset);
   puf_parallel_subblock block7(enable[31:0], challenge[7:0], out[7], done[7], clock, computer_reset);

endmodule