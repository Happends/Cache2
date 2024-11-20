module tag_compare

	#(parameter ADDRESS_BITS,
	  parameter SET_INDEX_BITS)
	(input [ADDRESS_BITS-1:0] address,
	 input valid,
	 output hit_miss,
	 output [SET_INDEX_BITS-1:0] set_index);


endmodule
