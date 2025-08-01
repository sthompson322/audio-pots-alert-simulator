import guru.ttslib.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;

ControlP5 p5;
Gain masterGain;
Glide masterGainGlide;
Glide heartRateGlide;

boolean manual;
boolean start;
boolean call;

String JSONdata = "sensordata.json";
TextToSpeechMaker ttsMaker;
PriorityQueue<Notification> queue;

float patientMin;
float patientMax;
float currentHR;
float recentShift;
float hydrationPercentage;
String currentPosture;
String currentActivity;
String currentLocation;
String faintingRisk;
String status;
boolean fainting;
boolean conscious;

Textlabel currentHeartRateLabel, heartRateShiftLabel, hydrationLabel, postureLabel, activityLabel, locationLabel, faintingLabel, consciousLabel;
Textlabel dataStreamModeLabel, manualModeLabel;
Numberbox patientMinBox, patientMaxBox, hrBox, hrShiftBox, hydrationBox;
RadioButton postureList, activityList, locationList, faintingList, consciousList;


SamplePlayer beeper;
SamplePlayer bells;
SamplePlayer downbells;
WavePlayer hydrationNoise;
SamplePlayer alarm;

Glide beepRateGlide;
Glide hrShiftPitchGlide;
double bellsLength;
double downbellsLength;

Button startEventStream;
Button pauseEventStream;
Button stopEventStream;

NotificationServer notificationServer;
//ArrayList<Notification> notifications;
int timer;


MyNotificationListener myNotificationListener;


void setup() {
  
  size(800, 800);
  p5 = new ControlP5(this);
  ac = new AudioContext();
  
  ttsMaker = new TextToSpeechMaker();
  
  notificationServer = new NotificationServer();
  
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
  Comparator<Notification> priorityComp = new Comparator<Notification>() {
    public int compare(Notification n1, Notification n2) {
      return min(n1.getTimestamp(), n2.getTimestamp());
    }
  };
  
  queue = new PriorityQueue<Notification>(10, priorityComp);
  call = true;
  
  manual = false;
  patientMin = 40;
  patientMax = 100;
  currentHR = 60;
  recentShift = 30;
  hydrationPercentage = 0.8;
  currentPosture = "laying";
  currentActivity = "none";
  currentLocation = "home";
  faintingRisk = "No";
  status = "Conscious";
  fainting = false;
  conscious = true;
  
  beeper = getSamplePlayer("beat.wav");
  beeper.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  beepRateGlide = new Glide(ac, 0, 0);
  beeper.setRate(beepRateGlide);
  beeper.pause(true);
  
  bells = getSamplePlayer("bells.wav");
  bells.pause(true);
  bellsLength = bells.getSample().getLength();
  
  downbells = getSamplePlayer("downbells.wav");
  downbells.pause(true);
  downbellsLength = downbells.getSample().getLength();
  
  hydrationNoise = new WavePlayer(ac, 440.0, Buffer.SINE);
  hydrationNoise.pause(true);
  
  alarm = getSamplePlayer("alarm.wav");
  alarm.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  alarm.pause(true);
  
  masterGainGlide = new Glide(ac, .2, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  masterGain.addInput(beeper);
  masterGain.addInput(bells);
  masterGain.addInput(downbells);
  masterGain.addInput(alarm);
  masterGain.addInput(hydrationNoise);
  ac.out.addInput(masterGain);
  
  p5.addSlider("GainSlider")
    .setPosition(150, 400)
    .setSize(30, 200)
    .setRange(0, 100)
    .setValue(10)
    .setFont(createFont("Arial", 15))
    .setLabel("Gain");
    
  startEventStream = p5.addButton("startEventStream")
    .setPosition(40, 90)
    .setSize(150, 30)
    .setFont(createFont("Arial", 10))
    .setLabel("Start Data Stream");
    
  pauseEventStream = p5.addButton("pauseEventStream")
    .setPosition(40, 130)
    .setSize(150, 30)
    .setFont(createFont("Arial", 10))
    .setLabel("Pause Data Stream");
 
  stopEventStream = p5.addButton("stopEventStream")
    .setPosition(40, 170)
    .setSize(150, 30)
    .setFont(createFont("Arial", 10))
    .setLabel("Stop Data Stream");
    
  p5.addTextlabel("SensorDataLabel")
     .setPosition(450, 120)
     .setSize(200, 80)
     .setFont(createFont("Arial", 20))
     .setText("Sensor Data:");
  
  currentHeartRateLabel = p5.addTextlabel("CurrentHeartRateLabel")
     .setPosition(400, 160)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Current Heart Rate (bpm): " + currentHR);
     
  heartRateShiftLabel = p5.addTextlabel("HeartRateShiftLabel")
     .setPosition(400, 200)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Most Recent Heart Rate Shift (bpm): " + recentShift);
     
  hydrationLabel = p5.addTextlabel("HydrationLabel")
     .setPosition(400, 240)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Hydration Percentage (%): " + (hydrationPercentage * 100));
     
  postureLabel = p5.addTextlabel("PostureLabel")
     .setPosition(400, 280)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Current Posture: " + currentPosture);
     
  activityLabel = p5.addTextlabel("ActivityLabel")
     .setPosition(400, 320)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Current Activity: " + currentActivity);
     
  locationLabel = p5.addTextlabel("LocationLabel")
     .setPosition(400, 360)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Location: " + currentLocation);
  
  faintingLabel = p5.addTextlabel("FaintingLabel")
     .setPosition(400, 400)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Risk of Fainting Episode: " + faintingRisk);
     
  consciousLabel = p5.addTextlabel("ConsciousLabel")
     .setPosition(400, 440)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Status: " + status);
  
  postureList = p5.addRadioButton("PostureList")
          .setPosition(420, 320)
          .setSize(20, 20)
          .addItem("laying", 1)
          .addItem("sitting", 2)
          .addItem("standing", 3)
          .setItemsPerRow(1)
          .activate(0)
          .setFont(createFont("Arial", 10))
          .hide();
          
  activityList = p5.addRadioButton("ActivityList")
          .setPosition(620, 320)
          .setSize(20, 20)
          .addItem("none", 1)
          .addItem("walking", 2)
          .addItem("running", 3)
          .addItem("driving", 4)
          .setItemsPerRow(1)
          .activate(0)
          .setFont(createFont("Arial", 10))
          .hide();
          
  locationList = p5.addRadioButton("LocationList")
          .setPosition(420, 470)
          .setSize(20, 20)
          .addItem("home", 1)
          .addItem("work", 2)
          .addItem("school", 3)
          .addItem("gym", 4)
          .setItemsPerRow(1)
          .activate(0)
          .setFont(createFont("Arial", 10))
          .hide();
          
  faintingList = p5.addRadioButton("FaintingList")
          .setPosition(620, 470)
          .setSize(20, 20)
          .addItem("No", 1)
          .addItem("Yes", 2)
          .setItemsPerRow(1)
          .activate(0)
          .setFont(createFont("Arial", 10))
          .hide();
          
  consciousList = p5.addRadioButton("ConsciousList")
          .setPosition(420, 620)
          .setSize(20, 20)
          .addItem("Conscious", 1)
          .addItem("Unconscious", 2)
          .setItemsPerRow(1)
          .activate(0)
          .setFont(createFont("Arial", 10))
          .hide();
     
  dataStreamModeLabel = p5.addTextlabel("DataStreamMode")
     .setPosition(300, 30)
     .setSize(200, 80)
     .setFont(createFont("Arial", 30))
     .setText("Data Stream Mode");
     
  manualModeLabel = p5.addTextlabel("ManualDataMode")
     .setPosition(300, 30)
     .setSize(200, 80)
     .setFont(createFont("Arial", 30))
     .setText("Manual Data Mode")
     .hide();
     
  p5.addTextlabel("HRRangeLabel")
     .setPosition(40, 250)
     .setSize(200, 80)
     .setFont(createFont("Arial", 15))
     .setText("Patient's Normal Heart Rate Range:");
     
  patientMinBox = p5.addNumberbox("PatientMinBox")
     .setPosition(70, 280)
     .setSize(70, 30)
     .setRange(0, 200)
     .setMultiplier(1)
     .setDirection(Controller.VERTICAL)
     .setLabel("Minimum")
     .setFont(createFont("Arial", 15))
     .setValue(patientMin);
     
  patientMaxBox = p5.addNumberbox("PatientMaxBox")
     .setPosition(190, 280)
     .setSize(70, 30)
     .setRange(0, 200)
     .setMultiplier(1)
     .setDirection(Controller.VERTICAL)
     .setLabel("Maximum")
     .setFont(createFont("Arial", 15))
     .setValue(patientMax);
     
  hrBox = p5.addNumberbox("HRBox")
     .setPosition(600, 150)
     .setSize(70, 30)
     .setRange(0, 200)
     .setMultiplier(1)
     .setDirection(Controller.VERTICAL)
     .setFont(createFont("Arial", 15))
     .setValue(currentHR)
     .setLabel("")
     .hide();
     
  hrShiftBox = p5.addNumberbox("HRShiftBox")
     .setPosition(650, 190)
     .setSize(70, 30)
     .setRange(-100, 100)
     .setMultiplier(1)
     .setDirection(Controller.VERTICAL)
     .setFont(createFont("Arial", 15))
     .setValue(recentShift)
     .setLabel("")
     .hide();
     
  hydrationBox = p5.addNumberbox("HydrationBox")
     .setPosition(600, 230)
     .setSize(70, 30)
     .setRange(0, 100)
     .setMultiplier(1)
     .setDirection(Controller.VERTICAL)
     .setFont(createFont("Arial", 15))
     .setValue(hydrationPercentage * 100)
     .setLabel("")
     .hide();
     
  p5.addButton("modeSwitch")
    .setPosition(40, 20)
    .setSize(150, 30)
    .setFont(createFont("Arial", 10))
    .setLabel("Mode")
    .activateBy((ControlP5.RELEASE));
  
  ac.start();
}

public void modeSwitch() {
  manual = !manual;
  if (manual == true) {
    dataStreamModeLabel.hide();
    startEventStream.hide();
    pauseEventStream.hide();
    stopEventStream.hide();
    manualModeLabel.show();
    stopEventStream(0);
    postureList.show();
    postureLabel.setText("Current Posture").setPosition(400, 300);
    activityList.show();
    activityLabel.setText("Current Activity").setPosition(600, 300);
    locationList.show();
    locationLabel.setText("Current Location").setPosition(400, 450);
    currentHeartRateLabel.setText("Current Heart Rate (bpm):");
    heartRateShiftLabel.setText("Most Recent Heart Rate Shift (bpm):");
    faintingList.show();
    faintingLabel.setText("Risk of Fainting Episode").setPosition(600, 450);
    consciousList.show();
    consciousLabel.setText("Status").setPosition(400, 600);
    hydrationLabel.setText("Hydration Percentage (%):");
    hrBox.show();
    hrShiftBox.show();
    hydrationBox.show();
  } else {
    hrBox.hide();
    hrShiftBox.hide();
    hydrationBox.hide();
    dataStreamModeLabel.show();
    startEventStream.show();
    pauseEventStream.show();
    stopEventStream.show();
    manualModeLabel.hide();
    postureLabel.setText("Current Posture: " + currentPosture).setPosition(400, 280);
    postureList.hide();
    activityLabel.setText("Current Activity: " + currentActivity).setPosition(400, 320);
    activityList.hide();
    locationLabel.setText("Location: " + currentLocation).setPosition(400, 360);
    locationList.hide();
    currentHeartRateLabel.setText("Current Heart Rate (bpm): " + currentHR).setPosition(400, 160);
    heartRateShiftLabel.setText("Most Recent Heart Rate Shift (bpm): " + recentShift).setPosition(400, 200);
    faintingList.hide();
    faintingLabel.setText("Risk of Fainting Episode: " + faintingRisk).setPosition(400, 400);
    consciousList.hide();
    consciousLabel.setText("Status: " + status).setPosition(400, 440);
    hydrationLabel.setText("Hydration Percentage (%): " + (hydrationPercentage * 100)).setPosition(400, 240);
  }
}

public void HRBox(float value) {
  if (manual) {
    currentHR = value;
  }
}

public void HRShiftBox(float value) {
  if (manual) {
   recentShift = value;
   if (recentShift < concerningIncrease) {
     oldIncrease = false;
   }
   if (recentShift > concerningDecrease) {
     oldDecrease = false;
   }
  }
}

public void HydrationBox(float value) {
  if (manual) {
    hydrationPercentage = value / 100;
  }
}

public void PostureList(String value) {
  if (manual) {
    currentPosture = value;
  }
}

public void ActivityList(String value) {
  if (manual) {
    currentActivity = value;
  }
}

public void LocationList(String value) {
  if (manual) {
    currentLocation = value;
  }
}

public void FaintingList(String value) {
  if (manual) {
    faintingRisk = value;
    if (faintingRisk.equals("No")) {
      fainting = false;
      oldFainting = false;
    } else {
      fainting = true;
    }
  }
}

public void ConsciousList(String value) {
  if (manual) {
   status = value;
   if (status.equals("Conscious")) {
     conscious = true;
   } else {
     conscious = false;
   }
  }
}

public void GainSlider(float value) {
  masterGainGlide.setValue(value/100);
}

void draw() {
  background(0);
  if (queue.peek() != null && call == true) {
    react();
  }
  
}

void ttsPlayback(String inputSpeech) {
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}

void react() {
    
  Notification notification = queue.poll();
  call = false;
  
  currentHR = notification.getHeartRate();
  currentHeartRateLabel.setText("Current Heart Rate (bpm): " + currentHR);
      
  recentShift = notification.getHRShift();
  if (recentShift < concerningIncrease) {
    oldIncrease = false;
  }
  if (recentShift > concerningDecrease) {
    oldDecrease = false;
  }
  heartRateShiftLabel.setText("Most Recent Heart Rate Shift (bpm): " + recentShift);
      
  hydrationPercentage = notification.getHydration();
  hydrationLabel.setText("Hydration Percentage (%): " + (hydrationPercentage * 100));
      
  currentPosture = notification.getPosture();
  postureLabel.setText("Current Posture: " + currentPosture);
      
  currentActivity = notification.getActivity();
  activityLabel.setText("Current Activity: " + currentActivity);
      
  currentLocation = notification.getLocation();
  locationLabel.setText("Current Location: " + currentLocation);
      
  fainting = notification.getFainting();
  if (fainting == false) {
    oldFainting = false;
  }
  faintingRisk = (fainting) ? "Yes" : "No";
  faintingLabel.setText("Risk of Fainting Episode: " + faintingRisk);
      
  conscious = notification.getConscious();
  status = (conscious) ? "Conscious" : "Unconscious";
  consciousLabel.setText("Status: " + status);
  println(notification.getTimestamp());
  tracker();
}


class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {}
  
  public void notificationReceived(Notification notification) {
      queue.add(notification);
  }
}

void startEventStream(int value) {
  notificationServer.loadEventStream(JSONdata);
}

void pauseEventStream(int value) {
  notificationServer.pauseEventStream();
}

void stopEventStream(int value) {
  notificationServer.stopEventStream();
}
