import java.io.*;

public class assembler{
	public static void main(String[] args){
		String filename = args[0];										//gets file name from arguments to main
		String line;													//allows line by line reading
		int lineCounter=0;												//counts lines when reading file
		
		try {
			FileReader fileReader = new FileReader(filename);			//create new FileReader (Opens the file)
			
			/* Conventional to wrap FileReader in BufferedReader for line by line access */
			
			BufferedReader labelFinder = new BufferedReader(fileReader); //will use this buffer to find labels
			BufferedReader decoder = new BufferedReader(fileReader);	//another buffer for the second pass
			
			while((line = labelFinder.readLine()) != null){				//parse the lines of the input file
				if(line.length() > 0){									//checks if line is not empty
					lineCounter++;
		
					/* The below code block checks if there is a char in the first position on the line and gets the label if there is one */	
					if(line.substring(0, 1)!=" "){
						String str;										//will store label
						int colonIndex =line.indexOf(":");
						str = line.substring(0,colonIndex+1);
					}
				}
			}
			
			/* Closes readers and frees resources */
			fileReader.close();
			labelFinder.close();
			decoder.close();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
}