
module tb_spi_master_slave;

  reg clk;
  reg rst;
  reg ss; 
  wire master_out; 
  

  spi_master uut (
    .clk(clk),
    .rst(rst),
    .ss(ss),
    .master_out(master_out)
  );

  initial begin
    clk = 1;
    forever #5 clk=~clk;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    rst = 1;ss  = 1;#20;    
    rst = 0;ss  = 0;#160;   
    ss = 0;#50;   
    $finish;
  end

endmodule
