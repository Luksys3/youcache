import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youcache/widgets/player/seek_bar.dart';
import 'package:audio_service/audio_service.dart';

class Player extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return SizedBox();
          }

          final running = snapshot.data ?? false;
          if (!running) {
            return Text('No playlist selected');
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<QueueState>(
                stream:
                    Rx.combineLatest2<List<MediaItem>?, MediaItem?, QueueState>(
                  AudioService.queueStream,
                  AudioService.currentMediaItemStream,
                  (queue, mediaItem) => QueueState(queue, mediaItem),
                ),
                builder: (context, snapshot) {
                  final queueState = snapshot.data;
                  final queue = queueState?.queue ?? [];
                  final mediaItem = queueState?.mediaItem;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (queue.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous),
                              iconSize: 64.0,
                              onPressed: mediaItem == queue.first
                                  ? null
                                  : AudioService.skipToPrevious,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next),
                              iconSize: 64.0,
                              onPressed: mediaItem == queue.last
                                  ? null
                                  : AudioService.skipToNext,
                            ),
                          ],
                        ),
                      if (mediaItem?.title != null) Text(mediaItem!.title),
                    ],
                  );
                },
              ),
              // Play/pause/stop buttons.
              StreamBuilder<bool>(
                stream: AudioService.playbackStateStream
                    .map((state) => state.playing)
                    .distinct(),
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (playing)
                        IconButton(
                          icon: Icon(Icons.pause),
                          iconSize: 64.0,
                          onPressed: AudioService.pause,
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 64.0,
                          onPressed: AudioService.play,
                        ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 64.0,
                        onPressed: AudioService.stop,
                      ),
                    ],
                  );
                },
              ),
              // A seek bar.
              StreamBuilder<MediaState>(
                stream: Rx.combineLatest2<MediaItem?, Duration, MediaState>(
                  AudioService.currentMediaItemStream,
                  AudioService.positionStream,
                  (mediaItem, position) => MediaState(mediaItem, position),
                ),
                builder: (context, snapshot) {
                  final mediaState = snapshot.data;
                  return SeekBar(
                    duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                    position: mediaState?.position ?? Duration.zero,
                    onChangeEnd: (newPosition) {
                      AudioService.seekTo(newPosition);
                    },
                  );
                },
              ),
              // Display the processing state.
              StreamBuilder<AudioProcessingState>(
                stream: AudioService.playbackStateStream
                    .map((state) => state.processingState)
                    .distinct(),
                builder: (context, snapshot) {
                  final processingState =
                      snapshot.data ?? AudioProcessingState.none;
                  return Text(
                    "Processing state: ${describeEnum(processingState)}",
                  );
                },
              ),
              // Display the latest custom event.
              StreamBuilder(
                stream: AudioService.customEventStream,
                builder: (context, snapshot) {
                  return Text("custom event: ${snapshot.data}");
                },
              ),
              // Display the notification click status.
              StreamBuilder<bool>(
                stream: AudioService.notificationClickEventStream,
                builder: (context, snapshot) {
                  return Text(
                    'Notification Click Status: ${snapshot.data}',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class QueueState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
