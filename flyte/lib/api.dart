import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flyte/dyte.dart';
import 'package:flyte/tools.dart';
import 'package:http/http.dart' as http;

import 'package:flyte/const.dart';

class Api {
  static final Api api = Api._internal();

  factory Api() {
    return api;
  }

  Api._internal();

  // Dyte
  Future<String?> restPostDyteMeeting() async {
    debugPrint('\n\nrestPostDyteMeeting');

    final response = await http.post(Uri.parse('$kfDyteUrl/meetings'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $kfDyteOrgIdApiKeyB64',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode({
          "title": 'Flyte\'s room',
          "preferred_region": 'us-east-1',
          "record_on_start": false,
          "live_stream_on_start": true,
          "recording_config": {
            "max_seconds": 300,
            "file_name_prefix": "string",
            "video_config": {
              "codec": "H264",
              "width": 1280,
              "height": 720,
              "watermark": {
                "url": "http://example.com",
                "size": {"width": 1, "height": 1},
                "position": "left top"
              }
            },
            "audio_config": {"codec": "AAC", "channel": "stereo"},
            "storage_config": {
              "type": "aws",
              "access_key": "string",
              "secret": "string",
              "bucket": "string",
              "region": "us-east-1",
              "path": "string",
              "auth_method": "KEY",
              "username": "string",
              "password": "string",
              "host": "string",
              "port": 0,
              "private_key": "string"
            },
            "dyte_bucket_config": {"enabled": true},
            "live_streaming_config": {
              "rtmp_url": "rtmp://a.rtmp.youtube.com/live2"
            }
          }
        }));

    if (response.statusCode == 201) {
      Map jsonResp = json.decode(response.body);
      String? id = jsonResp['data']['id'];

      return id;
    } else {
      debugPrint('Error restPostDyteMeeting: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<bool> restPatchDyteMeeting(String dyteMeetingId) async {
    debugPrint('\n\nrestPatchDyteMeeting');

    final response =
        await http.patch(Uri.parse('$kfDyteUrl/meetings/$dyteMeetingId'),
            headers: {
              HttpHeaders.authorizationHeader: 'Basic $kfDyteOrgIdApiKeyB64',
              HttpHeaders.contentTypeHeader: 'application/json'
            },
            body: jsonEncode({
              "title": 'Flyte\'s room',
              "preferred_region": "us-east-1",
              "record_on_start": false,
              "live_stream_on_start": true,
              "status": "ACTIVE"
            }));

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Error restPatchDyteMeeting: ${response.reasonPhrase}');
      return false;
    }
  }

  Future<String?> restPostDyteParticipant() async {
    debugPrint('\n\nrestPostDyteParticipant');

    final response = await http.post(
        Uri.parse('$kfDyteUrl/meetings/$dyteMeetingId/participants'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $kfDyteOrgIdApiKeyB64',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode({
          'name': Tools.tools.userName,
          'picture': Tools.tools.userPicture,
          'preset_name': 'group_call_host',
          'custom_participant_id': Tools.tools.userId
        }));

    debugPrint('Body: ${response.body}');

    if (response.statusCode == 201) {
      Map jsonResp = json.decode(response.body);
      String? token = jsonResp['data']['token'];

      return token;
    } else {
      debugPrint('Error restPostDyteParticipant: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<bool> restDeleteDyteParticipant(String id) async {
    debugPrint('\n\nrestDeleteDyteParticipant');

    final response = await http.delete(
        Uri.parse('$kfDyteUrl/meetings/$dyteMeetingId/participants/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $kfDyteOrgIdApiKeyB64',
          HttpHeaders.contentTypeHeader: 'application/json'
        });

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Error restDeleteDyteParticipant: ${response.reasonPhrase}');
      return false;
    }
  }
}
