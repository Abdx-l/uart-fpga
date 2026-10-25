library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity uart is
 generic(CLOCK_HZ:positive:=50000000;BAUD:positive:=115200);
 port(clk,rst:in std_logic;tx_valid:in std_logic;tx_data:in std_logic_vector(7 downto 0);tx_ready:out std_logic;tx:out std_logic;rx:in std_logic;rx_valid:out std_logic;rx_data:out std_logic_vector(7 downto 0);framing_error:out std_logic);
end;
architecture rtl of uart is
 signal phase:natural range 0 to CLOCK_HZ-1:=0;signal tick:std_logic:='0';
 signal tx_frame:std_logic_vector(9 downto 0):=(others=>'1');signal tx_bit:natural range 0 to 9:=0;signal tx_count:natural range 0 to 15:=0;signal busy:std_logic:='0';
 signal sync1,sync2:std_logic:='1';signal state:natural range 0 to 3:=0;signal count:natural range 0 to 15:=0;signal bit_index:natural range 0 to 7:=0;signal received:std_logic_vector(7 downto 0):=(others=>'0');
begin
 assert BAUD*16<CLOCK_HZ report "clock too slow for 16x oversampling" severity failure;
 tx_ready<=not busy;tx<=tx_frame(tx_bit) when busy='1' else '1';
 process(clk) begin if rising_edge(clk) then
  if rst='1' then phase<=0;tick<='0';sync1<='1';sync2<='1';
  else
   sync1<=rx;sync2<=sync1;
   if phase>=CLOCK_HZ-BAUD*16 then phase<=phase+BAUD*16-CLOCK_HZ;tick<='1';else phase<=phase+BAUD*16;tick<='0';end if;
  end if;
 end if;end process;
 process(clk) begin if rising_edge(clk) then
  if rst='1' then busy<='0';tx_bit<=0;tx_count<=0;tx_frame<=(others=>'1');
  else
   if busy='0' and tx_valid='1' then tx_frame<='1'&tx_data&'0';busy<='1';tx_bit<=0;tx_count<=0;
   elsif busy='1' and tick='1' then
    if tx_count=15 then tx_count<=0;if tx_bit=9 then busy<='0';else tx_bit<=tx_bit+1;end if;
    else tx_count<=tx_count+1;end if;
   end if;
  end if;
 end if;end process;
 process(clk) begin if rising_edge(clk) then
  rx_valid<='0';framing_error<='0';
  if rst='1' then state<=0;count<=0;bit_index<=0;rx_data<=(others=>'0');
  elsif tick='1' then
   case state is
    when 0=>if sync2='0' then state<=1;count<=0;end if;
    when 1=>if count=7 then if sync2='0' then state<=2;count<=0;bit_index<=0;else state<=0;end if;else count<=count+1;end if;
    when 2=>if count=15 then received(bit_index)<=sync2;count<=0;if bit_index=7 then state<=3;else bit_index<=bit_index+1;end if;else count<=count+1;end if;
    when others=>if count=15 then if sync2='1' then rx_data<=received;rx_valid<='1';else framing_error<='1';end if;state<=0;count<=0;else count<=count+1;end if;
   end case;
  end if;
 end if;end process;
end;
