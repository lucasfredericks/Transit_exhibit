/*
  Read the 18 channels of spectral light over I2C using the Spectral Triad
  By: Nathan Seidle
  SparkFun Electronics
  Date: October 25th, 2018
  License: MIT. See license file for more information but you can
  basically do whatever you want with this code.

  This example takes all 18 readings, 372nm to 966nm, over I2C and outputs
  them to the serial port.

  Feel like supporting open source hardware?
  Buy a board from SparkFun! https://www.sparkfun.com/products/15050

  Hardware Connections:
  Plug a Qwiic cable into the Spectral Triad and a BlackBoard
  If you don't have a platform with a Qwiic connection use the SparkFun Qwiic Breadboard Jumper (https://www.sparkfun.com/products/14425)
  Open the serial monitor at 9600 baud to see the output
*/

#include "SparkFun_AS7265X.h" //Click here to get the library: http://librarymanager/All#SparkFun_AS7265X
AS7265X sensor;

void setup() {
  Serial.begin(115200);
  Serial.println("AS7265x Spectral Triad Example");
  //
  if (sensor.begin() == false)
  {
    Serial.println("Sensor does not appear to be connected. Please check wiring. Freezing...");
    while (1);
  }
  sensor.disableIndicator();
  //
  //Serial.println("A,B,C,D,E,F,G,H,R,I,S,J,T,U,V,W,K,L");
}

void loop() {
  
  
  sensor.takeMeasurements(); //This is a hard wait while all 18 channels are measured
  String dataString = "";
  
  dataString += String(sensor.getCalibratedA());
  dataString += ",";
  dataString += String(sensor.getCalibratedB());
  dataString += ",";
  dataString += String(sensor.getCalibratedC());
  dataString += ",";
  dataString += String(sensor.getCalibratedD());
  dataString += ",";
  dataString += String(sensor.getCalibratedE());
  dataString += ",";
  dataString += String(sensor.getCalibratedF());
  dataString += ",";
  dataString += String(sensor.getCalibratedG());
  dataString += ",";
  dataString += String(sensor.getCalibratedH());
  dataString += ",";
  dataString += String(sensor.getCalibratedR());
  dataString += ",";
  dataString += String(sensor.getCalibratedI());
  dataString += ",";
  dataString += String(sensor.getCalibratedS());
  dataString += ",";
  dataString += String(sensor.getCalibratedJ());
  dataString += ",";
  dataString += String(sensor.getCalibratedT());
  dataString += ",";
  dataString += String(sensor.getCalibratedU());
  dataString += ",";
  dataString += String(sensor.getCalibratedV());
  dataString += ",";
  dataString += String(sensor.getCalibratedW());
  dataString += ",";
  dataString += String(sensor.getCalibratedK());
  dataString += ",";
  dataString += String(sensor.getCalibratedL());

  Serial.println(dataString);
  

  //  Serial.print(sensor.getCalibratedA());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedB());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedC());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedD());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedE());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedF());
  //  Serial.print(",");
  //
  //  Serial.print(sensor.getCalibratedG());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedH());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedR());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedI());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedS());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedJ());
  //  Serial.print(",");
  //
  //  Serial.print(sensor.getCalibratedT());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedU());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedV());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedW());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedK());
  //  Serial.print(",");
  //  Serial.print(sensor.getCalibratedL());
  //  //Serial.print(",");
  //
  //  Serial.println();
}
