package core;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;


public class ScoreCalculator {
	private File positiveWords;
	private File negativeWords;
	ArrayList<String> positive; // performace
	ArrayList<String> negative; // vs array..?
	private BufferedReader pr;
	private BufferedReader nr;
	static SentiWordNetDemoCode wordNet;
	
	public ScoreCalculator(String pathToSWN) throws IOException {
		positiveWords = new File("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\positive-words.txt");
		negativeWords = new File("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\negative-words.txt");
		wordNet = new SentiWordNetDemoCode(pathToSWN);
		positive = new ArrayList<String>();
		negative = new ArrayList<String>();
		
		pr = new BufferedReader(new FileReader(positiveWords.getAbsolutePath()));
		nr = new BufferedReader(new FileReader(negativeWords.getAbsolutePath()));
		
		String line;
		while ((line = pr.readLine()) != null) {
			positive.add(line);
		}
		while ((line = nr.readLine()) != null) {
			negative.add(line);
		}		
		
	}
	
	//Code added for Pie Chart
	public boolean isPositive(String word){
		if(positive.contains(word))
			return true;
		else
			return false;
	}
	
	private double getWordNetScore(String word) {
		double score;
		if ((score = wordNet.extract(word, "a")) == 0) {
			score = wordNet.extract(word, "n");
		}
		return score;
	}
	
	public boolean isOpinionWod(String word) {
		//guess if the word is actually an opinion word
		//this will act as a third and final level of refinement after 
		//the opinion word have been extracted...turns out they are not important
		if (!positive.contains(word) && !negative.contains(word)) {
			//if (getWordNetScore(word) == 0) //check if this is actually required..!!
				return false;
		}
		
		return true;
	}
	
	public double getScore(String word) {
		//EXPERIMENT HERE...!!
		double score = 0;
		if (positive.contains(word)) {
			score += 6;
		} else if (negative.contains(word)) {
			score += 3;
		} else {
			// the word is neutral or not an opinion word itself or ex, "emotive"
			score = 5;
			if (getWordNetScore(word) > 0) {
				score += 2;
			} else if (getWordNetScore(word) < 0) {
				score -= 2;
			}
		}
		
		//score += 3 * Math.pow(getWordNetScore(word), 2);
		score += 3 * getWordNetScore(word);		
		return score;
	}
	
}
