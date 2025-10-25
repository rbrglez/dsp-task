--------------------------------------------------------------------------------
-- dot_product
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;

entity dot_product is
    generic (
        DIMENSION_WIDTH_G : natural := 32;
        ELEMENT_WIDTH_G   : natural := 16;
        PRODUCT_WIDTH_G   : natural := 37
    );
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;

        ------------------------------------------------------------------------
        -- In Interface
        ------------------------------------------------------------------------
        in_valid_i    : in  std_logic;
        in_ready_o    : out std_logic;
        in_vector_a_i : in  StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);
        in_vector_b_i : in  StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);

        ------------------------------------------------------------------------
        -- Out Interface
        ------------------------------------------------------------------------
        out_valid_o       : out std_logic;
        out_dot_product_o : out std_logic_vector(PRODUCT_WIDTH_G - 1 downto 0)
    );
end entity dot_product;

architecture rtl of dot_product is

    type state_t is (
            IDLE_S,
            WORK_S,
            FINISHED_S
        );

    type two_process_r is record
        vector_a : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);
        vector_b : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);

        element_a : std_logic_vector(ELEMENT_WIDTH_G - 1 downto 0);
        element_b : std_logic_vector(ELEMENT_WIDTH_G - 1 downto 0);

        in_ready  : std_logic;
        out_valid : std_logic;

        sel : std_logic;

        idx : natural range 0 to DIMENSION_WIDTH_G;

        state : state_t;
    end record;

    signal r      : two_process_r;
    signal r_next : two_process_r;


    signal accumulate : std_logic_vector(PRODUCT_WIDTH_G - 1 downto 0);
    signal product    : std_logic_vector(PRODUCT_WIDTH_G - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Multiply and ACcumulate
    ----------------------------------------------------------------------------
    u_dsp_mac : entity work.dsp_mac
        generic map (
            WIDTH_A_G => ELEMENT_WIDTH_G,
            WIDTH_B_G => ELEMENT_WIDTH_G,
            WIDTH_C_G => PRODUCT_WIDTH_G,
            WIDTH_P_G => PRODUCT_WIDTH_G
        )
        port map (
            clk_i => clk_i,
            a_i   => r.element_a,
            b_i   => r.element_b,
            c_i   => accumulate,
            p_o   => product
        );

    ----------------------------------------------------------------------------
    -- MUX
    ----------------------------------------------------------------------------
    accumulate        <= product when r.sel = '1' else (others => '0');
    out_dot_product_o <= product;

    ----------------------------------------------------------------------------
    -- Combinatorial process
    ----------------------------------------------------------------------------
    p_comb : process(all) is
        variable v : two_process_r;
    begin

        v := r;

        -- Strobe
        v.out_valid := '0';

        case (r.state) is
            --------------------------------------------------------------------
            when IDLE_S =>

                v.sel      := '0';
                v.in_ready := '1';

                if in_valid_i = '1' and r.in_ready = '1' then
                    v.in_ready := '0';

                    -- Register Vectors
                    v.vector_a := in_vector_a_i;
                    v.vector_b := in_vector_b_i;

                    v.state := WORK_S;
                end if;

            --------------------------------------------------------------------
            when WORK_S =>

                v.element_a := r.vector_a(r.idx);
                v.element_b := r.vector_b(r.idx);

                v.idx := r.idx + 1;

                if (r.idx > 0) then
                    v.sel := '1';
                end if;

                if (r.idx > DIMENSION_WIDTH_G - 2) then
                    v.idx   := 0;
                    v.state := FINISHED_S;
                end if;

            --------------------------------------------------------------------
            when FINISHED_S =>
                v.sel       := '0';
                v.out_valid := '1';
                v.state     := IDLE_S;

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
                r.sel <= '0';

                r.in_ready  <= '1';
                r.out_valid <= '0';

                r.idx <= 0;

            end if;
        end if;
    end process;

end architecture rtl;
