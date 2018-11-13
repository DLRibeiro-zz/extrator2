package extrator;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import extrator.entities.MergeScenario;
import extrator.extractors.ExtractorConstants;
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
import java.util.Random;

public class SelectSampleRunner implements Runnable {

  @Override
  public void run() {
    Properties properties = new Properties();
    try {
      loadProperties(properties);
      System.out.println("Loaded properties");
      String[] repoNames = properties.getProperty("repos").split(",");
      String[] csvFilesPaths = new String[repoNames.length];
      int sampleConflictCommits = Integer.parseInt(properties.getProperty("sampleConflictCommits"));
      int sampleNoConflictsCommits = Integer
          .parseInt(properties.getProperty("sampleNoConflictsCommits"));

      int index = 0;
      List<String> csvFileNames = new ArrayList<>();
      for (String csvFileName : csvFilesPaths) {
        String fileName = properties.get("folder") + "/" + repoNames[index].replace("\"", "").trim()
            + "_MergeScenarioList.csv";
        csvFileNames.add(fileName);
        System.out.println(fileName);
        index++;
      }
      List<MergeScenario> samplesMergeScenarios = new ArrayList<>();
      index = 0;
      for (String csvFile : csvFileNames) {
        //For each chosen project
        System.out.println("Sampling from" + csvFile);
        InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream(csvFile);
        InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
        Reader reader = inputStreamReader;
        CSVReader csvReader = new CSVReader(reader);
        // Reading Records One by One in a String array
        String[] nextRecord;
        csvReader.readNext();
        List<MergeScenario> mergeScenarios = new ArrayList<>();
        while ((nextRecord = csvReader.readNext()) != null) {
          String[] ms = nextRecord;
          MergeScenario mergeScenario = new MergeScenario(ms[0], Boolean.parseBoolean(ms[1]), ms[2],
              ms[3], ms[4], ms[5], ms[6], ms[7], Integer.parseInt(ms[8]));
          mergeScenarios.add(mergeScenario);
        }
        List<MergeScenario> conflictingScenarios = this
            .sampleMergeScenearions(true, sampleConflictCommits, mergeScenarios);
        List<MergeScenario> nonConflictingScenarios = this
            .sampleMergeScenearions(false, sampleNoConflictsCommits, mergeScenarios);

        samplesMergeScenarios.addAll(conflictingScenarios);
        samplesMergeScenarios.addAll(nonConflictingScenarios);
      }
    writeToCsvFile("sample", samplesMergeScenarios);

    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  private List<MergeScenario> sampleMergeScenearions(boolean isConflicting, int quantity,
      List<MergeScenario> mergeScenarios) {
    List<MergeScenario> sampleMergeScenario = new ArrayList<>();
    Random random = new Random();
    int counter = 0;
    for (int i = 0; i < quantity && counter<150; counter++) {
      int indexToExtract = random.nextInt(mergeScenarios.size());
      MergeScenario mergeScenario = mergeScenarios.get(indexToExtract);
      if (mergeScenario.isMergeConfliting() == isConflicting) {
        sampleMergeScenario.add(mergeScenario);
        i++;
        counter = 0;
      }
    }
    return sampleMergeScenario;
  }

  private void writeToCsvFile(String name, List<MergeScenario> mergeScenarios)
      throws IOException {
    Writer writer = Files.newBufferedWriter(Paths.get(name+ ".csv"));
    CSVWriter csvWriter = new CSVWriter(writer, CSVWriter.DEFAULT_SEPARATOR,
        CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER,
        CSVWriter.DEFAULT_LINE_END);
    String[] headerRecord = {"mergeCommitId","isMergeConflicting","filesConflictants","parent1Id","parent1Files","parent2Id","parent2Files","ancestorId","numberOfConflicts"};
    csvWriter.writeNext(headerRecord);
    for(MergeScenario mergeScenario: mergeScenarios){
      csvWriter.writeNext(mergeScenario.toStringArray());
    }
    csvWriter.close();
  }

  private void loadProperties(Properties properties) throws IOException {
    InputStream inputStream = getClass().getClassLoader()
        .getResourceAsStream(ExtractorConstants.CONFIG_PROPERTIES);
    if (inputStream != null) {
      properties.load(inputStream);
    }
  }
}
