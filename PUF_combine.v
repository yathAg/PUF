module PUF(
  input enable,
  input wire [7:0] challenge,
  output wire [7:0] response,
  input orred,
  input reset,
  output done_sig
  );

  wire done;
  assign done_sig = orred | done;

  puf_parallel parallel_scheme(
    .enable(enable),
    .challenge(challenge),
    .out(response),
    .all_done(done),
    .computer_reset(reset)
  );
endmodule

module puf_parallel(
  input enable,
  input [7:0] challenge,
  output  [7:0] out,
  output  all_done,
  input computer_reset
);

  wire [7:0] done;

  assign all_done = &done;

  puf_parallel_subblock block0(
    .enable(enable),
    .challenge(challenge),
    .out(out[0]),
    .done(done[0]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block1(
    .enable(enable),
    .challenge(challenge),
    .out(out[1]),
    .done(done[1]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block2(
    .enable(enable),
    .challenge(challenge),
    .out(out[2]),
    .done(done[2]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block3(
    .enable(enable),
    .challenge(challenge),
    .out(out[3]),
    .done(done[3]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block4(
    .enable(enable),
    .challenge(challenge),
    .out(out[4]),
    .done(done[4]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block5(
    .enable(enable),
    .challenge(challenge),
    .out(out[5]),
    .done(done[5]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block6(
    .enable(enable),
    .challenge(challenge),
    .out(out[6]),
    .done(done[6]),
    .reset(computer_reset)
  );
  puf_parallel_subblock block7(
    .enable(enable),
    .challenge(challenge),
    .out(out[7]),
    .done(done[7]),
    .reset(computer_reset)
  );
  
endmodule

module puf_parallel_subblock(
    input [7:0] challenge,
    input enable,
    output out,
    output done,
    input reset
);

    wire [31:0] ro_out;                   // a 32-bit bus: each stems from the output of each ro
    wire first_mux_out, second_mux_out;   // output of muxes that go into the counters
    wire fin1, fin2;                      // outputs of the counters that go into the race arbiter
    wire [21:0] pmc1_out, pmc2_out;       // for debug, output of the counters

    // Instantiate 16 ring oscillators for the first array
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : first_ro_inst
        ring_osc first_ro_inst (
            .out(ro_out[i]),
            .enable(enable)
        );
        end
    endgenerate

    // Instantiate 16 ring oscillators for the second array
    generate
        for (i = 0; i < 16; i = i + 1) begin : second_ro_inst
        ring_osc second_ro_inst (
            .out(ro_out[i + 16]),
            .enable(enable)
        );
        end
    endgenerate

    mux_16to1 first_mux (
    .in(ro_out[15:0]),
    .sel(challenge[3:0]),
    .out(first_mux_out)
    );

    mux_16to1 second_mux (
    .in(ro_out[31:16]),
    .sel(challenge[7:4]),
    .out(second_mux_out)
    );

    post_mux_counter pmc1 (
    .out(pmc1_out),
    .finished(fin1),
    .enable(enable),
    .clk(first_mux_out),
    .reset(reset)
    );
  
    post_mux_counter pmc2 (
    .out(pmc2_out),
    .finished(fin2),
    .enable(enable),
    .clk(second_mux_out),
    .reset(reset)
    );

    race_arbiter arb (
    .finished1(fin1),
    .finished2(fin2),
    .reset(reset),
    .out(out),
    .done(done)
    );
endmodule

module ring_osc (
  output out,
  input enable
  );
  
  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;

  assign w15 = ~(enable & w14);
  assign w14 = ~w13;  // w14 is the output we are interested in
  assign w13 = ~w12;
  assign w12 = ~w11;
  assign w11 = ~w10;
  assign w10 = ~w9;
  assign w9 = ~w8;
  assign w8 = ~w7;
  assign w7 = ~w6;
  assign w6 = ~w5;
  assign w5 = ~w4;
  assign w4 = ~w3;
  assign w3 = ~w2;
  assign w2 = ~w1;
  assign w1 = ~w15;

  assign out = w14;
endmodule

module mux_16to1 (
  input [15:0] in,
  input [3:0] sel,
  output reg out
  );

  always @(*) begin
    case (sel)
      4'b0000: out = in[0];
      4'b0001: out = in[1];
      4'b0010: out = in[2];
      4'b0011: out = in[3];
      4'b0100: out = in[4];
      4'b0101: out = in[5];
      4'b0110: out = in[6];
      4'b0111: out = in[7];
      4'b1000: out = in[8];
      4'b1001: out = in[9];
      4'b1010: out = in[10];
      4'b1011: out = in[11];
      4'b1100: out = in[12];
      4'b1101: out = in[13];
      4'b1110: out = in[14];
      4'b1111: out = in[15];
    endcase
  end
endmodule

module post_mux_counter (
  output reg [21:0] out,    // Output of the counter
  output reg finished,      // Output finished signal
  input enable,             // enable for counter
  input clk,                // clock Input
  input reset               // reset Input
  );

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out <= 28'd0;
      finished <= 1'b0;
    end
    else if (out[21] == 1) begin
      finished <= 1'b1;
    end
    else if (enable) begin
      out <= out + 1;
    end
  end
endmodule

module race_arbiter (
  input finished1,
  input finished2,
  input reset,
  output reg out,
  output  done
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
