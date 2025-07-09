// Code your testbench here
// or browse Examples
module spi;
  reg clk;
  reg ss;
  reg rst;
//   reg master_in;
  wire master_out;
  spi_master dut(.clk(clk),.rst(rst),.ss(ss),.master_out(master_out));
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars();
    $monitor("clk=%b,rst=%b,ss=%b,master_in=%b,master_out=%b",clk,ss,master_out);
  end
  initial begin
    clk=1;
    forever #5clk=~clk;
  end
    initial begin
    rst=1;ss = 1;
    #10rst=0;ss = 0;
    #110 ss=1;
    #1000$finish;
  end
endmodule
   
