import processing.serial.*;

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
  size(640, 480);
  //blendMode(ADD);
  dataMax = 250;
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;
  axes = createGraphics(640, 480);
  plot = createGraphics(600, 440);
  xOff = axes.width - plot.width;
  yOff = axes.height - plot.height;
  barWidth = (plot.width)/18;
  plot.beginDraw();
  plot.blendMode(ADD);
  plot.endDraw();

  drawAxes(axes);
}

void draw() {
  while (myPort.available() > 0) {
    background(0);
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
  image(axes, 0, 0);
  image(plot, xOff, 0);
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
    int baseCurve = 5;
    int peakCurve = 7;
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
void drawAxes(PGraphics buffer){
  buffer.beginDraw();
  buffer.clear();
  buffer.background(0);
  buffer.blendMode(BLEND);
  drawXAxis(buffer);
  drawYAxis(buffer);
  buffer.endDraw();
}
void drawYAxis(PGraphics buffer) {
  buffer.textAlign(RIGHT, TOP);
  buffer.stroke(255);
  buffer.fill(255);
  buffer.strokeWeight(2);
  buffer.pushMatrix();
  //buffer.translate(xOff, 0);
  buffer.line(xOff, 0, xOff, buffer.height-yOff);
  buffer.strokeWeight(.5);
  int interval = 50;
  if(dataMax>500){
    interval = 100;
  }
  else if(dataMax > 1000){
    interval = 250;
  }
  for (int i = 0; i < dataMax; i+=interval) {
    buffer.pushMatrix();
    float tickHeight = map(i, 0, dataMax, plot.height, 0);
    buffer.translate(xOff, tickHeight);
    buffer.line(0, 0, plot.width, 0);
    String val = str(i);
    buffer.text(val, 0, -10);   
    buffer.popMatrix();
  }


  buffer.popMatrix();
}
void drawXAxis(PGraphics buffer) {
  buffer.textAlign(CENTER, BOTTOM);
  buffer.stroke(255);
  buffer.fill(255);
  buffer.strokeWeight(2);
  buffer.pushMatrix();
  buffer.translate(xOff, buffer.height-yOff);
  buffer.line(0, 0, plot.width, 0);
  //buffer.translate(barWidth/2, 0);
  for (int i = 0; i < wavelengths.length; i++) {
    buffer.pushMatrix();
    int xTrans = int(map(float(wavelengths[i]), 410, 940, barWidth/2, plot.width-barWidth/2));
    buffer.translate(xTrans, 0);
    String lambda = str(wavelengths[i]);
    buffer.text(lambda, 0, 20);
    buffer.strokeWeight(2);
    buffer.line(0, 0, 0, 5);
    buffer.popMatrix();
  }
  buffer.popMatrix();
}
