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
        DIMENSION_WIDTH_G : natural;

        FMT_IN_ELEMENT_A_G : string;
        FMT_IN_ELEMENT_B_G : string;
        FMT_OUT_RESULT_G   : string
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

    ----------------------------------------------------------------------------
    -- Types
    ----------------------------------------------------------------------------
    type state_t is (
            IDLE_S,
            CALCULATE_S,
            FINISHED_S
        );

    type two_process_r is record
        vector_a         : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
        vector_b         : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);
        in_ready         : std_logic;
        out_valid        : std_logic;
        feedback_mux_sel : std_logic;
        idx              : natural range 0 to DIMENSION_WIDTH_G;
        --
        state : state_t;
    end record;

    ----------------------------------------------------------------------------
    -- Two Process records
    ----------------------------------------------------------------------------
    signal r      : two_process_r;
    signal r_next : two_process_r;

    ----------------------------------------------------------------------------
    -- MAC (Multiply and ACcumulate) signals
    ----------------------------------------------------------------------------
    signal mac_accumulator : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);
    signal mac_result      : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- MAC (Multiply and ACcumulate)
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
            in_mult_a_i => r.vector_a(r.idx),
            in_mult_b_i => r.vector_b(r.idx),
            in_add_i    => mac_accumulator,

            out_valid_o  => open,
            out_result_o => mac_result
        );

    ----------------------------------------------------------------------------
    -- Feedback MUX
    ----------------------------------------------------------------------------
    mac_accumulator <= mac_result when r.feedback_mux_sel = '1' else (others => '0');
    out_result_o    <= mac_result;

    ----------------------------------------------------------------------------
    -- Combinatorial process
    ----------------------------------------------------------------------------
    p_comb : process(all) is
        variable v : two_process_r;
    begin

        -- Hold variables stable
        v := r;

        -- Single clock cycle pulse
        v.out_valid := '0';

        ------------------------------------------------------------------------
        -- FSM
        ------------------------------------------------------------------------
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

                    v.idx   := r.idx + 1;
                    v.state := CALCULATE_S;
                end if;

            --------------------------------------------------------------------
            when CALCULATE_S =>
                v.feedback_mux_sel := '1';
                v.idx              := r.idx + 1;

                if (r.idx = DIMENSION_WIDTH_G - 1) then
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
        ------------------------------------------------------------------------
        end case;

        -- Apply to record
        r_next <= v;

    end process;

    ----------------------------------------------------------------------------
    -- Output
    ----------------------------------------------------------------------------
    -- In Interface
    in_ready_o <= r.in_ready;
    -- Out Interface
    out_valid_o <= r.out_valid;

    ----------------------------------------------------------------------------
    -- Sequential Process
    ----------------------------------------------------------------------------
    p_seq : process(clk_i) is
    begin
        if rising_edge(clk_i) then
            r <= r_next;
            if (rst_i = '1') then
                r.in_ready         <= '1';
                r.out_valid        <= '0';
                r.feedback_mux_sel <= '0';
                r.idx              <= 0;
                r.state            <= IDLE_S;
            end if;
        end if;
    end process;

end architecture rtl;
