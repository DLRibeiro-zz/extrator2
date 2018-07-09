package extrator;

public class MainSample {
  public static void main(String[]args){
    Thread sampleThread = new Thread(new SelectSampleRunner());
    sampleThread.start();
  }
}
