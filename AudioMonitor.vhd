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
	 --signal in_en 		  : std_logic; -- input enable from SCOMP
    signal numClaps : std_logic_vector(15 downto 0);
    signal output_data : std_logic_vector(15 downto 0);
	 signal input_data  : std_logic_vector(15 downto 0); -- input from SCOMP to set the treshold
	 signal thresh_from_scomp : std_logic_vector(15 downto 0);
	 
	 signal threshold : integer := 10000;
	 constant clapLengthLimit : integer := 10; -- define how long the clap should be
	 
	 signal temp3 : integer := 0;
	 signal temp2 : integer := 0; -- temp2 variable for adding
	 signal temp1 : integer := 0;
	 
	 signal clapLength : integer := 0; -- measure length of clap
	 signal clapDetected : std_logic; -- for debugging
	 
	 
	 TYPE STATE_TYPE IS (
		--Analysis,
		--ClapState,
		ThresholdTest,
		ThresholdMet
	 );
	 
	 signal state : STATE_TYPE;

begin
		
		process(CS,IO_WRITE) begin
			if(CS = '1' AND IO_WRITE = '1') then -- when SCOMP is sending data
				thresh_from_scomp <= IO_DATA;
				threshold <= 1000*conv_integer(unsigned(thresh_from_scomp));
			elsif (CS = '1' AND IO_WRITE = '0') then 
				IO_DATA <= numClaps;
			else
				IO_DATA <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end process;
		
    -- Latch data on rising edge of CS to keep it stable during IN
    --process (CS) begin
    --    if rising_edge(CS) then
    --        output_data <= numClaps;
	--			input_data <= IO_DATA;
   --     end if;
   -- end process;
	 
    -- Drive IO_DATA when needed.
--    out_en <= CS AND ( NOT IO_WRITE );
 --   with out_en select IO_DATA <=
  --      output_data        when '1',
   --     "ZZZZZZZZZZZZZZZZ" when others;
	
--	 in_en <= CS AND IO_WRITE;
--	 with in_en select input_data <=
--			IO_DATA			when '1',
--			"0000000000001010" when others;
--			
	-- every time SCOMP writes the threshold, change the threshold value
--	process (CS,IO_WRITE) begin
--		if (CS = '1' AND IO_WRITE = '1') then
--			threshold <= conv_integer(signed(input_data));
--			threshold <= 1000*threshold;
--		end if;
--	end process;
	
    -- This template device just copies the input data
    -- to IO_DATA by latching the data every time a new
    -- value is ready.
	 
	process (RESETN, SYS_CLK)
	begin
		if (RESETN = '0') then -- on reset
			numClaps <= x"0000"; -- reset the output data
				
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
				
--			WHEN Analysis =>
--					IF(clapLength > clapLengthLimit) THEN
--						state <= ThresholdTest;
--					ELSE
--						state <= ClapState;
--					END IF;
--				
--				WHEN ClapState => 
--					temp2 <= conv_integer(numClaps) + 1;
--					numClaps <= conv_std_logic_vector(temp2, numClaps'length);
--					state <= ThresholdTest; 
					
			END CASE;
		end if;
    end process;

end a;
