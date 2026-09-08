import 'dart:typed_data';
import 'package:image/image.dart' as img;

class SpriteValidationResult {
  final bool isValid;
  final String message;
  final int? width;
  final int? height;

  SpriteValidationResult({
    required this.isValid,
    required this.message,
    this.width,
    this.height,
  });
}

class SpriteService {
  /// Audita que las dimensiones del PNG coincidan exactamente con blockSize * 32 px
  static SpriteValidationResult validateSprite({
    required Uint8List imageBytes,
    required int blockSize,
  }) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return SpriteValidationResult(
        isValid: false,
        message: 'No se pudo procesar la imagen PNG.',
      );
    }

    final expectedPixels = blockSize * 32;
    if (image.width != expectedPixels || image.height != expectedPixels) {
      return SpriteValidationResult(
        isValid: false,
        message: 'Error geométrico de Hitbox: El sprite debe medir '
            '${expectedPixels}x${expectedPixels} px (para size: $blockSize). '
            'Tu imagen mide ${image.width}x${image.height} px.',
        width: image.width,
        height: image.height,
      );
    }

    return SpriteValidationResult(
      isValid: true,
      message: 'Sprite validado correctamente.',
      width: image.width,
      height: image.height,
    );
  }
}
