class Book{
  final String title;
  final String keyword;
  final String poster;
  bool like;
  final int id;
  final String description;  // 새로 추가된 필드

  Book({
    required this.title,
    required this.keyword,
    required this.poster,
    required this.like,
    required this.id,
    this.description = '',  // 기본값 설정
  });


  Book.fromMap(Map<String, dynamic> map)
  : title = map['title'],
    keyword = map['keyword'], 
    poster = map['poster'],
    like = map['like'],
    id = map['id'],
    description = map['description'] ?? '';  // null 체크와 함께 추가

  Book.fromJson(Map<String, dynamic> json)
  : title = json['title'],
    keyword = json['keyword'],
    poster = json['poster_url'],
    like = json['like'],
    id = json['id'],
    description = json['description'] ?? '';

  Book copyWith({
    String? title,
    String? keyword,
    String? poster,
    bool? like,
    int? id,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      keyword: keyword ?? this.keyword,
      poster: poster ?? this.poster,
      like: like ?? this.like,
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }

  @override
    String toString() => 
    'Book: $id, $title, $keyword, $poster, $like, $description';

}
