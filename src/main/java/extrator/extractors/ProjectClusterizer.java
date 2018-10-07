package extrator.extractors;

import extrator.ExtractorConstants;
import extrator.PropertiesUtil;
import java.io.IOException;
import java.util.List;
import java.util.Properties;

/**
 * Class responsible to cluster the Java Files from a Android Project, utilizing the name of the source
 * files. It needs the absolute path for the project folder.
 * Configure it using the config.properties projectPath property as {@link String}.
 */
public class ProjectClusterizer {

  private List<String> stopWords;
  private String projectPath;

  public ProjectClusterizer(){
    Properties properties = new Properties();
    try {
      PropertiesUtil.loadProperties(properties);
      this.stopWords = PropertiesUtil.getStringList("stopWords.txt");
      this.projectPath = properties.getProperty(ExtractorConstants.PROJECT_PATH_PROPERTY);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

}
