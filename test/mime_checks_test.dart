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

  group('7.0.0 Office format precision', () {
    test('Word getters distinguish .doc from .docx', () {
      expect('a.docx'.isDOCX, isTrue);
      expect('a.doc'.isDOCX, isFalse);
      expect('a.doc'.isDOC, isTrue);
      expect('a.docx'.isDOC, isFalse);
      expect('a.doc'.isWord, isTrue);
      expect('a.docx'.isWord, isTrue);
      expect('a.pdf'.isWord, isFalse);
    });

    test('Excel getters distinguish .xls from .xlsx', () {
      expect('a.xlsx'.isXLSX, isTrue);
      expect('a.xls'.isXLSX, isFalse);
      expect('a.xls'.isXLS, isTrue);
      expect('a.xls'.isExcel, isTrue);
      expect('a.xlsx'.isExcel, isTrue);
    });
  });
}
