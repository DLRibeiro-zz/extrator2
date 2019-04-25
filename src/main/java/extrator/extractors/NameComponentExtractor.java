package extrator.extractors;

import extrator.PropertiesUtil;
import extrator.entities.MergeScenario;
import extrator.entities.Metrics;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.filefilter.HiddenFileFilter;

public class NameComponentExtractor extends SimpleStringComponentExtractor implements
    Extractor<MergeScenario> {

  private ProjectClusterizer clusterizer;
  private List<String> projectPaths;
  private int currentProjectPosition;

  public NameComponentExtractor(List<String> componentWords,
      List<String> excludedWords) {
    super(componentWords, excludedWords);
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
    } catch (IOException e) {
      e.printStackTrace();
    }
    String projectPaths = properties.getProperty(ExtractorConstants.PROJECT_PATH_PROPERTY);
    this.projectPaths = this.generateProjectPaths(projectPaths);
    this.currentProjectPosition = 0;
    this.clusterizer = new ProjectClusterizer(this.projectPaths.get(0));
    this.clusterizer.clusterProject();
  }

  public NameComponentExtractor(List<String> componentWords,
      List<String> excludedWords, boolean isName) {
    super(componentWords, excludedWords);
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
    } catch (IOException e) {
      e.printStackTrace();
    }
    String projectPaths = properties.getProperty(ExtractorConstants.PROJECT_PATH_PROPERTY);
    this.projectPaths = this.generateProjectPaths(projectPaths);
    this.currentProjectPosition = 0;
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
  protected List<String> extractComponentsFromFileList(String fileList) {
    Set<String> selectedComponents = new HashSet<>();
    List<String> javaFiles = this.getCleanJavaKotlinFiles(fileList);

    for (String javaFile : javaFiles) {
      try {
        List<String> componentsFromFile = this.clusterizer.getClusterComponents().get(javaFile);
        if (componentsFromFile == null) {
          this.clusterizer.addNewFileCluster(javaFile);
        }
        selectedComponents.addAll(this.clusterizer.getClusterComponents().get(javaFile));
      } catch (NullPointerException e) {
        System.out.println("Did not found :" + javaFile);
      }
    }
    List<String> selectedComponentsList = new ArrayList<>();
    for (String component : selectedComponents) {
      selectedComponentsList.add(component);
    }
    return selectedComponentsList;
  }

  @Override
  public Metrics extract(MergeScenario mergeScenario) {
    Metrics metric = super.extract(mergeScenario);
    return metric;
  }

  public void changeProjectClusterizer() {
    if(this.currentProjectPosition < this.projectPaths.size()-1) {
      this.currentProjectPosition++;
      this.clusterizer = new ProjectClusterizer(this.projectPaths.get(this.currentProjectPosition));
      this.clusterizer.clusterProject();
    }
  }

  protected String cleanForStopWord(String file) {
    String cleanFileName = FilenameUtils.getName(file);
    for (String stopWord : this.excludedWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
    }

    for (String componentWord : this.componentWords) {
      cleanFileName = cleanFileName.replace(componentWord, "");
    }
    return cleanFileName;
  }


  protected List<String> getCleanJavaKotlinFiles(String fileList) {
    List<String> javaFiles = this.getJavaKotlinFiles(fileList);
    List<String> cleanJavaFiles = new ArrayList<>();
    for (String javaFile : javaFiles) {
      String cleanJavaKotlinFile = FilenameUtils.getName(javaFile.replace(".java", "").replace(".kt",""));
      cleanJavaFiles.add(cleanJavaKotlinFile);
    }
    return cleanJavaFiles;
  }

  public ProjectClusterizer getClusterizer() {
    return clusterizer;
  }

  public void setClusterizer(ProjectClusterizer clusterizer) {
    this.clusterizer = clusterizer;
  }

  public List<String> getProjectPaths() {
    return projectPaths;
  }
}
