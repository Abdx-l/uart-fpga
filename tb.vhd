library ieee;use ieee.std_logic_1164.all;use ieee.numeric_std.all;use std.env.all;
entity tb is end;
architecture test of tb is
 signal clk:std_logic:='0';signal rst:std_logic:='1';signal valid:std_logic:='0';signal data,received:std_logic_vector(7 downto 0):=(others=>'0');signal ready,tx,rx,got,framing:std_logic;signal inject:std_logic:='0';
begin
 clk<=not clk after 10 ns;rx<=tx when inject='0' else '0';
 dut:entity work.uart generic map(CLOCK_HZ=>50000000,BAUD=>115200) port map(clk,rst,valid,data,ready,tx,rx,got,received,framing);
 process begin
  wait for 100 ns;wait until falling_edge(clk);rst<='0';
  for i in 0 to 255 loop
   wait until falling_edge(clk);while ready/='1' loop wait until falling_edge(clk);end loop;
   data<=std_logic_vector(to_unsigned(i,8));valid<='1';wait until falling_edge(clk);valid<='0';
   wait until got='1';assert received=std_logic_vector(to_unsigned(i,8)) report "loopback mismatch" severity failure;
  end loop;
  while ready/='1' loop wait until falling_edge(clk);end loop;
  inject<='1';wait until framing='1';inject<='0';report "PASS all 256 bytes and framing error";stop;wait;
 end process;
 process begin wait for 30 ms;assert false report "timeout" severity failure;end process;
end;
