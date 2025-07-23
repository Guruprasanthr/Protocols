module apb_tb;

  reg         pclk;
  reg         preset;
  reg         transfer;
  reg         read_write;
  reg  [7:0]  apb_write_paddr;
  reg  [7:0]  apb_write_data;
  reg  [7:0]  apb_read_paddr;

  wire        pready;
  wire [7:0]  prdata;

  // Instantiate top module
  apb_topmodule dut (
    .pclk(pclk),
    .preset(preset),
    .transfer(transfer),
    .read_write(read_write),
    .apb_write_paddr(apb_write_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_paddr(apb_read_paddr),
    .pready(pready),
    .prdata(prdata)
);
 // Clock generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  // Stimulus
  initial begin
    preset = 1;
    transfer = 0;
    read_write = 0;
    apb_write_paddr = 8'd0;
    apb_write_data  = 8'd0;
    apb_read_paddr  = 8'd0;

    #10 preset = 0;

    // Write to address 0x10
    #10;
    transfer = 1;
    read_write = 1;
    apb_write_paddr = 8'h10;
    apb_write_data  = 8'hA5;

    #50;
    transfer = 0;

    // Read from address 0x10
    #20;
    transfer = 1;
    read_write = 0;
    apb_read_paddr = 8'h10;

    #50;
    transfer = 0;

    #50 $finish;
  end

  // Dump waveform
  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0, apb_tb);
  end

endmodule
