import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:posto/core/encryption/encryption_provider.dart';

import '../utils/cloud_functions_endpoints.dart';

class EncryptionService {
  Future<Map<String, dynamic>> encryptData(String plaintext, String publicKey) async {
    final key = generateSymmetricKey();
    final encryptedDataMap = encryptWithSymmetricKey(plaintext, key);
    final encryptedKey = await encryptDek(key, publicKey);

    return {
      'data': encryptedDataMap['data']!,
      'iv': encryptedDataMap['iv']!,
      'key': encryptedKey,
    };
  }

  Future<String> decryptDek(Ref ref, String encryptedDek) async {
    KeyPair keyPar = await ref.read(encryptionNotifierProvider.notifier).getLocalKeyPair();

    String dek = await decryptDekAPI(encryptedDek, keyPar.publicKey);

    // Decrypt dek using private key
    return decryptWithRsaPrivateKey(dek, keyPar.privateKey);
  }

  String decryptData(Map<String, dynamic> encryptedMap, String key) {
    return decryptWithSymmetricKey(encryptedMap['data']!, encryptedMap['iv']!, key);
  }

  Future<String> encryptDek(String dek, String publicKey) async {
    return encryptWithRsaPublicKey(dek, publicKey);
  }

  Future<String> getChatKey(Ref ref, String chatId) async {
    KeyPair keyPar = await ref.read(encryptionNotifierProvider.notifier).getLocalKeyPair();

    // Send chatId + public key
    String dek = await getChatKeyAPI(chatId, keyPar.publicKey);

    // Decrypt dek using private key
    String decrypted = await decryptWithRsaPrivateKey(dek, keyPar.privateKey);
    return decrypted;
  }

  Map<String, dynamic> encryptWithSymmetricKey(String plaintext, String key) {
    final iv = _generateIv();
    final cipher = GCMBlockCipher(AESEngine());

    final params = AEADParameters(KeyParameter(base64Decode(key)), 128, iv, Uint8List(0));
    cipher.init(true, params);

    final input = Uint8List.fromList(utf8.encode(plaintext));
    final ciphertext = cipher.process(input);

    return {
      'iv': base64Encode(iv),
      'data': base64Encode(ciphertext),
    };
  }

  String decryptWithSymmetricKey(String encryptedText, String encodedIv, String key) {
    final iv = base64Decode(encodedIv);
    final ciphertext = base64Decode(encryptedText);

    final cipher = GCMBlockCipher(AESEngine());

    final params = AEADParameters(KeyParameter(base64Decode(key)), 128, iv, Uint8List(0));
    cipher.init(false, params);

    final output = cipher.process(ciphertext);
    return utf8.decode(output);
  }

  String generateSymmetricKey() {
    final secureRandom = Random.secure();
    final key = Uint8List.fromList(List.generate(32, (_) => secureRandom.nextInt(256)));
    return base64Encode(key);
  }

  Uint8List _generateIv() {
    final secureRandom = Random.secure();
    return Uint8List.fromList(List.generate(12, (_) => secureRandom.nextInt(256)));
  }

  Future<KeyPair> generateRsaKeyPair() async {
    return RSA.generate(2048);
  }

  Future<String> encryptWithRsaPublicKey(String plaintext, String publicKey) async {
    return RSA.encryptOAEP(plaintext, '', Hash.SHA256, publicKey);
  }

  Future<String> decryptWithRsaPrivateKey(String ciphertext, String privateKey) async {
    return RSA.decryptOAEP(ciphertext, '', Hash.SHA256, privateKey);
  }
}
