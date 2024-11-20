

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
	input	ram_valid,
	input	[DATA_BITS-1:0] ram_data [BLOCK_SIZE-1:0],

	output  [DATA_BITS-1:0] read_data,
        output  valid,
	output  miss,
        output  [RAM_ADDRESS_BITS-1:0] prop_address, 
	output	prop_read_en,
        output	[DATA_BITS-1:0] prop_write_data, 
        output  prop_write_en);

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

			ram_valid_reg <= 0;
			ram_data_reg <= '{default: '0};


		end else if(stop_cache) begin
        		address_reg <= address_reg;
        		read_en_reg <= read_en_reg;
        		write_data_reg <= write_data_reg;
        		write_en_reg <= write_en_reg;

			// not these two
			ram_valid_reg <= ram_valid;
			ram_data_reg <= ram_data;

		end else begin
        		address_reg <= address;
        		read_en_reg <= read_en;
        		write_data_reg <= write_data;
        		write_en_reg <= write_en;

			ram_valid_reg <= ram_valid;
			ram_data_reg <= ram_data;
		end
	end

endmodule
