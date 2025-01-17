/*
 * Copyright 2021 Canardoux.
 *
 * This file is part of the τ Sound project.
 *
 * τ Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Public License version 3 (GPL3.0),
 * as published by the Free Software Foundation.
 *
 * τ Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the GNU Public
 * License, v. 3.0. If a copy of the GPL was not distributed with this
 * file, You can obtain one at https://www.gnu.org/licenses/.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:tau_sound_lite/tau_sound.dart';
import 'package:intl/intl.dart';

import 'demo_media_path.dart';

/// Describes how the media is stored.
enum MediaStorage {
  /// The media is stored in a local file
  file,

  /// The media is stored in a in memory buffer
  buffer,

  /// The media is stored in an asset.
  asset,

  /// The media is being streamed
  stream,

  /// The media is a remote sample file.
  remoteExampleFile,
}

/// get the duration for the media with the given codec.
@deprecated
Future<Duration?>? getDuration(Codec? codec) async {
  Future<Duration?>? duration;
  switch (MediaPath().media) {
    case MediaStorage.file:
    case MediaStorage.buffer:
      duration = flutterSoundHelper.duration(MediaPath().pathForCodec(codec!)!);
      break;
    case MediaStorage.asset:
      duration = null;
      break;
    case MediaStorage.remoteExampleFile:
      duration = null;
      break;
    case MediaStorage.stream:
      duration = null;
      break;
    default:
      duration = null;
  }
  return duration;
}

/// formats a duration for printing.
///  mm:ss
String formatDuration(Duration duration) {
  var date =
      DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds, isUtc: true);
  return DateFormat('mm:ss', 'en_GB').format(date);
}

/// the set of samples availble as assets.
List<String> assetSample = [
  'assets/samples/sample.aac',
  'assets/samples/sample.aac',
  'assets/samples/sample.opus',
  'assets/samples/sample.caf',
  'assets/samples/sample.mp3',
  'assets/samples/sample.ogg',
  'assets/samples/sample.wav',
];

/// Checks if the past file exists
bool fileExists(String path) {
  return File(path).existsSync();
}

/// checks if the given directory exists.
bool directoryExists(String path) {
  return Directory(path).existsSync();
}

/// In this simple example, we just load a file in memory.
/// This is stupid but just for demonstration  of startPlayerFromBuffer()
Future<Uint8List?> makeBuffer(String path) async {
  try {
    if (!fileExists(path)) return null;
    var file = File(path);
    file.openRead();
    var contents = await file.readAsBytes();
    print('The file is ${contents.length} bytes long.');
    return contents;
  } on Object catch (e) {
    print(e.toString());
    return null;
  }
}
