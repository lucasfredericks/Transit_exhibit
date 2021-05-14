class Graph {
  color[] colors = {
    #7e00db, #2300ff, #007bff, #00eaff, #00ff00, #70ff00, 
    #c3ff00, #ffef00, #ff9b00, #ff0000, #ff0000, #f60000, 
    #c80000, #8d0000, #8d0000, #8d0000, #8d0000, #8d0000, 
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

  void updateData(float[] data_) {
    data = data_;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > dataMax) {
        dataMax = int(data[i]);
      }
    }
  }

  void labelXAxis(String label) {
    graph.textAlign(CENTER, TOP);
    graph.textSize(16);
    graph.stroke(255);
    graph.fill(255);
    graph.strokeWeight(2);
    graph.pushMatrix();
    graph.translate(leftOffset, graph.height);
    graph.text(label, plotWidth/2, -.5*bottomOffset);
    graph.popMatrix();
  }
  void labelYAxis(String label) {
    graph.pushMatrix();
    graph.translate(leftOffset/3, graph.height/2);
    graph.textAlign(CENTER, CENTER);
    graph.textSize(16);
    graph.rotate(-.5*PI);
    graph.text(label, 0, 10);
    graph.popMatrix();
  }
  void labelGraph(String label) {
    graph.textSize(18);
    graph.textAlign(CENTER, CENTER);
    graph.text(label, graph.width/2, topOffset/2);
  }
  PGraphics display() {
    return graph;
  }
}
