library IEEE;
use IEEE.std_logic_1164.all;

entity IR is
    port (
        clk: in std_logic;                         -- Clock-Signal
        load: in std_logic;                        -- Steuersignal
        ir_in: in std_logic_vector (15 downto 0);  -- Dateneingang
        ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
    );
    end IR;
    
architecture RTL of IR is
    -- Internal register
    signal reg: std_logic_vector (15 downto 0);
begin
    -- Output always contains register entry
    ir_out <= reg;

    -- State machine
    process(clk)
    begin
        if (rising_edge(clk)) then
            if load = '1' then
                reg <= ir_in;
            end if;
        end if;
    end process;
end RTL;
