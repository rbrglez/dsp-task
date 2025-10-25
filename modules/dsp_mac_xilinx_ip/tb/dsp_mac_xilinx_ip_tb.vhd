--------------------------------------------------------------------------------
-- dsp_mac_xilinx_ip_tb
--------------------------------------------------------------------------------

library std;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xbc;
context xbc.xbc_testbench_context;

library olo;
use olo.olo_base_pkg_logic.all;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;

entity dsp_mac_xilinx_ip_tb is
    generic (
        TEST_CASE_G : string := "demo"
    );
end entity dsp_mac_xilinx_ip_tb;

architecture tb of dsp_mac_xilinx_ip_tb is

    constant T_C : time := 10 ns;

    constant WIDTH_A_G : natural := 25;
    constant WIDTH_B_G : natural := 18;
    constant WIDTH_C_G : natural := 43;
    constant WIDTH_P_G : natural := 44;

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------s
    signal clk_i : std_logic;
    signal rst_i : std_logic;

    signal a_i : std_logic_vector(WIDTH_A_G - 1 downto 0);
    signal b_i : std_logic_vector(WIDTH_B_G - 1 downto 0);
    signal c_i : std_logic_vector(WIDTH_C_G - 1 downto 0);

    signal p_o : std_logic_vector(WIDTH_P_G - 1 downto 0);

    signal sel : std_logic;

    component dsp_mac_xilinx_ip
        port (
            clk : in  std_logic;
            a   : in  std_logic_vector(24 downto 0);
            b   : in  std_logic_vector(17 downto 0);
            c   : in  std_logic_vector(42 downto 0);
            p   : out std_logic_vector(43 downto 0)
        );
    end component;

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : dsp_mac_xilinx_ip
        port map (
            clk => clk_i,
            a   => a_i,
            b   => b_i,
            c   => c_i,
            p   => p_o
        );


    -- MUX
    c_i <= p_o(c_i'left downto 0) when sel = '1' else (others => '0');

    ----------------------------------------------------------------------------
    -- Clock process
    ----------------------------------------------------------------------------
    tb_clock(clk_i, T_C);

    ----------------------------------------------------------------------------
    -- Simulation process
    ----------------------------------------------------------------------------
    p_main : process is
    begin

        tb_clk_period(clk_i, 10);

        sel <= '0';

        log_info("Reset DUT");
        rst_i <= '0';
        tb_clk_period(clk_i);
        rst_i <= '1';
        tb_clk_period(clk_i, 5);
        rst_i <= '0';
        tb_clk_period(clk_i, 10);



        if (TEST_CASE_G = "demo") then
            --------------------------------------------------------------------
            log_info("Test Case: demo");
            for i in 0 to 32 - 1 loop

                a_i <= toUslv(1, a_i'length);
                b_i <= toUslv(1, b_i'length);

                tb_clk_period(clk_i, 4);
                
                sel <= '1';
            end loop;

            sel <= '0';

            tb_clk_period(clk_i, 100);


        end if;

        tb_finish;

    end process;

end architecture tb;