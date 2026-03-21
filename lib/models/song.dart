class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
  });

  final String id;
  final String title;
  final String artist;
  final String album;

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: '${json['id'] ?? json['_id'] ?? json['songId'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Untitled'}',
      artist:
          '${json['artist'] ?? json['artistName'] ?? json['author'] ?? 'Unknown Artist'}',
      album: '${json['album'] ?? json['albumName'] ?? 'Single'}',
    );
  }
}
