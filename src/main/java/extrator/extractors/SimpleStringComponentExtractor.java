package extrator.extractors;

import extrator.ComponentMetrics;
import extrator.PropertiesUtil;
import extrator.entities.MergeScenario;
import extrator.entities.Metrics;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.filefilter.HiddenFileFilter;

public class SimpleStringComponentExtractor implements Extractor<MergeScenario> {

  protected List<String> excludedWords;
  protected List<String> componentWords;
  private List<String> projectPaths;

  public SimpleStringComponentExtractor(){

  }

  public SimpleStringComponentExtractor(List<String> componentWords, List<String> excludedWords) {
    this.excludedWords = excludedWords;
    this.componentWords = componentWords;
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
    } catch (IOException e) {
      e.printStackTrace();
    }
    String projectPaths = properties.getProperty(ExtractorConstants.PROJECT_PATH_PROPERTY);
    this.projectPaths = this.generateProjectPaths(projectPaths);
  }

  /**
   * Creates a list of project paths from a base project path
   * @param projectPaths
   * @return The {@link List} of project paths
   */
  private List<String> generateProjectPaths(String projectPaths) {
    File baseFolder = new File(projectPaths);
    File[] underFolders = baseFolder.listFiles();
    List<String> listProjectPaths = new ArrayList<>();
    this.searchGitRepos(baseFolder, listProjectPaths);
//    String[] arrayProjectPaths = projectPaths.replace("[", "").replace("]", "").split("\\|");
//    for (String projectPath : arrayProjectPaths) {
//      String trimmedProjectPath = projectPath.trim();
//      if (!trimmedProjectPath.equals("")) {
//        listProjectPaths.add(trimmedProjectPath);
//      }
//    }
    return listProjectPaths;
  }

  private boolean isGitRepository(File folder){
    boolean isGitRepo = false;
    File[] hiddenFiles = folder.listFiles((FileFilter) HiddenFileFilter.HIDDEN);
    for(File file: hiddenFiles){
      if(file.getName().equals(".git")){
        isGitRepo = true;
      }
    }
    return isGitRepo;
  }

  private void searchGitRepos(File baseFolder, List<String> projectPaths){
    File[] folders = baseFolder.listFiles();
    for(File folder : folders){
      if(!folder.isDirectory()){
        continue;
      }
      if(this.isGitRepository(folder)){
        projectPaths.add(folder.getAbsolutePath());
      }else{
        this.searchGitRepos(folder, projectPaths);
      }
    }
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

  @Override
  public List<String> getProjectPaths() {
    return null;
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
    List<String> nonJavaFiles = this.getNonJavaKotlinFiles(fileList);
    List<String> components = new ArrayList<>();
    if(!nonJavaFiles.isEmpty()){
      components.add("RESOURCE");
    }
    return components;
  }

  protected List<String> getCleanJavaFiles(String fileList) {
    List<String> javaFiles = this.getJavaKotlinFiles(fileList);
    for (int i = 0; i < javaFiles.size(); i++) {
      String javaFile = javaFiles.get(i);
      javaFile = this.cleanForStopWord(javaFile);
      javaFiles.set(i, javaFile);
    }
    return javaFiles;
  }

  protected List<String> getNonJavaKotlinFiles(String fileList){
    List<String> nonJavaFiles = new ArrayList<>();
    String[] allFiles = fileList.replace("[", "").replace("]","").trim().split("@");
    for(String file: allFiles){
      if(!file.endsWith(".java") && !file.endsWith(".kt")){
        nonJavaFiles.add(file);
      }
    }
    return nonJavaFiles;
  }

  protected List<String> getJavaKotlinFiles(String fileList) {
    List<String> javaFiles = new ArrayList<>();
    String[] allFiles = fileList.replace("[", "").replace("]", "").trim().split("@");
    for (String file : allFiles) {
      if (file.endsWith(".java") || file.endsWith(".kt")) {
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
