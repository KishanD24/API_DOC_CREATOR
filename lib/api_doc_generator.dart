import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'dummy_data.dart';
import 'model/api_data_model.dart';

class ApiDocGenerator extends StatefulWidget {
  const ApiDocGenerator({super.key});

  @override
  State<ApiDocGenerator> createState() => _ApiDocGeneratorState();
}

class _ApiDocGeneratorState extends State<ApiDocGenerator> {
  List<ApiEntry> apis = [ApiEntry(isExpanded: true)];
  String baseUrl = "https://example.com/api/v1";

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

      buffer.writeln("## BASE_URL: \n${baseUrl}\n");
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

  String generatePostmanCollectionJson({
    required String collectionName,
    required String baseUrl,
  }) {
    final collection = {
      "info": {
        "name": collectionName,
        "schema":
        "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
      },
      "variable": [
        { "key": "base_url", "value": "$baseUrl" },
      ],
      "item": apis.map((api) {
        // FIX: Build complete URL THEN parse
        final fullUrl = "$baseUrl/${api.endpoint.replaceFirst("/", "")}";
        final uri = Uri.parse(fullUrl);
        return {
          "name": api.title,
          "request": {
            "method": api.method.toUpperCase(),
            "header": [],
            "body": {
              "mode": "raw",
              "raw": api.requestBody,
              "options": {"raw": {"language": "json"}}
            },
            "url": {
              "raw": "{{base_url}}/${api.endpoint.replaceFirst("/", "")}",
              "protocol": uri.scheme,
              "host": uri.host.split("."),
              "path": uri.pathSegments,
              // "raw": "{{base_url}}/"+api.endpoint,
              // "host": _parseHost(api.endpoint),
              // "path": _parsePath(api.endpoint),
            }
          },
          "response": [
            {
              "name": "${api.title} Response",
              "originalRequest": {},
              "body": api.responseBody,
            }
          ]
        };
      }).toList(),
    };
    return const JsonEncoder.withIndent("  ").convert(collection);
  }

  // Mobile share
  Future<void> shareMarkdownMobile(String content,{required String fileExt}) async {
    final file = io.File('/storage/emulated/0/Download/api_doc.$fileExt');
    await file.writeAsString(content);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)], text: "API Documentation"
    ));
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
  // Web download (JSON)
  void downloadJsonWeb(String content) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "api_doc_collection.json")
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
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              apis=dummyDataList;
            });
          },
          child: const Text("REST API Doc Creator")),backgroundColor: Colors.transparent,elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            width: double.infinity,
            color: Colors.black12, // light background to differentiate
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Base URL Text
                Expanded(
                  child: Text(
                    "Base URL: $baseUrl",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditBaseUrlDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  shareMarkdownMobile(md, fileExt: 'md');
                }
              },
              icon: const Icon(Icons.share),
              label: const Text("Export Markdown"),
            ),
            // EXPORT POSTMAN COLLECTION JSON
            FloatingActionButton.extended(
              onPressed: () {
                String jsonVal = generatePostmanCollectionJson(collectionName: 'API_DOC_COLLECTION', baseUrl: baseUrl);
                if (kIsWeb) {
                  downloadJsonWeb(jsonVal);
                } else {
                  shareMarkdownMobile(jsonVal, fileExt: 'json');
                }
              },
              icon: const Icon(Icons.share),
              label: const Text("Export JSON"),
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
            initialValue: api.method,
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

  void _showEditBaseUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: baseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Base URL"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Base URL",
              hintText: "https://yourapi.com",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  baseUrl = controller.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

}


