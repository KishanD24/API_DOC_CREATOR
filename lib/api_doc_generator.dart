import 'dart:convert';
import 'dart:io' as io;
import 'package:button_kit/button_kit.dart';
import 'package:button_kit/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;

import 'package:shared_preferences/shared_preferences.dart';

class ApiDocGenerator extends StatefulWidget {
  const ApiDocGenerator({super.key});

  @override
  State<ApiDocGenerator> createState() => _ApiDocGeneratorState();
}

class _ApiDocGeneratorState extends State<ApiDocGenerator> {
  List<ApiEntry> apis = [ApiEntry(isExpanded: true)];

  @override
  void initState() {
    super.initState();
    loadData();
  }
  // Generate final markdown document
  String generateMarkdown() {
    StringBuffer buffer = StringBuffer("# API Documentation\n\n");

    for (int i = 0; i < apis.length; i++) {
      final api = apis[i];

      buffer.writeln("## ${i + 1}. ${api.title}\n");
      buffer.writeln("**Endpoint:** `${api.endpoint}`\n");
      buffer.writeln("**Method:** `${api.method}`\n");
      buffer.writeln("### Request Body\n");
      buffer.writeln("```json\n${api.requestBody}\n```\n");
      buffer.writeln("### Response Body\n");
      buffer.writeln("```json\n${api.responseBody}\n```\n");
      buffer.writeln("---\n");
    }
    return buffer.toString();
  }

  // Mobile share
  Future<void> shareMarkdownMobile(String content) async {
    final file = io.File('/storage/emulated/0/Download/api_doc.md');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: "API Documentation");
  }

  // Web download
  void downloadMarkdownWeb(String content) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "api_document.md")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // Expand only one card, collapse others
  void toggleExpand(int index) {
    setState(() {
      for (int i = 0; i < apis.length; i++) {
        apis[i].isExpanded = i == index ? true : false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 230, 236, 243),
      appBar: AppBar(title: const Text("REST API Doc Creator"),backgroundColor: Colors.transparent,elevation: 0,),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 20,
          children: [
           
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  apis.add(ApiEntry(isExpanded: true));
                  toggleExpand(apis.length - 1);
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add API"),
            ),

            // EXPORT DOCUMENT
            FloatingActionButton.extended(
              onPressed: () {
                String md = generateMarkdown();
                if (kIsWeb) {
                  downloadMarkdownWeb(md);
                } else {
                  shareMarkdownMobile(md);
                }
              },
              icon: const Icon(Icons.share),
              label: const Text("Export"),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 24,right: 24,bottom: 24+80,top: 24),
        itemCount: apis.length,
        itemBuilder: (_, index) => apiCard(index),
      ),
    );
  }

  Widget apiCard(int index) {
    final api = apis[index];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: api.isExpanded
          ? expandedCard(api, index)
          : compactCard(api, index),
    );
  }

  // --------------------------------------
  // COMPACT VIEW
  // --------------------------------------
  Widget compactCard(ApiEntry api, int index) {
    return ListTile(
      title: Text(api.title.isEmpty ? "Untitled API" : api.title),
      subtitle: Text(api.endpoint.isEmpty ? "No endpoint" : api.endpoint),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => toggleExpand(index),
      ),
    );
  }

  // --------------------------------------
  // EXPANDED VIEW (FULL FORM)
  // --------------------------------------
  Widget expandedCard(ApiEntry api, int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: api.titleController,
            decoration: const InputDecoration(labelText: "API Title"),
            onChanged: (v) => api.title = v,
          ),

          TextField(
            controller: api.endpointController,
            decoration: const InputDecoration(labelText: "API Endpoint (URL)"),
            onChanged: (v) => api.endpoint = v,
          ),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Request Method"),
            value: api.method,
            borderRadius: BorderRadius.circular(24),
            elevation: 6,
            dropdownColor: Color.fromARGB(255, 230, 236, 243),
            items: const [
              DropdownMenuItem(value: "GET", child: Text("GET")),
              DropdownMenuItem(value: "POST", child: Text("POST")),
              DropdownMenuItem(value: "PUT", child: Text("PUT")),
              DropdownMenuItem(value: "PATCH", child: Text("PATCH")),
              DropdownMenuItem(value: "DELETE", child: Text("DELETE")),
            ],
            onChanged: (v) => setState(() => api.method = v!),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: api.requestController,
            decoration: const InputDecoration(
              labelText: "Request Body (JSON)",
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            onChanged: (v) => api.requestBody = v,
          ),

          const SizedBox(height: 10),

          TextField(
            controller: api.responseController,
            decoration: const InputDecoration(
              labelText: "Response Body (JSON)",
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            onChanged: (v) => api.responseBody = v,
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 12,
            children: [
              if (apis.length > 1)
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Remove"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500),
                  onPressed: () {
                    setState(() => apis.removeAt(index));
                  },
                ),

              
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                onPressed: () {
                  setState(() {
                    api.title = api.titleController.text;
                    api.endpoint = api.endpointController.text;
                    api.requestBody = api.requestController.text;
                    api.responseBody = api.responseController.text;
                    api.isExpanded = false;
                  });
                  saveData();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('api_docs', jsonEncode(apis.map((e) => e.toJson()).toList()));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('api_docs');

    if (data != null) {
      List list = jsonDecode(data);
      setState(() {
        apis.clear();
        apis.addAll(list.map((e) => ApiEntry.fromJson(e)).toList());
      });
    }
  }

}

// --------------------------------------
// MODEL CLASS WITH CONTROLLERS
// --------------------------------------
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

