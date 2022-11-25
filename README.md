# phone_mqtt
An application that allows you to share your location.
The application assumes the creation of a device tracking system (phone, gps).


<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/assets/background.png" width="300">


<h3 align="left">Languages and Tools:</h3>
<p align="left">
  <a href="https://firebase.google.com/" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/firebase/firebase-icon.svg" alt="firebase" width="40" height="40"/> </a> 
  <a href="https://flutter.dev" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/flutterio/flutterio-icon.svg" alt="flutter" width="40" height="40"/> </a> 
  <a href="https://cloud.google.com" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/google_cloud/google_cloud-icon.svg" alt="gcp" width="40" height="40"/> </a> 
  <a href="https://www.sqlite.org/" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/sqlite/sqlite-icon.svg" alt="sqlite" width="40" height="40"/> </a> </p>
  
  
<h3 align="left">Screenshoots:</h3>
Login page:
<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/Images/localization_login.jpg" width="300">
Home screen:
<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/Images/localization_main_screen.jpg" width="300">
Map(Recive data from MQTT broker and then by google maps plugin put marker on the map and camera track marker): 
<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/Images/localization_map.jpg" width="300">
Provider (take gps position(when device change position and send data to MQTT broker)
<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/Images/localization_provider.jpg" width="300">
GPS setup (GPS module, Sim module, ESP32 module, powermodule + battery), thats device will be send localization data to the broker by GPRS) Maybe receive some command in the future
<img src="https://github.com/KrzysztofSwierkowski/phone_mqtt/blob/master/Images/2022_11_25_0575.JPG" width="300">



