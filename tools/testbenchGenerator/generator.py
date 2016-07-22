import string


###########################
##### TEMPLATE CLASS ######
###########################
class MyTemplate(string.Template):
    delimiter = "%%"
		
packStart=(	"\n"	
		"Iend <= '0';\n"
        "Ivalid <= '0';\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "clk <= '1'; wait for 5 ns;\n"
        "clk <= '0'; wait for 5 ns;\n"
        "Ivalid <= '1';\n"
		"Istart <= '1';\n"
		"\n"	
		"Idata <= x\"00000000\";\n"
		"clk <= '1'; wait for 5 ns;\n"
		"clk <= '0'; wait for 5 ns;\n"
		"Istart <= '0';\n"
		"Idata <= x\"00000000\";\n"
		"clk <= '1'; wait for 5 ns;\n"
		"clk <= '0'; wait for 5 ns;\n"
		"Idata <= x\"00000000\";\n"
		"clk <= '1'; wait for 5 ns;\n"
		"clk <= '0'; wait for 5 ns;\n"
		"Idata <= x\"000088b5\";\n"
		"clk <= '1'; wait for 5 ns;\n"
		"clk <= '0'; wait for 5 ns;\n\n")

afterLine = ( "clk <= '1'; wait for 5 ns;\n"
              "clk <= '0'; wait for 5 ns;\n")

endString= ("\n" 
	    "Iend <= '0';\n")

filename= "ethtst_normal.txt"

num = 200
read = 0
data=""

with open(filename,"r") as fin:
    while read < num:

        data += packStart
        for i in range(0,16):
            str8 = fin.read(8)
            line = "Idata <= x\"{0}\";\n".format(str8);
            data += line
            if(i==15):
                data += "Iend <= '1';\n"
            data += afterLine
        read=read+1

        data+="---------------------------------\n"

data +="\n\n" + endString


filename ="testbench.template"
data_template=""
params = {"DATA":data}
with open (filename, "r") as template_file:
    data_template=template_file.read()

filename ="testbench_old.vhd"
with open (filename, "w") as output_file:
    s = MyTemplate(data_template)
    output_file.write(s.substitute(params))
