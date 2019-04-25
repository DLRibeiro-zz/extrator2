package extrator.extractors;

import extrator.entities.MergeScenario;
import extrator.entities.Metrics;
import extrator.extractors.Extractor;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.apache.commons.io.FilenameUtils;

public class PackageExtractor implements Extractor<MergeScenario> {


  public PackageExtractor(){

  }

  @Override
  public Metrics extract(MergeScenario mergeScenario) {
    Metrics metrics = null;
    List<String> leftFiles = this.getFiles(mergeScenario.getParent1Files());
    List<String> rightFiles = this.getFiles(mergeScenario.getParent2Files());
    List<String> leftPackage = new ArrayList<>();
    List<String> rightPackage = new ArrayList<>();
    for(String javaFile : leftFiles){
      leftPackage.add(this.getPackage(javaFile));
    }
    for(String javaFile: rightFiles){
      rightPackage.add(this.getPackage(javaFile));
    }
    int commonPackageCount = this.checkCommonPackages(leftPackage, rightPackage);
    boolean existCommonPackage = (commonPackageCount > 0) ? true : false;
    metrics = new Metrics(mergeScenario.getMergeCommitId(), mergeScenario.isMergeConfliting(), existCommonPackage, commonPackageCount);
    return metrics;
  }

  /**
   * Not implemented yet TODO
   * @return
   */
  @Override
  public List<String> getProjectPaths() {
    return null;
  }

  private List<String> getFiles(String fileList) {
    List<String> files = new ArrayList<>();
    String[] allFiles = fileList.replace("[", "").replace("]", "").trim().split("@");
    files = Arrays.asList(allFiles);
    return files;
  }

  private int checkCommonPackages(List<String> packagesLeft, List<String> packagesRight){
    int commonPackageCount = 0;
    for(String packageLeft: packagesLeft){
      if(packagesRight.contains(packageLeft)){
        commonPackageCount++;
      }
    }
    return commonPackageCount;
  }

  private String getPackage(String file){
    String packageName = FilenameUtils.getPath(file);
    return packageName;
  }
}
