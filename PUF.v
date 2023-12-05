module top_level(
  input enable,
  input clk,
  input orred,

  input wire [7:0] challenge,
  output wire [7:0] response,

  input ck_io0,
  output ck_io8
  );

  wire done;
  assign ck_io8 = orred | done;

  puf_parallel parallel_scheme(
    .enable(enable),
    .challenge(challenge),
    .out(response),
    .all_done(done),
    .clock(clk),
    .computer_reset(ck_io0)
  );
endmodule