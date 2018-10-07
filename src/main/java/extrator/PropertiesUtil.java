package extrator;

import extrator.extractors.ExtractorFactory;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class PropertiesUtil {

  public static void loadProperties(Properties properties) throws IOException {
    InputStream inputStream = PropertiesUtil.class.getClassLoader()
        .getResourceAsStream(ExtractorConstants.CONFIG_PROPERTIES);
    if (inputStream != null) {
      properties.load(inputStream);
    }
  }

  public static List<String> getStringList(String fileName) throws IOException {
    InputStream inputStream = ExtractorFactory.class.getClassLoader()
        .getResourceAsStream(fileName);
    BufferedReader buffReader = new BufferedReader(new InputStreamReader(inputStream));
    List<String> words = new ArrayList<>();
    String word = "";
    while ((word = buffReader.readLine()) != null) {
      words.add(word);
    }
    return words;
  }

}
