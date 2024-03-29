class LineGraph extends Graph {
  //int graphWidth, graphHeight;
  //int plotWidth;
  float[][] dataHistory;
  int indexPosition = 0;
  int history;
  int hDiv = 8; //increase this integer to reduce historical memory (scroll faster)

  LineGraph(int graphWidth_, int graphHeight_) {
    super(graphWidth_, graphHeight_);
    history = plotWidth/hDiv;
    dataHistory = new float[18][history];
  }

  void updateData(float[] data_) {
    super.updateData(data_); //just checks the dataMax value and increases it if necessary
    for (int i = 0; i < data.length; i++) {
      dataHistory[i][indexPosition] = data_[i];
    }
    indexPosition = (indexPosition +1) % history; //Reading begins at the location of the oldest data element and continues to the end of the array. At the end of the array, the % operator (p. 57) is used to wrap back to the beginning. 
    updateDisplay();
  }

  void updateDisplay() {
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

  void drawPlot() {
    //println("data in");
    graph.strokeWeight(2);
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
        graph.line(hDiv*j,lastVal, hDiv*(j+1), val); 
      }
    }
    graph.popMatrix();
    
  }
  
  float normToAxis(float f){
     f = map(f,0,dataMax,0, -plotHeight);
     return f;
  }
  void drawYAxis() {

    super.labelYAxis("Irradiance (μW/cm2)");
    super.drawYAxis();
  }
  void drawXAxis() {
    //super.labelXAxis("time");
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height - bottomOffset);
    graph.line(0, 0, plotWidth, 0);
    //graph.translate(barWidth/2, 0);
    graph.popMatrix();
  }
}
