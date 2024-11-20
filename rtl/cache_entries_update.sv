
module cache_entries_update

	#( parameter SET_INDEX_BITS,
	   parameter ADDRESS_BITS,
	   parameter DATA_BITS,
	   parameter BLOCK_SIZE)

	( input do_replace,
	  input [SET_INDEX_BITS-1:0] replace_set_index,
	  input mem_valid,
	  input [ADDRESS_BITS-1:0] mem_address,
	  input [DATA_BITS-1:0] mem_data [BLOCK_SIZE-1: 0]);

endmodule
