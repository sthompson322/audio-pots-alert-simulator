import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;

int concerningIncrease = 30;
int concerningDecrease = -30;
int highConcernIncrease = 50;
int highConcernDecrease = -50;
boolean oldFainting;
boolean oldIncrease;
boolean oldDecrease;
boolean alarmOn = false;
boolean faintingOn = false;

public void tracker() { 
  sonifyConscious();
  sonifyFainting();
  sonifyHRShift();
  sonifyHeartRate();
  sonifyHydration();
  call = true;
}

void sonifyFainting() {
  if (fainting && !alarmOn) {
    faintingOn = true;
  String faintingWarning = "Warning: You may be about to faint.";
  if (currentActivity.equals("driving")) {
    faintingWarning += " Find a safe place to pull over.";
  } else if (currentActivity.equals("walking")) {
    faintingWarning += " Please stop walking and sit down carefully.";
  } else if (currentActivity.equals("running")) {
    faintingWarning += " Please stop running and sit down carefully.";
  } else if (currentPosture.equals("standing")) {
    faintingWarning += " Please sit down carefully.";
  }
  if (hydrationPercentage < 0.5) {
    faintingWarning += " You are dehydrated, so drink some water.";
  }
  ttsPlayback(faintingWarning);
  } else {
    faintingOn = false;
  }
}

void sonifyHydration() {
  if (!alarmOn && !faintingOn) {
    if (hydrationPercentage < 0.5) {
      hydrationNoise.pause(false);
    } else {
      hydrationNoise.pause(true);
    }
  }
}

void sonifyHRShift() {
  if (!alarmOn && !faintingOn) {
  if (recentShift >= 30) {
    bells.start(0);
 
  } 
  if (recentShift <= -30) {
    downbells.start(0);
 
  }
  }
}


void sonifyHeartRate() {
  if (!alarmOn && !faintingOn) {
  if (currentHR >= patientMin && currentHR <= patientMax) {
    beeper.pause(true);
  } else {
    beepRateGlide.setValue(currentHR/60.0);
    beeper.pause(false);
  }
  }
}

void sonifyConscious() {
  if (conscious) {
    alarmOn = false;
    alarm.pause(true);
  } else {
    alarmOn = true;
    alarm.pause(false);
  }
}
