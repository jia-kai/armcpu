-- modified from flashandram
-- $File: flash_driver.vhd
-- $Date: Sun Oct 27 17:44:11 2013 +0800

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flash_driver_impl is
	Port ( addr : in  STD_LOGIC_VECTOR (22 downto 0);
		   data_in : in  STD_LOGIC_VECTOR (15 downto 0);
		   data_out : out  STD_LOGIC_VECTOR (15 downto 0);
		   clk : in std_logic;--随便什么时钟
		   reset : in std_logic;

		   flash_byte : out std_logic;--BYTE#
		   flash_vpen : out std_logic;
		   flash_ce : out std_logic;
		   flash_oe : out std_logic;
		   flash_we : out std_logic;
		   flash_rp : out std_logic;
			  --flash_sts : in std_logic;
		   flash_addr : out std_logic_vector(22 downto 0);
		   flash_data : inout std_logic_vector(15 downto 0);

		   enable_read : in  STD_LOGIC;
		   enable_write : in  STD_LOGIC;
		   enable_erase : in STD_LOGIC;

		   busy : out STD_LOGIC
	   );
end flash_driver_impl;

architecture Behavioral of flash_driver_impl is
	type flash_state is (
		waiting,
		write1, write2, write3, write4, write5, write6, write7, write8,
		read1, read2, read3, read4,
		sr1, sr2, sr3, sr4, sr5,
		erase1, erase2, erase3, erase4, erase5, erase6,
		done
	);
	signal state : flash_state := waiting;
	signal next_state : flash_state := waiting;
	
begin

	flash_byte <= '1';
	flash_vpen <= '1';
	flash_ce <= '0';
	flash_rp <= '1';

	process (state) begin
		case state is
			when waiting =>
				busy <= '0';
			when others =>
				busy <= '1';
		end case;
	end process;
	
	process (clk, reset)
	begin
		if (reset = '0') then
			flash_oe <= '1';
			flash_we <= '1';
			state <= waiting;
			next_state <= waiting;
			flash_data <= (others => 'Z');
			--data_out <= (others => 'Z');
			--flash_addr <= (others => '0');--not nessary
		elsif (clk'event and clk = '1') then
			case state is
				when waiting =>
					if (enable_read /= '0') then
						flash_we <= '0';
						state <= read1;
					elsif (enable_write /= '0') then
						flash_we <= '0';
						state <= write1;
					elsif (enable_erase /= '0') then
						flash_we <= '0';
						data_out(0) <= '0';
						state <= erase1;
					else
					end if;
				when write1 =>
					flash_data <= x"0040";
					--flash_addr <= addr;
					state <= write2;
				when write2 =>
					flash_we <= '1';
					state <= write3;
				when write3 =>
					flash_we <= '0';
					state <= write4;
				when write4 =>
					flash_addr <= addr;
					flash_data <= data_in;
					state <= write5;
				when write5 =>
					flash_we <= '1';
					state <= sr1;
					--next_state <= write6;
					next_state <= done;
				when sr1 =>
					flash_we <= '0';
					flash_data <= x"0070";
					state <= sr2;
				when sr2 =>
					flash_we <= '1';
					state <= sr3;
				when sr3 =>
					flash_data <= (others => 'Z');
					state <= sr4;
				when sr4 =>
					flash_oe <= '0';
					state <= sr5;
				when sr5 =>
					flash_oe <= '1';
					if (flash_data(7) = '0') then
						state <= sr1;
					else
						state <= next_state;
					end if;
				when write6 =>
					flash_we <= '0';
					state <= write7;
				when write7 =>
					flash_data <= x"00FF";
					state <= write8;
				when write8 =>
					flash_we <= '1';
					state <= done;
					
				when read1 =>
					flash_data <= x"00FF";
					state <= read2;
				when read2 =>
					flash_we <= '1';
					state <= read3;
				when read3 =>
					flash_oe <= '0';
					flash_addr <= addr;
					flash_data <= (others => 'Z');
					state <= read4;
				when read4 =>
					data_out <= flash_data;
					state <= done;
					
					
				when erase1 =>
					flash_data <= x"0020";
					state <= erase2;
				when erase2 =>
					flash_we <= '1';
					state <= erase3;
				when erase3 =>
					flash_we <= '0';
					state <= erase4;
				when erase4 =>
					flash_data <= x"00D0";
					flash_addr <= addr;
					state <= erase5;
				when erase5 =>
					flash_we <= '1';
					next_state <= erase6;
					state <= sr1;
				when erase6 =>
					state <= done;
					data_out(0) <= '1';
					
				when others =>
					flash_oe <= '1';
					flash_we <= '1';
					flash_data <= (others => 'Z');
					state <= waiting;
			end case;
		end if;
	end process;
	

end Behavioral;


