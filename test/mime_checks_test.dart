import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MIME checks', () {
    test('image types', () {
      const file = 'photo.png';
      expect(file.mimeType(), 'image/png');
      expect(file.isImage, isTrue);
      expect(file.isPNG, isTrue);
      expect(file.isJPEG, isFalse);
    });

    test('video types', () {
      const file = 'movie.mp4';
      expect(file.isVideo, isTrue);
      expect(file.isMP4, isTrue);
    });

    test('document types', () {
      const file = 'manual.pdf';
      expect(file.isPDF, isTrue);
      expect(file.isDOC, isFalse);
    });

    test('archive types', () {
      const file = 'archive.zip';
      expect(file.isArchive, isTrue);
      expect(file.isZIP, isTrue);
    });

    test('programming types', () {
      const file = 'script.js';
      expect(file.isJavaScript, isTrue);
      expect(file.isTypeScript, isFalse);
    });
  });
}
