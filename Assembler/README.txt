To run this assembler, you need build 1.7 of the Java SE Runtime Environment. After, place the assembly program
in the same directory as the compiled assembler.class file and open the terminal there. Then run the command
"java assembler <assemblyprogram>" where <assemblyprogram> is the name of your assembly program, including the file 
extension. The program will then write the assembly program it interprets to the output.txt file in human readable format,
and to the Init.data file in binary encoded ASCII. This can then be loaded to the processor.