package extrator.runners;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import extrator.ComponentMetrics;
import extrator.MergeScenarioReader;
import extrator.PropertiesUtil;
import extrator.entities.MergeScenario;
import extrator.entities.Metrics;
import extrator.extractors.*;

import java.io.File;
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
import java.util.logging.SocketHandler;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

public class ExtractorRunner implements Runnable {

    private Extractor componentExtractor;
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
        List<String> repoPaths;
        List<String> repoNames;
        String[] csvFilesPaths;
        try {
            loadAndBuildExtractor(properties);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        repoPaths = this.componentExtractor.getProjectPaths();
        repoNames = this.getRepoNames(repoPaths);
        csvFilesPaths = new String[repoNames.size()];
        int index = 0;
        List<String> csvFileNames = new ArrayList<>();
        for (String csvFileName : csvFilesPaths) {
            String fileName = properties.get("folder") + "/" + (repoNames.get(index).replace("\"", "").trim())
                    + "_MergeScenarioList.csv";
            csvFileNames.add(fileName);
            System.out.println(fileName);
            index++;
        }
        index = 0;
        int projectCount = 0;
        System.out.println("Going to extract now");
        for (String csvFile : csvFileNames) {
            System.out.println("Looking for :" + csvFile);
            try {
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
                    Metrics mergeScenarioPackageMetrics = this.packageExtractor.extract(mergeScenario);
                    componentMetrics.add(mergeScenarioComponentMetrics);
                    packageMetrics.add(mergeScenarioPackageMetrics);
                }
                if (this.componentExtractor instanceof NameComponentExtractor) {
                    System.out.println("Change project");
                    NameComponentExtractor nameComponentExtractor = (NameComponentExtractor) this.componentExtractor;
                    nameComponentExtractor.changeProjectClusterizer();
                }
                String repoName = repoNames.get(index);
                String metricsFolder = properties.getProperty(ExtractorConstants.METRICS_FOLDER);
                String extractorType = properties.getProperty(ExtractorConstants.EXTRACTOR_PROPERTY_NAME);
                String componentsFolder = properties.getProperty(ExtractorConstants.COMPONENTS_FOLDER);
                String mergeFolder = properties.getProperty(ExtractorConstants.MERGE_FOLDER_PROPERTY);
                writeToCsvFile(metricsFolder + "_" + extractorType + "_" + mergeFolder, repoName, "", componentMetrics);
                writeToCsvFile(metricsFolder + "_" + extractorType + "_" + mergeFolder, repoName, "_Packages", packageMetrics);
                writeToComponentsToCsvFile(componentsFolder + "_" + extractorType + "_" + mergeFolder, repoName, "", componentMetrics);
                projectCount++;
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                index++;
            }
        }
    }

    private void loadAndBuildExtractor(Properties properties) throws IOException {
        PropertiesUtil.loadProperties(properties);
        System.out.println("Loaded properties");
        this.componentExtractor = ExtractorFactory.createExtractor(properties.getProperty(ExtractorConstants.EXTRACTOR_PROPERTY_NAME));
        System.out.println("Build component extractor");
    }

    private List<String> getRepoNames(List<String> repoPaths) {
        List<String> repoNames = new ArrayList<>();
        for (String repoPath : repoPaths) {
            String repoPathUnix = FilenameUtils.separatorsToUnix(repoPath.replace("\"", ""));
            String[] pathSegments = repoPathUnix.split("/");
            String repoName = pathSegments[pathSegments.length - 2] + "_" + pathSegments[pathSegments.length - 1];
            repoNames.add(repoName);
        }
        return repoNames;
    }

    private void writeToComponentsToCsvFile(String folder, String repository, String extraName, List<Metrics> metrics)
            throws IOException {
        String completeFolderPath = "results/" + folder;
        File folderFile = new File(completeFolderPath);
        FileUtils.forceMkdir(folderFile);
        Writer writer = Files.newBufferedWriter(Paths.get(completeFolderPath + "/" + repository + extraName + "_components" + ".csv"));
        CSVWriter csvWriter = new CSVWriter(writer, CSVWriter.DEFAULT_SEPARATOR,
                CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER,
                CSVWriter.DEFAULT_LINE_END);
        String[] headerRecord = {"mergeID", "isConfliting", "existsCommonSlices", "totalCommonSlices", "leftComponents", "rightComponents"};
        csvWriter.writeNext(headerRecord);
        for (Metrics metric : metrics) {
            csvWriter.writeNext(((ComponentMetrics) metric).convertToComponentsStringArray());
        }
        csvWriter.close();
    }

    private void writeToCsvFile(String folder, String repository, String extraName, List<Metrics> metrics)
            throws IOException {
        String completeFolderPath = "results/" + folder;
        File folderFile = new File(completeFolderPath);
        FileUtils.forceMkdir(folderFile);
        Writer writer = Files.newBufferedWriter(Paths.get(completeFolderPath + "/" + repository + extraName + ".csv"));
        CSVWriter csvWriter = new CSVWriter(writer, CSVWriter.DEFAULT_SEPARATOR,
                CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER,
                CSVWriter.DEFAULT_LINE_END);
        String[] headerRecord = {"mergeID", "isConfliting", "existsCommonSlices", "totalCommonSlices"};
        csvWriter.writeNext(headerRecord);
        for (Metrics metric : metrics) {
            csvWriter.writeNext(metric.convertToStringArray());
        }
        csvWriter.close();
    }


}
