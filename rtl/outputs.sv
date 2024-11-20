module outputs

	#( parameter SET_INDEX_BITS,
	   parameter OFFSET_BITS,
	   parameter DATA_BITS)

	(input hit_miss,
	 input [SET_INDEX_BITS-1:0] set_index,
	 input [OFFSET_BITS-1:0] address_offset,

	 output miss,
	 output valid,
	 output [DATA_BITS-1:0] data);

endmodule
