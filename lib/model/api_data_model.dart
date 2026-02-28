
// --------------------------------------
// MODEL CLASS WITH CONTROLLERS
// --------------------------------------
import 'package:flutter/material.dart';

class ApiEntry {
  String title;
  String endpoint;
  String method;
  String requestBody;
  String responseBody;
  bool isExpanded;

  late TextEditingController titleController;
  late TextEditingController endpointController;
  late TextEditingController requestController;
  late TextEditingController responseController;

  ApiEntry({
    this.title = "",
    this.endpoint = "",
    this.method = "GET",
    this.requestBody = "{}",
    this.responseBody = "{}",
    this.isExpanded = false,
  }) {
    titleController = TextEditingController(text: title);
    endpointController = TextEditingController(text: endpoint);
    requestController = TextEditingController(text: requestBody);
    responseController = TextEditingController(text: responseBody);
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "endpoint": endpoint,
      "method": method,
      "requestBody": requestBody,
      "responseBody": responseBody,
      "isExpanded": isExpanded,
    };
  }

  factory ApiEntry.fromJson(Map<String, dynamic> json) {
    return ApiEntry(
      title: json["title"] ?? "",
      endpoint: json["endpoint"] ?? "",
      method: json["method"] ?? "GET",
      requestBody: json["requestBody"] ?? "{}",
      responseBody: json["responseBody"] ?? "{}",
      isExpanded: json["isExpanded"] ?? false,
    );
  }

}