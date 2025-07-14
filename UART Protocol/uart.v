module top_module(
  input clk,rst,
  output reg baud_clk,
  input [7:0]data,
  output reg tx,done_t,
  output reg done_r,error
);
  baud_rate baud(.clk(clk),.rst(rst),.baud_clk(baud_clk));
  
  wire baud_tclk;
  assign baud_tclk = baud_clk;
  
  transmitter trans(.clk(clk),.rst(rst),.data(data),.baud_tclk(baud_tclk),.tx(tx),.done_t(done_t));
  
  wire rx;
  assign rx = tx;
  reciver res(.clk(clk),.rst(rst),.baud_rclk(baud_tclk),.rx(rx),.done_r(done_r),.error(error));
endmodule

module baud_rate(
  input clk,rst,
  output reg baud_clk
);
  parameter integer baud_rate = 921600;
  parameter integer fqr = 50000000;
  integer count;
  parameter integer clk_div = fqr / baud_rate;
  
  always@(posedge clk ) begin
    if(rst) begin
      count <= 0;
      baud_clk <= 0;
    end
    else begin
      if(count == clk_div) begin
      count <= 0;
      baud_clk <= 1;
    end
    else begin
      count =count + 1;
      baud_clk <= 0;
    end
    end
  end
endmodule

module transmitter(
  input clk,baud_tclk,rst,
  input [7:0]data,
  output reg tx,done_t
);
  
  
  reg [1:0]ps,ns;
  reg [3:0]count;
  reg st = 1'b0;
  
  parameter idle = 2'b00, start = 2'b01, parity = 2'b10, stop = 2'b11;
  
  
  always@(posedge clk) begin
    if(rst) begin
      ps <= idle;
      ns <= idle;
      tx <= 1'b1;
      count <= 4'd0;
      done_t <= 1'b0;
    end
    else begin
      ps <= ns;
    end
  end
  
  always@(posedge baud_tclk) begin
    case(ps)
      idle : begin 
        if(!st) begin 
          tx <= 1'b0;
          ns <= start;
          st <= 1'b1;
        end
        else ns <= idle;
      end
      start : begin
        if (count <= 7) begin
          tx <= data[count];
          count = count + 1'b1;
        end 
        else begin
          count <= 0;
          ns <= parity;
        end
      end
      parity : begin
        tx <= ^data;
        ns <= stop;
      end
      stop : begin
        tx <= 1'b1;
        done_t <= 1'b1;
        ns <= idle;
      end
    endcase
  end
  
endmodule


module receiver(
  input clk,rst,baud_rclk,rx,
  output reg done_r,error
);
  
  
  reg [1:0]ps,ns;
  reg [3:0]count;
  reg [7:0]data;
  
  parameter idle = 2'b00, start = 2'b01, parity = 2'b10;
  
  
  always@(posedge clk) begin
    if(rst) begin
      ps <= idle;
      ns <= idle;
      count <= 4'd0;
      done_r <= 1'b0;
      data <= 8'd0;
    end
    else begin
      ps <= ns;
    end
  end
  
  always@(posedge baud_rclk) begin
    case(ps)
      idle : begin 
        if(!rx) begin
          ns <= start;
        end
      end
      start : begin
        if(count <= 7) begin
          data[count] <= rx;
          count <= count + 1'b1;
        end
        else begin
          ns <= parity;
          count <= 4'd0;
        end
      end
      parity : begin
        if((^data^rx) == 1'b0) begin 
          done_r <= 1'b1;
          error <= 0;
          ns <= idle;
        end
        else begin
          error <= 1'b1;
          ns <= idle;
        end
      end
      default ns <= idle;
    endcase
  end
  
  
endmodule
