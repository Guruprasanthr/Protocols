module tb();
reg clk, rst;
reg [7:0] data;
  
  wire baud_clk, tx, done_t, done_r, error;
  top_module dut (
    .clk(clk),
    .rst(rst),
    .data(data),
    .tx(tx),
    .done_t(done_t),
    .done_r(done_r),
    .error(error)
  );

  initial clk = 0;
  always #5 clk = ~clk;  // 50 MHz toggle rate

  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
 
    rst = 1;
    data = 8'd0;
    #20;

    
    rst = 0;
    #20;

   
    data = 8'b10010101;

   
    #100000;

    $finish;
  end

endmodule
