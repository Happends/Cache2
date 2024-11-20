
module cache 
    #(  parameter RAM_ADDRESS_BITS = 10,    // change to size
        parameter CACHE_ADDRESS_BITS = 5,   // change to size
        parameter DATA_BITS=32,
        parameter ASOC_BITS=1,
        parameter BLOCK_BITS=2)

    (   input   clk,
        input   reset_n,
        input   [RAM_ADDRESS_BITS-1:0] address, 
        input   read_en,
        input	[DATA_BITS-1:0] write_data, 
        input	write_en,
	input	mem_valid,
	input	[DATA_BITS-1:0] mem_data [BLOCK_SIZE-1:0],

	output  [DATA_BITS-1:0] read_data,
        output  valid,
	output  miss,
        output  [RAM_ADDRESS_BITS-1:0] prop_address, 
	output	prop_read_en,
        output	[DATA_BITS-1:0] prop_write_data, 
        output  prop_write_en,
	output  prop_valid);

	parameter TAG_BITS = RAM_ADDRESS_BITS-CACHE_ADDRESS_BITS+ASOC_BITS;
	parameter INDEX_BITS = CACHE_ADDRESS_BITS-ASOC_BITS-BLOCK_BITS;


   	// typedef for getting cache_address parts 
    	typedef struct packed {
        	logic [TAG_BITS-1:0] tag;
        	logic [INDEX_BITS-1:0] index;
        	logic [BLOCK_BITS-1:0] offset;
    	} cache_address_t;


	parameter BLOCK_SIZE = 2**BLOCK_BITS;
	parameter ASOC_SIZE = 2**ASOC_BITS;


	// typedef for cache entries
	typedef struct packed {
		logic valid;
		logic dirty;
		logic [ASOC_BITS-1:0] lru_number;
	} cache_entry_control_bits_t;

    	typedef struct {
		cache_entry_control_bits_t control_bits;
        	logic [TAG_BITS-1:0] tag;
       		logic [DATA_BITS-1:0] data [0:BLOCK_SIZE-1];     // might have to be packed to match input from RAM
    	} cache_entry_t;

	typedef struct {
		cache_entry_t block [0:ASOC_SIZE-1];
	} cache_set_t;


        logic [DATA_BITS-1:0] read_data_logic;
        logic valid_logic;
        logic miss_logic;
        logic [RAM_ADDRESS_BITS-1:0] prop_address_logic;
        logic prop_read_en_logic;
        logic [DATA_BITS-1:0] prop_write_data_logic [0:BLOCK_SIZE-1];
        logic prop_write_en_logic;


        logic [RAM_ADDRESS_BITS-1:0] address_reg;
        logic read_en_reg;
        logic [DATA_BITS-1:0] write_data_reg;
        logic write_en_reg;
        logic mem_valid_reg;
	logic [RAM_ADDRESS_BITS-1:0] mem_address_reg;
        logic [DATA_BITS-1:0] mem_data_reg [BLOCK_SIZE-1:0];


        cache_address_t cache_address;
        assign cache_address = address_reg;

        parameter INDEX_SIZE = 2**INDEX_BITS;
        cache_set_t cache [INDEX_SIZE-1:0];

        assign read_data = read_data_logic;
        assign valid = valid_logic;
        assign miss = miss_logic;
        assign prop_address = prop_address_logic;
        assign prop_read_en = prop_read_en_logic;
        assign prop_write_en = prop_write_en_logic;
  
	logic stop_cache;



	initial begin

		if (RAM_ADDRESS_BITS < CACHE_ADDRESS_BITS) begin
			$error("ERROR: cache settings wrong");
		end 
        	if ((ASOC_BITS+BLOCK_BITS) > CACHE_ADDRESS_BITS) begin 
			$error("ERROR: cache settings wrong");
        	end
        	$display("cache settings ok");
		cache = '{default: '{block: '{default: '{control_bits: '{valid: 0, dirty: 0, lru_number: '0}, tag: '0, data: '{default: '1}}}}}; // valid temporary
    	end


	always_ff @(posedge clk)
	begin
		if (!reset_n) begin
        		address_reg <= '0;
        		read_en_reg <= 0;
        		write_data_reg <= '0;
        		write_en_reg <= 0;

			mem_valid_reg <= 0;
			mem_data_reg <= '{default: '0};


		end else if(stop_cache) begin
        		address_reg <= address_reg;
        		read_en_reg <= read_en_reg;
        		write_data_reg <= write_data_reg;
        		write_en_reg <= write_en_reg;

			// not these two
			mem_valid_reg <= mem_valid;
			mem_data_reg <= mem_data;

		end else begin
        		address_reg <= address;
        		read_en_reg <= read_en;
        		write_data_reg <= write_data;
        		write_en_reg <= write_en;

			mem_valid_reg <= mem_valid;
			mem_data_reg <= mem_data;
		end
	end

	logic hit_miss;
	logic [INDEX_BITS-1:0] set_index;
	logic [INDEX_BITS-1:0] replace_set_index;
	logic do_replace;

	tag_compare  #(	.ADDRESS_BITS (RAM_ADDRESS_BITS),
			.SET_INDEX_BITS (INDEX_BITS))
			 tag_comp
		      (	.address (cache_address),
		      	.valid (valid),
			      
			.hit_miss (hit_miss),
			.set_index (set_index));

	mem_request  #(	.ADDRESS_BITS (RAM_ADDRESS_BITS),
			.SET_INDEX_BITS (INDEX_BITS),
			.DATA_BITS (DATA_BITS))
			 mem_req
		      (	.write_en (write_en),
			.address (cache_address),
			.hit_miss (hit_miss),
			.set_index (set_index),
			
			.prop_address (prop_address),
			.prop_write_en (prop_write_en),
			.prop_valid (prop_valid),
			.prop_write_data (prop_write_data));

	replace_index #(.SET_INDEX_BITS (INDEX_BITS))
			 rep_index
		       (.hit_miss (hit_miss),
			.write_en (write_en),
			.read_en (read_en),
			
			.replace_set_index (replace_set_index),
			.do_replace (do_replace));

	cache_entries_update #(	.SET_INDEX_BITS (INDEX_BITS),
				.ADDRESS_BITS (RAM_ADDRESS_BITS),
				.DATA_BITS (DATA_BITS),
				.BLOCK_SIZE (BLOCK_SIZE))
				 cache_entries_up
			      ( .do_replace (do_replace),
	      			.replace_set_index (replace_set_index),

				.mem_valid (mem_valid_reg),
				.mem_address (mem_address_reg),
				.mem_data (mem_data_reg));				

	stop_cache stop_c
		  (.do_replace (do_replace),
		   .do_prop_write (prop_valid & prop_write_en),
		   .mem_valid (mem_valid_reg),
		   .stop_cache (stop_cache));

	outputs #( .SET_INDEX_BITS (INDEX_BITS),
		   .OFFSET_BITS (BLOCK_BITS),
		   .DATA_BITS (DATA_BITS))
		    out
		 ( .hit_miss (hit_miss),
		   .set_index (set_index),
		   .address_offset (cache_address.offset),
		   
		   .miss (miss),
		   .valid (valid),
		   .data (read_data));

endmodule
