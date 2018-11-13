package extrator.extractors;

import java.util.ArrayList;
import java.util.List;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.core.StopAnalyzer;
import org.apache.lucene.analysis.en.KStemFilter;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import info.debatty.java.stringsimilarity.*;

public class MainTeste {

  public static void main(String[] args) throws Exception {
    String term = "Testing car cart royal royalty lister display displays feed feeder feeding clear clearing cleared voyage testable tester";
    Analyzer analyzer = new StandardAnalyzer();
    TokenStream result = analyzer.tokenStream(null, term);
    result = new KStemFilter(result);
    result = new StopFilter(result, StopAnalyzer.ENGLISH_STOP_WORDS_SET);
    CharTermAttribute resultAttr = result.addAttribute(CharTermAttribute.class);
    result.reset();

    NormalizedLevenshtein nl = new NormalizedLevenshtein();
    System.out.println(nl.distance("http", "httpd"));
    System.out.println(nl.similarity("http","httpd"));
    List<String> tokens = new ArrayList<>();
    while (result.incrementToken()) {
      tokens.add(resultAttr.toString());
    }
    System.out.println(tokens);
  }

}
