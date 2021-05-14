import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class transit_graph extends PApplet {




Capture cam;

BarGraph barGraph;
LineGraph lineGraph;
int graphWidth = 640;
int graphHeight = 540;

int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial myPort;  // The serial port


public void setup() {
  //size(1280, 720);
  frameRate(30);
  
  
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

public void draw() {
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
      data = PApplet.parseFloat(split(myString, ","));
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

public void initCamera() {
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
class BarGraph extends Graph {


  int[] xTrans;
  int barWidth;

  BarGraph(int graphWidth_, int graphHeight_) {
    super(graphWidth_, graphHeight_);

    barWidth = plotWidth/18;
    xTrans = new int[18];
    for (int i = 0; i < 18; i++) {
      xTrans[i] = PApplet.parseInt(map(wavelengths[i], 410, 940, barWidth/2, plotWidth-barWidth/2));
    }
  }

  public void updateData(float[] data_) {
    super.updateData(data_);
    updateDisplay();
  }

  public void updateDisplay() {
    graph.beginDraw();
    graph.clear();
    graph.background(0);
    graph.blendMode(BLEND);

    drawXAxis();
    drawYAxis();
    super.labelGraph("Spectrum Graph");
    drawPlot();
    graph.endDraw();
  }

  public void drawPlot() {
    //println("data in");
    graph.noStroke();
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height - bottomOffset);
    graph.blendMode(ADD);

    int baseCurve = 2;
    int peakCurve = 4;
    for (int i = 0; i < wavelengths.length; i++) {
      int wavelength = wavelengths[i];
      float val = map(data[i], 0, dataMax, 0, plotHeight);
      graph.pushMatrix();
      graph.translate(xTrans[i], 0);
      graph.fill(colors[i]);
      graph.beginShape();
      graph.vertex(-barWidth/2-baseCurve, 0);
      graph.bezierVertex(0, 0, -peakCurve, -val, 0, -val);
      graph.bezierVertex(peakCurve, -val, 0, 0, barWidth/2+ baseCurve, 0);
      graph.endShape();
      graph.popMatrix();
    }
    graph.popMatrix();
  }
  public void drawYAxis() {

    super.labelYAxis("Irradiance (μW/cm2)");

    graph.stroke(255);
    graph.fill(255);
    graph.strokeWeight(2);
    graph.pushMatrix();
    graph.translate(leftOffset, topOffset);
    graph.line(0, 0, 0, plotHeight);
    graph.textAlign(RIGHT, CENTER);
    //    graph.popMatrix();

    //draw y axis
    graph.textSize(8);
    graph.strokeWeight(.5f);
    int interval = 50;
    if (dataMax>500) {
      interval = 100;
    } else if (dataMax > 1000) {
      interval = 250;
    }
    for (int i = 0; i <= dataMax; i+=interval) {
      graph.pushMatrix();
      float tickHeight = map(i, 0, dataMax, plotHeight, 0);
      graph.translate(0, tickHeight);
      graph.line(0, 0, plotWidth, 0);
      String val = str(i);
      graph.text(val, -10, 0);   
      graph.popMatrix();
    }

    graph.popMatrix();
  }
  public void drawXAxis() {
    super.labelXAxis("Wavelength (nanometers)");
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height - bottomOffset);
    graph.line(0, 0, plotWidth, 0);
    //graph.translate(barWidth/2, 0);
    graph.textSize(8);
    for (int i = 0; i < wavelengths.length; i++) {
      graph.pushMatrix();
      graph.translate(xTrans[i], 0);
      String lambda = str(wavelengths[i]);
      graph.pushMatrix();
      graph.translate(0, 15);
      graph.rotate(.5f*PI);
      graph.text(lambda, 0, 0);
      graph.popMatrix();
      graph.strokeWeight(2);
      graph.line(0, 0, 0, 5);
      graph.popMatrix();
    }
    graph.popMatrix();
  }
}
class Graph {
  int[] colors = {
    0xff7e00db, 0xff2300ff, 0xff007bff, 0xff00eaff, 0xff00ff00, 0xff70ff00, 
    0xffc3ff00, 0xffffef00, 0xffff9b00, 0xffff0000, 0xffff0000, 0xfff60000, 
    0xffc80000, 0xff8d0000, 0xff8d0000, 0xff8d0000, 0xff8d0000, 0xff8d0000, 
  };
  int[] wavelengths = {
    410, 435, 460, 485, 510, 535, 
    560, 585, 610, 645, 680, 705, 
    730, 760, 810, 860, 900, 940 
  };
  float[] data;

  PGraphics graph;
  int graphWidth, graphHeight;
  int plotWidth, plotHeight;
  int topOffset = 40;
  int bottomOffset = 60;
  int rightOffset = 20;
  int leftOffset = 60;
  int dataMax = 100;

  Graph(int graphWidth_, int graphHeight_) {
    graphWidth = graphWidth_;
    graphHeight = graphHeight_;
    graph = createGraphics(graphWidth, graphHeight);
    plotWidth = graphWidth - (rightOffset + leftOffset);
    plotHeight = graphHeight - (topOffset + bottomOffset);
  }

  public void updateData(float[] data_) {
    data = data_;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > dataMax) {
        dataMax = PApplet.parseInt(data[i]);
      }
    }
  }

  public void labelXAxis(String label) {
    graph.textAlign(CENTER, TOP);
    graph.textSize(16);
    graph.stroke(255);
    graph.fill(255);
    graph.strokeWeight(2);
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height);
    graph.text(label, plotWidth/2, -.5f*bottomOffset);
    graph.popMatrix();
  }
  public void labelYAxis(String label) {
    graph.pushMatrix();
    graph.translate(leftOffset/3, graph.height/2);
    graph.textAlign(CENTER, CENTER);
    graph.textSize(12);
    graph.rotate(-.5f*PI);
    graph.text(label, 0, 10);
    graph.popMatrix();
  }
  public void labelGraph(String label) {
    graph.textSize(18);
    graph.textAlign(CENTER, CENTER);
    graph.text(label, graph.width/2, topOffset/2);
  }
  public PGraphics display() {
    return graph;
  }
}
class LineGraph extends Graph {
  //int graphWidth, graphHeight;
  //int plotWidth;
  float[][] dataHistory;
  int indexPosition = 0;
  int history;

  LineGraph(int graphWidth_, int graphHeight_) {
    super(graphWidth_, graphHeight_);
    history = plotWidth/4;
    dataHistory = new float[18][history];
  }

  public void updateData(float[] data_) {
    super.updateData(data_); //just checks the dataMax value and increases it if necessary
    for (int i = 0; i < data.length; i++) {
      dataHistory[i][indexPosition] = data_[i];
    }
    indexPosition = (indexPosition +1) % history; //Reading begins at the location of the oldest data element and continues to the end of the array. At the end of the array, the % operator (p. 57) is used to wrap back to the beginning. 
    updateDisplay();
  }

  public void updateDisplay() {
    graph.beginDraw();
    graph.clear();
    graph.background(0);
    graph.blendMode(BLEND);

    drawXAxis();
    drawYAxis();
    super.labelGraph("Irradiance over Time");
    drawPlot();
    graph.endDraw();
  }

  public void drawPlot() {
    //println("data in");
    graph.strokeWeight(.5f);
    graph.strokeJoin(ROUND);
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height - bottomOffset);
    for (int i = 0; i < 18; i++) {
      graph.stroke(colors[i]);
      for (int j = 1; j < history; j++) {   
        int pos = (indexPosition + j) % history;
        int lastPos = (indexPosition + j-1)% history;
        float val = normToAxis(dataHistory[i][pos]);
        float lastVal = normToAxis(dataHistory[i][lastPos]);
        graph.line(4*j,lastVal, 4*(j+1), val); 
      }
    }
    graph.popMatrix();
    
  }
  
  public float normToAxis(float f){
     f = map(f,0,dataMax,0, -plotHeight);
     return f;
  }
  public void drawYAxis() {

    super.labelYAxis("Irradiance (μW/cm2)");

    graph.stroke(255);
    graph.fill(255);
    graph.strokeWeight(2);
    graph.pushMatrix();
    graph.translate(leftOffset, topOffset);
    graph.line(0, 0, 0, plotHeight);
    graph.textAlign(RIGHT, CENTER);
    //    graph.popMatrix();

    //draw y axis
    graph.textSize(8);
    graph.strokeWeight(1);
    int interval = 50;
    if (dataMax>500) {
      interval = 100;
    } else if (dataMax > 1000) {
      interval = 250;
    }
    for (int i = 0; i <= dataMax; i+=interval) {
      graph.pushMatrix();
      float tickHeight = map(i, 0, dataMax, plotHeight, 0);
      graph.translate(0, tickHeight);
      graph.line(0, 0, plotWidth, 0);
      String val = str(i);
      graph.text(val, -10, 0);   
      graph.popMatrix();
    }

    graph.popMatrix();
  }
  public void drawXAxis() {
    super.labelXAxis("time");
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height - bottomOffset);
    graph.line(0, 0, plotWidth, 0);
    //graph.translate(barWidth/2, 0);
    graph.popMatrix();
  }
}
  public void settings() {  fullScreen();  smooth(4); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "transit_graph" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
