#define SIM800L_IP5306_VERSION_20190610
#include "utilities.h"

#define TINY_GSM_MODEM_SIM800
#include <TinyGPS++.h>


// Set serial for debug console (to the Serial Monitor, default speed 115200)
#define SerialMon Serial

// Set serial for AT commands (to the module)
// Use Hardware Serial on Mega, Leonardo, Micro
#define Serialatitude Serial1

// See all AT commands, if wanted
//#define DUMP_AT_COMMANDS

// Define the serial console for debug prints, if needed
#define TINY_GSM_DEBUG SerialMon

//------------------------------------------------------------------------------------
// RX TX GPS
//------------------------------------------------------------------------------------

#define RXD2 32
#define TXD2 33

//------------------------------------------------------------------------------------
// TINY GPS PLUS
//------------------------------------------------------------------------------------

#define GPS Serial2
#define uS_TO_S_FACTOR 1000000ULL  /* Conversion factor for micro seconds to seconds */
#define TIME_TO_SLEEP  15        /* Time ESP32 will go to sleep (in seconds) */
TinyGPSPlus gps;

// GPS VARIABLES
//------------------------------------------------------------------------------------

double latitude = 0.00;
double longitude = 0.00;
int countChangesBelow15meters = 0;
double speed = 0.00;
double altitude = 0.00;
double altitudeOld = 0.00;
const char* idGPS = "001";
bool locationIsValid = true;

// Add a reception delay - may be needed for a fast processor at a slow baud rate
// #define TINY_GSM_YIELD() { delay(2); }

// Define how you're planning to connect to the internet
#define TINY_GSM_USE_GPRS true
#define TINY_GSM_USE_WIFI false

// set GSM PIN, if any
#define GSM_PIN ""

// Your GPRS credentials, if any
const char apn[] = "internet";
const char gprsUser[] = "";
const char gprsPass[] = "";

// MQTT details
const char *broker = "178.43.120.9";

char* topicSpeed = "gpsDevice/001/speed";
char* topicAltitude = "gpsDevice/001/altitude";
char* topicLongLat = "gpsDevice/001/longLat";
char* topicInit = "gpsDevice/001/state";





//const char *topicGps = "test";

#include <TinyGsmClient.h>
#include <PubSubClient.h>

#ifdef DUMP_AT_COMMANDS
#include <StreamDebugger.h>
StreamDebugger debugger(Serialatitude, SerialMon);
TinyGsm modem(debugger);
#else
TinyGsm modem(Serialatitude);
#endif
TinyGsmClient client(modem);
PubSubClient mqtt(client);

int ledStatus = LOW;

uint32_t lastReconnectAttempt = 0;



//void mqttCallback(char *topic, byte *payload, unsigned int len)

void mqttCallback(char *topic, byte *payload, unsigned int len)
{
  SerialMon.print("Message arrived [");
  SerialMon.print(topic);
  SerialMon.print("]: ");
  SerialMon.write(payload, len);
  SerialMon.println();

  SerialMon.print(topicSpeed);
  SerialMon.print(topicAltitude);
  SerialMon.print(topicLongLat);
  SerialMon.print(topicInit);

  // Only proceed if incoming message's topic matches
  if (mqtt.connected()) {
    ledStatus = !ledStatus;
    digitalWrite(LED_GPIO, ledStatus);
    //mqtt.publish(topicLongLat, ledStatus ? "1" : "0");

    if (gps.location.isValid()) {
      double latitude = (gps.location.lat());
      double longitude = (gps.location.lng());


      Serial.println("********** Publish MQTT data to TENTEGO");
      char mqtt_payload[50] = "";
      // {\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()}}
      snprintf (mqtt_payload, 50, "{\"latitude\":%lf,\"longitude\":%lf}", latitude, longitude);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicLongLat, mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");

      delay(3000);// delay
    } else {
      Serial.println(F("INVALID"));
    }
  }
}

boolean mqttConnect()
{
  SerialMon.print("Connecting to ");
  SerialMon.print(broker);

  // Connect to MQTT Broker
  //boolean status = mqtt.connect("GsmClientTest");

  // Or, if you want to authenticate MQTT:
  boolean status = mqtt.connect("test", "rstt", "3333");

  if (status == false) {
    SerialMon.println(" fail");
    return false;
  }
  SerialMon.println(" success");
  mqtt.publish(topicInit, "GsmClientTest started");
  //mqtt.subscribe(topicLed);
  return mqtt.connected();
}


void setup()
{
  // Set console baud rate
  SerialMon.begin(115200);

  delay(10);

  setupModem();

  SerialMon.println("Wait...");

  // Set GSM module baud rate and UART pins
  Serialatitude.begin(115200, SERIAL_8N1, MODEM_RX, MODEM_TX);

  delay(6000);

  // Restart takes quite some time
  // To skip it, call init() instead of restart()
  SerialMon.println("Initializing modem...");
  modem.restart();
  // modem.init();

  String modemInfo = modem.getModemInfo();
  SerialMon.print("Modem Info: ");
  SerialMon.println(modemInfo);

#if TINY_GSM_USE_GPRS
  // Unlock your SIM card with a PIN if needed
  if ( GSM_PIN && modem.getSimStatus() != 3 ) {
    modem.simUnlock(GSM_PIN);
  }
#endif

  SerialMon.print("Waiting for network...");
  if (!modem.waitForNetwork()) {
    SerialMon.println(" fail");
    delay(10000);
    return;
  }
  SerialMon.println(" success");

  if (modem.isNetworkConnected()) {
    SerialMon.println("Network connected");
  }

  // GPRS connection parameters are usually set after network registration
  SerialMon.print(F("Connecting to "));
  SerialMon.print(apn);
  if (!modem.gprsConnect(apn, gprsUser, gprsPass)) {
    SerialMon.println(" fail");
    delay(10000);
    return;
  }
  SerialMon.println(" success");

  if (modem.isGprsConnected()) {
    SerialMon.println("GPRS connected");
  }

  // MQTT Broker setup
  mqtt.setServer(broker, 1883);
  mqtt.setCallback(mqttCallback);


  GPS.begin(9600, SERIAL_8N1, RXD2, TXD2);
  Serial.println("[GPS]: Serial initialize");


}


static void searchGPS(unsigned long ms)
{

  unsigned long start = millis();

  do
  {

    while (GPS.available() > 0)
    {
      gps.encode(GPS.read());

      if (gps.location.isValid())
      {

        locationIsValid = true;

        latitude = gps.location.lat();
        longitude = gps.location.lng();
        speed = gps.speed.kmph();
      }
      else
      {
        speed = 0.00;
        locationIsValid = false;
      }

    }

  } while (millis() - start < ms);
}


void loop()
{

  if (!mqtt.connected()) {
    SerialMon.println("=== MQTT NOT CONNECTED ===");
    // Reconnect every 10 seconds
    uint32_t t = millis();
    if (t - lastReconnectAttempt > 10000L) {
      lastReconnectAttempt = t;
      if (mqttConnect()) {
        lastReconnectAttempt = 0;
      }
    }
    delay(100);
    return;
  }
  searchGPS(1000);
  SerialMon.println("loop");
  checkGps();
  sendLocation();
  sendAltitude();
  sendSpeed();
  delay(3000);
  mqtt.loop();
  //  SerialMon.print(topic);
}


void checkChangeLocationAndSleep() {
  if (gps.location.isValid()) {
    float newlatitude = (gps.location.lat());
    float newlongitude = (gps.location.lng());
    float diffCordLat = newlatitude - latitude;
    float diffCordLon = newlongitude - longitude;
    Serial.println(newlatitude,8);
    Serial.println(newlongitude,8);

    Serial.println(latitude,8);
    Serial.println(longitude,8);

    Serial.println(diffCordLat,8);
    Serial.println(diffCordLon,8);


float delLat = abs(latitude-newlatitude)*111194.9;
float delLong = 111194.9*abs(longitude-newlongitude)*cos(radians((latitude-newlatitude)/2));
float distance = sqrt(pow(delLat,2)+pow(delLong,2));
Serial.println(distance,3);




    
    if (diffCordLat >= 0.000174 ||  diffCordLon >= 0.000174) { //0.000174 - 20m
      countChangesBelow15meters ++;
      Serial.println("how many is the same position");
      Serial.println(countChangesBelow15meters);
      if (countChangesBelow15meters >= 10) {
        esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
        Serial.println("Start sleep...");
        esp_deep_sleep_start();
        countChangesBelow15meters = 0;
      }
    }

  }
}


//double calculateDistance(lat1, lon1, lat2, lon2){
//  var p = 0.017453292519943295;
//  var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
//        cos(lat1 * p) * cos(lat2 * p) * 
//        (1 - cos((lon2 - lon1) * p))/2;
//  return 12742 * asin(sqrt(a));
//}







void sendLocation()
{


  if (mqtt.connected()) {
    ledStatus = !ledStatus;
    digitalWrite(LED_GPIO, ledStatus);
    //mqtt.publish(topicLongLat, ledStatus ? "1" : "0");

    if (gps.location.isValid()) {
      double latitude = (gps.location.lat());
      double longitude = (gps.location.lng());


      Serial.println("********** Publish location data to Server");
      char mqtt_payload[60] = "";
      // {\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()}}
      snprintf(mqtt_payload, 60, "{\"latitude\":%lf,\"longitude\":%lf,\"idGPS\":\"%s\"}", latitude, longitude, idGPS);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicLongLat, mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");


    } else {
      Serial.println(F("NO GPS SIGNAL"));
    }
  }
}


void sendSpeed()
{
  if (gps.location.isValid()) {
    double speed = (gps.speed.kmph());
    if (speed > 0)
    {
      Serial.println("********** Publish speed by MQTT");
      char mqtt_payload[50] = "";
      snprintf (mqtt_payload, 50, "%0.2lf", speed);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicSpeed, mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");

    }
  } else {
    Serial.println(F("NO GPS SIGNAL"));
  }



}


void sendAltitude()
{
  if (gps.location.isValid()) {
    double altitude = (gps.altitude.meters());
    Serial.println(altitude);
    //      if (altitude =! altitudeOld)
    //      {
    //       double altitudeOld = altitude;
    Serial.println("********** Publish altitude by MQTT");
    char mqtt_payload[50] = "";
    snprintf (mqtt_payload, 50, "%0.2lf", altitude);
    Serial.print("Publish message: ");
    Serial.println(mqtt_payload);
    mqtt.publish(topicAltitude, mqtt_payload);
    Serial.println("> MQTT data published");
    Serial.println("********** End ");
    Serial.println("*****************************************************");

    //     }



  } else {
    Serial.println(F("NO GPS SIGNAL"));
    Serial.print("Satellites in view: ");
    Serial.print(gps.satellites.value());
  }



}

void checkGps() {
  checkChangeLocationAndSleep();
  // Debug: if we haven't seen lots of data in 5 seconds, something's wrong.
  if (millis() > 5000 && gps.charsProcessed() < 10) // uh oh
  {
    Serial.println("ERROR: not getting any GPS data!");
    // dump the stream to Serial
    Serial.println("GPS stream dump:");
    while (true) // infinite loop
      if (GPS.available() > 0) // any data coming in?
        Serial.write(GPS.read());
  }

}
