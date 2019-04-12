package extrator.extractors;

import extrator.PropertiesUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;

/**
 * Class responsible to cluster the Java Files from a Android Project, utilizing the name of the
 * source files. It needs the absolute path for the project folder. Configure it using the
 * config.properties projectPath property as {@link String}.
 */
public class ProjectClusterizer {

  private List<String> stopWords;
  private List<String> componentWords;
  private String projectPath;
  private Map<String, List<String>> clusterComponents;
  private Map<String, Integer> candidateComponents;

  public ProjectClusterizer(String projectPath) {
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
      this.stopWords = PropertiesUtil.getStringList("stopWords.txt");
      this.componentWords = PropertiesUtil.getStringList("componentWords.txt");
      this.projectPath = projectPath;
      this.clusterComponents = new HashMap<>();
      this.candidateComponents = new HashMap<>();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  /**
   * Cluster all Java Files on a component. This list can be retrieved using the get.
   */
  public void clusterProject() {
    File projectMainFolder = new File(this.projectPath);
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

  protected void getFilesAndPossibleComponents(File[] allFiles,
      Map<String, List<String>> mapFilePossibleComponents) {
    for (File fileOrDir : allFiles) {
      mapFilePossibleComponents.putAll(this.getJavaKotlinFiles(fileOrDir));
    }
  }

  protected void mapFileToModule(Map<String, Integer> candidateComponents,
      Map<String, List<String>> mapFilePossibleComponents) {
    /**
     * For each file now, check which POSSIBLE COMPONENTS that were extracted from him for POSSIBLE COMPONENTS
     * WITH HIGH CARDINALITY. THEN, IT IS CLUSTERED TO THE COMPONENTS WITH HIGHER CARDINALITY.
     */
    for (Entry<String, List<String>> mapFileComponentsFromFile : mapFilePossibleComponents
        .entrySet()) {
      List<String> chosenComponentsForFile = new ArrayList<>();
      addToBiggerCluster(candidateComponents, mapFileComponentsFromFile,
          chosenComponentsForFile);
      /**
       * Finalize the clustering, mapping each file to their clusters, to be consulted after
       */
      this.clusterComponents.put(mapFileComponentsFromFile.getKey(), chosenComponentsForFile);
    }
  }

  protected void countFilesForComponents(Map<String, Integer> candidateComponents,
      Map<String, List<String>> mapFilePossibleComponents) {
    for (Entry<String, List<String>> mapFileComponentsFromFile : mapFilePossibleComponents
        .entrySet()) {
      for (String possibleComponent : mapFileComponentsFromFile.getValue()) {
        countCandidateComponents(candidateComponents, possibleComponent);
      }
    }
    this.candidateComponents = candidateComponents;
  }

  private void addToBiggerCluster(Map<String, Integer> candidateComponents,
      Entry<String, List<String>> mapFileComponentsFromFile,
      List<String> componentsForFile) {
    int higherCount = 0;
    for (String possibleComponent : mapFileComponentsFromFile.getValue()) {
      Integer currentCount = candidateComponents.get(possibleComponent);
      if (currentCount.intValue() > higherCount) {
        componentsForFile.removeAll(componentsForFile);
        componentsForFile.add(possibleComponent);
        higherCount = currentCount.intValue();
      } else if (currentCount.intValue() == higherCount) {
        componentsForFile.add(possibleComponent);
      }
    }
  }

  protected int countCandidateComponents(Map<String, Integer> candidateComponents,
      String possibleComponent) {
    Integer countFilesOnComponent = candidateComponents.get(possibleComponent);
    if (countFilesOnComponent != null) {
      candidateComponents.replace(possibleComponent, countFilesOnComponent.intValue()+1);
      return countFilesOnComponent.intValue()+1;
    } else {
      candidateComponents.put(possibleComponent, 1);
      return 1;
    }
  }

  /**
   * Adds a new file to the cluster
   * @param fileName, just the class name, not
   */
  public void addNewFileCluster(String fileName){
    Map<String, List<String>> possibleComponents = new HashMap<>();
    this.getPossibleComponentsFromFile(possibleComponents, fileName);
    List<String> possibleComponentesFromFile = possibleComponents.get(fileName);
    for(String possibleComponent: possibleComponentesFromFile){
      this.countCandidateComponents(this.candidateComponents, possibleComponent);
    }
    mapFileToModule(this.candidateComponents, possibleComponents);

  }


  private Map<String, List<String>> getJavaKotlinFiles(File file) {
    Map<String, List<String>> javaFileNames = new HashMap<>();
    if (file.isDirectory()) {
      File[] subFiles = file.listFiles();
      getFilesAndPossibleComponents(subFiles, javaFileNames);
      return javaFileNames;
    } else {
      String fileName = FilenameUtils.getName(file.getAbsolutePath());
      if (fileName.contains(".java") || fileName.contains(".kt")) {
        this.getPossibleComponentsFromFile(javaFileNames, fileName);
        return javaFileNames;
      }
    }
    return javaFileNames;
  }

  private void getPossibleComponentsFromFile(Map<String, List<String>> javaFileNames,
      String fileName) {
    String fileNameNoExtension = fileName.replace(".java", "").replace(".kt", "");
    String cleanFileName = this.cleanNameStopwordsComponentWords(fileNameNoExtension);
    List<String> componentsCandidates = Arrays
        .asList(StringUtils.splitByCharacterTypeCamelCase(cleanFileName));
    List<String> lowerCaseComponentsCandidates = new ArrayList<>();
    for(String componentName : componentsCandidates){
      try {
        lowerCaseComponentsCandidates.add(componentNameExtract(componentName));
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    javaFileNames.put(fileNameNoExtension, lowerCaseComponentsCandidates);
  }

  protected String componentNameExtract(String componentName) throws IOException {
    return componentName.toLowerCase();
  }
  public List<String> getStopWords() {
    return stopWords;
  }

  public void setStopWords(List<String> stopWords) {
    this.stopWords = stopWords;
  }

  public List<String> getComponentWords() {
    return componentWords;
  }

  public void setComponentWords(List<String> componentWords) {
    this.componentWords = componentWords;
  }

  public String getProjectPath() {
    return projectPath;
  }

  public void setProjectPath(String projectPath) {
    this.projectPath = projectPath;
  }

  public Map<String, List<String>> getClusterComponents() {
    return clusterComponents;
  }

  public void setClusterComponents(
      Map<String, List<String>> clusterComponents) {
    this.clusterComponents = clusterComponents;
  }

  private String cleanNameStopwordsComponentWords(String fileName){
    String cleanFileName = fileName;
    for (String stopWord : this.stopWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
      cleanFileName = cleanFileName.replace(stopWord.toLowerCase(),"");
    }

    for (String stopWord : this.componentWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
      cleanFileName = cleanFileName.replace(stopWord.toLowerCase(),"");
    }
    return cleanFileName;


  }
}
