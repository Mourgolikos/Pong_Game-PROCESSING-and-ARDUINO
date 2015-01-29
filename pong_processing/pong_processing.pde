import processing.serial.*;
import java.util.Map;

// TODO: Clean up the Mess in the end!

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////  i want to make the code as much portable as i think i can
///////////////////////////////////////////////////////////////////////////////////////
 
float ballX=random(300, 500);
float ballY=random(200, 300);
float velocity[]={0,0}; //[0]=Horizontial speed, [1]=Vertical speed
int padDimensions[]={33,99}; //[0]=width, [1]=height
int ballRadious=22;
int hits=0;
int score=0;
int framerate=30;

////////////////////////////////////////////////////////////  INPUT  FROM  THE  ARDUINO  /////////////////////////////////////////////////////////

// TODO: Populate this Section!
class ArduinoConnection{
  Serial myPort;  // Create object from Serial Class
  String portName;  // The port that the Arduino is connected to
  PApplet paplet;  // This is gonna be the "PApplet pong_processing.this" for the Serial Constructor
  int baudRate;  // The Baud Rate that is the same as the Arduino's, for proper communication.
  
  ArduinoConnection(PApplet paplet){  // Constructor. I have to pass as argument the "this" in order to get the "PApplet pong_processing.this" for the Serial Constructor
    this.paplet = paplet;
  }
  
  //Well... Java... crap! no default values to arguments! ...so let's do some Overloading...
  void connectToArduino(){
    for (int i=0; i<Serial.list().length; i++ ){//Check ALL the Serial Ports to find where the Arduino is connected.
      setListeningPort(i);
      if (getPortData() != "NA"){// TODO:  I have to provide via arduino a special phrase in order to recognise it.
        break;
      }
    }
  }
  void connectToArduino(int arduinoPort){//The Arduino port is being provided (so no loop for searching for it!)
    setListeningPort(arduinoPort);
  }
  
  void setListeningPort(int portNum) {
    this.portName = Serial.list()[portNum];
    this.myPort = new Serial(this.paplet, portName, this.baudRate);
    //myPort = new Serial(pong_processing.this, portName, this.baudRate); //Working Alternative in case of messing up the "paplet" variable above
  }
  
  String getPortData(){
    if ( this.myPort.available() > 0){  // If data is available,
      return this.myPort.readStringUntil('\n');  // read it and return it
    }
    return "NA";  // Return NA if the serial in empty
  }
}

ArduinoConnection currentArduinoConnection; // Setting the variable that is gonna contain the Arduino Connection's Settings
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////  CHANGE  DIFFICULTY  //////////////////////////////////////////////////////////////////

// TODO: Populate this Section!
class Difficulty{
  color ballColor;
  float ballAcceleration;
  
  Difficulty(){  //Initialization
    this.ballColor = color(255, 255, 255);
    this.ballAcceleration = 1/framerate;//Crazy maths for the estimation of the acceleration! Yeah!
  }
  
  void Increase(){  // Increase Difficulty level
    this.ballAcceleration *= 1.1; //Increase 10%
  }
  void Decrease(){  // Decrease Difficulty level
    this.ballAcceleration *= 0.9; //Decrease 10%
  }
  
}

Difficulty currentDifficulty; // Setting the variable that is gonna contain the Difficulty Settings
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////  FUNCTIONS  FOR  INITIALISATION  ///////////////////////////////////////////////////////
void initialiseObjects(){
  currentDifficulty = new Difficulty(); // Initialise from the object Difficulty
  currentSensorsData = new SensorsData(); // Initialise from the object SensorsData
  currentArduinoConnection = new ArduinoConnection(this); // Initialise from the object ArduinoConnection, i am passing the "PApplet pong_processing.this" for the Serial constructor inside
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////  FUNCTIONS  ABOUT  SENSORS'  DATA  //////////////////////////////////////////////////////
class SensorsData{  // TODO: Populate
  float heartRate;
  float oxygenSaturation;
  float bodyTemperature;
  float perspiration;
  float bodyAcceleration;
  boolean isSocked;
  
  SensorsData(){  //Initialization
    this.heartRate = 80;             // testing value
    this.oxygenSaturation = 99;      // testing value
    this.bodyTemperature = 36.4;     // testing value
    this.perspiration = 42;          // testing value
    bodyAcceleration = 0.2;          // testing value
    isSocked = true;                 // testing value
  }
  
  void updateHeartRate(){  // Read data from Arduino cia Serial
  }
  
  void updateOxygenSaturation(){  // Read data from Arduino cia Serial
  }
  
  void updateBodyTemperature(){  // Read data from Arduino cia Serial
  }
  
  void updatePerspiration(){  // Read data from Arduino cia Serial
  }
  
  void updateBodyAcceleration(){  // Read data from Arduino cia Serial
  }
  
  void updateIsSocked(){  // Read data from Arduino cia Serial
  }
  
  void updateAll(){
    updateHeartRate();
    updateOxygenSaturation();
    updateBodyTemperature();
    updatePerspiration();
    updateBodyAcceleration();
    updateIsSocked();
  }
  
  private Map<String, String> collectAllSensorsData(){  // To collect all Sensors' data in a Dictionary and prepare them
    Map<String, String> dataDict = new HashMap<String, String>();
    dataDict.put("HRM", Float.toString(this.heartRate));
    dataDict.put("O2", Float.toString(this.oxygenSaturation));
    dataDict.put("BT", Float.toString(this.bodyTemperature));
    dataDict.put("Per", Float.toString(this.perspiration));
    dataDict.put("SCK", Boolean.toString(this.isSocked));
    return dataDict;
  }
  String allSensorsDataToString(){  // Return All Sensors' Data as a String format
    return collectAllSensorsData().toString();
  }
  
}

SensorsData currentSensorsData; // Setting the variable that is gonna contain the Sensors' Data
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////  FUNCTIONS FOR  THE  PONG  GAME  ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////  Collision Check Ball-Wall(top or bot)
boolean hitTopWall(){
  if (ballY >= height-ballRadious  &&  velocity[1] >= 0){
    return true;      
  }
  return false;
}
boolean hitBotWall(){
  if (ballY <= ballRadious  &&  velocity[1] <= 0){
    return true;      
  }
  return false;
}
boolean hitWall(){
  return hitTopWall() || hitBotWall();
}

////////////////////////////////////////////////////////  Collision Check Ball-Pad 
boolean hitLeftPad(){
  if (ballX >= ballRadious/2
   && ballX <= ballRadious+padDimensions[0]+velocity[0]
   && ballY >= mouseY-padDimensions[1]-sqrt(2)/2*ballRadious
   && ballY <= mouseY+padDimensions[1]+sqrt(2)/2*ballRadious
   && velocity[0]<=0){
     
     scorePadHits();
     return true;
  }
  return false;
}

boolean hitRightPad(){
  if (ballX >= width-padDimensions[0]-ballRadious-velocity[0]
   && ballX <= width-ballRadious
   && ballY >= mouseY-padDimensions[1]-sqrt(2)/2*ballRadious
   && ballY <= mouseY+padDimensions[1]+sqrt(2)/2*ballRadious
   && velocity[0]>=0){
    
      scorePadHits();
      return true;
  }
  return false;
}

boolean hitPad(){
  return hitLeftPad() || hitRightPad();
}

////////////////////////////////////////////////////////  Restarting the Game
////////////////////////////////////  Reseting the Ball
void ballReset(){
  ballX=random(width/3, 2/3*width);
  ballY=random(height/3, 2/3*height);
  velocity[0]=random(-5,5)*(1+currentDifficulty.ballAcceleration);
  velocity[1]=random(-3,3)*(1+currentDifficulty.ballAcceleration);
}

////////////////////////////////////////////////////////  SCORING 
void scoring(){
  if (ballX > width+ballRadious*2 || ballX < -ballRadious*2){
    score = max(score, hits);
    hits=0;
    ballReset();
  }
}
void scorePadHits() {
  hits++;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////  SETUP  ROUTINE  ///////////////////////////////////////////////////////////////////////////
void setup() {
  size(1111, 666);
  background(0);
  colorMode(RGB);
  frameRate(framerate);
  smooth();
  ///////////////////////////////////// Starting the initialisation
  initialiseObjects();
}

/////////////////////////////////////////////////////////  DRAW  ROUTINE ////////////////////////////////////////////////////////////////////////////
void draw() {
  background(0);
  rect(width-padDimensions[0], mouseY-padDimensions[1], padDimensions[0], 2*padDimensions[1]);
  rect(0, mouseY-padDimensions[1], padDimensions[0], 2*padDimensions[1]);
  ellipse(ballX, ballY, ballRadious, ballRadious);
  ballX += velocity[0];
  ballY += velocity[1];
  
  
  if(hitPad()){
    velocity[0] += Math.signum(velocity[0]) * currentDifficulty.ballAcceleration; //Increase the speed!
    velocity[0] *= -1; //Change the horizontial direction of the ball
  }
  if (hitWall()){
    velocity[1] += Math.signum(velocity[1]) * currentDifficulty.ballAcceleration; //Increase the speed!
    velocity[1] *= -1; //Change the vertical direction of the ball
  }
  
  
  if (mousePressed) {
    ballReset();
    hits = 0;
  }
  
  scoring();
 
  textSize(49);
  text(hits, 40, 40);
  text(score, width-80, 40);
  textSize(18);
  // Note for later: The textAscent() is returning the current textSize
  text(currentSensorsData.allSensorsDataToString(),width*1/4,20);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
