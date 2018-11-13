package extrator.extractors;

import extrator.entities.MergeScenario;
import java.util.List;

public class StemComponentExtractor extends NameComponentExtractor implements Extractor<MergeScenario> {

  public StemComponentExtractor(List<String> componentWords,
      List<String> excludedWords) {
    super(componentWords, excludedWords, false);
    String firstProjectPath = super.getProjectPaths().get(0);
    StemProjectClusterizer projectClusterizer = new StemProjectClusterizer(firstProjectPath);
    projectClusterizer.clusterProject();
    super.setClusterizer(projectClusterizer);
  }


}
