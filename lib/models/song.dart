class Song {
  final String _id;
  final String _name;
  final String _imageUrl;
  final String _length;
  final bool _downloaded;

  Song({
    required id,
    required name,
    required imageUrl,
    required length,
    required downloaded,
  })   : _id = id,
        _name = name,
        _imageUrl = imageUrl,
        _length = length,
        _downloaded = downloaded;

  String get id => _id;
  String get name => _name;
  String get imageUrl => _imageUrl;
  String get length => _length;
  bool get downloaded => _downloaded;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'imageUrl': _imageUrl,
      'length': _length,
      'downloaded': _downloaded,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      length: json['length'],
      downloaded: json['downloaded'],
    );
  }
}
