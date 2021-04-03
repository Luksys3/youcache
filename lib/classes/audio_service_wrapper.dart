import 'package:audio_service/audio_service.dart';
import 'package:youcache/classes/audio_player_task.dart';
import 'package:youcache/constants/primary_swatch.dart';

// Must be a top level function
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioServiceWrapper {
  static Future<void> start() async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'YouCache',
      androidNotificationColor: PRIMARY_COLOR,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );
  }
}
