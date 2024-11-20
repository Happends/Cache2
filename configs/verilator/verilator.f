--binary
./rtl/tag_compare.sv
./rtl/mem_request.sv
./rtl/replace_index.sv
./rtl/cache_entries_update.sv
./rtl/stop_cache.sv
./rtl/outputs.sv
./rtl/cache.sv
./rtl/simulation/tb.sv
--top tb

//--Wall
-j 0

--assert

--trace-fst
--trace-structs

--x-assign unique
--x-initial unique
