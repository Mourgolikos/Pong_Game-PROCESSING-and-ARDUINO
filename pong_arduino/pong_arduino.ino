////////////////////////  CLASSES  ////////////////////////
class SensorsData{
    private:
      float heartRate;
      float oxygenSaturation;
      float bodyTemperature;
      float perspiration;
      float bodyAcceleration;
      String startOfStream;
      String separator;
      String endOfStream;
    public:
      
      SensorsData(){
          startOfStream = "ARD";
          separator = "|";
          endOfStream = "@";
          
          // set some default values for testing purposes only
          heartRate = 80;
          oxygenSaturation = 99;
          bodyTemperature = 36.4;
          perspiration = 0.2;
          bodyAcceleration = 0.3;
      };
      
      String getHeartRate(){
          return String(heartRate);
      };
      String getOxygenSaturation(){
          return String(oxygenSaturation);
      };
      String getBodyTemperature(){
          return String(bodyTemperature);
      };
      String getPerspiration(){
          return String(perspiration);
      };
      String getBodyAcceleration(){
          return String(bodyAcceleration);
      };
      String getAllSensorsData(){
          String str = startOfStream
                      + getHeartRate()        +separator
                      + getOxygenSaturation() +separator
                      + getBodyTemperature()  +separator
                      + getPerspiration()     +separator
                      + getBodyAcceleration() +endOfStream;
          return str;
      };
};

SensorsData currentSensorsData;

////////////////////////  SETUP  ////////////////////////
void setup(){
  Serial.begin(9600); // Setting up the serial communication bus
}


////////////////////////  LOOP  ////////////////////////
void loop()
{
    //send data over the serial port
    Serial.println( currentSensorsData.getAllSensorsData() );
    //wait 1000 milliseconds to avoid flooding the serial port
    delay(1000);
}

