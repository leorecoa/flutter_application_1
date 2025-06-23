# Guia de Integrações - SaaS AgendaFácil

## 🔗 Integrações Externas

### 1. WhatsApp API Integration

#### Opção 1: Z-API (Recomendada)
```dart
class WhatsAppService {
  static const String baseUrl = 'https://api.z-api.io';
  static const String instanceId = 'YOUR_INSTANCE_ID';
  static const String token = 'YOUR_TOKEN';

  static Future<bool> sendMessage({
    required String phone,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/instances/$instanceId/token/$token/send-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'message': message,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar WhatsApp: $e');
      return false;
    }
  }

  static Future<bool> sendTemplate({
    required String phone,
    required String templateName,
    required Map<String, dynamic> variables,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/instances/$instanceId/token/$token/send-template'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'template': templateName,
          'variables': variables,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar template WhatsApp: $e');
      return false;
    }
  }
}
```

#### Templates de Mensagens
```dart
class WhatsAppTemplates {
  static String appointmentConfirmation({
    required String clientName,
    required String serviceName,
    required String date,
    required String time,
    required String businessName,
  }) {
    return '''
🎉 *Agendamento Confirmado!*

Olá $clientName!

Seu agendamento foi confirmado:
📅 *Serviço:* $serviceName
🗓️ *Data:* $date
⏰ *Horário:* $time
🏪 *Local:* $businessName

Nos vemos em breve! 😊

_Mensagem automática do AgendaFácil_
    ''';
  }

  static String appointmentReminder({
    required String clientName,
    required String serviceName,
    required String time,
    required String businessName,
  }) {
    return '''
⏰ *Lembrete de Agendamento*

Olá $clientName!

Lembrando que você tem um agendamento hoje:
📅 *Serviço:* $serviceName
⏰ *Horário:* $time
🏪 *Local:* $businessName

Te esperamos! 😊

_Mensagem automática do AgendaFácil_
    ''';
  }

  static String paymentConfirmation({
    required String clientName,
    required double amount,
    required String paymentMethod,
  }) {
    return '''
✅ *Pagamento Confirmado!*

Olá $clientName!

Seu pagamento foi processado com sucesso:
💰 *Valor:* R\$ ${amount.toStringAsFixed(2)}
💳 *Método:* $paymentMethod

Obrigado pela preferência! 🙏

_Mensagem automática do AgendaFácil_
    ''';
  }
}
```

### 2. Payment Integration

#### Stripe Integration
```dart
class StripeService {
  static const String publishableKey = AppConfig.stripePublishableKey;
  static const String secretKey = AppConfig.stripeSecretKey;

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(),
          'currency': currency,
          'customer': customerId,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro Stripe: $e');
      return null;
    }
  }

  static Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao confirmar pagamento: $e');
      return false;
    }
  }
}
```

#### Mercado Pago Integration
```dart
class MercadoPagoService {
  static const String accessToken = AppConfig.mercadoPagoAccessToken;
  static const String publicKey = AppConfig.mercadoPagoPublicKey;

  static Future<Map<String, dynamic>?> createPixPayment({
    required double amount,
    required String description,
    required String payerEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/v1/payments'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transaction_amount': amount,
          'description': description,
          'payment_method_id': 'pix',
          'payer': {
            'email': payerEmail,
          },
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro Mercado Pago: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mercadopago.com/v1/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao consultar pagamento: $e');
      return null;
    }
  }
}
```

### 3. AWS Services Integration

#### DynamoDB Service
```dart
class DynamoDBService {
  static const String region = AppConfig.awsRegion;
  static const String tableName = 'agenda-facil-prod';

  static Future<Map<String, dynamic>?> getItem({
    required String pk,
    required String sk,
  }) async {
    try {
      final response = await ApiService.post('/dynamodb/get-item', {
        'TableName': tableName,
        'Key': {
          'PK': {'S': pk},
          'SK': {'S': sk},
        },
      });

      return response['Item'];
    } catch (e) {
      print('Erro DynamoDB GetItem: $e');
      return null;
    }
  }

  static Future<bool> putItem(Map<String, dynamic> item) async {
    try {
      await ApiService.post('/dynamodb/put-item', {
        'TableName': tableName,
        'Item': _convertToAttributeValue(item),
      });

      return true;
    } catch (e) {
      print('Erro DynamoDB PutItem: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> query({
    required String pk,
    String? skBeginsWith,
  }) async {
    try {
      final keyCondition = {
        'PK': {
          'AttributeValueList': [{'S': pk}],
          'ComparisonOperator': 'EQ',
        },
      };

      if (skBeginsWith != null) {
        keyCondition['SK'] = {
          'AttributeValueList': [{'S': skBeginsWith}],
          'ComparisonOperator': 'BEGINS_WITH',
        };
      }

      final response = await ApiService.post('/dynamodb/query', {
        'TableName': tableName,
        'KeyConditions': keyCondition,
      });

      return List<Map<String, dynamic>>.from(
        response['Items'].map((item) => _convertFromAttributeValue(item)),
      );
    } catch (e) {
      print('Erro DynamoDB Query: $e');
      return [];
    }
  }

  static Map<String, dynamic> _convertToAttributeValue(Map<String, dynamic> item) {
    final result = <String, dynamic>{};
    
    for (final entry in item.entries) {
      if (entry.value is String) {
        result[entry.key] = {'S': entry.value};
      } else if (entry.value is num) {
        result[entry.key] = {'N': entry.value.toString()};
      } else if (entry.value is bool) {
        result[entry.key] = {'BOOL': entry.value};
      } else if (entry.value is List) {
        result[entry.key] = {'SS': entry.value};
      } else if (entry.value is Map) {
        result[entry.key] = {'M': _convertToAttributeValue(entry.value)};
      }
    }
    
    return result;
  }

  static Map<String, dynamic> _convertFromAttributeValue(Map<String, dynamic> item) {
    final result = <String, dynamic>{};
    
    for (final entry in item.entries) {
      final value = entry.value as Map<String, dynamic>;
      
      if (value.containsKey('S')) {
        result[entry.key] = value['S'];
      } else if (value.containsKey('N')) {
        result[entry.key] = num.parse(value['N']);
      } else if (value.containsKey('BOOL')) {
        result[entry.key] = value['BOOL'];
      } else if (value.containsKey('SS')) {
        result[entry.key] = value['SS'];
      } else if (value.containsKey('M')) {
        result[entry.key] = _convertFromAttributeValue(value['M']);
      }
    }
    
    return result;
  }
}
```

#### SQS Service (Para processamento assíncrono)
```dart
class SQSService {
  static const String queueUrl = 'https://sqs.us-east-1.amazonaws.com/123456789/whatsapp-queue';

  static Future<bool> sendMessage(Map<String, dynamic> message) async {
    try {
      await ApiService.post('/sqs/send-message', {
        'QueueUrl': queueUrl,
        'MessageBody': jsonEncode(message),
        'MessageAttributes': {
          'Type': {
            'StringValue': message['type'],
            'DataType': 'String',
          },
        },
      });

      return true;
    } catch (e) {
      print('Erro SQS: $e');
      return false;
    }
  }
}
```

### 4. Notification Service
```dart
class NotificationService {
  static Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required DateTime reminderTime,
    required String clientPhone,
    required String message,
  }) async {
    // Agendar lembrete via SQS com delay
    await SQSService.sendMessage({
      'type': 'whatsapp_reminder',
      'appointmentId': appointmentId,
      'phone': clientPhone,
      'message': message,
      'scheduledFor': reminderTime.toIso8601String(),
    });
  }

  static Future<void> sendAppointmentConfirmation({
    required String clientPhone,
    required String clientName,
    required String serviceName,
    required String date,
    required String time,
    required String businessName,
  }) async {
    final message = WhatsAppTemplates.appointmentConfirmation(
      clientName: clientName,
      serviceName: serviceName,
      date: date,
      time: time,
      businessName: businessName,
    );

    await WhatsAppService.sendMessage(
      phone: clientPhone,
      message: message,
    );
  }

  static Future<void> sendPaymentConfirmation({
    required String clientPhone,
    required String clientName,
    required double amount,
    required String paymentMethod,
  }) async {
    final message = WhatsAppTemplates.paymentConfirmation(
      clientName: clientName,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    await WhatsAppService.sendMessage(
      phone: clientPhone,
      message: message,
    );
  }
}
```

## 🔄 Fluxo de Integração

### 1. Fluxo de Agendamento
```
Cliente agenda → DynamoDB → SQS → WhatsApp Confirmação
```

### 2. Fluxo de Pagamento
```
Pagamento → Stripe/MP → Webhook → DynamoDB → WhatsApp Confirmação
```

### 3. Fluxo de Lembrete
```
Agendamento → SQS Delayed → Lambda → WhatsApp Lembrete
```

## 🔧 Configuração de Webhooks

### Stripe Webhook
```dart
class StripeWebhookHandler {
  static Future<void> handleWebhook(Map<String, dynamic> event) async {
    switch (event['type']) {
      case 'payment_intent.succeeded':
        await _handlePaymentSuccess(event['data']['object']);
        break;
      case 'payment_intent.payment_failed':
        await _handlePaymentFailed(event['data']['object']);
        break;
    }
  }

  static Future<void> _handlePaymentSuccess(Map<String, dynamic> paymentIntent) async {
    final appointmentId = paymentIntent['metadata']['appointment_id'];
    
    // Atualizar status do agendamento
    await DynamoDBService.putItem({
      'PK': 'USER#${paymentIntent['customer']}',
      'SK': 'APPOINTMENT#$appointmentId',
      'paymentStatus': 'paid',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Enviar confirmação via WhatsApp
    await NotificationService.sendPaymentConfirmation(
      clientPhone: paymentIntent['metadata']['client_phone'],
      clientName: paymentIntent['metadata']['client_name'],
      amount: paymentIntent['amount'] / 100,
      paymentMethod: 'Cartão',
    );
  }
}
```