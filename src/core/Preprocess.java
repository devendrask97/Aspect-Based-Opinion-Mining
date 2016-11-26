package core;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.Sentence;
import edu.stanford.nlp.process.DocumentPreprocessor;
import weka.core.Stopwords;

public class Preprocess {
	File preprocessedFile;
	File finalPreprocessedFile;

	public Preprocess(String inputFile, String outputFile) throws IOException {
		preprocessedFile = new File(outputFile);
		preprocessedFile.createNewFile();

		BufferedWriter bw = new BufferedWriter(new FileWriter(
				preprocessedFile.getAbsoluteFile()));
		DocumentPreprocessor dp = new DocumentPreprocessor(inputFile);

		for (List<HasWord> sentence : dp) {
			String s = Sentence.listToString(sentence);
			//System.out.println(s);
			//NOTE
			s = s.replaceAll("[^a-zA-Z ]", "");
			s = s.trim(); // trailing and starting spaces
			s = s.replaceAll("\\s+", " "); // merging spaces 
			//s.replaceAll("\\P{L}", "");
			//System.out.println(s);
			bw.append(s);
			bw.append("\n");
			bw.flush();
		}
		bw.close();

		/*
		 * for (List<HasWord> sentence : dp) { bw.write(sentence.toString());
		 * 
		 * 
		 * String print = removeStopWords(sentence); if (!print.equals("")) { //
		 * if it returns an empty string --> a new line will be added //
		 * BUG...parser will give null pointer exception bw.write(print);
		 * bw.write("\n"); bw.flush(); } }
		 */
		bw.close();

	}

	private String removeStopWords(List<HasWord> text) {
		
		//Stop word removal changes the dependencies and hence limiting the performance
		StringBuilder build = new StringBuilder();
		String result = null;
		Stopwords stopWordChecker = new Stopwords(); // WEKA - RAINBOW
		// negation should not be a stop word .........!!!!!!
		stopWordChecker.remove("not");
		stopWordChecker.remove("no");
		for (HasWord word : text) {
			if (!stopWordChecker.is(word.word().toLowerCase())) {
				// if "word" is not a stop word then
				build.append(word.word().toLowerCase());
				build.append(" ");
				// First remove the stop words then the punctuation
				result = build.toString();
				result = result.replaceAll("[^a-zA-Z ]", "");
			}
		}
		// NOTE : THE FIRT LETTER SHOULD NOT BE SPACE OR THE PARSER WILL THROW
		// NULL POINTER EXCEPTION
		result = result.trim();
		return result;

	}

	public void finalPreprocess(String inputFile, String outputFile,
			ArrayList<Aspect> aspects) throws IOException {
		finalPreprocessedFile = new File(outputFile);
		finalPreprocessedFile.createNewFile();

		File source = new File(inputFile);

		BufferedWriter bw = new BufferedWriter(new FileWriter(
				finalPreprocessedFile.getAbsoluteFile()));
		BufferedReader br = new BufferedReader(new FileReader(
				source.getAbsoluteFile()));

		String line;
		// BUG -- REPEATING LINE
		/*
		 * LINE - The visuals were jaw dropping , acting was superb , and the
		 * story was filled with originality and hand full of surprises along
		 * the way . LINE - The visuals were jaw dropping , acting was superb ,
		 * and the story was filled with originality and hand full of surprises
		 * along the way . LINE - The visuals were jaw dropping , acting was
		 * superb , and the story was filled with originality and hand full of
		 * surprises along the way .
		 */
		while ((line = br.readLine()) != null) {
			for (Aspect aspect : aspects) {
				if (checkAspect(line, aspect)) {
					bw.write(line);
					bw.write("\n");
					bw.flush();
					break; // THIS SHOULD SOVE THE BUG
				}
			}

		}

		bw.close();
		br.close();
	}

	public boolean checkAspect(String sentence, Aspect aspect) {
		return sentence.contains(aspect.getAspectName());
	}

}
