#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID        "6f692fbe-0858-4747-89fb-6c3fe7a6681f"
#define CHARACTERISTIC_UUID "428c918a-53ab-4eef-827d-74a0d4b6d267"

#define BUZZER_PIN 25
#define FREQUENCY 1000
#define RELAY_PIN 26

const std::string START = "start";
const std::string STOP = "stop";
const std::string IN_USE = "in-use";
const std::string WAIT = "wait";
const std::string AVAILABLE = "available";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool processInProgress = false;

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) override {
        tone(BUZZER_PIN, FREQUENCY);
        delay(200);
        noTone(BUZZER_PIN);
        digitalWrite(RELAY_PIN, HIGH); // Ativa o relé
        delay(200);
        digitalWrite(RELAY_PIN, LOW); // Desativa o relé
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
            tone(BUZZER_PIN, FREQUENCY);
            delay(200);
            noTone(BUZZER_PIN);
            digitalWrite(RELAY_PIN, HIGH); // Ativa o relé
            delay(2000);
            digitalWrite(RELAY_PIN, LOW); // Desativa o relé
            pCharacteristic->setValue(AVAILABLE);
        } else {
            pCharacteristic->setValue(WAIT);
        }
    }

    void handleStopCommand() {
        if (processInProgress) {
            processInProgress = false;
            digitalWrite(RELAY_PIN, LOW); // Garante que o relé esteja desativado
        }
    }
};

void setup() {
    Serial.begin(115200);
    pinMode(RELAY_PIN, OUTPUT); // Configura o pino do relé como saída
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

    pService->start();
    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();
}

void loop() {
    delay(1000);
}
