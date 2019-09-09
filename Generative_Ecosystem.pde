//Fabiola Belaen PAT 204 Final project

//I set up visuals for the virtual environment of rhubarb growing in the MAX patch. 
//Had trouble with the speed of the rhubarb growing and type of pattern, and I couldn't
//get the wind to casually flow with the wind values. I ended up making something similar
//in the background, but I didn't assign it to the wind values because I wanted the amplitute
//to update as the wind levels changed, however my visuals looked odd without keeping the 
//stroke in the background.

//sources: https://www.openprocessing.org/sketch/436597 also found in the 'tree' file 
//under the 'fractals and l-systems' processing examples.

import netP5.*;
import oscP5.*;
//set address
OscP5 oscP5;
NetAddress myRemoteLocation;

//declaring integers for equations, array sizes, values, and storing counts
int count = 0;
float xoff = 0.0;
float theta; 
float rhuVal;
int rainMax = 75;
int rainVal = 0;
//float windVal;
int dropMax = 65;
int dropCount = 0;
Rainfall[] rain = new Rainfall[rainMax];
Drop[] drops;

void setup() {
  noStroke();
  //slow frame rate 
  frameRate(10);
  //size(800, 600);
  fullScreen();
  //dark bg
  background(0);
  //declare new oscP5 to receive info from max via port
  oscP5 = new OscP5(this, 9000);
  //assign port
  myRemoteLocation = new NetAddress("127.0.0.1", 9500);
  
  //connect objects from object to values
  oscP5.plug(this,"rhu","/rhuFreq");
  oscP5.plug(this,"rainNum","/rainNum");
  OscMessage rainMsg = new OscMessage("/rainGen");
  rainMsg.add(random(5000, 9000));
  oscP5.send(rainMsg, myRemoteLocation);
  
  //set up rain array
  for (int i = 0; i < rain.length; i++) {
    rain[i] = new Rainfall();
  }
  
   //set up drop/circle array
  drops = new Drop[dropMax]; 
  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop(); 
  }
}

void draw() {
  //if receiving data from rain sound in MAX
  if (rainVal >= 1) {
     for (int i = 0; i < rain.length; i++) {
    rain[i].show();
    rain[i].move();
    //if (rain[i].position.y <= 0) stop(); 
  } 
  }
  // array drawing for drops in background
  for (int i = 0; i < drops.length; i++) {
    drops[i].show();
    drops[i].increase();
  }
  //set stroke of rhubarb root
  stroke(219, 13, 116);
  PVector location = new PVector(width/2,height);
  PVector velocity = new PVector(1, 1);
  //use rhubarb frequency for degree
  float a = (rhuVal*(random(0.8, 1.4))/ (float) width) * 90f;
  // Convert it to radians
  theta = radians(a);
  ///start rhubarb at bottom
  translate(location.x,location.y);
  // Draw a line 110 pixels
  line(0,0,0,-110);
  translate(0,-110);
  ///trying to slow the growth a little bit with this?
  if (location.x > 0) {
    velocity.x = velocity.x * 0.5;
  }
  if (location.y >= 0) {
    velocity.y = velocity.y * 0.5;
  }
  //recursion growth
  grow(random(70, 120));
  }
  
  
  
  void grow(float h) {
  //random proportion of previous leaf
  h *= random(0.4, 0.8);
  //must be atleast 2 pixels and a decent amt of sound from rhubarb
  if (h > 2 && rhuVal > 30) {
    pushMatrix();    
    rotate(theta);   
    //stroke color of various shades of green
    stroke(0,random(190, 255), random(0,120));
    strokeWeight(0.9);
    //line for recursion growth
    line(0, 0, 0, -h);  
    //translate to end of rhubarb root
    translate(0, -h-20); 
    //more branches
    grow(h*(0.9));      
    popMatrix();     
    //repeat for left side
    pushMatrix();
    rotate(-theta);
    line(0, 0, 0, -h-10);
    translate(0, -h-20);
    grow(h*(0.9));
    popMatrix();
  }
}
  
void mouseClicked() {
  //send clicked messages to max
  OscMessage myMessage = new OscMessage("/rhub");
  //sending x position to second rhubarb system
  myMessage.add(mouseX);
  oscP5.send(myMessage, myRemoteLocation);
  OscMessage newMessage = new OscMessage("/wind");
  //sending random alteration in wind
  newMessage.add(random(-0.2, 0.2));
  oscP5.send(newMessage, myRemoteLocation);
  pushMatrix();
  //grow rhubarb at random places, map sound to max
  stroke(random(190, 219), random(11, 35), 116);
  translate(random(-(width-50), width-50), 100);
  grow(random(50, 180));
  popMatrix();
  count = int(random(1, 3));
  println(count);
  // make sound 2/3 times
  if (count == 1 || count == 2) {
    drops[dropCount].start(mouseX, mouseY);
    //send sound triggers when clicking screen
    OscMessage cMessage = new OscMessage("/cricket");
    cMessage.add(mouseX);
    oscP5.send(cMessage, myRemoteLocation);
    //make wave only 1/3 times
    if (count == 1) {
    dropCount++;
    if (dropCount >= dropMax) {
      dropCount = 0;
    }
    }
  }
}

//plug in values from max to processing
public void rhu(float value) {
    rhuVal = value;
    println("rhu:" + rhuVal);
 }
 
 //same for rain value
 public void rainNum(float value) {
    rainVal = int(value);
    println("rain:" + rainVal);
 }
 
 //rainfall class
 class Rainfall {
   //default constructor - set position and velocity
   Rainfall() {
     //Rainfall(int i, int arrayLength) {
     position = new PVector(random(2*width), -height);
 velocity = new PVector(rainVal/10, random(-15,5));
   }
   PVector position;
   PVector velocity;

 //display for rain
 void show() {
   strokeWeight(2);
  stroke(random(53, 180), random(201, 237), 255);
 xoff = xoff + 0.01;
 //try to made it move, didn't really work
 float n = noise(millis()/100.*xoff) * position.x;
 //fill(random(53, 180), random(201, 237), 255);
 line(n, position.y, n, (position.y)-random(20));
 
 //option 2: smaller rain drops
 //point(position.x, position.y);
 }
 
 //move down the screen
 void move() {
   position.y += velocity.y;
   position.x += velocity.x;
 } 
 }
 
 //rain 'drops' in backdrop
 class Drop {
   //assign values in default ctor
  float x, y;       
  float size;     
  boolean display = false; 
  PVector velocity;
  PVector position;
  
  //initial assignment of values
  void start(float xPos, float yPos) {
    x = xPos;
    y = yPos; 
    velocity = new PVector(random(5, 10), random(10, 15));
    position = new PVector(xPos, yPos);
    size = random(3);
    //size = 1;
    display = true;
    //size
  }
  
  //the visual aspect of the circles dropping
  //sin to change the waveforms a little bit
  void show() {
    if (display == true) {
     strokeWeight(random(2));
      stroke(random(26, 170), random(2, 166), random(204, 237), 22);
       noFill();
      ellipse(x, y, size*sin(TWO_PI/20.0)*random(10,30), size);
    }
  }
  
  //the spreading / echo effect
  void increase() {
    if (display == true) {
    position.y += velocity.y;
    position.x += velocity.x;
    //various sizes
     size += random(4,20);
     //try to change the sizes a little bit & no longer expand past screen
      if (size > width-(random(60))) {
        display = false;
        size = random(3);
      }
    }
  }
}

//void keysPressed() {
//  if (key == 'c') {
//    clear();
//    background(0);
//  }
//}
  
//couldn't get the waveforms to not interfere with the background, wanted to connect
//the wind to this. 
//init / set up
//Wave[] waves;
//int numWaves = 30;
//int curWave = 0;
//waves = new Wave[numWaves];
  //  for (int i = 0; i < waves.length; i++) {
  //  waves[i] = new Wave(); 
  //}
// draw
//for (int i = 0; i < waves.length; i++) {
    // int counter = 0;
    //waves[i].display();
    //waves[i].move();
   // if (counter > 4) stop();  
    //get wind input
 //public void wind(float value) {
 //  windVal = value;
 //  if (windVal < 0.5 ) {
 //    stroke(random(160, 200));
 //    //add sine wave in background
//class Wave {
//  // x and y coords
//  float x, y;
//  float amp;
//  float period;
//  float phase = random(-0.03,0.03);
//  boolean view = false;
//  float amp_drift;
//  PVector velocity;
//  PVector position; 
//  Wave() {
//    //x = xPos;
//    //y = yPos;
//    velocity = new PVector(random(5, 10), random(10, 15));
//    position = new PVector(width, mouseY);
//    amp = 20;
//    period = random(250,350);
//    //period = (millis()/200.);
//    view = true;
//    amp_drift = random(-3,3);
//  }
//  void display() {
//    if (view == true) {
//      noFill();
//      strokeWeight(0.3);
//      stroke(180, 150);
//      float xoff = 0.0;
//      float yoff = 0.00;
//      beginShape();
//      //noStroke();
//    for (x = 0; x < width; x += 10) {
//    y = amp * sin(x * (TWO_PI/period) - (phase*period)) + height/2;
//    //y = map(noise(xoff, yoff), 0, 20, random(50, 300), random(100,200));
//    vertex(x, y);
//    xoff = sin(x*(TWO_PI/period));
//    //line(0, height/2, x, y);
//    }
//  }
//      vertex(width, height);
//      vertex(0, height);
//      endShape(CLOSE);  
//    }
//  }

 
