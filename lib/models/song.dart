class Song {
  final String id;
  final String playlistId;
  final String videoId;
  final String name;
  final String? imageUrl;
  final String status;
  final String? ownerChannelTitle;
  final bool downloaded;

  Song({
    required this.id,
    required this.playlistId,
    required this.videoId,
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.ownerChannelTitle,
    required this.downloaded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlistId': playlistId,
      'videoId': videoId,
      'name': name,
      'imageUrl': imageUrl,
      'status': status,
      'ownerChannelTitle': ownerChannelTitle,
      'downloaded': downloaded ? 1 : 0,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      playlistId: json['playlistId'],
      videoId: json['videoId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      ownerChannelTitle: json['ownerChannelTitle'],
      downloaded: json['downloaded'] == 1 ? true : false,
    );
  }
}
