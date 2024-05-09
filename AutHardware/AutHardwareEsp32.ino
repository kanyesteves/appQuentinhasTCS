#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>

#define SERVICE_UUID        "6f692fbe-0858-4747-89fb-6c3fe7a6681f"
#define CHARACTERISTIC_UUID "428c918a-53ab-4eef-827d-74a0d4b6d267"

Servo meuServo;

const int pinoServo = 26;

// Definindo as constantes
const std::string START = "start";
const std::string STOP = "stop";
const std::string IN_USE = "in-use";
const std::string WAIT = "wait";
const std::string AVAILABLE = "available";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool processInProgress = false;

class MyServerCallbacks : public BLEServerCallbacks {
private:
    Servo* pMeuServo;

public:
    MyServerCallbacks(Servo* servo) : pMeuServo(servo) {}

    void onConnect(BLEServer* pServer) override {
        if (pMeuServo) {
            pMeuServo->write(50);
            delay(200);
            pMeuServo->write(0);
        }
    }

    void onDisconnect(BLEServer* pServer) override {
      BLEAdvertising *pAdvertising = pServer->getAdvertising();
      pAdvertising->start();
    }
};

class MyCharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) override {
        std::string value = pCharacteristic->getValue();

        if (value == START) {
            handleStartCommand();
        } else if (value == STOP) {
            handleStopCommand();
        }
    }

    void handleStartCommand() {
        if (!processInProgress) {
            processInProgress = true;
            pCharacteristic->setValue(IN_USE);
            meuServo.write(50);
            delay(200);
            meuServo.write(0);
        } else {
            pCharacteristic->setValue(WAIT);
        }
    }

    void handleStopCommand() {
        if (processInProgress) {
            processInProgress = false;
            pCharacteristic->setValue(AVAILABLE);
        }
    }
};

void setup() {
    Serial.begin(115200);
    meuServo.attach(pinoServo);
    BLEDevice::init("ESP32 LUCAS TCS");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks(&meuServo));
    BLEService *pService = pServer->createService(SERVICE_UUID);

    pCharacteristic = pService->createCharacteristic(
                        CHARACTERISTIC_UUID,
                        BLECharacteristic::PROPERTY_READ |
                        BLECharacteristic::PROPERTY_WRITE |
                        BLECharacteristic::PROPERTY_NOTIFY
                    );
    
    pCharacteristic->addDescriptor(new BLE2902());
    pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());
    pCharacteristic->setValue(AVAILABLE);

    pService->start();
    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();
}

void loop() {
    delay(1000);
}
