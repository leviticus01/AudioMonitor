-- AudioMonitor.vhd
-- Created 2023
-- Levi Tucker, George Lee, Edmond Li, Isaac Chia, Edward Kwak
-- This SCOMP peripheral detects claps and passes this information to SCOMP's IO bus.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use lpm.lpm_components.all;

entity AudioMonitor is
	port(
		CS			:	in		std_logic; -- chip select
		IO_WRITE	: 	in		std_logic; -- 0 = out to SCOMP, 1 = in from SCOMP
		SYS_CLK	: 	in  	std_logic; -- SCOMP's clock
		RESETN	: 	in  	std_logic; -- reset
		AUD_NEW	: 	in  	std_logic; -- 1 when new audio data
		
		AUD_DATA	: 	in		std_logic_vector(15 downto 0); -- incoming audio data
		IO_DATA	: 	inout	std_logic_vector(15 downto 0)  -- IO bus
	);
end AudioMonitor;

architecture a of AudioMonitor is

	-- IO information for SCOMP
	signal numClaps : std_logic_vector(15 downto 0); -- output
	signal thresh_from_scomp : std_logic_vector(15 downto 0); -- input
	 
	-- maximum length of clap
	constant clapLengthLimit : integer := 10; -- maximum length of a clap

	-- "variables"
	signal threshold : integer := 10000; -- default threshold value in case SCOMP doesn't set one initially
	signal temp2 : integer := 0; -- temporary variable for adding
	signal clapLength : integer := 0; -- counter to measure the length of the clap
	 
	 TYPE STATE_TYPE IS (
		ThresholdTest,
		ThresholdMet
	 );
	 
	 signal state : STATE_TYPE;

begin
		
	-- determines if data should be sent or recieved
	process(CS,IO_WRITE) begin
			
		-- when SCOMP provides a hex value using OUT, convert
		-- to an integer and multiply by 1000 to obtain a threshold
		if(CS = '1' AND IO_WRITE = '1') then
			thresh_from_scomp <= IO_DATA;
			threshold <= 1000*conv_integer(unsigned(thresh_from_scomp));
					
		-- when SCOMP requests data using IN, provide the number of claps that have occured
		elsif (CS = '1' AND IO_WRITE = '0') then 
			IO_DATA <= numClaps;
				
		-- otherwise do not drive the IO bus
		else
			IO_DATA <= "ZZZZZZZZZZZZZZZZ";
		end if;
		
	end process;

	process (RESETN, SYS_CLK)
	begin
		if (RESETN = '0') then -- on reset
			numClaps <= "0000000000000000"; -- reset the output data
				
		elsif (rising_edge(AUD_NEW)) then -- when new audio data comes in
			state <= ThresholdTest; -- initial state: check if the threshold is met for the audio data
			
			CASE state IS
			
				WHEN ThresholdTest =>  -- check if the threshold is met
					clapLength <= 0; -- reset the length of the clap
					IF (conv_integer(signed(AUD_DATA)) > threshold) THEN -- check if audio is above threshold
						state <= ThresholdMet; -- move into above threshold state
					ELSE
						state <= ThresholdTest; -- stay in this state otherwise (wait)
					END IF;
					
				WHEN ThresholdMet => -- when audio is above threshold
					IF (conv_integer(signed(AUD_DATA)) > threshold) THEN -- check if audio is still above threshold
						clapLength <= clapLength + 1; -- increase the length of the clap
						state <= ThresholdMet; -- if it's met move into the met state
					ELSE
						IF(clapLength > clapLengthLimit) THEN -- measure claplength
							state <= ThresholdTest; -- if it's too long, not a clap, go back to initial state
						ELSE
							temp2 <= conv_integer(numClaps) + 1; -- store number of claps as integer in temp variable
							numClaps <= conv_std_logic_vector(temp2, numClaps'length); -- convert temp variable back to stdlogicvec
							state <= ThresholdTest; -- go back to initial state
						END IF;
					END IF;
			END CASE;
		end if;
    end process;

end a;
