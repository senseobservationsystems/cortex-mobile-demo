cortex-mobile-demo
==================

Android and iOS demo applications of cortex. The goal is to provide useful code snippets that you can use in your own application.

## Cortex
 
The cortex demo can only be used in combination with the [sense-android-library](https://github.com/senseobservationsystems/sense-android-library) or [sense-ios-library](https://github.com/senseobservationsystems/sense-ios-library) repositories.
It also requires additional native libraries which you need to place in the /libs folder for Android.
Please contact steven@, pim@ or ted@ sense-os.nl to obtain the libraries.

An installable demo application can be found in the bin/ folder. This demo application is for testing purposes only.  
Your data will be logged to common.sense-os.nl and can be viewed as _user_ cortex with password _demo_.

### Functionality

Currently Cortex contains the following functionalities.

__Location based__:
* Geo-Fencing
* Position noise filter
* Distance measure between two positions

__Activity based__:
* Physical Activity classification
* Human fall detector

__Presence based__:
* Carry device: on body, in hand
