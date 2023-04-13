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
	 

	 --constant threshold : std_logic_vector(15 downto 0) := x"2710";
	 constant threshold : integer := 50000;
	 constant clapLengthLimit : integer := 100; -- define how long the clap should be?
	 
	 signal temp : integer := 0; -- temp variable for adding
	 
	 signal clapLength : integer := 0; -- measure
	 
	 
	 TYPE STATE_TYPE IS (
		--Analysis,
		clapState,
		ThresholdTest
		--ThresholdMet
	 );
	 
	 signal state : STATE_TYPE;
	 signal summon: std_logic_vector(1 DOWNTO 0);

begin

    -- Latch data on rising edge of CS to keep it stable during IN
  --  process (CS) begin
    --    if rising_edge(CS) then
      --      output_data <= parsed_data;
    --    end if;
   -- end process;
	 
    -- Drive IO_DATA when needed.
    out_en <= CS AND ( NOT IO_WRITE );
    with out_en select IO_DATA <=
        parsed_data        when '1',
        "ZZZZZZZZZZZZZZZZ" when others;

    -- This template device just copies the input data
    -- to IO_DATA by latching the data every time a new
    -- value is ready.
    process (RESETN, SYS_CLK)
    begin
        if (RESETN = '0') then -- on reset
            parsed_data <= x"0000"; -- reset the parsed data
				
		elsif (rising_edge(AUD_NEW)) then -- when new audio data comes in
		
			--state <= ThresholdTest; -- initial state: check if the threshold is met for the audio data
			
			CASE state IS
			
				WHEN ThresholdTest =>  -- check if the threshold is met
					IF (conv_integer(unsigned(AUD_DATA)) >= threshold) THEN
						state <= ClapState; -- if it's met move into the met state
					ELSE
						state <= ThresholdTest; -- stay here otherwise
					END IF;
					
						
				WHEN clapState => 
					temp <= conv_integer(parsed_data) + 1;
					parsed_data <= conv_std_logic_vector(temp, parsed_data'length);
					state <= ThresholdTest; 
					
			END CASE;
		end if;
    end process;
summon <= CS & IO_WRITE;

end a;