/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0), as published by
 * the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tau_sound/tau_sound.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

const _boum = 'assets/samples/sample2.aac';

///
typedef Fn = void Function();

/// Example app.
class PlayerOnProgress extends StatefulWidget {
  @override
  _PlayerOnProgressState createState() => _PlayerOnProgressState();
}

class _PlayerOnProgressState extends State<PlayerOnProgress> {
  final TauPlayer _mPlayer = TauPlayer();
  bool _mPlayerIsInited = false;
  Uint8List _boumData = Uint8List(0);
  int pos = 0;
  double _interval = 0.0;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    stopPlayer(_mPlayer);
    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer.close();

    super.dispose();
  }

  Future<void> init() async {
    await _mPlayer.open();
    _boumData = await getAssetData(_boum);
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  // -------  Here is the code to playback  -----------------------

  void play(TauPlayer? player) async {
    await player!.play(
        from: InputBuffer(_boumData, codec: Aac(AudioFormat.adts)),
        to: DefaultOutputDevice(),
        onProgress: (Duration position, Duration duration) {
          setState(() {
            pos = position.inMilliseconds;
          });
        },
        interval: Duration(milliseconds: _interval.floor()),
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer(TauPlayer player) async {
    await player.stop();
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn(TauPlayer? player) {
    if (!_mPlayerIsInited) {
      return null;
    }
    return player!.isStopped
        ? () {
            play(
              player,
            );
          }
        : () {
            stopPlayer(player).then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      //return Column(
      //children: [
      return Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(3),
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFFAF0E6),
          border: Border.all(
            color: Colors.indigo,
            width: 3,
          ),
        ),
        child: Column(children: [
          Row(children: [
            ElevatedButton(
              onPressed: getPlaybackFn(_mPlayer),
              child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
            ),
            SizedBox(
              width: 20,
            ),
            Text(_mPlayer.isPlaying
                ? 'Playback in progress'
                : 'Player is stopped'),
            SizedBox(
              width: 20,
            ),
            Text('Pos: $pos'),
          ]),
          Text('Subscription Duration:'),
          Slider(
            value: _interval,
            min: 0.0,
            max: 2000.0,
            onChanged: (double d) {
              _interval = d;
              setState(() {});
            },
            //divisions: 100
          ),
        ]),
        //),
        //],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Player onProgress'),
      ),
      body: makeBody(),
    );
  }
}