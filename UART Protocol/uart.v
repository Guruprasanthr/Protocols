module top_module(
  input clk,
  input rst,
  input [7:0] data,
  output wire tx,
  output wire done_t,
  output wire done_r,
  output wire error
);
  wire baud_clk;

  baud_rate baud(
    .clk(clk),
    .rst(rst),
    .baud_clk(baud_clk)
  );

  wire baud_tclk = baud_clk;
  wire rx = tx;

  transmitter trans(
    .clk(clk),
    .rst(rst),
    .data(data),
    .baud_tclk(baud_tclk),
    .tx(tx),
    .done_t(done_t)
  );

  reciver recv(
    .clk(clk),
    .rst(rst),
    .baud_rclk(baud_tclk),
    .rx(rx),
    .done_r(done_r),
    .error(error)
  );
endmodule

module baud_rate(
  input clk,
  input rst,
  output reg baud_clk
);
  parameter integer baud_rate = 921600;
  parameter integer fqr = 50000000;
  localparam integer clk_div = fqr / baud_rate;

  integer count;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count <= 0;
      baud_clk <= 0;
    end else begin
      if (count >= clk_div - 1) begin
        count <= 0;
        baud_clk <= 1;
      end else begin
        count <= count + 1;
        baud_clk <= 0;
      end
    end
  end
endmodule

module transmitter(
  input clk,
  input rst,
  input [7:0] data,
  input baud_tclk,
  output reg tx,
  output reg done_t
);
  reg [2:0] ps, ns;
  reg [3:0] count;
  reg [7:0] temp_data;
  reg parity_bit;
  reg st;

  localparam IDLE = 3'd0,
             START = 3'd1,
             DATA = 3'd2,
             PARITY = 3'd3,
             STOP = 3'd4;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ps <= IDLE;
      tx <= 1'b1;
      done_t <= 1'b0;
      count <= 0;
      st <= 0;
    end else begin
      ps <= ns;
    end
  end

  always @(posedge baud_tclk or posedge rst) begin
    if (rst) begin
      ns <= IDLE;
    end else begin
      case (ps)
        IDLE: begin
          tx <= 1'b1;
          done_t <= 1'b0;
          if (!st) begin
            temp_data <= data;
            parity_bit <= ^data;
            ns <= START;
            st <= 1;
          end else begin
            ns <= IDLE;
          end
        end

        START: begin
          tx <= 1'b0;
          ns <= DATA;
        end

        DATA: begin
          tx <= temp_data[count];
          if (count < 7) begin
            count <= count + 1;
            ns <= DATA;
          end else begin
            count <= 0;
            ns <= PARITY;
          end
        end

        PARITY: begin
          tx <= parity_bit;
          ns <= STOP;
        end

        STOP: begin
          tx <= 1'b1;
          done_t <= 1'b1;
          ns <= IDLE;
          st <= 0;
        end

        default: ns <= IDLE;
      endcase
    end
  end
endmodule

module reciver(
  input clk,
  input rst,
  input baud_rclk,
  input rx,
  output reg done_r,
  output reg error
);
  reg [2:0] ps, ns;
  reg [3:0] count;
  reg [7:0] data;
  reg parity_bit;

  localparam IDLE = 3'd0,
             START = 3'd1,
             DATA = 3'd2,
             PARITY = 3'd3,
             STOP = 3'd4;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ps <= IDLE;
      done_r <= 0;
      error <= 0;
      count <= 0;
      data <= 8'd0;
    end else begin
      ps <= ns;
    end
  end

  always @(posedge baud_rclk or posedge rst) begin
    if (rst) begin
      ns <= IDLE;
    end else begin
      case (ps)
        IDLE: begin
          done_r <= 0;
          error <= 0;
          if (!rx) ns <= START;
          else ns <= IDLE;
        end

        START: ns <= DATA;

        DATA: begin
          data[count] <= rx;
          if (count < 7) begin
            count <= count + 1;
            ns <= DATA;
          end else begin
            count <= 0;
            ns <= PARITY;
          end
        end

        PARITY: begin
          parity_bit <= rx;
          if (^data == rx) begin
            error <= 0;
          end else begin
            error <= 1;
          end
          ns <= STOP;
        end

        STOP: begin
          done_r <= 1;
          ns <= IDLE;
        end

        default: ns <= IDLE;
      endcase
    end
  end
endmodule
  
