import 'dart:convert';

class GitReleaseModel {
  final String tagName;
  final String name;
  final String htmlUrl;
  final String body;

  GitReleaseModel({
    required this.tagName,
    required this.name,
    required this.htmlUrl,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'tag_name': tagName,
      'name': name,
      'html_url': htmlUrl,
      'body': body,
    };
  }

  factory GitReleaseModel.fromMap(Map<String, dynamic> map) {
    return GitReleaseModel(
      tagName: map['tag_name'],
      name: map['name'],
      htmlUrl: map['html_url'],
      body: map['body'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GitReleaseModel.fromJson(String source) =>
      GitReleaseModel.fromMap(json.decode(source));

  factory GitReleaseModel.empty() {
    return GitReleaseModel(
      tagName: '',
      name: '',
      htmlUrl: '',
      body: '',
    );
  }

  bool get isEmpty {
    return this.tagName.isEmpty &&
        this.name.isEmpty &&
        this.htmlUrl.isEmpty &&
        this.body.isEmpty;
  }
}
