package extrator.extractors;

import extrator.ExtractorConstants;
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

  public ProjectClusterizer() {
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
      this.stopWords = PropertiesUtil.getStringList("stopWords.txt");
      this.componentWords = PropertiesUtil.getStringList("componentWords.txt");
      this.projectPath = properties.getProperty(ExtractorConstants.PROJECT_PATH_PROPERTY);
      this.clusterComponents = new HashMap<>();
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
    Map<String, List<String>> mapFileComponent = new HashMap<>();
    List<String> selectedComponents = new ArrayList<>();
    List<String> javaFileNames = new ArrayList<>();
    /**
     * Get all possible components from all files, associated with their respective file.
     * e.g Map -> FeedItem : {Feed, Item}
     */
    for (File fileOrDir : allFiles) {
      mapFilePossibleComponents.putAll(this.getJavaFiles(fileOrDir));
    }

    /**
     * Count how many files have each component
     */
    for (Entry<String, List<String>> mapFileComponentsFromFile : mapFilePossibleComponents
        .entrySet()) {
      for (String possibleComponent : mapFileComponentsFromFile.getValue()) {
        Integer countFilesOnComponent = candidateComponents.get(possibleComponent);
        if (countFilesOnComponent != null) {
          candidateComponents.replace(possibleComponent, countFilesOnComponent.intValue()+1);
        } else {
          candidateComponents.put(possibleComponent, 1);
        }
      }
    }
    /**
     * For each file now, check which POSSIBLE COMPONENTS that were extracted from him for POSSIBLE COMPONENTS
     * WITH HIGH CARDINALITY. THEN, IT IS CLUSTERED TO THE COMPONENTS WITH HIGHER CARDINALITY.
     */
    for (Entry<String, List<String>> mapFileComponentsFromFile : mapFilePossibleComponents
        .entrySet()) {
      int higherCount = 0;
      List<String> componentsForFile = new ArrayList<>();
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
      /**
       * Finalize the clustering, mapping each file to their clusters, to be consulted after
       */
      clusterComponents.put(mapFileComponentsFromFile.getKey(), componentsForFile);
    }
  }


  private Map<String, List<String>> getJavaFiles(File file) {
    Map<String, List<String>> javaFileNames = new HashMap<>();
    if (file.isDirectory()) {
      File[] subFiles = file.listFiles();
      for (File fileOrDir : subFiles) {
        javaFileNames.putAll(this.getJavaFiles(fileOrDir));
      }
      return javaFileNames;
    } else {
      String fileName = FilenameUtils.getName(file.getAbsolutePath());
      if (fileName.contains(".java")) {
        String fileNameNoExtension = fileName.replace(".java", "");
        String cleanFileName = this.cleanNameStopwordsComponentWords(fileNameNoExtension);
        List<String> componentsCandidates = Arrays
            .asList(StringUtils.splitByCharacterTypeCamelCase(cleanFileName));
        List<String> lowerCaseComponentsCandidates = new ArrayList<>();
        for(String componentName : componentsCandidates){
          lowerCaseComponentsCandidates.add(componentName.toLowerCase());
        }
        javaFileNames.put(fileNameNoExtension, lowerCaseComponentsCandidates);
        return javaFileNames;
      }
    }
    return javaFileNames;
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
    }

    for (String stopWord : this.componentWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
    }
    return cleanFileName;


  }
}
