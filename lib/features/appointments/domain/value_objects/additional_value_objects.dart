import 'package:flutter/material.dart';
import '../../../core/errors/app_exceptions.dart';

/// Value Object para data de agendamento
class AppointmentDate {
  final DateTime value;
  
  AppointmentDate._(this.value);
  
  factory AppointmentDate(DateTime input) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Remove a parte de hora para comparar apenas as datas
    final inputDate = DateTime(input.year, input.month, input.day);
    
    if (inputDate.isBefore(today)) {
      throw ValidationException('A data não pode ser no passado');
    }
    
    // Limita agendamentos a 1 ano no futuro
    final oneYearFromNow = DateTime(today.year + 1, today.month, today.day);
    if (inputDate.isAfter(oneYearFromNow)) {
      throw ValidationException('A data não pode ser mais de 1 ano no futuro');
    }
    
    return AppointmentDate._(input);
  }
  
  @override
  String toString() => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

/// Value Object para hora de agendamento
class AppointmentTime {
  final TimeOfDay value;
  
  AppointmentTime._(this.value);
  
  factory AppointmentTime(TimeOfDay input) {
    // Verifica se está dentro do horário comercial (8h às 18h)
    if (input.hour < 8 || input.hour >= 18) {
      throw ValidationException('O horário deve estar entre 8:00 e 18:00');
    }
    
    return AppointmentTime._(input);
  }
  
  @override
  String toString() => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

/// Value Object para notas de agendamento
class AppointmentNotes {
  final String value;
  
  AppointmentNotes._(this.value);
  
  factory AppointmentNotes(String input) {
    final trimmed = input.trim();
    
    // Notas podem ser vazias
    if (trimmed.isEmpty) {
      return AppointmentNotes._('');
    }
    
    // Limita o tamanho das notas
    if (trimmed.length > 500) {
      throw ValidationException('As notas não podem exceder 500 caracteres');
    }
    
    return AppointmentNotes._(trimmed);
  }
  
  @override
  String toString() => value;
}

/// Value Object para duração de agendamento
class AppointmentDuration {
  final int minutes;
  
  AppointmentDuration._(this.minutes);
  
  factory AppointmentDuration(int minutes) {
    if (minutes <= 0) {
      throw ValidationException('A duração deve ser maior que zero');
    }
    
    if (minutes > 480) { // 8 horas
      throw ValidationException('A duração não pode exceder 8 horas');
    }
    
    return AppointmentDuration._(minutes);
  }
  
  @override
  String toString() {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '$hours h${mins > 0 ? ' $mins min' : ''}';
    } else {
      return '$mins min';
    }
  }
}