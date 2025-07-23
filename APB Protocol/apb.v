
module apb_topmodule (
  input        pclk,
  input        preset,
  input        transfer,
  input        read_write,
  input  [7:0] apb_write_paddr,
  input  [7:0] apb_write_data,
  input  [7:0] apb_read_paddr,

  output       pready,
  output [7:0] prdata
);

  wire        pwrite, psel, penable;
  wire [7:0]  paddr, pdata;
  wire [7:0]  apb_read_data;

  apb_master uut (
    .pclk(pclk),
    .preset(preset),
    .transfer(transfer),
    .read_write(read_write),
    .apb_write_paddr(apb_write_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_paddr(apb_read_paddr),
    .pready(pready),
    .pr_data(prdata),
    .pwrite(pwrite),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pdata(pdata),
    .apb_read_data(apb_read_data)
  );

  apb_slave uut1 (
    .clk(pclk),
    .rst(preset),
    .pwrite(pwrite),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pwdata(pdata),
    .pready(pready),
    .prdata(prdata)
  );

endmodule

///////////////////////////////////////////////////////

module apb_master (
  input  pclk,
  input  preset,
  input  transfer,
  input  read_write,
  input  [7:0] apb_write_paddr,
  input  [7:0] apb_write_data,
  input  [7:0] apb_read_paddr,
  input  pready,
  input  [7:0] pr_data,

  output reg        pwrite,
  output reg        psel,
  output reg        penable,
  output reg [7:0]  paddr,
  output reg [7:0]  pdata,
  output reg [7:0]  apb_read_data
);

  parameter IDLE   = 2'b00,
            SETUP  = 2'b01,
            ACCESS = 2'b10;

  reg [1:0] state, next_state;

  // State Transition
  always @(posedge pclk or posedge preset) begin
    if (preset)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Next State Logic
  always @(*) begin
    case (state)
      IDLE: begin
        penable = 1'b0;
        if (transfer)
          next_state = SETUP;
        else
          next_state = IDLE;
      end
      SETUP: begin
        penable = 1'b0;
        next_state = ACCESS;
      end
      ACCESS: begin
        penable = 1'b1;
        if (!pready)
          next_state = ACCESS;
        else if (pready && transfer)
          next_state = SETUP;
        else // if (pready && !transfer)
          next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end
  // Output Logic
  always @(*) begin
    // Default values
    psel = (state != IDLE);
    pwrite = 1'b0;
    paddr = 8'b0;
    pdata = 8'b0;
    apb_read_data = 8'b0;

    if ((state == SETUP) || (state == ACCESS)) begin
      pwrite = read_write;
      paddr  = read_write ? apb_write_paddr : apb_read_paddr;
      pdata  = read_write ? apb_write_data  : 8'b0;

      if (!read_write)
        apb_read_data = pr_data;
    end
  end

endmodule

////////////////////////////////////////////////////

module apb_slave (
  input        clk,
  input        rst,
  input        pwrite,
  input        psel,
  input        penable,
  input  [7:0] paddr,
  input  [7:0] pwdata,

  output reg       pready,
  output reg [7:0] prdata
);

  reg [7:0] mem [0:255];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      pready <= 0;
      prdata <= 8'd0;
    end else begin
      if (psel && penable) begin
        pready <= 1;
        if (pwrite) begin
          mem[paddr] <= pwdata;
        end else begin
          prdata <= mem[paddr];
        end
      end else begin
        pready <= 0;
      end
    end
  end

endmodule
