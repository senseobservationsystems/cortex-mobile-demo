cortex-mobile-demo
==================

Android and iOS demo applications of cortex. The goal is to provide useful code snippets that you can use in your own application.

## Cortex
 
The cortex demo can only be used in combination with the [sense-android-library](https://github.com/senseobservationsystems/sense-android-library) or [sense-ios-library](https://github.com/senseobservationsystems/sense-ios-library) repositories.
It also requires additional native libraries which you need to place in the /libs folder for Android.
Please contact pim@ or ted@ sense-os.nl to obtain the libraries.

An installable demo application can be found in the bin/ folder. This demo application is for testing purposes only.  
Your data will be logged to common.sense-os.nl and can be viewed as _user_ cortex with password _demo_.

### Functionality

Currently Cortex contains the following functionalities:  

__Location based__:

* Geo-Fencing ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_geo_fence_sensor.html), iOS)  
_Location based notifications when leaving or entering an area_
* Position noise filter ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_filtered_position_sensor.html), iOS)  
_Removes bogus GPS data coming from GSM/WIFI_
* Distance measure between GPS points ([Native](http://senseobservationsystems.github.io/aim/native/html/class_position_distance_measure.html))  
_Calculates the distance in meters between GPS points_
* Top Locations ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_top_locations_sensor.html), ios)  
_Ranking of the most visited locations_

__Activity based__:

* Physical Activity recognition ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_physical_activity_sensor.html), iOS)  
_Recognizes the activity of the user: walking, running, cycling, idle_
* Human fall detector ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_fall_sensor.html), iOS)  
_Detects a fall consisting of 4 stages: free fall, impact, orientation change, and inactivity_
* Step Counter ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_step_count_sensor.html), ios)  
_Calculates amount of steps of the user_  
* Sleep Time ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_sleep_time_sensor.html), ios)  
_Measures the time a user goes to sleep and wakes up, and calculates the effective amount of sleep hours_  
* Sit / Stand Activity ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_sit_stand_sensor.html), ios)  
_Determines whether a user is most likely sitting or standing (works best in combination with Carry Device)_  
* Time Active ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_time_active_sensor.html), ios)  
_Registers how much time a user has been physically active_  

__Presence based__:

* Carry device: on body, in hand ([Android](http://senseobservationsystems.github.io/aim/android/html/classnl_1_1sense__os_1_1cortex_1_1_carry_device_sensor.html), iOS)  
_Recognizes if the device is with the user and whether it is being operated or is in a pocket_

