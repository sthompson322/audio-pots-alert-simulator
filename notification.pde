class Notification {
 
  int timestamp; //time in seconds (represents time in a day)
  float heartRate; // beats per minute
  float hrShift; //heart rate shift
  float hydration; // percent hydrated
  String posture; //laying, sitting, standing
  String activity; //none, walking, running, driving
  String location;
  String verbalInput;
  boolean fainting; // about to faint is true, not about to faint is false
  boolean conscious;  // conscious is true, not unconscious is false
  
  public Notification(JSONObject json) {
    
    this.timestamp = json.getInt("timestamp");
    
    this.heartRate = json.getFloat("heartRate");
    
    this.hrShift = json.getFloat("hrShift");
     
    this.hydration = json.getFloat("hydration");
   
    if (json.isNull("posture")) {
      this.posture = "";
    }
    else {
      this.posture = json.getString("posture");
    }
    
    if (json.isNull("activity")) {
      this.activity = "";
    }
    else {
      this.activity = json.getString("activity");      
    }
    
    if (json.isNull("location")) {
      this.location = "";
    }
    else {
      this.location = json.getString("location");      
    }
    
    if (json.isNull("verbalInput")) {
      this.verbalInput = "";
    }
    else {
      this.verbalInput = json.getString("verbalInput");      
    }
    
    this.fainting = json.getBoolean("fainting");
    
    this.conscious = json.getBoolean("conscious");
    
  }
  
  public int getTimestamp() { return timestamp; }
  public float getHeartRate() { return heartRate; }
  public float getHRShift() { return hrShift; }
  public String getPosture() { return posture; }
  public String getActivity() { return activity; }
  public float getHydration() { return hydration; }
  public String getLocation() { return location; }
  public String getVerbalInput() { return verbalInput; }
  public boolean getFainting() { return fainting; }
  public boolean getConscious() { return conscious; }
  
  public String toString() {
      String output = "Current Sensor Data: ";
      output += "(timestamp: " + getTimestamp() + ") ";
      output += "(heart rate: " + getHeartRate() + ") ";
      output += "(heart rate shift: " + getHRShift() + ") ";
      output += "(posture: " + getPosture() + ") ";
      output += "(activity: " + getActivity() + ") ";
      output += "(hydration: " + getHydration() + ") ";
      output += "(location: " + getLocation() + ") ";
      output += "(fainting: " + getFainting() + ") ";
      output += "(conscious: " + getConscious() + ") ";
      output += "(verbal input: " + getVerbalInput() + ") ";
      return output;
    }
}
