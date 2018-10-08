package extrator.extractors;

import extrator.entities.MergeScenario;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.FilenameUtils;

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
      selectedComponents.addAll(this.clusterizer.getClusterComponents().get(javaFile));
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
}
