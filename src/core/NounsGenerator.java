package core;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import edu.stanford.nlp.parser.lexparser.LexicalizedParser;
import edu.stanford.nlp.trees.Tree;

public class NounsGenerator {
	private ArrayList<String> nouns;
	private File preprocessedFile;
	private File parsedFile;
	private File nounsFile;

	public NounsGenerator(String preprocessedFile) {
		this.preprocessedFile = new File(preprocessedFile);
		nouns = new ArrayList<String>();
		
	}

	public void generateAspects() throws IOException {
		String grammar = "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz";
		String[] options = { "-maxLength", "80", "-retainTmpSubcategories" };
		LexicalizedParser lp = LexicalizedParser.loadModel(grammar, options);

		nounsFile = new File("nounsFile");
		nounsFile.createNewFile();

		// create a new file to save the parsed File
		parsedFile = new File("parsedFile");
		if (!parsedFile.exists()) {
			parsedFile.createNewFile();
			BufferedWriter bw = new BufferedWriter(new FileWriter(parsedFile.getAbsoluteFile()));

			// for reading the pre-processed file
			BufferedReader br = new BufferedReader(new FileReader(preprocessedFile.getAbsoluteFile()));

			// Read from the pre-processed file line-to-line and parse
			String line;
			while ((line = br.readLine()) != null) {
				Tree parsed = lp.parse(line);

				List<Tree> leaves = parsed.getLeaves();
				// Print words and POS Tags
				for (Tree leaf : leaves) {
					Tree parent = leaf.parent(parsed);

					// Generate nouns
					if (parent.label().value().equals("NN") || parent.label().value().equals("NNS")
							|| parent.label().value().equals("NNP") || parent.label().value().equals("NNPS")) {
						nouns.add(leaf.label().value().toLowerCase());
					}

					System.out.print(leaf.label().value() + "-" + parent.label().value() + " ");
					bw.write(leaf.label().value() + "-" + parent.label().value() + " ");
				}
				bw.write("\n");
				bw.flush();
				System.out.println();
				// Force a request call to the garbage collector
				System.gc();
			}
			bw.close();
			br.close();

			bw = new BufferedWriter(new FileWriter(nounsFile.getAbsoluteFile()));
			for (String noun : nouns) {
				bw.write(noun);
				bw.write("\n");
				bw.flush();
			}
		} else {
			// parsing has been done and nouns have been generated in the
			// nounsFile
			// no need for doing anything just populate the nouns list from
			// generated nounsFile
			BufferedReader br = new BufferedReader(new FileReader(nounsFile.getAbsoluteFile()));
			String line;
			while ((line = br.readLine()) != null) {
				nouns.add(line);
			}
		}
	}


	public ArrayList<String> getNounsListString() {
		return (ArrayList<String>) nouns.clone();
	}
}
