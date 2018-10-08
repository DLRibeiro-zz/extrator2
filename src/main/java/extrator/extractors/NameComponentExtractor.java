package extrator.extractors;

import extrator.entities.MergeScenario;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.ObjectUtils.Null;

public class NameComponentExtractor extends SimpleStringComponentExtractor implements Extractor<MergeScenario> {

  ProjectClusterizer clusterizer;
  public NameComponentExtractor(List<String> componentWords,
      List<String> excludedWords) {
    super(componentWords, excludedWords);
    this.clusterizer = new ProjectClusterizer();
    this.clusterizer.clusterProject();
  }

  @Override
  protected List<String> extractComponentsFromFileList(String fileList) {
    List<String> selectedComponents = new ArrayList<>();
    List<String> javaFiles = getCleanJavaFiles(fileList);

    for(String javaFile: javaFiles){
      try {
        selectedComponents.addAll(this.clusterizer.getClusterComponents().get(javaFile));
      }catch(NullPointerException e){
        System.out.println("Did not found :" + javaFile);
      }
    }

    return selectedComponents;
  }

  protected String cleanForStopWord(String file) {
    String cleanFileName = FilenameUtils.getName(file);
    for (String stopWord : this.excludedWords) {
      cleanFileName = cleanFileName.replace(stopWord, "");
    }

    for(String componentWord: this.componentWords){
      cleanFileName = cleanFileName.replace(componentWord, "");
    }
    return cleanFileName;
  }

  @Override
  protected List<String> getCleanJavaFiles(String fileList) {
    List<String> javaFiles = this.getJavaFiles(fileList);
    List<String> cleanJavaFiles = new ArrayList<>();
    for(String javaFile : javaFiles){
      String cleanJavaFile = FilenameUtils.getName(javaFile.replace(".java", ""));
      cleanJavaFiles.add(cleanJavaFile);
    }
    return cleanJavaFiles;
  }
}
