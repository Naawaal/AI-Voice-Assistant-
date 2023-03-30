import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/const/api.dart';

class OpenAIServices {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIAPIKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Does this message want to generate an AI image or anything similar? $prompt . Simply answer with yse or no. ",
            }
          ]
        }),
      );
      print("status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final body = response.body.toString();
        final json = jsonDecode(body)['choices'][0]['message']['content'];
        switch (json) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final response = await dallEAPI(prompt);
            return response;

          default:
            final response = await chatGPTAPI(prompt);
            return response;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return 'An Intrenal Error Occur';
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIAPIKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      print("status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = response.body.toString();
        final json = jsonDecode(body)['choices'][0]['message']['content'];
        messages.add({
          'role': 'assistant',
          'content': json,
        });
        return json;
      }
    } catch (e) {
      return e.toString();
    }
    return 'Chat-GPT';
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIAPIKey",
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final body = response.body.toString();
        final json = jsonDecode(body)['data'][0]['url'];
        messages.add({
          'role': 'assistant',
          'content': json,
        });
        return json;
      }
    } catch (e) {
      return e.toString();
    }
    return 'Dall-E';
  }
}
