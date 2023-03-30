-- AudioMonitor.vhd
-- Created 2023
-- Levi Tucker, George Lee, Edmond Li, Isaac Chia, Edward Kwak
-- This SCOMP peripheral passes data from an input bus to SCOMP's I/O bus.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use lpm.lpm_components.all;

entity AudioMonitor is
port(
    CS          : in  std_logic;
    IO_WRITE    : in  std_logic;
    SYS_CLK     : in  std_logic;  -- SCOMP's clock
    RESETN      : in  std_logic;
    AUD_DATA    : in  std_logic_vector(15 downto 0);
    AUD_NEW     : in  std_logic;
    IO_DATA     : inout  std_logic_vector(15 downto 0)
);
end AudioMonitor;

architecture a of AudioMonitor is

    signal out_en      : std_logic;
    signal parsed_data : std_logic_vector(15 downto 0);
    signal output_data : std_logic_vector(15 downto 0);
	 
	 
	 
	 signal threshold_met : std_logic;
	 constant threshold : std_logic_vector(15 downto 0) := x"2710";
	 
	 
	 TYPE STATE_TYPE IS (
		ThresholdTest,
		ThresholdMet
	 );
	 
	 signal state : STATE_TYPE;

begin

    -- Latch data on rising edge of CS to keep it stable during IN
    process (CS) begin
        if rising_edge(CS) then
            output_data <= parsed_data;
        end if;
    end process;
    -- Drive IO_DATA when needed.
    out_en <= CS AND ( NOT IO_WRITE );
    with out_en select IO_DATA <=
        output_data        when '1',
        "ZZZZZZZZZZZZZZZZ" when others;

    -- This template device just copies the input data
    -- to IO_DATA by latching the data every time a new
    -- value is ready.
    process (RESETN, SYS_CLK)
    begin
        if (RESETN = '0') then -- on reset
            parsed_data <= x"0000";
				threshold_met <= '0';
			elsif (rising_edge(AUD_NEW)) then
				CASE state IS
					WHEN ThresholdTest =>
						IF (unsigned(AUD_DATA) >= unsigned(threshold)) THEN
							state <= ThresholdMet;
						ELSE
							state <= ThresholdTest;
						END IF;
					WHEN ThresholdMet =>
						--define ThresholdMet state
							--counter++
							if (unsigned(NEW_DATA) >= unsigned(threshold)) then 
								state <= ThresholdMet; 
							else 
								state <= Analysis; 
							end if; 
					WHEN Analysis => 
						-- compare counter w/ clap limit
							if (counter <= clap limit) then 
								--clapState; 
							else 
								--notClapState;
							end if; 
					WHEN clapState => 
						-- send to SCOMP, increment hex thing 
					WHEN notClapState => 
						state <= ThresholdTest; 
				END CASE;
			end if;
    end process;

end a;
