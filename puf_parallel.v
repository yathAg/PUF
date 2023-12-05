module puf_parallel(
  input [31:0] enable,
  input [7:0] challenge,
  output reg [7:0] out,
  output reg all_done,
  input clock,
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