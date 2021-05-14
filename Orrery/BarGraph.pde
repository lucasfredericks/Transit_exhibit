class BarGraph extends Graph {


  int[] xTrans;
  int barWidth;

  BarGraph(int graphWidth_, int graphHeight_) {
    super(graphWidth_, graphHeight_);

    barWidth = plotWidth/18;
    xTrans = new int[18];
    for (int i = 0; i < 18; i++) {
      xTrans[i] = int(map(wavelengths[i], 410, 940, barWidth/2, plotWidth-barWidth/2));
    }
  }

  void updateData(float[] data_) {
    super.updateData(data_);
    updateDisplay();
  }

  void updateDisplay() {
    graph.beginDraw();
    graph.clear();
    graph.background(0);
    graph.blendMode(BLEND);

    drawXAxis();
    drawYAxis();
    super.labelGraph("Irradiance by Wavelength");
    drawPlot();
    graph.endDraw();
  }

  void drawPlot() {
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
  void drawYAxis() {

    super.labelYAxis("Irradiance (μW/cm2)");
    super.drawYAxis();
    
  }
  void drawXAxis() {
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
      graph.rotate(.5*PI);
      graph.text(lambda, 0, 0);
      graph.popMatrix();
      graph.strokeWeight(2);
      graph.line(0, 0, 0, 5);
      graph.popMatrix();
    }
    graph.popMatrix();
  }
}
