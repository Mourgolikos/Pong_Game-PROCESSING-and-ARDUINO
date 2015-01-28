import processing.serial.*;

void setup() {
  size(1111, 666);
  background(0);
  colorMode(HSB);
  frameRate(30);
  smooth();
}
 
float ballX=random(300, 500);
float ballY=random(200, 300);
float velocity[]={0,0}; //[0]=Horizontial speed, [1]=Vertical speed
int padDimensions[]={33,99}; //[0]=width, [1]=height
int ballRadious=22;
int hits=0;
int score=0;


////////////////////////////////////////////////////////////  INPUT  FROM  THE  ARDUINO  /////////////////////////////////////////////////////////
Serial myPort;  // Create object from Serial class
String portName;  // The port that the Arduino is connected to

//Well... Java... crap! not default values to arguments! ...so let's do some Overloading...
void connectToArduino(){
  for (int i=0; i<Serial.list().length; i++ ){//Check ALL the Serial Ports to find where the Arduino is connected.
    setListeningPort(i);
    if (getPortData() != "NA"){// TODO:  I have to provide via arduino a special phrase in order to recognise it.
      break;
    }
  }
}
void connectToArduino(int arduinoPort){//The Arduino port is being provided (so not loop for searching it!)
  setListeningPort(arduinoPort);
}

void setListeningPort(int portNum) {
  portName = Serial.list()[portNum];
  myPort = new Serial(this, portName, 9600);
}

String getPortData(){
  if ( myPort.available() > 0){  // If data is available,
    return myPort.readStringUntil('\n');  // read it and return it
  }
  return "NA";  // Return NA if the serial in empty
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


float acceleration(){ //Crazy maths for the estimation of the acceleration! Yeah!
  return random(1,2)/random(2,3);
}

//Collision Check Ball-Wall(top or bot)
boolean hitTopWall(){
  if (ballY>=height-ballRadious && velocity[1]>=0){
    return true;      
  }
  return false;
}
boolean hitBotWall(){
  if (ballY<=ballRadious && velocity[1]<=0){
    return true;      
  }
  return false;
}
boolean hitWall(){
  return hitTopWall() || hitBotWall();
}

//Collision Check Ball-Pad 
boolean hitLeftPad(){
  if (ballRadious/2<=ballX && ballX<=ballRadious+padDimensions[0] && mouseY-padDimensions[1]-sqrt(2)/2*ballRadious<=ballY && ballY<=mouseY+padDimensions[1]+sqrt(2)/2*ballRadious && velocity[0]<=0){
    scorePadHits();
    return true;
  }
  return false;
}
boolean hitRightPad(){
  if (width-padDimensions[0]-ballRadious<=ballX && ballX<=width-ballRadious && mouseY-padDimensions[1]-sqrt(2)/2*ballRadious<=ballY && ballY<=mouseY+padDimensions[1]+sqrt(2)/2*ballRadious && velocity[0]>=0){
    scorePadHits();
    return true;
  }
  return false;
}
boolean hitPad(){
  return hitLeftPad() || hitRightPad();
}

//Restarting the Game
//Reseting the Ball
void ballReset(){
  ballX=random(width/3, 2/3*width);
  ballY=random(height/3, 2/3*height);
  velocity[0]=4*random(-5, 5);
  velocity[1]=3*random(-5, 5);
}

//Scoring
void scoring(){
  if (ballX>width+ballRadious*2 || ballX<-ballRadious*2){
    score = max(score,hits);
    hits=0;
    ballReset();
  }
}
void scorePadHits() {
  hits++;
}

void draw() {
  background(0);
  rect(width-padDimensions[0], mouseY-padDimensions[1], padDimensions[0], 2*padDimensions[1]);
  rect(0, mouseY-padDimensions[1], padDimensions[0], 2*padDimensions[1]);
  ellipse(ballX, ballY, ballRadious, ballRadious);
  ballX += velocity[0];
  ballY += velocity[1];
  
  
  if(hitPad()){
    velocity[0] += Math.signum(velocity[0]) * acceleration(); //Increase the speed!
    velocity[0] *= -1; //Change the horizontial direction of the ball
  }
  if (hitWall()){
    velocity[1] += Math.signum(velocity[1]) * acceleration(); //Increase the speed!
    velocity[1] *= -1; //Change the vertical direction of the ball
  }
  
  
  if (mousePressed) {
    ballReset();
    hits=0;
  }
  
  scoring();
 
  text(hits, 40, 40);
  textSize(50);
  text(score, width-80, 40);
}
