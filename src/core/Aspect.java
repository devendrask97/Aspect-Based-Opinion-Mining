package core;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import edu.stanford.nlp.parser.lexparser.LexicalizedParser;
import edu.stanford.nlp.trees.GrammaticalStructure;
import edu.stanford.nlp.trees.GrammaticalStructureFactory;
import edu.stanford.nlp.trees.Tree;
import edu.stanford.nlp.trees.TreebankLanguagePack;
import edu.stanford.nlp.trees.TypedDependency;

public class Aspect implements Runnable {
	private String aspectName;
	private ArrayList<String> opinionWords;
	private double score;
	private double total;
	
	private static File reviewFile;
	BufferedReader br;

	private ScoreCalculator sc;
	private static String grammar = "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz";
	private static String[] options = { "-maxLength", "80", "-retainTmpSubcategories" };
	private static LexicalizedParser lp = LexicalizedParser.loadModel(grammar, options);

	private static TreebankLanguagePack tlp = lp.getOp().langpack();
	private static GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();

	public Aspect(String aspectName) throws IOException {
		this.aspectName = aspectName;

		opinionWords = new ArrayList<String>();
		score = 0.0;
		total = 0.0;
		sc = new ScoreCalculator("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\SentiWordNet_3.0.0_20130122.txt");
	}

	public String getAspectName() {
		return aspectName;
	}

	public void setAspectName(String aspectName) {
		this.aspectName = aspectName;
	}

	public void calculateScore() {
		double sum = 0.0;
		for (String word : opinionWords) {
			double tempScore = 0.0;
			if (word.equals(word.toUpperCase())) {
				// upper case negation present
				tempScore = (10 - sc.getScore(word.toLowerCase()));
				tempScore = Math.ceil(tempScore);
				System.out.println("WORD -- " + word + " " + tempScore);

			} else {
				tempScore = sc.getScore(word);
				tempScore = Math.ceil(tempScore);
				System.out.println("WORD -- " + word + " " + tempScore);

			}
			sum += tempScore;
		}
		total = sum;
		score = Math.ceil(sum / opinionWords.size());
	}

	public static void setReviewFile(String file) {
		reviewFile = new File(file);
	}

	public ArrayList<String> getOpinionWords() {
		return (ArrayList<String>) opinionWords.clone();
	}

	public void insert(String word) {
		opinionWords.add(word);
	}

	public double getScore() {
		return score;
	}
	
	public double getTotal() {
		return total;
	}

	public void setScore(double score) {
		this.score = score;
	}

	//@Override
	public void run() /*generateAspects()*/ {
		System.out.println("*********");
		String line;

		try {
			br = new BufferedReader(new FileReader(reviewFile.getAbsolutePath()));
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		try {
			while ((line = br.readLine()) != null) {
				if (checkAspect(line, aspectName)) {
					getAdjectives(line, aspectName);
					getVerb(line, aspectName);
					
				}

			}
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("####SCORE CALCULATED#####" + aspectName);
		calculateScore();
		//br.close(); this is causing problems
	}

	public boolean checkAspect(String sentence, String aspectName) {
		return sentence.contains(aspectName);
	}

	private boolean checkNegation(String word, Collection<TypedDependency> td) {
		String y;
		boolean flag = false;

		for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("neg") && t.gov().originalText().equals(word))
				flag = true;
			if (t.reln().getShortName().equals("conj_negcc") && t.dep().originalText().equals(word))
				flag = true;
			if (t.reln().getShortName().equals("pobj") && t.dep().originalText().equals(word)
					&& t.gov().originalText().equals("not"))
				flag = true;
		}

		return flag;
	}

	private void getVerb(String line, String aspect) {
		line = line.toLowerCase();
		String y = null;
		System.gc();
		Tree parse = lp.parse(line);
		
		GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);
		Collection<TypedDependency> td = gs.allTypedDependencies();

		// implement algorithm 1
		for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("root") && t.gov().originalText().equals("")) {
				y = t.dep().originalText();

				for (TypedDependency t1 : td) {
					if (t1.reln().getShortName().equals("nsubj") && t1.gov().originalText().equals(y)
							&& t1.dep().originalText().equals(aspect)) {
						System.out.println(aspect  + " #####1 - " + y);

					}
				}
			}
			// }

			// implement algorithm 2
			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("root") && t.gov().originalText().equals("")) {
				y = t.dep().originalText();
				for (TypedDependency t1 : td) {
					if ((t1.reln().getShortName().equals("dobj") && t1.gov().originalText().equals(y)
							&& t1.dep().originalText().equals(aspect))
							|| (t1.reln().getShortName().equals("pobj") && t1.gov().originalText().equals(y)
									&& t1.dep().originalText().equals(aspect))) {
						System.out.println(aspect  + " #####2 - " + y);
					}
				}
			}
			// }

			// implement algorithm 3
			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("root") && t.gov().originalText().equals("")) {
				y = t.dep().originalText();
				for (TypedDependency t1 : td) {
					if ((t1.reln().getShortName().equals("nsubj_pass") && t1.gov().originalText().equals(y)
							&& t1.dep().originalText().equals(aspect))
							|| (t1.reln().getShortName().equals("xsubj") && t1.gov().originalText().equals(y)
									&& t1.dep().originalText().equals(aspect))) {
						System.out.println(aspect  + " #####3 - " + y);
					}
				}
			}

		}
		if (y != null) {
			if (checkNegation(y, td)) {
				System.out.println("negation present in " + y);
				insertOpinionWord(aspect, y, true);
			} else {
				insertOpinionWord(aspect, y, false);
			}

			getAdverbs(aspect, line, y, td);
		}

	}

	private void getAdverbs(String aspect, String line, String verb, Collection<TypedDependency> td) {

		String y = null;
		System.gc();

		// implement algorithm 1
		for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("advmod") && t.gov().originalText().equals(verb)) {
				y = t.dep().originalText();
				System.out.println(aspect  + " %%%%%1 - " + y);
				insertOpinionWord(aspect, y, false);
			}

			if (t.reln().getShortName().equals("advcl") && t.gov().originalText().equals(verb)) {
				y = t.dep().originalText();
				System.out.println(aspect  + " %%%%%2 - " + y);
				insertOpinionWord(aspect, y, false);
			}

			if (t.reln().getShortName().equals("amod") && t.gov().originalText().equals(verb)) {
				y = t.dep().originalText();
				System.out.println(aspect  + " %%%%%3 - " + y);
				insertOpinionWord(aspect, y, false);
			}
		}
	}

	private void getAdjectives(String line, String aspect) throws IOException {
		line = line.toLowerCase();
		// We have to parse the line here again
		System.gc();
		Tree parse = lp.parse(line);
		GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);
		Collection<TypedDependency> td = gs.allTypedDependencies();

		/*
		 * for (TypedDependency t : td) { System.out.println(t); //
		 * ORDER-reln(gov, dep) System.out.println(); }
		 */

		// implement algorithm - 1
		String x = null, y = null, y1 = null;
		for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("cc") && t.dep().originalText().equals("but")) {
				y = t.gov().originalText();
				for (TypedDependency t1 : td) {
					if (t1.reln().getShortName().equals("nsubj") && t1.gov().originalText().equals(y)) {
						x = t1.dep().originalText();
						if (x.equals("it") || x.equals(aspect)) {
							System.out.println(aspect  + " ****1 - " + y);
							if (checkNegation(y, td)) {
								System.out.println("negation present in " + y);
								insertOpinionWord(aspect, y, true);
							} else {
								insertOpinionWord(aspect, y, false);
							}

							break;
						}
					}
				}
			}
			// }

			// implement algorithm - 2

			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("amod") || t.reln().getShortName().equals("rcmod")
					|| t.reln().getShortName().equals("advmod")) {
				if (t.gov().originalText().equals(aspect)) {
					y = t.dep().originalText().toString();
					System.out.println(aspect  + " ****2.1 - " + y);
					if (checkNegation(y, td)) {
						System.out.println("negation present in " + y);
						insertOpinionWord(aspect, y, true);
					} else {
						insertOpinionWord(aspect, y, false);
					}
					break;
					/*
					 * for (TypedDependency t1 : td) { if
					 * (t1.reln().getShortName().equals("conj_and") &&
					 * t1.gov().originalText().equals(y)) { // conj_and or conj
					 * y1 = t1.dep().originalText(); System.out.println(
					 * "****2.2 - " + y1); } }
					 */

				}
			}
			// }

			// implement algorithm - 3
			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("prep_like") && t.dep().originalText().equals(aspect)) {
				System.out.println(aspect  + " ****3 - " + "like");
				y = "like";
			}
			// }

			// implement algorithm - 4
			// for (TypedDependency t : td) {
			/*
			 * if (t.reln().getShortName().equals("prep_of") &&
			 * t.dep().originalText().equals(aspect.getAspectName())) { Aspect
			 * newAspect = new Aspect(t.gov().originalText());
			 * System.out.println("****4****"); getAdjectives(line, newAspect);
			 * System.out.println("***--***"); }
			 */
			// }

			// implement algorithm - 5
			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("root") && t.gov().originalText().equals("")) {
				// "" --> empty for root element, i.e, ROOT
				y = t.dep().originalText();
				for (TypedDependency t1 : td) {
					if (t1.reln().getShortName().equals("nsubj") && t1.gov().originalText().equals(y)
							&& t1.dep().originalText().equals(aspect)) {
						for (TypedDependency t2 : td) {
							if (t2.reln().getShortName().equals("cop") && t2.gov().originalText().equals(y)) {
								System.out.println(aspect  + " ****5 - " + y);
								if (checkNegation(y, td)) {
									System.out.println("negation present in " + y);
									insertOpinionWord(aspect, y, true);
								} else {
									insertOpinionWord(aspect, y, false);
								}

							}
							break;
						}
					}
				}
			}
			// }

			// implement algorithm - 6
			// for (TypedDependency t : td) {
			if (t.reln().getShortName().equals("nsubj") && t.dep().originalText().equals(aspect)) {

				x = t.gov().originalText();
				for (TypedDependency t1 : td) {
					if (t1.reln().getShortName().equals("acomp") && t1.gov().originalText().equals(x)) {
						y = t.dep().originalText();
						System.out.println(aspect  + " ****6 - " + y);
						if (checkNegation(y, td)) {
							System.out.println("negation present in " + y);
							insertOpinionWord(aspect, y, true);
						} else {
							insertOpinionWord(aspect, y, false);
						}
						break;
					}
				}
			}
		}

		// checking negations
		/*
		 * if (y != null) { if (checkNegation(y, td)) System.out.println(
		 * "negation present in " + y); }
		 */
		/*
		 * if (y1 != null) { if (checkNegation(y1, td)) System.out.println(
		 * "negation present in " + y1); }
		 */
	}

	/*
	 * After extraction of the opinion word...insert method will
	 * insertOpinionWord() will perform the task to insert the word into Aspect
	 * object.... when the negation is present in the word...we will insert it
	 * in CAPITALS.. this will conter the need of a more complex data structure
	 * to hold a flag for each opinion word... FINAL checking of the opinion
	 * word itself will be done in this method
	 */

	public void insertOpinionWord(String aspect, String word, boolean negation) {
		if (sc.isOpinionWod(word)) {
			if (!negation)
				// aspect.insert(word.toLowerCase()); // no negation ->
				// lowercase
				opinionWords.add(word.toLowerCase());
			else {
				// aspect.insert(word.toUpperCase()); // negation -> UPPERCASE
				opinionWords.add(word.toUpperCase());
			}
		}
	}
}
