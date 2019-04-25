package extrator.extractors;

import extrator.entities.Metrics;

import java.util.List;

public interface Extractor<T> {

  public Metrics extract(T t);

  public List<String> getProjectPaths();
}
