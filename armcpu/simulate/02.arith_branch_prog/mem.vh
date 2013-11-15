case (instrmem_addr)
32'h00000000: instrmem_data = 32'h00000000;
32'h00000004: instrmem_data = 32'h24840001;
32'h00000008: instrmem_data = 32'h24a50001;
32'h0000000c: instrmem_data = 32'h00853021;
32'h00000010: instrmem_data = 32'h00a02021;
32'h00000014: instrmem_data = 32'h08000003;
32'h00000018: instrmem_data = 32'h00c02821;
default: instrmem_data = 0;
endcase
