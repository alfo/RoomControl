/* Room Control DMX */
/* Alex Forey's home lighting automation system. 
This part deals with the DMX controlling of LED lights, and remote control of
power sockets. All the messages are received by serial from a Raspberry Pi, which
is running as a HA server.
*/

/* Designed for the SK-Pang DMX Shield, rev E + F so DMX pin is 2  */

// Include the Library
#include <DmxSimple.h>
#include <SoftwareSerial.h>

SoftwareSerial portOne(6,7);

// Pins for DMX Shield
int DMX_dir = 4;
// Status LED on shield
int LED2 = 8;  
int RELAY = 7;

void setup() {
  // Set up all the DMX things!
  pinMode(DMX_dir, OUTPUT);
  pinMode(LED2, OUTPUT);   
  pinMode(RELAY, OUTPUT); 
  digitalWrite(DMX_dir, HIGH);  // Set direction pin of trasnsceiver to Tx.
  DmxSimple.usePin(2);
  
  // Serial bits
  Serial.begin(9600);
  portOne.begin(9600);
  Serial.println("RoomControl DMX Ready!");
  
  
}

// Counters for DMX operation
int value = 0;
int channel;
int wait = 3;

// Nine elements long, as we use index 1 to 8.
// 1 is the first element as it needs to hold something
int store[] = {1,0,0,0,0,0,0,0,0};

// Function to output value to channel over DMX
// Fading from previous value
void setChannel(int channel, int value) {
  
  // Debug
  Serial.print("Channel: ");
  Serial.println(channel);
  
  if (channel == 500) {
        if (value == 0)
          digitalWrite(RELAY, LOW);
        else
          digitalWrite(RELAY, HIGH);
  } else {

  
  // Put the old channel value from the store
  int oldValue = store[channel];
  
  // Debug
  Serial.print("Old Value:");
  Serial.println(oldValue);
  Serial.print("New Value:");
  Serial.println(value);
  
  // We're fading to a value smaller than the previous one
  if (oldValue > value) {
    // Debug
    Serial.print(oldValue);
    Serial.print(" > ");
    Serial.println(value);
    
    // Turn on the status LED
    digitalWrite(LED2, HIGH);
    
    // For loop between old value and new value
    for (int x = oldValue; x > value; x--) {
      // Debug
      Serial.println(x);
      
      // Output the value over DMX
      DmxSimple.write(channel, x);
      
      // Wait for a slower fade
      delay(wait);
    }
    
    // Turn off the status LED
    digitalWrite(LED2, LOW);
    
    // Store the new value for the next time it is changed
    store[channel] = value;
  }
  // We're fading to a value larger than the previous one
  else if (oldValue < value) {
    // Debug
    Serial.print(oldValue);
    Serial.print(" < ");
    Serial.println(value);
    
    // Turn on the status LED
    digitalWrite(LED2, HIGH);
    
    // For loop between old value and new value
    for (int x = oldValue; x < value; x++) {
      // Debug
      Serial.println(x);
      
      // Output the value over DMX
      DmxSimple.write(channel, x);
      
      // Wait for a slower fade
      delay(wait);
    }
    
    // Turn off the status LED
    digitalWrite(LED2, LOW);
    
    // Store the new value for the next time it is changed
    store[channel] = value;
    
  }
}
}

void loop() {
  int c;

  // Wait for new bits via serial
  while(!Serial.available());
  
  // Read char into c
  c = Serial.read();
  
  // Is the character numeric?
  if ((c>='0') && (c<='9')) {
    // Store that as the value
    value = 10*value + c - '0';
  } else {
    // If the next char is c, store the value as the channel
    if (c=='c') channel = value;
    else if (c=='w') {
      // The char is a w, meaning we're selecting an intensity
      // Fire off the function to change the value of the channel
      setChannel(channel, value);
    }
    
    // Reset the value for the next time around
    value = 0;
  }
}
