/**************

udp_send.v

Takes in data from the application along with a valid bit, an IP address and destination port number, and encapsulates it with the UDP header.  Outputs the data, a valid bit, the destination IP address, and the data length.

* Note : No Checksum Used 



**************/

`define SOURCE_PORT 16'h0400
`define CHECKSUM 16'h0

module udp_send(
	input             clk,
	input             reset,

	//Data From Application Layer
	input             data_in_valid,
	input [31:0]      data_in,
	input [31:0]	  ip_addr_in,
	input [15:0]	  dest_port,
	input [15:0]	  length_in,

	//Data sent to IP_send
	output reg [31:0] ip_addr_out,
	output reg        data_out_valid,
	output reg [31:0] data_out,
	output reg [15:0] length_out
);

reg [2:0] cnt, bufcnt;
reg [31:0] data_buffer1, data_buffer2;

always @(posedge clk) begin
// If reset bit is set to 1 -> reinitialize all counters, addresses etc.
	if (reset) begin
		cnt <= 2'h0;
		bufcnt <= 2'h0;
		ip_addr_out <= 32'b0;
		data_out_valid <= 1'b0;
		data_out <= 32'b0;
		length_out <= 16'b0;
		data_buffer1 <= 32'b0;
		data_buffer2 <= 32'b0;
	end
	
	// If valid bit is high from Application Layer then receive the data and send to IP_send
	else if (data_in_valid) begin
		case (cnt) 
			0: begin
				data_out <= {`SOURCE_PORT, dest_port}; // SOURCE PORT is the port number of application which requested access (kept constant for simplicity)
				data_out_valid <= 1'b1; // Output Data valid
				ip_addr_out <= ip_addr_in; // Destination IP address
				length_out <= length_in + 16'h8;  // UDP header is of size 8 bytes hence we add 16'h8
				data_buffer1 <= data_in;
				cnt <= cnt + 2'b1;
				bufcnt <= bufcnt + 2'h1;
			end
			1: begin
				data_out <= {length_out, `CHECKSUM};
				data_out_valid <= 1'b1;
				data_buffer2 <= data_buffer1;
				data_buffer1 <= data_in;
				cnt <= cnt + 2'b1;
				bufcnt <= bufcnt + 2'h1;
			end
			2: begin
				data_out_valid <= 1'b1;
				data_out <= data_buffer2;
				data_buffer2 <= data_buffer1;
				data_buffer1 <= data_in;
			end
			default: cnt <= 2'h0;
		endcase
	end
	else if (~data_in_valid) begin
		if (bufcnt != 2'h0) begin
			data_out_valid <= 1'b1;
			data_out <= data_buffer2;
			data_buffer2 <= data_buffer1;
			data_buffer1 <= data_in;
			bufcnt <= bufcnt - 2'h1;
			cnt <= 2'h0;
		end
		else begin
			data_out_valid <= 1'b0;
			cnt <= 2'h0;
		end
	end	
end

endmodule