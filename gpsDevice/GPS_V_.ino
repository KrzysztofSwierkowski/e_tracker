//////////TEST///////////
#include "esp_bt_main.h"
#include "esp_bt_device.h"
///////////Threads Handler//////////////
// #include <atomic>
// TaskHandle_t ELM327_task;
// TaskHandle_t GPS_task;
// TaskHandle_t Mqtt_task;

//std::atomic<short> rpm{ 0 };
///////////////////////
//storing data liblary by preferences 

#include <Preferences.h>
Preferences preferences;

//////////////////////


#define SIM800L_IP5306_VERSION_20190610
#include "utilities.h"


//ELM327
////////////////////////////////////////////////////
//ELM327 liblary
#include "ELMduino.h"

//variable for ELM327:
float odometer = -1;
float rpm = 0;
float mph = 0;
uint16_t freezeDTC;

unsigned long startMillis;  //some global variables available anywhere in the program
unsigned long currentMillis;
const unsigned long period = 600000;  //the value is a number of milliseconds

typedef enum { ENG_RPM,
               SPEED,freezeDTCs } obd_pid_states;
obd_pid_states obd_state = ENG_RPM;


enum bluetoothConnectionStates {
  connneting,
  connectedState,
  disconnected,
};

enum bluetoothConnectionStates elm327State;


//Bluetooth lib
#include <BluetoothSerial.h>

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#if !defined(CONFIG_BT_SPP_ENABLED)
#error Serial Bluetooth not available or not enabled. It is only available for the ESP32 chip.
#endif

BluetoothSerial SerialBT;


#define BT_DISCOVER_TIME 10000


static bool btScanAsync = true;
static bool btScanSync = true;


#define ELM_PORT SerialBT
#define DEBUG_PORT Serial
ELM327 myELM327;
////////////////////////////////////////////////////
//Flag for handle funtions
int bluetoothPowerON = -1;
int gpsPowerOn = -1;
int obdIIPowerOn = -1;
int accelerometerPowerOn = -1;



//////////////////////////////////////////////////
#define TINY_GSM_MODEM_SIM800
#include <TinyGPS++.h>

//Accelerometer:

#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

Adafruit_MPU6050 mpu;  //22 scl, 21 SDA

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
#define uS_TO_S_FACTOR 1000000ULL /* Conversion factor for micro seconds to seconds */
#define TIME_TO_SLEEP 60          /* Time ESP32 will go to sleep (in seconds) */
TinyGPSPlus gps;

// GPS VARIABLES
//------------------------------------------------------------------------------------

double latitude = 0.00;
double longitude = 0.00;
int countChangesBelowInMeters = 0;
int changesMoreThanSleepLimit = 0;
double speed = 0.00;
double altitude = 0.00;
double altitudeOld = 0.00;
const char* idGPS = "001";
bool locationIsValid = true;


//battery monitor value init:
//const int BatteryPin = 34;
int adc_read = 0;
float battery_voltage = 0;

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
const char* broker = "rsttpl.ddns.net";

char* topicSpeed = "gpsDevice/001/speed";  
char* topicAltitude = "gpsDevice/001/altitude";
char* topicLongLat = "gpsDevice/001/longLat";
char* topicInit = "gpsDevice/001/state";
char* topicBluetoothPowerOn = "gpsDevice/001/BluetoothOn";
char* topicObdIIPowerOn = "gpsDevice/001/obdIIOn";
char* topicGpsPowerOn = "gpsDevice/001/GpsOn";
char* topicaccelerometerPowerOn = "gpsDevice/001/accelerometerOn";
char* topicMotionTrigger = "gpsDevice/001/MotionTrigger";
char* topicMotion = "gpsDevice/001/Motion";

const char* topic = "obdPower";

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

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);

  Serial.print("Message:");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }

  Serial.println();
  Serial.println("-----------------------");
  if (topic == topicGpsPowerOn) {
    int recv_payload = *(int*)payload;
    gpsPowerOn = recv_payload;
  }
}

boolean mqttConnect() {
  SerialMon.print("Connecting to ");
  SerialMon.print(broker);

  // Or, if you want to authenticate MQTT:
  boolean status = mqtt.connect("gps001", "rstt", "3333");

  if (status == false) {
    SerialMon.println(" fail");
    return false;
  }
  SerialMon.println(" - success");
  mqtt.publish(topicInit, "GsmClientTest started");
  return mqtt.connected();
}


void setup() {
  // Set console baud rate
  SerialMon.begin(115200);
  delay(10);
  //pref init
  preferencesInit();
  // Sim800L initializer
  simInit();
  //MQTT Setup:
  mqttBrokerSetup();
  //Subscribe topic:
  subscribeInitTopic();
  //GPS Setup:
  gpsSetup();
  // elm327Setup();
//  elm327Setup();
  //accelerometr init:
  mpu6050Init();
  gyroTest();
  //
  delay(1000);
}
///////////////////////////////////////////////////////////////////////////////////////

//shared preferences initialize 
void preferencesInit(){
  preferences.begin("lastlocation", false);

}

// MQTT init:
void mqttBrokerSetup() {
  // MQTT Broker setup
  Serial.println("[SIM800L]: Initiating a mobile broadcast...");
  mqtt.setServer(broker, 1883);
  mqtt.setCallback(mqttCallback);
}

void subscribeInitTopic() {
  mqtt.subscribe(topicBluetoothPowerOn);
  mqtt.subscribe(topicObdIIPowerOn);
  mqtt.subscribe(topicGpsPowerOn);
  mqtt.subscribe(topicaccelerometerPowerOn);
}


//GPS Setup:
void gpsSetup() {
  GPS.begin(9600, SERIAL_8N1, RXD2, TXD2);
  Serial.println("[GPS]: Serial initialize");
}

//MPU6050 Initialize
void mpu6050Init() {
  // Try to initialize!
  Serial.println("[MPU6050]: Serial Initiating...");
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
  }
  Serial.println("MPU6050 Found!");

  // set accelerometer range to +-8G
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);

  // set gyro range to +- 500 deg/s
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);

  // set filter bandwidth to 21 Hz
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  //threadsCreator();
  motionDetectionByMPU6050Gyro();

  Serial.println("End of [MPU6050] initializing! all ok !");
}

// Modem Sim800L initialize:

void simInit() {
  Serial.println("[SIM800L]: Initiating a mobile broadcast...");
  setupModem();
  SerialMon.println("Wait...");

  // Set GSM module baud rate and UART pins
  Serialatitude.begin(115200, SERIAL_8N1, MODEM_RX, MODEM_TX);

  delay(6000);

  // Restart takes quite some time
  // To skip it, call init() instead of restart()
  SerialMon.println("Initializing modem...");
  //modem.restart();
  modem.init();

  String modemInfo = modem.getModemInfo();
  SerialMon.print("Modem Info: ");
  SerialMon.println(modemInfo);

#if TINY_GSM_USE_GPRS
  // Unlock your SIM card with a PIN if needed
  if (GSM_PIN && modem.getSimStatus() != 3) {
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
}



//EL327 Initialize (SETUP)

void elm327Setup() {
  Serial.println("[OBD2]: Bluetooth Initiating...");
  String name = "Android-Vlink";
  DEBUG_PORT.begin(115200);
  SerialBT.setPin("1234");
  ELM_PORT.begin("E-Tracker", true);
  elm327State = connneting;
  bool connected;
  connected = SerialBT.connect(name);
  if (!ELM_PORT.connect(name)) {  //nazwa urzadzenia
    DEBUG_PORT.println("Couldn't connect to OBD scanner - Phase 1");
  }

  if (!myELM327.begin(ELM_PORT, true, 2000)) {
    Serial.println("Couldn't connect to OBD scanner - Phase 2");
    elm327State = disconnected;
    if (mqtt.connected()) {

      // Serial.println("********** Publish speed by MQTT");
      // char mqtt_payload[60] = "";
      // snprintf(mqtt_payload, 50, "Nie połączono z OBDII");
      // Serial.print("Publish message: ");
      // Serial.println(mqtt_payload);
      // mqtt.publish("gpsDevice/001/rpm", mqtt_payload);
      // Serial.println("> MQTT data published");
      // Serial.println("********** End ");
      // Serial.println("*****************************************************");
    }
    return;
  }
  elm327State = connectedState;
  Serial.println("Connected to ELM327");
}



/////////////////////Threads init//////////////////////////

// void threadsCreator() {
//   // Do blocking OBD call on one core
//   xTaskCreatePinnedToCore(
//     get_ELM327_task,  // Task function.
//     "Task1",          // Name of task.
//     10000,            // Stack size of task
//     NULL,             // Parameter of the task
//     0,                // Priority of the task
//     &ELM327_task,     // Task handle to keep track of created task
//     0);               // Pin task to core 0

//   // Do timing specific work on another core
//   xTaskCreatePinnedToCore(
//     gps_handler_task,  // Task function.
//     "Task2",           // Name of task.
//     10000,             // Stack size of task
//     NULL,              // Parameter of the task
//     0,                 // Priority of the task
//     &GPS_task,         // Task handle to keep track of created task
//     1);                // Pin task to core 1
// }

// void gps_handler_task(void* parameters) {
//   Serial.print("GPS_task running on core ");
//   Serial.println(xPortGetCoreID());
//   for (;;) {
//     mqttReconnect();
//     //batteryMonitor();
//     sendGyro();
//     searchGPS(1000);
//     checkGps();
//     sendLocation();
//     sendAltitude();
//     sendSpeed();
//     //delay(3000);
//     mqtt.loop();
//     mqtt.setCallback(mqttCallback);
//     delay(1);
//   }
// }
// void get_ELM327_task(void* parameters) {
//   String name = "Android-Vlink";
//   bool connected;
//   connected = SerialBT.connect(name);
//   Serial.print("ELM327_task running on core ");
//   Serial.println(xPortGetCoreID());
//   if (connected) {
//     for (;;) {
//       mqttReconnect();
//      // odometerDistance();
//       //elm327LoopTest();
//       mqtt.loop();
//       delay(1);
//     }
//   } else {
//     while (!SerialBT.connected(5000)) {
//       Serial.println("Failed to connect. Make sure remote device is available and in range, then restart app.");
//     }
//   }
// }
//////////////////////////////////////////////

static void searchGPS(unsigned long ms) {

  unsigned long start = millis();

  do {

    while (GPS.available() > 0) {
      gps.encode(GPS.read());

      if (gps.location.isValid()) {

        locationIsValid = true;

        latitude = gps.location.lat();
        longitude = gps.location.lng();
        speed = gps.speed.kmph();
      } else {
        speed = 0.00;
        locationIsValid = false;
      }
    }

  } while (millis() - start < ms);
}


void loop() {
  //vTaskDelete(NULL);
    mqttReconnect();
    //batteryMonitor();
    sendGyro();
    searchGPS(1000);
    checkGps();
    sendLocation();
    sendAltitude();
    sendSpeed();
    mqtt.loop();
    mqtt.setCallback(mqttCallback);
}

void gyroTest() {

  if (mpu.getMotionInterruptStatus()) {
    /* Get new sensor events with the readings */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    /* Print out the values */
    Serial.print("Acceleration X: ");
    Serial.print(a.acceleration.x);
    Serial.print(", Y: ");
    Serial.print(a.acceleration.y);
    Serial.print(", Z: ");
    Serial.print(a.acceleration.z);
    Serial.println(" m/s^2");

    Serial.print("Rotation X: ");
    Serial.print(g.gyro.x);
    Serial.print(", Y: ");
    Serial.print(g.gyro.y);
    Serial.print(", Z: ");
    Serial.print(g.gyro.z);
    Serial.println(" rad/s");

    Serial.print("Temperature: ");
    Serial.print(temp.temperature);
    Serial.println(" degC");

    Serial.println("");
    delay(500);
  }
}


void mqttReconnect() {
  if (!mqtt.connected()) {
    SerialMon.println("=== MQTT NOT CONNECTED ===");
    // Reconnect every 10 seconds
    uint32_t t = millis();
    if (t - lastReconnectAttempt > 10000L) {
      lastReconnectAttempt = t;
      if (mqttConnect()) {
        lastReconnectAttempt = 0;
        mqtt.subscribe(topic);
        mqtt.subscribe("gpsDevice/001/a.acceleration.z");
      }
    }
    delay(100);
    return;
  }
}

void odometerDistance() {

  if (myELM327.queryPID(01, 166))  //PID KM distance

  {
    int32_t kmDistanceOdometer = myELM327.findResponse();

    if (myELM327.nb_rx_state == ELM_SUCCESS) {
      odometer = kmDistanceOdometer;
      Serial.print("Odometer Km: ");
      Serial.println(odometer);
    } else if (myELM327.nb_rx_state != ELM_GETTING_MSG) {
      myELM327.printError();
    }
  }
}

void elm327LoopTest() {

  if (!mqtt.connected()) {
    mqttReconnect();
  }
  currentMillis = millis();
  if (currentMillis - startMillis >= period)  //test whether the period has elapsed
  {
    if (elm327State = disconnected) {
      elm327Setup();
    }
    startMillis = currentMillis;  //IMPORTANT to save the start time of the current LED state.
  }

  /////////////////////////////

  switch (obd_state) {
    case ENG_RPM:
      {
        rpm = myELM327.rpm();

        if (myELM327.nb_rx_state == ELM_SUCCESS) {
          Serial.print("rpm: ");
          Serial.println(rpm);

          ////////MQTT:
                Serial.println("********** Publish speed by MQTT");
      char mqtt_payload[60] = "";
      snprintf(mqtt_payload, 50, "%f", rpm);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish("gpsDevice/001/rpm", mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");

      ///////////////////////////
          obd_state = SPEED;
        } else if (myELM327.nb_rx_state != ELM_GETTING_MSG) {
          myELM327.printError();
          obd_state = SPEED;
        }

        break;
      }

    case SPEED:
      {
        mph = myELM327.mph();

        if (myELM327.nb_rx_state == ELM_SUCCESS) {
          Serial.print("mph: ");
          Serial.println(mph);
          obd_state = freezeDTCs;
        } else if (myELM327.nb_rx_state != ELM_GETTING_MSG) {
          myELM327.printError();
          obd_state = freezeDTCs;
        }

        break;
      }

    case freezeDTCs:
      {
        freezeDTC = myELM327.freezeDTC();

        if (myELM327.nb_rx_state == ELM_SUCCESS) {
          Serial.print("DTC: ");
          Serial.println(freezeDTC);

////////MQTT:
 // Serial.println("********** Publish speed by MQTT");
      Serial.println("********** Publish speed by MQTT");
      char mqtt_payload[600] = "";
      snprintf(mqtt_payload, 500, "%f", freezeDTC);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish("gpsDevice/001/dtc", mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");
      ////////////////////

          obd_state = ENG_RPM;
        } else if (myELM327.nb_rx_state != ELM_GETTING_MSG) {
          myELM327.printError();
          obd_state = ENG_RPM;
        }

        break;
      }



  }




  ///////////////////







  // rpm = myELM327.rpm();

  // if (myELM327.nb_rx_state == ELM_SUCCESS) {

  //   Serial.print("RPM: ");
  //   Serial.println(rpm);


  //   if (mqtt.connected()) {

  //     Serial.println("********** Publish speed by MQTT");
  //     char mqtt_payload[60] = "";
  //     snprintf(mqtt_payload, 50, "%f", rpm);
  //     Serial.print("Publish message: ");
  //     Serial.println(mqtt_payload);
  //     mqtt.publish("gpsDevice/001/rpm", mqtt_payload);
  //     Serial.println("> MQTT data published");
  //     Serial.println("********** End ");
  //     Serial.println("*****************************************************");
  //     delay(3000);
  //   }


  // } else if (myELM327.nb_rx_state != ELM_GETTING_MSG) {
  //   Serial.print("BŁĄD:");
  //   myELM327.printError();
  // }


  return;
}


// void batteryMonitor() {
//   adc_read = analogRead(BatteryPin);

//   //using R1 = 5k and R2 = .650k

//   battery_voltage = (adc_read * (6.065 / 4096) * (2.320)) / 0.430;
//   Serial.println("Batt:");
//   Serial.println(battery_voltage);
// }



void motionDetectionByMPU6050Gyro() {

  //setupt motion detection
  mpu.setHighPassFilter(MPU6050_HIGHPASS_0_63_HZ);
  mpu.setMotionDetectionThreshold(1);
  mpu.setMotionDetectionDuration(20);
  mpu.setInterruptPinLatch(true);  // Keep it latched.  Will turn off when reinitialized.
  mpu.setInterruptPinPolarity(true);
  mpu.setMotionInterrupt(true);
}

void checkChangeLocationAndSleep() {
  if (gps.location.isValid()) {
    float newlatitude = (gps.location.lat());
    float newlongitude = (gps.location.lng());
    float diffCordLat = newlatitude - latitude;
    float diffCordLon = newlongitude - longitude;
    // Serial.println(newlatitude, 8);
    // Serial.println(newlongitude, 8);

    // Serial.println(latitude, 8);
    // Serial.println(longitude, 8);

    // Serial.println(diffCordLat, 8);
    // Serial.println(diffCordLon, 8);


    float delLat = abs(latitude - newlatitude) * 6371;
    float delLong = 6371 * abs(longitude - newlongitude) * cos(radians((latitude - newlatitude) / 2));
    float distance = (sqrt(pow(delLat, 2) + pow(delLong, 2))) * 1000;  //distance in meters
    Serial.println(distance, 3);

    //Sleep flag reset :
    if (distance >= 10) {
      changesMoreThanSleepLimit++;
      Serial.println(changesMoreThanSleepLimit);
      if (changesMoreThanSleepLimit >= 3) {
        countChangesBelowInMeters = 0;
        changesMoreThanSleepLimit = 0;
      }
    }

    if (distance <= 10) {
      countChangesBelowInMeters++;
      Serial.println("how many is the same position");
      Serial.println(countChangesBelowInMeters);
      if (countChangesBelowInMeters >= 30) {
        esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
        esp_sleep_enable_ext0_wakeup(GPIO_NUM_15, 1);
        Serial.println("Start sleep...");
         Set IO25 to sleep hold, so that when ESP32 sleeps, SIM800X will keep power and running
        gpio_hold_en(GPIO_NUM_25);  //MODEM_POWER_ON
                                    //       esp_deep_sleep_start();
        countChangesBelowInMeters = 0;
      }
    }
  }
}

void sendLocation() {


  if (mqtt.connected()) {
    ledStatus = !ledStatus;
    digitalWrite(LED_GPIO, ledStatus);
    //mqtt.publish(topicLongLat, ledStatus ? "1" : "0");

    if (gps.location.isValid()) {
      double latitude = (gps.location.lat());
      double longitude = (gps.location.lng());
      preferences.putDouble("latitude", gps.location.lat());
      preferences.putDouble("longitude", gps.location.lng());

      Serial.println("********** Publish location data to Server");
      char mqtt_payload[60] = "";
      snprintf(mqtt_payload, 60, "{\"latitude\":%lf,\"longitude\":%lf,\"idGPS\":\"%s\"}", latitude, longitude, idGPS);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicLongLat, mqtt_payload);
      Serial.println("*****************************************************");


    } else {
      Serial.println(F("NO GPS SIGNAL"));
    }
  }
}


void sendSpeed() {
  if (gps.location.isValid()) {
    double speed = (gps.speed.kmph());
    if (speed > 0) {
      Serial.println("********** Publish speed by MQTT");
      char mqtt_payload[50] = "";
      snprintf(mqtt_payload, 50, "%0.2lf", speed);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicSpeed, mqtt_payload);
      Serial.println("*****************************************************");
    }
  } else {
    Serial.println(F("NO GPS SIGNAL"));
  }
}


void sendAltitude() {
  if (gps.location.isValid()) {
    double altitude = (gps.altitude.meters());
    Serial.println(altitude);
    Serial.println("********** Publish altitude by MQTT");
    char mqtt_payload[50] = "";
    snprintf(mqtt_payload, 50, "%0.2lf", altitude);
    Serial.print("Publish message: ");
    Serial.println(mqtt_payload);
    mqtt.publish(topicAltitude, mqtt_payload);
    Serial.println("*****************************************************");

    //     }



  } else {

    double latitude = preferences.getDouble("latitude", 0);
    double longitude = preferences.getDouble("longitude", 0);
    
    Serial.println(F("NO GPS SIGNAL"));
    Serial.println("Last known location:");
     Serial.println("********** Publish location data to Server");
      char mqtt_payload[60] = "";
      snprintf(mqtt_payload, 60, "{\"latitude\":%lf,\"longitude\":%lf,\"idGPS\":\"%s\"}", latitude, longitude, idGPS);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicLongLat, mqtt_payload);
      Serial.println("*****************************************************");


    Serial.print("Satellites in view: ");
    Serial.print(gps.satellites.value());
  }
}

void checkGps() {
  checkChangeLocationAndSleep();
  // Debug: if we haven't seen lots of data in 5 seconds, something's wrong.
  if (millis() > 5000 && gps.charsProcessed() < 10)  // uh oh
  {
    Serial.println("ERROR: not getting any GPS data!");
    // dump the stream to Serial
    Serial.println("GPS stream dump:");
    //while (true) // infinite loop
    if (GPS.available() > 0)  // any data coming in?
      Serial.write(GPS.read());
  }
}

void sendGyro() {

  if (mqtt.connected()) {


    ledStatus = !ledStatus;
    digitalWrite(LED_GPIO, ledStatus);
    if (mpu.getMotionInterruptStatus()) {
      /* Get new sensor events with the readings */
      sensors_event_t a, g, temp;
      mpu.getEvent(&a, &g, &temp);

      char mqtt_payload[150] = "";

      snprintf(mqtt_payload, 50,"{\"1,\"idGPS\":\"%s\"}",idGPS);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicMotionTrigger, mqtt_payload);
      Serial.println("*****************************************************");

      snprintf(mqtt_payload, 150, "{\"acceleration.x\":%lf,\"acceleration.y\":%lf,\"acceleration.z\":%lf,\"idGPS\":\"%s\"}", a.acceleration.x, a.acceleration.y, a.acceleration.z,idGPS);
      Serial.print("Publish message: ");
      Serial.println(mqtt_payload);
      mqtt.publish(topicMotion, mqtt_payload);
      Serial.println("> MQTT data published");
      Serial.println("********** End ");
      Serial.println("*****************************************************");



    }
  }



}
