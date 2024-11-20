module mem_request

	#(parameter ADDRESS_BITS,
	  parameter SET_INDEX_BITS,
	  parameter DATA_BITS)
	(input write_en,
	 input [ADDRESS_BITS-1:0] address,
	 input hit_miss,
	 input [SET_INDEX_BITS-1:0] set_index,
	 
	 output [ADDRESS_BITS-1:0] prop_address,
	 output prop_write_en,
	 output prop_valid,
	 output [DATA_BITS-1:0] prop_write_data);


endmodule
