package extrator.extractors;

import info.debatty.java.stringsimilarity.NormalizedLevenshtein;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.core.StopAnalyzer;
import org.apache.lucene.analysis.en.KStemFilter;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;

public class StemProjectClusterizer extends ProjectClusterizer {

  private Analyzer analyzer;
  private Map<String, Set<String>> similarStrings;

  public StemProjectClusterizer(String projectPath) {
    super(projectPath);
    this.analyzer = new StandardAnalyzer();
    this.similarStrings = new HashMap<>();
  }

  @Override
  protected String componentNameExtract(String componentName) throws IOException {
    TokenStream result = this.analyzer.tokenStream(null, componentName);
    result = new KStemFilter(result);
    result = new StopFilter(result, StopAnalyzer.ENGLISH_STOP_WORDS_SET);
    CharTermAttribute resultAttr = result.addAttribute(CharTermAttribute.class);
    result.reset();
    List<String> tokens = new ArrayList<>();
    while (result.incrementToken()) {
      tokens.add(resultAttr.toString());
    }
    return tokens.get(0);
  }

  public void clusterProject() {
    File projectMainFolder = new File(super.getProjectPath());
    File[] allFiles = projectMainFolder.listFiles();
    Map<String, Integer> candidateComponents = new HashMap<String, Integer>();
    System.out.println(projectMainFolder.isDirectory());
    Map<String, List<String>> mapFilePossibleComponents = new HashMap<>();
    /**
     * Get all possible components from all files, associated with their respective file.
     * e.g Map -> FeedItem : {Feed, Item}
     */
    getFilesAndPossibleComponents(allFiles, mapFilePossibleComponents);

    /**
     * Count how many files have each component
     */
    countFilesForComponents(candidateComponents, mapFilePossibleComponents);
    mapFileToModule(candidateComponents, mapFilePossibleComponents);
  }

  private void findSimilarStrings(Map<String, List<String>> mapFilePossibleComponents) {
    NormalizedLevenshtein nl = new NormalizedLevenshtein();
    List<String> comparableStrings = new ArrayList<>();
    for (List<String> possibleComponents : mapFilePossibleComponents.values()) {
      for (String possibleComponent : possibleComponents) {
        comparableStrings.add(possibleComponent);
      }
    }
    for (int i = 0; i < comparableStrings.size(); i++) {
      String first = comparableStrings.get(i);
      for (int j = i + 1; j < comparableStrings.size(); j++) {
        String second = comparableStrings.get(j);
        if (nl.similarity(first, second) > 0.8) {
          if (this.similarStrings.get(first) == null) {
            Set<String> newSimilar = new HashSet<>();
            newSimilar.add(second);
            this.similarStrings.put(first, newSimilar);
            Set<String> newSimilar1 = new HashSet<>();
            newSimilar1.add(first);
            this.similarStrings.put(second, newSimilar1);
          } else {
            Set<String> oldSimilar = this.similarStrings.get(first);
            oldSimilar.add(second);
            this.similarStrings.replace(first, oldSimilar);
            Set<String> oldSimilar2 = this.similarStrings.get(second);
            oldSimilar2.add(first);
            this.similarStrings.replace(second, oldSimilar2);
          }
        }
      }
    }

  }
  //TODO NEED TO CHANGE FOR COUNTING ON THE SIMILARS
  @Override
  protected void countFilesForComponents(Map<String, Integer> candidateComponents,
      Map<String, List<String>> mapFilePossibleComponents) {
    super.countFilesForComponents(candidateComponents, mapFilePossibleComponents);
  }

  protected int countCandidateComponents(Map<String, Integer> candidateComponents,
      String possibleComponent) {
    Integer countFilesOnComponent = candidateComponents.get(possibleComponent);
    if (countFilesOnComponent != null) {
      candidateComponents.replace(possibleComponent, countFilesOnComponent.intValue()+1);
      Set<String> similarComponents = this.similarStrings.get(possibleComponent);
      for(String similarComponent: similarComponents){
        Integer countSimilar = candidateComponents.get(similarComponent);
        if(countSimilar != null){
          candidateComponents.replace(similarComponent, countSimilar.intValue() +1);
        }else{
          candidateComponents.put(similarComponent, 1);
        }
      }
      return countFilesOnComponent.intValue()+1;
    } else {
      candidateComponents.put(possibleComponent, 1);
      return 1;
    }
  }
}
