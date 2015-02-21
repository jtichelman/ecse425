import java.io.*;
import java.util.*;
import java.awt.Desktop;

public class assembler{
	public static void main(String[] args){
		String filename = args[0];										//gets file name from arguments to main
		String line;													//allows line by line reading
		Integer lineCounter=0;											//counts lines when reading file
		
		Map<String, Integer> labels = new HashMap<String, Integer>();
		
		try {
			FileReader fileReader = new FileReader(filename);			//create new FileReader (Opens the file)
			//Conventional to wrap FileReader in BufferedReader for line by line access
			BufferedReader readBuffer = new BufferedReader(fileReader);
			
			//Similarly create FileWriter and writeBuffer
			File binaryOutputFile = new File("outputB.txt");
			FileWriter fileWriter = new FileWriter(binaryOutputFile);
			BufferedWriter writeBuffer = new BufferedWriter(fileWriter);

			//for debugging purposes will also write a human readable output file
			File outputFile = new File("output.txt");
			FileWriter fw = new FileWriter(outputFile);
			BufferedWriter wb = new BufferedWriter(fw);

			//Have to mark bufferedReader to reset later
			//argument is readAhead limit, set to sufficiently large value
			readBuffer.mark(50000);							
			
			// The first pass just finds and stores the labels and line # for branch offset calculations
			while((line = readBuffer.readLine()) != null){				//parse the lines of the input file
				if(!isEmpty(line)){									//checks if line is not empty
					lineCounter++;
		
					//The below code block checks if there is a label on the line and stores it in labels map
					if(!(line.startsWith(" ") || line.startsWith("\t"))){
						String str;										//will store label
						int colonIndex =line.indexOf(":");
						str = line.substring(0,colonIndex);
						labels.put(str, lineCounter);					//store label and line number in labels map
					}
				}
			}
			
			//Reset readBuffer and lineCounter for second pass
			readBuffer.reset();
			lineCounter = 0;
			
			// The second pass decodes and encodes instructions line by line
			while((line = readBuffer.readLine()) != null) {
				if(!isEmpty(line)){
					lineCounter++;
					//gets instructions in ArrayList format
					ArrayList<String> instruction = delimitInstruction(line);
					//for parsing list
					ListIterator li = instruction.listIterator();
					
					//TODO: Based on the instruction entered calculate the appropriate arguments
					
					//Gets first item in list (the operation)
					String operation = li.next().toString();
					wb.write(operation + " ");
					
					//Calculates arguments and encodes depending on operation
					switch(operation){
					case "add":
						int d = getIntFromRegister(li.next().toString(), false);
						int s = getIntFromRegister(li.next().toString(), false);
						int t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("000000" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "sub":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("000001" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
					
					case "addi":
						t = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						int i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + s + " " + i);
						writeBuffer.write("000010" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "mult":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);
						wb.write(s + " " + t);
						writeBuffer.write("000011" + toBinary(s,5) + toBinary(t,5) + "0000000000000000");
						break;
						
					case "div":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						wb.write(s + " " + t);
						writeBuffer.write("000100" + toBinary(s,5) + toBinary(t,5) + "0000000000000000");
						break;
						
					case "slt":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("000101" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "slti":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + s + " " + i);
						writeBuffer.write("000110" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "and":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("000111" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "or":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("001000" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "nor":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("001001" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "xor":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);
						wb.write(d + " " + s + " " + t);
						writeBuffer.write("001010" + toBinary(s,5) + toBinary(t,5) + toBinary(d, 5) + "00000000000");
						break;
						
					case "andi":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + s + " " + i);
						writeBuffer.write("001011" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "ori":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + s + " " + i);
						writeBuffer.write("001100" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "xori":
						t = getIntFromRegister(li.next().toString(), true);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + s + " " + i);
						writeBuffer.write("001101" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "mfhi":
						d = getIntFromRegister(li.next().toString(), true);
						wb.write(d);
						writeBuffer.write("0011100000000000" + toBinary(d,5) + "00000000000");
						break;
						
					case "mflo":
						d = getIntFromRegister(li.next().toString(),true);
						wb.write(String.valueOf(d));
						writeBuffer.write("0011110000000000" + toBinary(d,5) + "00000000000");
						break;
						
					case "lui":
						t = getIntFromRegister(li.next().toString(), true);
						i = Integer.parseInt(li.next().toString());
						wb.write(t + " " + i);
						writeBuffer.write("01000000000" + toBinary(t, 5) + toBinary(i, 16));
						break;
						
					case "sll":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						int h = Integer.parseInt(li.next().toString());
						wb.write(d + " " + t + " " + h);
						writeBuffer.write("010001" + toBinary(d,5) + toBinary(t,5) + toBinary(h,5) + "00000000000");
						break;
						
					case "slr":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						h = Integer.parseInt(li.next().toString());
						wb.write(d + " " + t + " " + h);
						writeBuffer.write("010010" + toBinary(d,5) + toBinary(t,5) + toBinary(h,5) + "00000000000");
						break;
						
					case "sra":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						h = Integer.parseInt(li.next().toString());
						wb.write(d + " " + t + " " + h);
						writeBuffer.write("010011" + toBinary(d,5) + toBinary(t,5) + toBinary(h,5) + "00000000000");
						break;
						
					case "lw":
						t = getIntFromRegister(li.next().toString(), false);
						String str= li.next().toString();
						i = getOffset(str);
						d = getAddressRegister(str);
						wb.write(t + " " + i + " " + d);
						writeBuffer.write("010100" + toBinary(d,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "lb":
						t = getIntFromRegister(li.next().toString(), false);
						str= li.next().toString();
						i = getOffset(str);
						d = getAddressRegister(str);
						wb.write(t + " " + i + " " + d);
						writeBuffer.write("010101" + toBinary(d,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "sw":
						t = getIntFromRegister(li.next().toString(), false);
						str= li.next().toString();
						i = getOffset(str);
						d = getAddressRegister(str);
						wb.write(t + " " + i + " " + d);
						writeBuffer.write("010110" + toBinary(d,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "sb":
						t = getIntFromRegister(li.next().toString(), false);
						str= li.next().toString();
						i = getOffset(str);
						d = getAddressRegister(str);
						wb.write(t + " " + i + " " + d);
						writeBuffer.write("010111" + toBinary(d,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					//Branch instructions need to find label line and calculate offset
					case "beq":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						String label = li.next().toString();
						int labelIndex = labels.get(label);
						i = labelIndex - lineCounter;
						wb.write(s + " " + t + " " + i + " (" + label + ", " + labelIndex + ")");
						writeBuffer.write("011000" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "bne":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						label = li.next().toString();
						labelIndex = labels.get(label);
						i = labelIndex - lineCounter;
						wb.write(s + " " + t + " " + i + " (" + label + ", " + labelIndex + ")");
						writeBuffer.write("011001" + toBinary(s,5) + toBinary(t,5) + toBinary(i,16));
						break;
						
					case "j":
						label = li.next().toString();
						labelIndex = labels.get(label);
						i = labelIndex - lineCounter;
						wb.write(i);
						writeBuffer.write("011010" + toBinary(i,26));
						break;
						
					case "jr":
						s = getIntFromRegister(li.next().toString(), false);	
						wb.write(s);
						writeBuffer.write("011011" + toBinary(s, 5) + "000000000000000000000");
						break;
						
					case "jal":
						label = li.next().toString();
						labelIndex = labels.get(label);
						i = labelIndex - lineCounter;
						wb.write(i);
						writeBuffer.write("011100" + toBinary(i,26));
						break;		
						
					//If none of these cases are met the instruction is invalid	
					default:
						System.out.println("Instruction " + operation + " not recognized");
						break;
					}	
					wb.newLine();
					writeBuffer.newLine();
				}
			}				
			
			//Closes readers/writers and frees resources 
			writeBuffer.close(); 
			fileWriter.close();
			wb.close();
			fw.close();
			fileReader.close();
			readBuffer.close();
			
			//The below instructions simply open the written output file after execution
			Desktop dt = Desktop.getDesktop();
			dt.open(outputFile);
		}
		catch (Exception e) {
			//Gives line # of instruction where error occured if it occurs while parsing
			if(lineCounter !=0)
				System.out.println("Error interpretring instruction number " + lineCounter);
			e.printStackTrace();
		}
	}
	
	// Line is empty if there's no characters on it or if it begins with '#'
	public static boolean isEmpty(String str){
		while(str.startsWith(" ") || str.startsWith("\t")){					//get rid of empty space at beginning of string
			str = str.substring(1);
		}
		if(str.isEmpty())													//if string is empty then line is empty
			return true;
		if(str.startsWith("#"))											//if string begins with #, line is a commment and should be ignored
			return true;
		return false;
	}
	
	// Returns array list of instructions
	public static ArrayList<String> delimitInstruction(String s){
		ArrayList<String> instruction = new ArrayList<String>();		//Creates list
		
		if(s.contains(":")){
			int colonIndex = s.indexOf(":");
			s = s.substring(colonIndex+1);
		}
		while(s.startsWith(" ") || s.startsWith("\t")){					//get rid of empty space at beginning of string
			s = s.substring(1);
		}
		
		//Try to remove tabs, seems to be a bug with Stirng.replace that won't allow you to replace "\t"
		//for now I just remove everything after the tab
		if(s.contains("\t")){
			int tabIndex = s.indexOf("\t");
			s=s.substring(0, tabIndex);	
		}
		try{															//delimit string by spaces
			String[] str = s.split(" ");
			for(int i =0; i<str.length; i++){
				if(!str[i].isEmpty()){
					if(str[i].startsWith("#")){break;}					//stop adding to arrayList if we reach a comment
					instruction.add(str[i]);							//adds split strings to arrayList if they are not empty  or comments
				}	
			}	
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return instruction;											//return list
	}
	
	//Returns integer r from String "$r," (false) or "$r" (true)
	public static int getIntFromRegister(String s, boolean isLast){
		if(isLast){
			int dollarIndex = s.indexOf("$");
			s = s.substring(dollarIndex+1);
			return Integer.parseInt(s);
		}
		else {
			int dollarIndex = s.indexOf("$");
			int commaIndex = s.indexOf(",");
			s = s.substring(dollarIndex+1, commaIndex);
			return Integer.parseInt(s);
		}
	}
	
	//Returns offset O from String "O($r)"
	public static int getOffset(String s){
		int bracketIndex = s.indexOf("(");
		s = s.substring(0, bracketIndex);
		return Integer.parseInt(s);
	}
	
	//Returns register r from String "O($r)"
	public static int getAddressRegister(String s){
		int openBracketIndex = s.indexOf("(");
		int closeBracketIndex = s.indexOf(")");
		s = s.substring(openBracketIndex+1, closeBracketIndex);
		return getIntFromRegister(s, true);
	}
	
	public static String toBinary(int n, int numBits){
		String str = Integer.toBinaryString(n);
		if(str.length()>numBits){
			System.out.println("Can't represent " + n + " in " + numBits + " bits, truncating...");
			str =  str.substring(0, numBits);
		}
		if(str.length()<numBits){
			int padBits = numBits - str.length();
			StringBuffer sb = new StringBuffer();
			for(int i=0; i<padBits; i++){
				sb.append("0");
			}
			sb.append(str);
			str = sb.toString();
		}
		return str;	
	}
}

