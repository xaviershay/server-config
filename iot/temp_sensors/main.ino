#include <ESP8266WiFiMulti.h>
#include <InfluxDbClient.h>
#include "constants.h"

// #define DEBUG 1

ESP8266WiFiMulti wifiMulti;

#define PIN_LED 2

InfluxDBClient client(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN);
Point sensor("air_quality");

// Set timezone string according to https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html
#define TZ_INFO "CET-1CEST,M3.5.0,M10.5.0/3"

#include <DHT.h>
#define Type DHT11

int sensePin = 4;
DHT HT(sensePin,Type);

// From DHT11 spec "When power supplied to the sensor, do not send any
// instruction [for 1s]"
int setupTime = 1000;

void setup() {
  pinMode(PIN_LED, OUTPUT);
  // Onboard LED should be on when setup or in error,
  // off during normal operation.
  // LOW turns it on for some reason.
  digitalWrite(PIN_LED, LOW);

  Serial.begin(9600);
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

  float h = HT.readHumidity();
  float t = HT.readTemperature();

  // Going to assume 0% humidity not a thing, I've seen it
  // as a return value errantly.
  if (isnan(h) || isnan(t) || h <= 0.1) {
    digitalWrite(PIN_LED, LOW);
    #ifdef DEBUG
      Serial.println("Error reading from sensor");
    #endif
  } else {
    sensor.addField("humid", h);
    sensor.addField("temp", t);

    // Serial writes are disable in production to avoid flashing the serial LED
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

  // DHT library caches any value read sooner than 2s.
  delay(2000);
}
