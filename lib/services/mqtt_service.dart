import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  MqttBrowserClient? client;
  final StreamController<String> _tempController =
      StreamController<String>.broadcast();
  Stream<String> get tempStream => _tempController.stream;

  // Поточний хост за замовчуванням
  String currentHost = 'broker.hivemq.com';

  Future<void> connect({String? newHost}) async {
    if (newHost != null) currentHost = newHost;

    // Якщо клієнт вже є — відключаємо старе з'єднання
    client?.disconnect();

    // Створюємо клієнта. Для Web обов'язково додаємо ws:// та /mqtt
    final String url = 'ws://$currentHost/mqtt';
    client = MqttBrowserClient(
      url,
      'luna_web_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Налаштування для WebSockets
    client!.port = 8000;
    client!.setProtocolV311();
    client!.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      debugPrint('MQTT: Спроба підключення до $currentHost...');
      await client!.connect();
      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('MQTT: Успішно підключено до $currentHost');
        _subscribeToTopic('sensor/temperature/luna');
      }
    } catch (e) {
      debugPrint('MQTT Помилка підключення: $e');
    }
  }

  void _subscribeToTopic(String topic) {
    client?.subscribe(topic, MqttQos.atMostOnce);
    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _tempController.add(payload);
    });
  }

  void disconnect() {
    client?.disconnect();
    _tempController.close();
  }
}
