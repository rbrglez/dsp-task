--------------------------------------------------------------------------------
-- matrix_vector_product
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library olo;
use olo.olo_base_pkg_array.all;

library work;
use work.extend_pkg_array.all;

entity matrix_vector_product is
    generic (
        NUM_DOT_PRODUCTS_G : positive := 11;

        MATRIX_ROW_WIDTH_G    : natural := 32;
        MATRIX_COLUMN_WIDTH_G : natural := 32;
        IN_ELEMENT_WIDTH_G    : natural := 16;
        OUT_ELEMENT_WIDTH_G   : natural := 37
    );
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;

        ------------------------------------------------------------------------
        -- In Interface
        ------------------------------------------------------------------------
        in_valid_i  : in  std_logic;
        in_ready_o  : out std_logic;
        in_matrix_i : in  StlvVectorArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);
        in_vector_i : in  StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);

        ------------------------------------------------------------------------
        -- Out Interface
        ------------------------------------------------------------------------
        out_valid_o  : out std_logic;
        out_error_o  : out std_logic;
        out_result_o : out StlvArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(OUT_ELEMENT_WIDTH_G - 1 downto 0)
    );
end entity matrix_vector_product;

architecture rtl of matrix_vector_product is

    constant NUM_STAGES_C : positive := integer(ceil(real(MATRIX_ROW_WIDTH_G) / real(NUM_DOT_PRODUCTS_G)));

    type state_t is (
            IDLE_S,
            FEED_DOT_PRODUCT_S,
            COLLECT_DOT_PRODUCT_S,
            ERROR_S
        );

    type two_process_r is record
        matrix_extended : StlvVectorArray_t(NUM_DOT_PRODUCTS_G*NUM_STAGES_C - 1 downto 0)(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);
        vector          : StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);

        result : StlvArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(OUT_ELEMENT_WIDTH_G - 1 downto 0);

        stage_idx : natural range 0 to NUM_STAGES_C - 1;

        in_dot_valid : std_logic;

        in_ready  : std_logic;
        out_valid : std_logic;

        out_error : std_logic;

        --
        state : state_t;
    end record;

    signal r      : two_process_r;
    signal r_next : two_process_r;

    signal out_dot_valid  : std_logic_vector(NUM_DOT_PRODUCTS_G - 1 downto 0);
    signal out_dot_result : StlvArray_t(NUM_DOT_PRODUCTS_G - 1 downto 0)(OUT_ELEMENT_WIDTH_G - 1 downto 0);

    signal in_dot_ready : std_logic_vector(NUM_DOT_PRODUCTS_G - 1 downto 0);

    signal matrix_muxed : StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Dot Product
    ----------------------------------------------------------------------------
    GEN_DOT_PRODUCT : for i in 0 to NUM_DOT_PRODUCTS_G - 1 generate

        -- GHDL requires static names in port maps. 
        -- Since r.matrix_extended(...) is dynamic, 
        -- we use the intermediate signal matrix_muxed instead.
        matrix_muxed <= r.matrix_extended(i + r.stage_idx * NUM_DOT_PRODUCTS_G);

        u_dot_product : entity work.dot_product
            generic map (
                DIMENSION_WIDTH_G => MATRIX_COLUMN_WIDTH_G,
                ELEMENT_WIDTH_G   => IN_ELEMENT_WIDTH_G,
                RESULT_WIDTH_G    => OUT_ELEMENT_WIDTH_G
            )
            port map (
                clk_i => clk_i,
                rst_i => rst_i,

                in_valid_i    => r.in_dot_valid,
                in_ready_o    => in_dot_ready(i),
                in_vector_a_i => matrix_muxed,
                in_vector_b_i => r.vector,

                out_valid_o       => out_dot_valid(i),
                out_dot_product_o => out_dot_result(i)
            );
    end generate GEN_DOT_PRODUCT;

    ----------------------------------------------------------------------------
    -- Combinatorial process
    ----------------------------------------------------------------------------
    p_comb : process(all) is
        variable v : two_process_r;
    begin

        v := r;

        v.out_valid := '0';
        v.out_error := '0';

        case (r.state) is
            --------------------------------------------------------------------
            when IDLE_S =>
                v.stage_idx := 0;

                v.in_ready := '1';
                if in_valid_i = '1' and r.in_ready = '1' then
                    v.in_ready := '0';

                    -- Register Vector and Matrix
                    v.matrix_extended(MATRIX_ROW_WIDTH_G - 1 downto 0) := in_matrix_i;
                    v.vector                                           := in_vector_i;

                    v.in_dot_valid := '1';

                    v.state := FEED_DOT_PRODUCT_S;
                end if;

            --------------------------------------------------------------------
            when FEED_DOT_PRODUCT_S =>

                v.in_dot_valid := '1';
                if (r.in_dot_valid = '1' and in_dot_ready /= (in_dot_ready'range => '0')) then
                    v.in_dot_valid := '0';

                    if (in_dot_ready /= (in_dot_ready'range => '1')) then
                        -- ERROR !!!
                        -- all of dot_product in_ready inputs weren't set at the same time!
                        v.state := ERROR_S;
                    else
                        v.state := COLLECT_DOT_PRODUCT_S;

                    end if;

                end if;

            --------------------------------------------------------------------
            when COLLECT_DOT_PRODUCT_S =>

                if (out_dot_valid /= (out_dot_valid'range => '0')) then

                    for i in 0 to NUM_DOT_PRODUCTS_G - 1 loop
                        if (i + r.stage_idx * NUM_DOT_PRODUCTS_G < MATRIX_ROW_WIDTH_G) then
                            v.result(i + r.stage_idx * NUM_DOT_PRODUCTS_G) := out_dot_result(i);
                        end if;
                    end loop;

                    if (out_dot_valid /= (out_dot_valid'range => '1')) then
                        -- ERROR
                        v.state := ERROR_S;
                    elsif (r.stage_idx < NUM_STAGES_C - 1) then
                        v.stage_idx := r.stage_idx + 1;
                        v.state     := FEED_DOT_PRODUCT_S;
                    else
                        v.out_valid := '1';
                        v.in_ready  := '1';

                        v.stage_idx := 0;

                        v.state := IDLE_S;
                    end if;
                end if;


            --------------------------------------------------------------------
            when ERROR_S =>
                v.out_error := '1';

            --------------------------------------------------------------------
            when others =>
                null;
        end case;
        r_next <= v;

    end process;

    ----------------------------------------------------------------------------
    -- Output
    ----------------------------------------------------------------------------
    out_result_o <= r.result;
    out_error_o  <= r.out_error;

    out_valid_o <= r.out_valid;

    in_ready_o <= r.in_ready;

    ----------------------------------------------------------------------------
    -- Sequential Process
    ----------------------------------------------------------------------------
    p_seq : process(clk_i) is
    begin
        if rising_edge(clk_i) then
            r <= r_next;
            if (rst_i = '1') then

                r.stage_idx       <= 0;
                r.matrix_extended <= (others => (others => (others => 'X')));
                r.in_ready        <= '1';

                r.out_valid <= '0';

                r.out_error <= '0';

                r.state <= IDLE_S;
            end if;
        end if;
    end process;

end architecture rtl;
