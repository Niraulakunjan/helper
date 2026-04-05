import 'user_model.dart';

class HelperModel {
  final int id;
  final UserModel user;
  final String serviceName;
  final double price;
  final String location;
  final double rating;

  HelperModel({
    required this.id,
    required this.user,
    required this.serviceName,
    required this.price,
    required this.location,
    required this.rating,
  });

  factory HelperModel.fromJson(Map<String, dynamic> json) => HelperModel(
    id: json['id'],
    user: UserModel.fromJson(json['user']),
    serviceName: json['service']['name'],
    price: double.tryParse(json['price'].toString()) ?? 0.0,
    location: json['location'],
    rating: (json['rating'] as num).toDouble(),
  );
}

class ServiceModel {
  final int id;
  final String name;
  final String description;

  ServiceModel({required this.id, required this.name, required this.description});

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
  );
}

class BookingModel {
  final int id;
  final HelperModel helper;
  final UserModel user;
  final String date;
  final String status;

  BookingModel({required this.id, required this.helper, required this.user, required this.date, required this.status});

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'],
    helper: HelperModel.fromJson(json['helper']),
    user: UserModel.fromJson(json['user']),
    date: json['date'],
    status: json['status'],
  );
}

class MessageModel {
  final int id;
  final UserModel sender;
  final UserModel receiver;
  final String content;
  final String timestamp;

  MessageModel({required this.id, required this.sender, required this.receiver, required this.content, required this.timestamp});

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    sender: UserModel.fromJson(json['sender']),
    receiver: UserModel.fromJson(json['receiver']),
    content: json['content'],
    timestamp: json['timestamp'],
  );
}
