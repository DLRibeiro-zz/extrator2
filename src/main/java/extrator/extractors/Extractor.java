package extrator.extractors;

import extrator.entities.Metrics;

public interface Extractor<T> {

  Metrics extract(T t);
}
