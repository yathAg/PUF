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