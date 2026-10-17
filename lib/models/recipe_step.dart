/// One instruction step. The step number shown in the UI is its
/// position in the list, so we do not store it.
class RecipeStep {
  final String text;
  final String? photoUrl;

  const RecipeStep({required this.text, this.photoUrl});

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      text: map['text'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'photoUrl': photoUrl,
    };
  }
}
