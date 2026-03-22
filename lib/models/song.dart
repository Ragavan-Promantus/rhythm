class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.genre = '',
    this.coverImage = '',
    this.durationSeconds,
    this.releaseDate = '',
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String coverImage;
  final int? durationSeconds;
  final String releaseDate;

  factory Song.fromJson(Map<String, dynamic> json) {
    final durationValue = json['duration'];

    return Song(
      id: '${json['id'] ?? json['_id'] ?? json['songId'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Untitled'}',
      artist:
          '${json['artist'] ?? json['artistName'] ?? json['author'] ?? 'Unknown Artist'}',
      album: '${json['album'] ?? json['albumName'] ?? 'Single'}',
      genre: '${json['genre'] ?? ''}',
      coverImage: '${json['cover_image'] ?? json['coverImage'] ?? ''}',
      durationSeconds: durationValue is num
          ? durationValue.toInt()
          : int.tryParse('${durationValue ?? ''}'),
      releaseDate: '${json['release_date'] ?? ''}',
    );
  }
}
