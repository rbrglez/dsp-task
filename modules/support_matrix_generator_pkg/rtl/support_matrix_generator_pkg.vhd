---------------------------------------------------------------------------------------------------
-- support_matrix_generator_pkg
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;

library work;
use work.extend_pkg_array.all;

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------
package support_matrix_generator_pkg is

    function ascending_matrix(
            constant MATRIX_ROW_WIDTH    : integer;
            constant MATRIX_COLUMN_WIDTH : integer;
            constant ELEMENT_WIDTH       : integer
        ) return StlvVectorArray_t;

    function descending_matrix(
            constant MATRIX_ROW_WIDTH    : integer;
            constant MATRIX_COLUMN_WIDTH : integer;
            constant ELEMENT_WIDTH       : integer
        ) return StlvVectorArray_t;
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body support_matrix_generator_pkg is

    function ascending_matrix(
            constant MATRIX_ROW_WIDTH    : integer;
            constant MATRIX_COLUMN_WIDTH : integer;
            constant ELEMENT_WIDTH       : integer
        ) return StlvVectorArray_t is
        variable result_v : StlvVectorArray_t(MATRIX_ROW_WIDTH - 1 downto 0)(MATRIX_COLUMN_WIDTH - 1 downto 0)(ELEMENT_WIDTH - 1 downto 0);
    begin
        for row in 0 to MATRIX_ROW_WIDTH - 1 loop
            for col in 0 to MATRIX_COLUMN_WIDTH - 1 loop
                result_v(row)(col) := toUslv(col + row * MATRIX_COLUMN_WIDTH, ELEMENT_WIDTH);
            end loop;
        end loop;

        return result_v;
    end function ascending_matrix;

    function descending_matrix(
            constant MATRIX_ROW_WIDTH    : integer;
            constant MATRIX_COLUMN_WIDTH : integer;
            constant ELEMENT_WIDTH       : integer
        ) return StlvVectorArray_t is
        variable result_v      : StlvVectorArray_t(MATRIX_ROW_WIDTH - 1 downto 0)(MATRIX_COLUMN_WIDTH - 1 downto 0)(ELEMENT_WIDTH - 1 downto 0);
        variable max_element_v : unsigned(ELEMENT_WIDTH - 1 downto 0) := (others => '1');
    begin
        for row in 0 to MATRIX_ROW_WIDTH - 1 loop
            for col in 0 to MATRIX_COLUMN_WIDTH - 1 loop
                result_v(row)(col) := std_logic_vector(max_element_v - to_unsigned(col + row * MATRIX_COLUMN_WIDTH, ELEMENT_WIDTH));
            end loop;
        end loop;

        return result_v;
    end function descending_matrix;

end package body;