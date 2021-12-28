library verilog;
use verilog.vl_types.all;
entity CPU_vlg_sample_tst is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(3 downto 0);
        SW              : in     vl_logic_vector(17 downto 0);
        sampler_tx      : out    vl_logic
    );
end CPU_vlg_sample_tst;
