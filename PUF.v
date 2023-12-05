`include "race_arbiter.v"
`include "ring_osc.v"
`include "puf_parallel_subblock.v"
`include "puf_parallel.v"
`include "mux_16to1.v"
`include "post_mux_counter.v"

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