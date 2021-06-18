/*

* This Module is a placeholder for the AJIT processor and sends a stream of data to the udp_send module
* Acts as the application Layer
*
*
*
*


*/
`define DEST_IP_ADDR 32'hc0a80103    // Address : 192.168.1.3 - Placeholder
`define DEST_PORT    16'hc000        // Port Number : 49152  -  Placeholder  
`define INITIALIZE   0
`define SEND_STATE   1
`define WAIT_STATE   2

module app_layer(

input             clk,
input             reset,

output  reg          data_valid,
output  reg [31:0]   data_in,
output  reg [31:0]	 ip_addr_in,
output  reg [15:0]	 dest_port,
output  reg [15:0]	 length_in     // Lenght in Bytes

);



reg [4:0] count;
reg [31:0] data_send;
reg [31:0] chars [0:15];
reg [4:0]  max_size;
reg tx_end;
reg [2:0] state;
reg [2:0] send_packets;

initial 
    begin
    
        chars[0]  <= "ACT";
        chars[1]  <= "ADD";
        chars[2]  <= "AND";
        chars[3]  <= "BEE";
        chars[4]  <= "BIG";
        chars[5]  <= "BOX";
        chars[6]  <= "BOG";
        chars[7]  <= "BOY";
        chars[8]  <= "CAR";
        chars[9]  <= "CAT";
        chars[10] <= "DAB";
        chars[11] <= "DOG";
        state     <= `INITIALIZE;
        tx_end    <= 0;
        max_size <= 11;
        send_packets <= 0;
        ip_addr_in <= `DEST_IP_ADDR;
        dest_port  <= `DEST_PORT;
        length_in  <=  24;
        data_valid <= 0;
        data_send <= 0;
        count  <=  0;
    end




always @(posedge clk) begin
// If reset bit is set to 1 -> reinitialize all counters, addresses etc.
	if (reset) begin
		count <= 0;
		tx_end    <= 0;
		data_send <= 0;
		data_valid <= 0;
		data_in <= 0 ;
		send_packets <= 0;
		ip_addr_in <= `DEST_IP_ADDR;
        dest_port  <= `DEST_PORT;
        length_in  <=  24;
        state     <= `INITIALIZE;
		
	end
	
	// If valid bit is high from Application Layer then receive the data and send to IP_send
	else 
	   begin
	   
	   case (state)
	   
	   `INITIALIZE:
	       begin
	           send_packets <= 0;
	           count = 0;
	           state = `SEND_STATE;
	       end
	   
	   `SEND_STATE :
	       begin
	           if(send_packets < 2)
	           begin
	               data_send <= chars[count];
	               length_in <= 6;   // Length for 2 data units in bytes (48 bits)
	               ip_addr_in <= `DEST_IP_ADDR;
	               dest_port <=  `DEST_PORT;
	               data_valid <= 1;
	               count <= count + 1;
	               send_packets <= send_packets + 1;
	           end
	         else
	         begin
	           send_packets <= 0;
	           state <=`WAIT_STATE;
	           data_valid <= 0;
	         end  
	       end
	       
	   `WAIT_STATE :
	       begin
	           data_valid <= 0;     
	           if(count <= max_size && ~tx_end)
	           begin 
	           state <= `SEND_STATE;
	           end
	           
	           else
	           begin
	           
	           state <= `WAIT_STATE;
	           tx_end <= 1;
	           end
	       
	       end
	   
	   
	   
	   
	   endcase
	   
	   
	   
	   
	   
	   end
end    
endmodule