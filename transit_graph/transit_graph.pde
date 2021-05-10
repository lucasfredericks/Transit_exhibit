import processing.serial.*;
import processing.video.*;

Capture cam;

PGraphics axes;
PGraphics plot;
int xOff;
int yOff;

int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial myPort;  // The serial port
int barWidth;
float dataMax;
color[] colors = {
  #7e00db, 
  #2300ff, 
  #007bff, 
  #00eaff, 
  #00ff00, 
  #70ff00, 
  #c3ff00, 
  #ffef00, 
  #ff9b00, 
  #ff0000, 
  #ff0000, 
  #f60000, 
  #c80000, 
  #8d0000, 
  #8d0000, 
  #8d0000, 
  #8d0000, 
  #8d0000, 
};

int[] wavelengths = {
  410, //a
  435, 
  460, 
  485, 
  510, 
  535, 
  560, 
  585, //h 
  610, 
  645, 
  680, 
  705, 
  730, 
  760, 
  810, 
  860, 
  900, 
  940 
};

void setup() {
  //size(1280, 720);
  fullScreen();
  smooth(4);
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, 1920, 1080, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
  //blendMode(ADD);
  dataMax = 250;
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;
  axes = createGraphics(380, 280);
  plot = createGraphics(300, 220);
  xOff = (axes.width - plot.width)/2 + 10;
  yOff = (axes.height - plot.height);
  barWidth = (plot.width)/18;
  plot.beginDraw();
  plot.blendMode(ADD);
  plot.endDraw();

  drawAxes(axes);
}

void draw() {
  if (frameCount%10 == 0) {
    println(frameRate);
  }

  if (cam.available() == true) {
    cam.read();
  }
  noStroke();
  image(cam, 0, 0);

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
        drawPlot(data);
      }
    }
  }
  strokeWeight(4);
  stroke(255);
  noFill();
  rect(width-axes.width-10, height-axes.height-10, axes.width, axes.height);
  image(axes, width-axes.width-10, height-axes.height-10);
  noStroke();
  image(plot, width-axes.width+xOff-10, height-axes.height-10);
  text(frameRate, 20, 20);
}

void drawPlot(float[] data) {
  //println("data in");
  plot.beginDraw();
  plot.blendMode(ADD);
  plot.clear();
  plot.noStroke();
  plot.pushMatrix();
  plot.translate(0, plot.height);
  for (int i = 0; i < 18; i++) {
    if (data[i] > dataMax) {
      dataMax = data[i];
      drawAxes(axes);
    }
    int wavelength = wavelengths[i];
    int xTrans = int(map(float(wavelength), 410, 940, barWidth/2, plot.width-barWidth/2));
    float val = map(data[i], 0, dataMax, 0, plot.height);
    plot.pushMatrix();
    plot.translate(xTrans, 0);
    int baseCurve = 2;
    int peakCurve = 4;
    plot.fill(colors[i]);
    plot.beginShape();
    plot.vertex(-barWidth/2-baseCurve, 0);
    plot.bezierVertex(0, 0, -peakCurve, -val, 0, -val);
    plot.bezierVertex(peakCurve, -val, 0, 0, barWidth/2+ baseCurve, 0);
    plot.endShape();
    plot.popMatrix();
    //rect(0, 0, barWidth, val);
    //translate(barWidth, 0);
  }
  plot.popMatrix();
  plot.endDraw();
}
void drawAxes(PGraphics buffer) {
  buffer.beginDraw();
  buffer.clear();
  buffer.background(0);
  buffer.blendMode(BLEND);
  drawXAxis(buffer);
  drawYAxis(buffer);
  buffer.endDraw();
}
void drawYAxis(PGraphics buffer) {
  buffer.pushMatrix();
  buffer.translate(0, buffer.height/2);
  buffer.textSize(12);
  buffer.rotate(-.5*PI);
  buffer.text("Irradiance (μW/cm2)", 0, 10);
  buffer.popMatrix();

  buffer.stroke(255);
  buffer.fill(255);
  buffer.strokeWeight(2);
  buffer.pushMatrix();
  //buffer.translate(xOff, 0);
  buffer.textSize(16);
  buffer.textAlign(CENTER, CENTER);
  buffer.text("Spectrum Graph", buffer.width/2, 10);
  buffer.textAlign(RIGHT, CENTER);
  buffer.line(xOff, 20, xOff, buffer.height-yOff);
  buffer.textSize(8);
  buffer.strokeWeight(.5);
  int interval = 50;
  if (dataMax>500) {
    interval = 100;
  } else if (dataMax > 1000) {
    interval = 250;
  }
  for (int i = 0; i < dataMax; i+=interval) {
    buffer.pushMatrix();
    float tickHeight = map(i, 0, dataMax, plot.height, 0);
    buffer.translate(xOff, tickHeight);
    buffer.line(0, 0, plot.width, 0);
    String val = str(i);
    buffer.text(val, -10, 0);   
    buffer.popMatrix();
  }
  buffer.popMatrix();
}
void drawXAxis(PGraphics buffer) {
  buffer.textAlign(CENTER, CENTER);
  buffer.textSize(12);
  buffer.stroke(255);
  buffer.fill(255);
  buffer.strokeWeight(2);
  buffer.pushMatrix();
  buffer.translate(xOff, buffer.height-yOff);
  buffer.text("Wavelength (nanometers)", buffer.width/2-xOff, 40);
  buffer.textSize(8);
  buffer.line(0, 0, plot.width, 0);
  //buffer.translate(barWidth/2, 0);
  for (int i = 0; i < wavelengths.length; i++) {
    buffer.pushMatrix();
    int xTrans = int(map(float(wavelengths[i]), 410, 940, barWidth/2, plot.width-barWidth/2));
    buffer.translate(xTrans, 0);
    String lambda = str(wavelengths[i]);
    buffer.pushMatrix();
    buffer.translate(0, 15);
    buffer.rotate(.5*PI);
    buffer.text(lambda, 0, 0);
    buffer.popMatrix();
    buffer.strokeWeight(2);
    buffer.line(0, 0, 0, 5);
    buffer.popMatrix();
  }
  buffer.popMatrix();
}
