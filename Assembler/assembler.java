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
			File outputFile = new File("output.txt");
			FileWriter fileWriter = new FileWriter(outputFile);
			BufferedWriter writeBuffer = new BufferedWriter(fileWriter);

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
					writeBuffer.write(operation + " ");
					
					switch(operation){
					case "add":
						int d = getIntFromRegister(li.next().toString(), false);
						int s = getIntFromRegister(li.next().toString(), false);
						int t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "sub":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
					
					case "addi":
						t = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						int i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + s + " " + i);
						break;
						
					case "mult":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);
						writeBuffer.write(s + " " + t);
						break;
						
					case "div":
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						writeBuffer.write(s + " " + t);
						break;
						
					case "slt":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "slti":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + s + " " + i);
						break;
						
					case "and":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "or":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "nor":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);	
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "xor":
						d = getIntFromRegister(li.next().toString(), false);
						s = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), true);
						writeBuffer.write(d + " " + s + " " + t);
						break;
						
					case "andi":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + s + " " + i);
						break;
						
					case "ori":
						t = getIntFromRegister(li.next().toString(), false);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + s + " " + i);
						break;
						
					case "xori":
						t = getIntFromRegister(li.next().toString(), true);	
						s = getIntFromRegister(li.next().toString(), false);
						i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + s + " " + i);
						break;
						
					case "mfhi":
						d = getIntFromRegister(li.next().toString(), true);
						writeBuffer.write(d);
						break;
						
					case "mflo":
						d = getIntFromRegister(li.next().toString(),true);
						writeBuffer.write(String.valueOf(d));
						break;
						
					case "lui":
						t = getIntFromRegister(li.next().toString(), true);
						i = Integer.parseInt(li.next().toString());
						writeBuffer.write(t + " " + i);
						break;
						
					case "sll":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						int h = Integer.parseInt(li.next().toString());
						writeBuffer.write(d + " " + t + " " + h);
						break;
						
					case "slr":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						h = Integer.parseInt(li.next().toString());
						writeBuffer.write(d + " " + t + " " + h);
						break;
						
					case "sra":
						d = getIntFromRegister(li.next().toString(), false);
						t = getIntFromRegister(li.next().toString(), false);
						h = Integer.parseInt(li.next().toString());
						writeBuffer.write(d + " " + t + " " + h);
						break;
						
					//Memory instructions will have to calculate offsets
					case "lw":
						break;
						
					case "lb":
						break;
						
					case "sw":
						break;
						
					case "sb":
						break;
						
					//Branch instructions need to find label line and calculate offset
					case "beq":
						break;
						
					case "bne":
						break;
						
					case "j":
						break;
						
					case "jr":
						break;
						
					case "jal":
						break;		
						
					//If none of these cases are met the instruction is invalid	
					default:
						System.out.println("Instruction " + operation + " not recognized");
						break;
					}	
					
					//writes list to output file
/*					while(li.hasNext()){
						writeBuffer.write(li.next().toString());
						writeBuffer.write(" ");
					}*/
					writeBuffer.newLine();
				}
			}				
			
			//Closes readers/writers and frees resources 
			writeBuffer.close(); 
			fileWriter.close();
			fileReader.close();
			readBuffer.close();
			
			//The below instructions simply open the written output file after execution
			Desktop dt = Desktop.getDesktop();
			dt.open(outputFile);
		}
		catch (Exception e) {
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
		if(s.contains("\t")){
			int tabIndex = s.indexOf("\t");
			s=s.substring(0, tabIndex);	
		}
		System.out.println(s);
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
}

