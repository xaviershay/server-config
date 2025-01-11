#include <ESP8266WiFiMulti.h>
#include <InfluxDbClient.h>
#include <DHT20.h>
#include "constants.h"

// On-board LED for NodeMCU 1.0
#define PIN_LED 2

ESP8266WiFiMulti wifiMulti;
InfluxDBClient client(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN);
Point sensor("air_quality");
DHT20 HT;

// From DHT11 spec "When power supplied to the sensor, do not send any
// instruction [for 1s]"
int setupTime = 1000;

void setup() {
  pinMode(PIN_LED, OUTPUT);
  // Onboard LED should be on when setup or in error,
  // off during normal operation.
  // LOW turns it on for some reason.
  digitalWrite(PIN_LED, LOW);

  Serial.begin(115200);
  Wire.begin();
  HT.begin();

  WiFi.mode(WIFI_STA);
  wifiMulti.addAP(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to wifi");
  while (wifiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(100);
  }
  Serial.println();
  sensor.addTag("sensor", DEVICE);
  timeSync(TZ_INFO, "pool.ntp.org", "time.nis.gov");

  // Check server connection
  if (client.validateConnection()) {
    Serial.print("Connected to InfluxDB: ");
    Serial.println(client.getServerUrl());
  } else {
    Serial.print("InfluxDB connection failed: ");
    Serial.println(client.getLastErrorMessage());
  }
  
  delay(setupTime);
}

void loop() {
  // Clear fields for reusing the point. Tags will remain untouched
  sensor.clearFields();
  int status = HT.read();
  float h = HT.getHumidity();
  float t = HT.getTemperature();

  // Going to assume 0% humidity not a thing, I've seen it
  // as a return value errantly.
  if (status != DHT20_OK) {
    digitalWrite(PIN_LED, LOW);
    #ifdef DEBUG
      Serial.println("Error reading from sensor");
    #endif
  } else {
    sensor.addField("humid", h);
    sensor.addField("temp", t);

    // Serial writes are disabled in production to avoid flashing the serial LED
    #ifdef DEBUG
      Serial.print("Writing: ");
      Serial.println(sensor.toLineProtocol());
    #endif
    
    if (client.writePoint(sensor)) {
      // Disable the LED since we just successfully wrote a point.
      // It won't be enabled again until an error condition is hit.
      digitalWrite(PIN_LED, HIGH);
    } else {
      #ifdef DEBUG
        Serial.print("InfluxDB write failed: ");
        Serial.println(client.getLastErrorMessage());
      #endif
    }
  }

  delay(1000);
}
