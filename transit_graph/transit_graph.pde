import processing.serial.*;
import processing.video.*;

Capture cam;

BarGraph barGraph;
LineGraph lineGraph;
int graphWidth = 640;
int graphHeight = 540;

int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial myPort;  // The serial port


void setup() {
  //size(1280, 720);
  frameRate(30);
  fullScreen();
  smooth(4);
  initCamera();

  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;
  barGraph = new BarGraph(graphWidth, graphHeight);
  lineGraph = new LineGraph(graphWidth, graphHeight);
}

void draw() {
  if (frameCount%10 == 0) {
    println(frameRate);
  }

  if (cam.available() == true) {
    cam.read();
  }


  while (myPort.available() > 0) {
    //background(0);
    float[] data;
    myString = myPort.readStringUntil(lf);
    if (myString != null) {
      //println(myString);
      data = float(split(myString, ","));
      //printArray(data);
      //myPort.clear();
      if (data.length != 18) {
        myPort.clear();
      } else {
        barGraph.updateData(data);
        lineGraph.updateData(data);
      }
    }
  }
  noStroke();
  pushMatrix();
  translate(graphWidth, 0);
  imageMode(CENTER);
  image(cam, (width-graphWidth)/2, height/2);
  popMatrix();

  //imageMode(CORNER);
  strokeWeight(4);
  stroke(255);
  noFill();
  image(lineGraph.display(), graphWidth/2, height/2 - graphHeight/2);
  image(barGraph.display(), graphWidth/2, height/2 + graphHeight/2);
  rectMode(CENTER);
  rect(graphWidth/2, height/2 - graphHeight/2, graphWidth, graphHeight);
  rect(graphWidth/2, height/2 + graphHeight/2, graphWidth, graphHeight);
  text(frameRate, 20, 20);
}

void initCamera() {
  String[] cameras = Capture.list();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);
    cam = new Capture(this, 1280, 1080, cameras[0]);
    cam.start();
  }
}
