module spi_master(input clk,rst,ss,output reg master_out);
  reg [7:0]master_mem=8'b11010011;
  reg[3:0]count;
  reg master_in;
  wire master_reg;
  parameter idle=1'b0;
  parameter transmit=1'b1;
  reg state,next_state;
  always @ (posedge clk or posedge rst)begin
    if(rst)begin
      state<=idle;
      next_state<=idle;
      master_out<=1'b0;
      count<=1'd7;
    end
      else
        state<=next_state;
  end
  always @(posedge clk)begin
    case(state)
      idle: begin
      if(!ss)begin
        count<=4'd7;
        next_state<=transmit;
      end
        else
          next_state<=idle;
      end
    transmit: begin
      master_out<=master_mem[7];
      master_mem<={master_mem[6:0],master_in};
      if(count==0) begin
//       	count <= 4'd7; 
        next_state<=idle;
      end
      else begin
        count<=count-1;
      next_state<=transmit;
      end
    end
    endcase
  end
  spi_slave ins(.clk(clk),.rst(rst),.slave_in(master_out),.ss(ss),.slave_out(master_reg ));
   
  
  assign master_in =master_reg;
endmodule
module spi_slave(input clk,rst,ss,slave_in,output reg slave_out);
    reg [7:0]slave_mem=8'b01011101;
  reg[3:0]count;
  wire master_w;
  parameter idle=1'b0;
  parameter transmit=1'b1;
  reg state,next_state;
  always @ (posedge clk or posedge rst)begin
    if(rst)begin
      state<=idle;
      next_state<=idle;
      slave_out<=1'b0;
      count<=1'b0;
    end 
      else
        state<=next_state;
  end
  always @(posedge clk)begin
    case(state)
      
  idle   :begin
        		if(!ss)begin
          			count      <= 4'd7;
          			next_state <= transmit ;
            	end
       			else
          			next_state <= idle;
           	  end
     transmit:begin
          	    slave_out <= slave_mem[7];
       slave_mem    <= {slave_mem[6:0],slave_in};
       			if (count == 0)
          			next_state <= idle;         		   
       		    else begin
         			count <= count - 1;
                    next_state <= transmit;
        		end
              end
    endcase
  end
endmodule
