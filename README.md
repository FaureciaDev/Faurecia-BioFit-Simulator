Faurecia-BioFit-Simulator
=========================

Turn your Mac into a Bluetooth LE peripheral that simulate Faurecia's BioFit hardware. This app is designed for developers who want to develop iOS and Android apps that integrate with the BioFit hardware.

This app requires OS X 10.9 running on a Mac that supports Bluetooth LE 4.0. All 2013+ Macbooks should work; no 2010 and earlier models will. For 2011 and 2012 hardware, it will work if System Information reports Bluetooth "LMP Version" is 0x06. See http://www.imore.com/how-tell-if-your-mac-has-bluetooth-40 for details.  Bluetooth also needs to be [turned on](http://support.apple.com/kb/ht1153) for the simulator to function.

Getting Started
===============

* clone this repo to your Mac
* open the *workspace* in Xcode: `open Faurecia\ BioFit\ Simulator.xcworkspace`
* run!

We use Kiwi for testing, but this repo bundles CocoaPods and Kiwi in case you aren't familiar with it.

The BioFit hardware doesn't advertise all the time; it is triggered by an occupant. When you first start the simulator, a window will appear showing the current state of the simulation. It will not advertise as a Bluetooth peripheral until you press the Sit Down button. Once that happens, the simulator starts advertising as a BioFit-01 peripheral and you can connect to it from an iOS or Android device. While the simulator (BioFit peripheral) is connected to a phone, it will not break the connection if the occupant gets out of the seat. Occupant status only affects advertising.

Bluetooth support on iOS is very good: iPhones 4S and newer and iPods 5th gen and newer will work with the simulator. Android support is generally good on newer phones running Android 4.4 and higher, but obviously varies by manufacturer.
