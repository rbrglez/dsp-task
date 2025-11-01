--------------------------------------------------------------------------------
-- fix_dot_product
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fix_dot_product is
    generic (
        DIMENSION_WIDTH_G : natural := 32;

        FMT_IN_ELEMENT_A_G : string := "(0, 2, 2)";
        FMT_IN_ELEMENT_B_G : string := "(0, 2, 2)";
        FMT_OUT_RESULT_G   : string := "(0, 9, 4)"
    );
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;

        ------------------------------------------------------------------------
        -- In Interface
        ------------------------------------------------------------------------
        in_valid_i    : in  std_logic := '1';
        in_ready_o    : out std_logic;
        in_vector_a_i : in  StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
        in_vector_b_i : in  StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);

        ------------------------------------------------------------------------
        -- Out Interface
        ------------------------------------------------------------------------
        out_valid_o  : out std_logic;
        out_result_o : out std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0)
    );
end entity fix_dot_product;

architecture rtl of fix_dot_product is

    type state_t is (
            IDLE_S,
            CALCULATE_S,
            FINISHED_S
        );

    type two_process_r is record
        vector_a         : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
        vector_b         : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);
        factor_a         : std_logic_vector(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
        factor_b         : std_logic_vector(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);
        in_ready         : std_logic;
        out_valid        : std_logic;
        feedback_mux_sel : std_logic;
        idx              : natural range 0 to DIMENSION_WIDTH_G;
        --
        state : state_t;
    end record;

    signal r      : two_process_r;
    signal r_next : two_process_r;

    signal accumulator : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);
    signal result      : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Multiply and ACcumulate
    ----------------------------------------------------------------------------
    u_fix_dsp_mac : entity work.fix_dsp_mac
        generic map (
            FMT_MULT_A_G => FMT_IN_ELEMENT_A_G,
            FMT_MULT_B_G => FMT_IN_ELEMENT_B_G,
            FMT_ADD_G    => FMT_OUT_RESULT_G,
            FMT_RESULT_G => FMT_OUT_RESULT_G
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,

            in_valid_i  => '1',
            in_mult_a_i => r.factor_a,
            in_mult_b_i => r.factor_b,
            in_add_i    => accumulator,

            out_valid_o  => open,
            out_result_o => result
        );

    ----------------------------------------------------------------------------
    -- Feedback MUX
    ----------------------------------------------------------------------------
    accumulator  <= result when r.feedback_mux_sel = '1' else (others => '0');
    out_result_o <= result;

    ----------------------------------------------------------------------------
    -- Combinatorial process
    ----------------------------------------------------------------------------
    p_comb : process(all) is
        variable v : two_process_r;
    begin

        v := r;

        -- Single clock cycle pulse
        v.out_valid := '0';

        case (r.state) is
            --------------------------------------------------------------------
            when IDLE_S =>
                v.feedback_mux_sel := '0';
                v.idx              := 0;

                v.in_ready := '1';
                if in_valid_i = '1' and r.in_ready = '1' then
                    v.in_ready := '0';

                    -- Register Vectors
                    v.vector_a := in_vector_a_i;
                    v.vector_b := in_vector_b_i;

                    -- Extract the first factors from register
                    v.factor_a := in_vector_a_i(r.idx);
                    v.factor_b := in_vector_b_i(r.idx);

                    v.idx := r.idx + 1;

                    v.state := CALCULATE_S;
                end if;

            --------------------------------------------------------------------
            when CALCULATE_S =>

                v.feedback_mux_sel := '1';

                v.factor_a := r.vector_a(r.idx);
                v.factor_b := r.vector_b(r.idx);

                v.idx := r.idx + 1;

                if (r.idx > DIMENSION_WIDTH_G - 2) then
                    v.idx   := 0;
                    v.state := FINISHED_S;
                end if;

            --------------------------------------------------------------------
            when FINISHED_S =>
                v.feedback_mux_sel := '0';
                v.out_valid        := '1';
                v.in_ready         := '1';

                v.state := IDLE_S;

            --------------------------------------------------------------------
            when others =>
                null;
        end case;

        r_next <= v;

    end process;

    ----------------------------------------------------------------------------
    -- Output
    ----------------------------------------------------------------------------
    out_valid_o <= r.out_valid;
    in_ready_o  <= r.in_ready;

    ----------------------------------------------------------------------------
    -- Sequential Process
    ----------------------------------------------------------------------------
    p_seq : process(clk_i) is
    begin
        if rising_edge(clk_i) then
            r <= r_next;
            if (rst_i = '1') then
                r.feedback_mux_sel <= '0';
                r.in_ready         <= '1';
                r.out_valid        <= '0';
                r.idx              <= 0;
                r.state            <= IDLE_S;
            end if;
        end if;
    end process;

end architecture rtl;
