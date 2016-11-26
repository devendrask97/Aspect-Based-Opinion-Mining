package core;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class AspectsGenerator {

	// private ArrayList<String> finalAspectList; // only the name as String
	private ArrayList<Aspect> finalAspects; // actual objects of Aspect
	private ArrayList<String> suggestedAspects;// suggestions to the user
	private File fileFinalAspectsList;

	public AspectsGenerator(ArrayList<String> nouns, int frequencyParameter) throws IOException {
		// finalAspectList = new ArrayList<String>();
		finalAspects = new ArrayList<Aspect>();
		suggestedAspects = new ArrayList<String>();
		fileFinalAspectsList = new File("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\FinalizedAspects");
		fileFinalAspectsList.createNewFile();
		
		Map<String, Integer> wordCount = new HashMap<String, Integer>();

		for (String noun : nouns) {
			Integer count = wordCount.get(noun);
			wordCount.put(noun, (count == null) ? 1 : count + 1);
		}

		for (Map.Entry<String, Integer> entry : wordCount.entrySet()) {
			if (entry.getValue() >= frequencyParameter) {
				suggestedAspects.add(entry.getKey());
			}
		}
		System.gc();

		// creating a file --- IN CASE NEEDED
		File suggestedAspectsFile = new File("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\suggestedAspects");
		suggestedAspectsFile.createNewFile();
		BufferedWriter bw = new BufferedWriter(new FileWriter(suggestedAspectsFile.getAbsoluteFile()));
		for (String aspect : suggestedAspects) {
			bw.write(aspect);
			bw.write("\n");
			bw.flush();
		}
		bw.close();

	}

	public ArrayList<String> getSuggestedAspects() {
		return (ArrayList<String>) suggestedAspects.clone();
	}

	public void finalizeAspects(ArrayList<String> finalAspectsName) throws IOException {
		/*
		 * Entered aspects<String> will be finalized -->actual "Aspect" object
		 * will be created for each object....A file will also be created to
		 * keep a backup.
		 */
		BufferedWriter bw = new BufferedWriter(new FileWriter(fileFinalAspectsList.getAbsoluteFile()));
		
		for (String aspect : finalAspectsName) {

			bw.write(aspect);
			bw.write("\n");
			bw.flush();

			// Create ArrayList of "Aspect" objects for finalized aspects
			this.finalAspects.add(new Aspect(aspect));

		}
		bw.close();

	}

	public ArrayList<Aspect> getAspects() {
		return (ArrayList<Aspect>) finalAspects.clone();
	}

}
