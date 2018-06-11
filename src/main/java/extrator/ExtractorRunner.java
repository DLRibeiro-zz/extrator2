package extrator;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import org.apache.commons.io.FileUtils;

public class ExtractorRunner implements Runnable {

  private ComponentExtractor componentExtractor;
  private PackageExtractor packageExtractor;
  private MergeScenarioReader mergeScenarioReader;

  public ExtractorRunner() {
    this.componentExtractor = null;
    this.packageExtractor = null;
    this.mergeScenarioReader = null;
  }

  @Override
  public void run() {
    Properties properties = new Properties();
    this.packageExtractor = new PackageExtractor();
    try {
      loadProperties(properties);
      System.out.println("Loaded properties");
      buildComponentExtractor();
      System.out.println("Build component extractor");
      String[] repoNames = properties.getProperty("repos").split(",");
      String[] csvFilesPaths = new String[repoNames.length];

      int index = 0;
      List<String> csvFileNames = new ArrayList<>();
      for (String csvFileName : csvFilesPaths) {
        System.out.println(properties.get("folder"));
        String fileName = properties.get("folder") + "/" + repoNames[index].replace("\"", "")
                + "_MergeScenarioList.csv";
        csvFileNames.add(fileName);
        index++;
      }
      index = 0;
      for (String csvFile : csvFileNames) {
        InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream(csvFile);
        InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
        Reader reader = inputStreamReader;
        CSVReader csvReader = new CSVReader(reader);
        // Reading Records One by One in a String array
        String[] nextRecord;
        List<Metrics> componentMetrics = new ArrayList<>();
        List<Metrics> packageMetrics = new ArrayList<>();
        csvReader.readNext();
        while ((nextRecord = csvReader.readNext()) != null) {
          String[] ms = nextRecord;
          MergeScenario mergeScenario = new MergeScenario(ms[0], Boolean.parseBoolean(ms[1]), ms[2],
              ms[3], ms[4], ms[5], ms[6], ms[7], Integer.parseInt(ms[8]));
          Metrics mergeScenarioComponentMetrics = this.componentExtractor.extract(mergeScenario);
          Metrics mergeScenearioPackageMetrics = this.packageExtractor.extract(mergeScenario);
          componentMetrics.add(mergeScenarioComponentMetrics);
          packageMetrics.add(mergeScenearioPackageMetrics);
        }
        String repoName = repoNames[index].replace("\"","");
        writeToCsvFile(repoName,"",componentMetrics);
        writeToCsvFile(repoName,"_Packages",packageMetrics);
        writeToComponentsToCsvFile(repoName,"", componentMetrics);
        index++;
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  private void writeToComponentsToCsvFile(String repository, String extraName, List<Metrics> metrics)
      throws IOException {
    Writer writer = Files.newBufferedWriter(Paths.get(repository + extraName +"_components" + ".csv"));
    CSVWriter csvWriter = new CSVWriter(writer, CSVWriter.DEFAULT_SEPARATOR,
        CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER,
        CSVWriter.DEFAULT_LINE_END);
    String[] headerRecord = {"mergeID","isConfliting","existsCommonSlices","totalCommonSlices","leftComponents","rightComponents"};
    csvWriter.writeNext(headerRecord);
    for(Metrics metric: metrics){
      csvWriter.writeNext(((ComponentMetrics) metric).convertToComponentsStringArray());
    }
    csvWriter.close();
  }

  private void writeToCsvFile(String repository, String extraName, List<Metrics> metrics)
      throws IOException {
    Writer writer = Files.newBufferedWriter(Paths.get(repository + extraName + ".csv"));
    CSVWriter csvWriter = new CSVWriter(writer, CSVWriter.DEFAULT_SEPARATOR,
        CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER,
        CSVWriter.DEFAULT_LINE_END);
    String[] headerRecord = {"mergeID","isConfliting","existsCommonSlices","totalCommonSlices"};
    csvWriter.writeNext(headerRecord);
    for(Metrics metric: metrics){
      csvWriter.writeNext(metric.convertToStringArray());
    }
    csvWriter.close();
  }

  private void buildComponentExtractor() throws IOException {
    InputStream inputStream = getClass().getClassLoader()
        .getResourceAsStream("stopWords.txt");
    BufferedReader buffReader = new BufferedReader(new InputStreamReader(inputStream));
    List<String> listStopWords = new ArrayList<>();
    String stopWord = "";
    while ((stopWord = buffReader.readLine()) != null) {
      listStopWords.add(stopWord);
    }
    InputStream inputStream2 = getClass().getClassLoader()
        .getResourceAsStream("componentWords.txt");
    BufferedReader buffReader2 = new BufferedReader(new InputStreamReader(inputStream2));
    List<String> listComponentWords = new ArrayList<>();
    String componentWord = "";
    while ((componentWord = buffReader2.readLine()) != null) {
      listComponentWords.add(componentWord);
    }
    this.componentExtractor = new ComponentExtractor(listComponentWords, listStopWords);
  }

  private void loadProperties(Properties properties) throws IOException {
    InputStream inputStream = getClass().getClassLoader()
        .getResourceAsStream(Constants.configFilename);
    if (inputStream != null) {
      properties.load(inputStream);
    }
  }
}
