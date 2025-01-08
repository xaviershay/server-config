# Temp Sensors

This is code for an ESP8266 development board (I used a Freenove) with a DHT11
sensor directly attached to GPIO4, GND, and 5V. It measures temperature and
humidity every two seconds, reporting the reading to an influxdb database over
wifi. The onboard LED will be turned on during setup and any error state, but is
off in normal operation.

As of January 2025, these components cost around $A10-$15 total.

`cp constants.{example.,}h`, then use Arduino IDE to compile and write to the
board. `#define DEBUG` to get readings written to the serial port, though this
is disabled normal to avoid blinking the serial write LED.

A plastic takeaway container with some melted holes and electrical tape can be
used for a cheap enclosure. I also add a weight (e.g. a box of cards), otherwise
it is too light to sit flat without being wagged by the cable.