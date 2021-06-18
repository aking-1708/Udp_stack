`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

Accumulates the entire frame in an array and sends it through an AXI interface to the TX_FIFO


*/
//////////////////////////////////////////////////////////////////////////////////


module axi_buf_send(
    input clk,
    input reset,
    input axi_ip_ready,
    output reg axi_ip_done,
	output reg [7:0] axi_ip_index,
	input [47:0] axi_ip_mac,
	input [31:0] axi_ip_data,
	input [7:0] axi_ip_length,
	input axi_arp_ready,
	output reg axi_arp_done,
	output reg [2:0] axi_arp_index,
	input  [47:0] axi_arp_mac,
	input [31:0] axi_arp_data
	
	// AXI-S side interface here
    
    
    
    );
    
    
    
    localparam IP_INIT = 0;
    localparam IP_RECV = 1;
    localparam IP_SEND = 2;
    localparam IP_END = 6;
    
    localparam ARP_INIT = 3;
    localparam ARP_RECV = 4;
    localparam ARP_SEND = 5;
    localparam ARP_END = 7;
    
    reg [31:0] ip_packet  [255:0];
    reg [31:0] arp_packet [6:0];
    
    reg [2:0] ip_state;
    reg [2:0] arp_state;
    
    reg [7:0] ip_count;
    reg [2:0] arp_count;
    
    reg [47:0] ip_mac;
    reg [7:0] ip_length;
    
    reg [47:0] arp_mac;
    reg [7:0] arp_length;
    
    integer i;
    
    
    reg ip_packet_ready;
    reg arp_packet_ready;
    
    always@(posedge clk)
    begin
      
      case(ip_state)
      
      
      IP_INIT : 
      begin
        if(axi_ip_ready)
        begin
        axi_ip_done <= 0;
        ip_mac <= axi_ip_mac;
        ip_length <= axi_ip_length;
        ip_state <= IP_RECV;
        end
      end
      
      
      IP_RECV:
      begin
      
      for( i = 0; i<ip_length ; i = i + 1)
      begin
      
      axi_ip_index  = i;
      ip_packet[ip_count] = axi_ip_data;
      ip_count = ip_count + 1;
      
      end
      end
      
      IP_SEND:
      begin
      // Use this to send data on the AXI Stream interface to FIFO
      
      end
      
      IP_END:
      begin
      
      
      
      end
      
      
      endcase  
    end
    
    
    


 always@(posedge clk)
    begin
      
      case(arp_state)
      
      
      ARP_INIT : 
      begin
        if(axi_arp_ready)
        begin
        axi_arp_done <= 0;
        arp_mac <= axi_arp_mac;
        arp_state <= ARP_RECV;
        end
      end
      
      
      ARP_RECV:
      begin
      
      for( i = 0; i<=6 ; i = i + 1)
      begin
      
      axi_arp_index  = i;
      arp_packet[arp_count] = axi_arp_data;
      arp_count = arp_count + 1;
      
      end
      end
      
      ARP_SEND:
      begin
      // Use this to send data on the AXI Stream interface to FIFO
      
      end
      
      
      ARP_END:
      begin
      
      
      
      end
      
      
      endcase  
    end
    
    
    
    
    
    
    
    
    
    
endmodule
