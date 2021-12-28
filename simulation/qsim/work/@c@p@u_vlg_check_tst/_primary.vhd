library verilog;
use verilog.vl_types.all;
entity CPU_vlg_check_tst is
    port(
        HEX0            : in     vl_logic_vector(6 downto 0);
        HEX1            : in     vl_logic_vector(6 downto 0);
        HEX2            : in     vl_logic_vector(6 downto 0);
        HEX3            : in     vl_logic_vector(6 downto 0);
        HEX4            : in     vl_logic_vector(6 downto 0);
        HEX5            : in     vl_logic_vector(6 downto 0);
        HEX6            : in     vl_logic_vector(6 downto 0);
        HEX7            : in     vl_logic_vector(6 downto 0);
        LCD_BLON        : in     vl_logic;
        LCD_DATA        : in     vl_logic_vector(7 downto 0);
        LCD_EN          : in     vl_logic;
        LCD_ON          : in     vl_logic;
        LCD_RS          : in     vl_logic;
        LCD_RW          : in     vl_logic;
        LEDG            : in     vl_logic_vector(8 downto 0);
        LEDR            : in     vl_logic_vector(17 downto 0);
        sampler_rx      : in     vl_logic
    );
end CPU_vlg_check_tst;
