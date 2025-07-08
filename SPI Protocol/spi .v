module spi_master(
  input clk,
  input rst,
  input ss,
  output reg master_out
  );  
  
  reg [7:0]mem_m;
  reg [3:0] count;
  reg master_in;
  wire master_reg;
  
  parameter IDLE     = 1'b0 ,
  			TRANSMIT = 1'b1 ;
  
  reg state,next_state;
  
  //state logic
  always@(posedge clk or posedge rst)begin
    if(rst)begin
      state		 <= IDLE;
      next_state <= IDLE ;
      count 	 <= 0;
      mem_m 	 <= 8'b1001_1111;
      master_out <= 0;
    end
    else
      state 	 <= next_state;
  end
  
  //Next_state logic
  always@(posedge clk)begin
      case(state)
        IDLE    :begin
          		   if(!ss)begin
                     next_state <= TRANSMIT;
                     count      <= 4'd8;
                   end
          		   else 
                     next_state <= IDLE;
        		 end
       TRANSMIT :begin
         			master_out <= mem_m[7];
         			mem_m      <= {mem_m[6:0],master_in};
                    count      <= count-1;
         			if(count ==0)begin
                        count <=  4'd8;
           				next_state <= IDLE;
                    end
                    else begin
                        count      <= count-1;
                        next_state <= TRANSMIT;
                    end
       			  end
      endcase
  end
  
  //Instantiation of slave
  spi_slave ins1(.clk(clk),.rst(rst),.slave_in(master_out),.ss(ss),.slave_out(master_reg ));
   
  //Output logic
  assign master_in = (!ss) ? master_reg : 1'b0;
 

endmodule
    
/////////////////////////////////slave_module////////////////////////////////////////////
                    
module spi_slave(
  input clk,
  input rst,
  input slave_in,
  input ss,
  output reg slave_out);
  
  reg [7:0]mem_s;
  reg [3:0]count;
  
  parameter IDLE 	 = 1'b0,
  			TRANSMIT = 1'b1;
  reg state,next_state;
  
  //State logic
  always@(posedge clk)begin
    if(rst)begin
      state 	<= IDLE;
      mem_s 	<= 8'b1111_1110;
      count 	<= 0;
      slave_out <= 0;
    end
    else
      state 	<= next_state;
  end
  
  //Next_state_logic
  always@(posedge clk)begin
    case(state)
      IDLE   :begin
        		if(!ss)begin
          			next_state <= TRANSMIT ;
          			count      <= 4'd9;
            	end
       			else
          			next_state <= IDLE;
           	  end
     TRANSMIT:begin
          	    slave_out <= mem_s[7];
       			mem_s     <= {mem_s[6:0],slave_in};
       			if (count == 0)
          			next_state <= IDLE;         		   
       		    else begin
                    next_state <= TRANSMIT;
         			count <= count - 1;
        		end
              end
    endcase
  end
endmodule
                              
        		
      
      
      
      
  
    
