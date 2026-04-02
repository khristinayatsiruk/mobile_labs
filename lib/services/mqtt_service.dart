import 'dart:async';

import 'package:flutter/foundation.dart'; // Додай цей рядок першим
import 'package:mqtt_client/mqtt_browser_client.dart'; // Саме цей імпорт для Chrome
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  // 1. Для Chrome використовуємо MqttBrowserClient
  // 2. Додаємо префікс 'ws://' (WebSocket)
  final MqttBrowserClient client = MqttBrowserClient(
    'ws://broker.hivemq.com/mqtt',
    'luna_web_${DateTime.now().millisecondsSinceEpoch}',
  );

  final StreamController<String> _tempController =
      StreamController<String>.broadcast();
  Stream<String> get tempStream => _tempController.stream;

  Future<void> connect() async {
    // 3. Порт 8000 — це стандарт для WebSockets у HiveMQ
    client.port = 8000;
    client.setProtocolV311();
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      debugPrint('MQTT: Спроба підключення через WebSockets...');
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('MQTT: Успішно підключено до брокера в браузері!');
        _subscribeToTopic('sensor/temperature/luna');
      }
    } catch (e) {
      debugPrint('MQTT Помилка: $e');
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      debugPrint('MQTT Отримано: $payload'); // Перевірка в консолі
      _tempController.add(payload);
    });
  }

  void disconnect() {
    client.disconnect();
    _tempController.close();
  }
}
