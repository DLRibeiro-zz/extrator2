package extrator.extractors;

import extrator.ComponentMetrics;
import extrator.entities.MergeScenario;
import extrator.entities.Metrics;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.FilenameUtils;

public class SimpleStringComponentExtractor implements Extractor<MergeScenario> {

  protected List<String> excludedWords;
  protected List<String> componentWords;

  public SimpleStringComponentExtractor(List<String> componentWords, List<String> excludedWords) {
    this.excludedWords = excludedWords;
    this.componentWords = componentWords;
  }

  @Override
  public Metrics extract(MergeScenario mergeScenario) {
    Metrics metrics = null;
    String fileListsLeft = mergeScenario.getParent1Files();
    String fileListRight = mergeScenario.getParent2Files();
    List<String> leftComponents = extractComponentsFromFileList(fileListsLeft);
    List<String> righComponents = extractComponentsFromFileList(fileListRight);
//    leftComponents.addAll(this.extractComponentsFromNonJava(fileListsLeft));
//    righComponents.addAll(this.extractComponentsFromNonJava(fileListRight));
    int commonSlicesCount = this.checkCommonSlices(leftComponents, righComponents);
    boolean existCommonSlices = (commonSlicesCount > 0);
    metrics = new ComponentMetrics(mergeScenario.getMergeCommitId(),
        mergeScenario.isMergeConfliting(), existCommonSlices, commonSlicesCount, leftComponents, righComponents);
    return metrics;
  }

  protected int checkCommonSlices(List<String> left, List<String> right) {
    int commonSlicesCount = 0;
    for (String component : left) {
      if (right.contains(component)) {
        commonSlicesCount++;
      }
    }
    return commonSlicesCount;
  }

  protected List<String> extractComponentsFromFileList(String fileList) {
    List<String> javaFiles = getCleanJavaFiles(fileList);
    List<String> components = new ArrayList<>();
    for (String javaFile : javaFiles) {
      String component = this.extractComponent(javaFile);
      if(!component.equals("") && !components.contains(component)){
        components.add(component);
      }
    }
    return components;
  }

  protected List<String> extractComponentsFromNonJava(String fileList){
    List<String> nonJavaFiles = this.getNonJavaFiles(fileList);
    List<String> components = new ArrayList<>();
    if(!nonJavaFiles.isEmpty()){
      components.add("RESOURCE");
    }
    return components;
  }

  protected List<String> getCleanJavaFiles(String fileList) {
    List<String> javaFiles = this.getJavaFiles(fileList);
    for (int i = 0; i < javaFiles.size(); i++) {
      String javaFile = javaFiles.get(i);
      javaFile = this.cleanForStopWord(javaFile);
      javaFiles.set(i, javaFile);
    }
    return javaFiles;
  }

  protected List<String> getNonJavaFiles(String fileList){
    List<String> nonJavaFiles = new ArrayList<>();
    String[] allFiles = fileList.replace("[", "").replace("]","").trim().split("@");
    for(String file: allFiles){
      if(!file.endsWith(".java")){
        nonJavaFiles.add(file);
      }
    }
    return nonJavaFiles;
  }

  protected List<String> getJavaFiles(String fileList) {
    List<String> javaFiles = new ArrayList<>();
    String[] allFiles = fileList.replace("[", "").replace("]", "").trim().split("@");
    for (String file : allFiles) {
      if (file.endsWith(".java")) {
        javaFiles.add(file);
      }
    }
    return javaFiles;
  }

  protected String cleanForStopWord(String file) {
    String cleanFileName = FilenameUtils.getName(file);
    for (String stopWord : this.excludedWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
    }
    return cleanFileName;
  }

  protected String extractComponent(String file) {
    String component = file;
    for (String componentWord : this.componentWords) {
      component = component.replace(componentWord, "");
    }
    if(component.equals(file)){
      component = "";
    }
    return component;
  }
}
