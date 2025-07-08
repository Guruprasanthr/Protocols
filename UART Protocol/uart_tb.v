module tb();

  reg clk, rst;
  reg [7:0] data;
  
  wire baud_clk, tx, done_t, done_r, error;

  // Instantiate the top-level module
  top_module dut (
    .clk(clk),
    .rst(rst),
    .data(data),
    .tx(tx),
    .done_t(done_t),
    .done_r(done_r),
    .error(error)
  );

  // Clock generation: 100MHz clock (10ns period)
  initial clk = 0;
  always #5 clk = ~clk;  // 50 MHz toggle rate

  // Stimulus
  initial begin
    // Dump waveform file
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    // Initialize
    rst = 1;
    data = 8'd0;
    #20;

    // Release reset
    rst = 0;
    #20;

    // Send a data byte
    data = 8'b10010101;

    // Wait long enough for transmission + reception to complete
    #100000;

    $finish;
  end

endmodule
