#include <SoftwareSerial.h>

SoftwareSerial portOne(6,7);

void setup() {
  portOne.begin(9600);
  Serial.begin(9600);
  pinMode(12, OUTPUT);
}

void loop() {
  portOne.listen();
  while (portOne.available() > 0) {
    char inByte = portOne.read();
    int no = inByte - 48;
    Serial.println(no);
    if (no == 0) {
      digitalWrite(12, HIGH);
    } else if (no == 1) {
      digitalWrite(12, LOW);
    }
  }
}
