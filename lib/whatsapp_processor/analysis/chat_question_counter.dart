/// Cuenta bloques de interrogación (misma regla que el procesador original).
abstract final class ChatQuestionCounter {
  static final _questionPattern = RegExp(r'[?¿](?:\s*[?¿])*');

  static int countQuestions(String text) {
    return _questionPattern.allMatches(text).length;
  }
}
