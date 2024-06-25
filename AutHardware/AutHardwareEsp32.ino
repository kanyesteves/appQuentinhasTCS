#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID        "6f692fbe-0858-4747-89fb-6c3fe7a6681f"
#define CHARACTERISTIC_UUID "428c918a-53ab-4eef-827d-74a0d4b6d267"

#define BUZZER_PIN 25
#define FREQUENCY 1000
#define RELAY_PIN 26


const String START = "start";
const String STOP = "stop";
const String IN_USE = "in-use";
const String WAIT = "wait";
const String AVAILABLE = "available";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool processInProgress = false;

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) override {
        tone(BUZZER_PIN, FREQUENCY);
        delay(200);
        noTone(BUZZER_PIN);
        digitalWrite(RELAY_PIN, LOW); // Activate relay
        delay(2000);
        digitalWrite(RELAY_PIN, HIGH); // Deactivate relay
    }

    void onDisconnect(BLEServer* pServer) override {
        BLEAdvertising *pAdvertising = pServer->getAdvertising();
        pAdvertising->start();
        for(int i = 0; i < 3; i++) {
            tone(BUZZER_PIN, FREQUENCY);
            delay(200);
            noTone(BUZZER_PIN);
            delay(200);
        }
    }
};

class MyCharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) override {
        String value = pCharacteristic->getValue().c_str();

        if (value.startsWith(START)) {
            // Extrai o tempo do comando (após a palavra "start")
            String timeString = value.substring(START.length());
            int relayTime = timeString.toInt(); // Converte para inteiro

            handleStartCommand(relayTime);
        } else if (value == STOP) {
            handleStopCommand();
        }
    }

    void handleStartCommand(int relayTime) {
        if (!processInProgress) {
            processInProgress = true;
            pCharacteristic->setValue(IN_USE);
              for(int i = 0; i < 3; i++) {
              tone(BUZZER_PIN, FREQUENCY);
              delay(200);
              noTone(BUZZER_PIN);
              delay(200);
              }
            digitalWrite(RELAY_PIN, LOW); // Ativa o relé
            delay(relayTime); // Mantém o relé ligado pelo tempo especificado
            digitalWrite(RELAY_PIN, HIGH); // Desativa o relé
            pCharacteristic->setValue(AVAILABLE);
            processInProgress = false;
        } else {
            pCharacteristic->setValue(WAIT);
        }
    }

    void handleStopCommand() {
        if (processInProgress) {
            processInProgress = false;
            digitalWrite(RELAY_PIN, HIGH); // Ensure relay is deactivated
        }
    }
};

void setup() {
    Serial.begin(115200);
    pinMode(RELAY_PIN, OUTPUT); // Configure relay pin as output
    pinMode(BUZZER_PIN, OUTPUT);
    BLEDevice::init("ESP32 LUCAS TCS");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());
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

    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, HIGH);

    pService->start();
    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();
}

void loop() {
    delay(1000);
}
