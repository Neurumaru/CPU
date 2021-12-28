library verilog;
use verilog.vl_types.all;
entity ascii_decoder_hex is
    port(
        \in\            : in     vl_logic_vector(3 downto 0);
        \out\           : out    vl_logic_vector(7 downto 0)
    );
end ascii_decoder_hex;
