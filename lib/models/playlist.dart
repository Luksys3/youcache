class Playlist {
  final String _id;
  final String _name;
  final String _imageUrl;
  final int _itemCount;
  final int _downloadedItemCount;

  Playlist({
    required id,
    required name,
    required imageUrl,
    required itemCount,
    required downloadedItemCount,
  })   : _id = id,
        _name = name,
        _imageUrl = imageUrl,
        _itemCount = itemCount,
        _downloadedItemCount = downloadedItemCount;

  String get id => _id;
  String get name => _name;
  String get imageUrl => _imageUrl;
  int get itemCount => _itemCount;
  int get downloadedItemCount => _downloadedItemCount;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'imageUrl': _imageUrl,
      'itemCount': _itemCount,
      'downloadedItemCount': _downloadedItemCount,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      itemCount: json['itemCount'],
      downloadedItemCount: json['downloadedItemCount'],
    );
  }
}
