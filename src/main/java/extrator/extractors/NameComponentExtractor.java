package extrator.extractors;

import extrator.entities.MergeScenario;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;

public class NameComponentExtractor extends SimpleStringComponentExtractor implements Extractor<MergeScenario> {

  public NameComponentExtractor(List<String> componentWords,
      List<String> excludedWords) {
    super(componentWords, excludedWords);
  }

  @Override
  protected List<String> extractComponentsFromFileList(String fileList) {
    Map<String, Integer> candidateComponents = new HashMap<String, Integer>();
    List<String> selectedComponents = new ArrayList<>();
    List<String> javaFiles = getCleanJavaFiles(fileList);

    for (String javaFile : javaFiles) {
      List<String> candidateComponentsFromFile = Arrays
          .asList(StringUtils.splitByCharacterTypeCamelCase(javaFile));
      for(String candidate: candidateComponentsFromFile){
        Integer count = candidateComponents.get(candidate);
        if(count != null){
          candidateComponents.replace(candidate, count+1);
        }else {
          candidateComponents.put(candidate, 1);
        }
      }
    }
    return selectedComponents;
  }
}
