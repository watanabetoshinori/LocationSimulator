# Location Simulator

Location Simulator is macOS app which allows you to spoofing a location on iOS device.

This app using [idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation) library for spoofing a location on device.


## Features

- [x] Spoofing iOS device location without jailbrake or app install.
- [x] Easy to set device location from the map.
- [x] Supported 3 movement speeds (Walk/Cycle/Car).

### Preview

<img src="https://raw.githubusercontent.com/watanabetoshinori/LocationSimulator/master/Preview/1.png" width="365" height="315">


## How to Build

### Requirements

- macOS 10.13+
- Xcode 9.0+
- Swift 4.0+

### Build the app

1. Install latest version of [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) by [homebrew](https://brew.sh):

	```bash
	$brew install libimobiledevice --HEAD
	```

2. Install [idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation) from source code.
3. Open project with Xcode.
4. Tap Run to execute the app.


## Usage

- Start spoofing

  1. Connect the iOS device to your computer.
  2. Long tap the point you want to set as the current location on the map.

- Moving

  - Tap walk button at bottom left of map. Drag the blue triangle to change the direction of movement.
  	<br><img src="https://raw.githubusercontent.com/watanabetoshinori/LocationSimulator/master/Preview/walk.png" width="60" height="60">
  - Long tap walk button to enabled auto move. Tap again to disable auto move.
  	<br><img src="https://raw.githubusercontent.com/watanabetoshinori/LocationSimulator/master/Preview/automove.png" width="60" height="60">

- Stop spoofing

  - Tap Reset button.


## Acknowledgements

Location Simulator uses the following libraries:

- [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) for talk protocols for iOS deivce.
- [idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation) for simulate a location on iOS device.
