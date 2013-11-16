RoomControl
===========

The first step in my home automation setup for my bedroom. Inspired by [this](http://www.youtube.com/watch?v=BW9FbjjkKo4).

Sinatra App
-----------

The first part of this project is a Sinatra app. It recieves web requests, reads presets, and then sends information over a serial connection to the Arduino at the other end.

It's fairly straightforward, and I've commented the source code for easier reading.

Arduino Sketch
--------------

The second part is an Arduino sketch. The Arduino it runs on has a [Sainsmart 4-Channel Relay](http://www.sainsmart.com/4-channel-5v-relay-module-for-pic-arm-avr-dsp-arduino-msp430-ttl-logic.html) attached to pin 7, and an [SK Pang DMX Shield](http://www.skpang.co.uk/catalog/arduino-dmx-shield-p-663.html) to control some DMX RGB Parcans that I have pointing upwards in the corners of my room.

The Arduino recieves messages over serial and then flips on or off a digital pin, or sends the DMX message to the DMX shield using the [DMX Simlpe](https://code.google.com/p/tinkerit/wiki/DmxSimple) library from Tinker.it.

iOS App
-------

Uncompleted, although basically functional, is an iOS app for iOS 7 that sends the necessary POST HTTP requests over the internet or LAN to the Mac Mini server with the Sinatra app on it for easy control. In the future I might experiment with iBeacons and a Raspberry Pi to get them to turn on and off by themselves. 
