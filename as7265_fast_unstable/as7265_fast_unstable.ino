/*
  Read the 18 channels of spectral light over I2C using the Spectral Triad
  By: Nathan Seidle
  SparkFun Electronics
  Date: October 25th, 2018
  License: MIT. See license file for more information but you can
  basically do whatever you want with this code.

  This example shows how to setup the sensor for max, calibrated read rate.
  Printing floats is the greatest bottleneck so we increase it to 115200.

  Feel like supporting open source hardware?
  Buy a board from SparkFun! https://www.sparkfun.com/products/15050

  Hardware Connections:
  Plug a Qwiic cable into the Spectral Triad and a BlackBoard
  If you don't have a platform with a Qwiic connection use the SparkFun Qwiic Breadboard Jumper (https://www.sparkfun.com/products/14425)
  Open the serial monitor at 115200 baud to see the output
*/

#include "SparkFun_AS7265X.h" //Click here to get the library: http://librarymanager/All#SparkFun_AS7265X
AS7265X sensor;

#include <Wire.h>

void setup() {
  Serial.begin(115200);
  Serial.println("AS7265x Spectral Triad Example");

  if (sensor.begin() == false)
  {
    Serial.println("Sensor does not appear to be connected. Please check wiring. Freezing...");
    while (1);
  }

  //Once the sensor is started we can increase the I2C speed
  Wire.setClock(400000);

  sensor.setMeasurementMode(AS7265X_MEASUREMENT_MODE_6CHAN_CONTINUOUS); //All 6 channels on all devices

  sensor.setIntegrationCycles(1);
  //0 seems to cause the sensors to read very slowly
  //1*2.8ms = 5.6ms per reading
  //But we need two integration cycles so 89Hz is aproximately the fastest read rate

  sensor.disableIndicator();

  //Rather than toggle the LEDs with each measurement, turn on LEDs all the time
  //  sensor.enableBulb(AS7265x_LED_WHITE);
  //  sensor.enableBulb(AS7265x_LED_IR);
  //  sensor.enableBulb(AS7265x_LED_UV);
  //
  //Serial.println("A,B,C,D,E,F,G,H,R,I,S,J,T,U,V,W,K,L");
}

void loop() {
  long startTime = millis();
  //We must wait two integration cycles to get all values
  while (sensor.dataAvailable() == false) {} //Do nothing
  long endTime = millis();
  String dataString = "";

  //  float readRate = 1000.0 / (endTime - startTime);
  //  Serial.print(readRate, 2);
  //  Serial.print("Hz,");
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
}
