module replace_index
	#(parameter SET_INDEX_BITS)

	(input hit_miss,
	 input write_en,
	 input read_en,
	
	 output [SET_INDEX_BITS-1:0] replace_set_index,
	 output do_replace);

endmodule
