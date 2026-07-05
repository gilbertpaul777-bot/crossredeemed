import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class E2EService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'e2e_private_key';
  
  // Initialize E2E keys on device if not exists
  static Future<void> initializeKeys() async {
    final existingKey = await _storage.read(key: _privateKeyKey);
    if (existingKey != null) return; // Keys already exist

    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    
    // Extract keys
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    
    // Save private key locally securely
    await _storage.write(key: _privateKeyKey, value: base64Encode(privateKeyBytes));
    
    // Upload public key to Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('user_public_keys').upsert({
        'user_id': user.id,
        'public_key': base64Encode(publicKey.bytes),
      });
    }
  }

  // Retrieve our private key
  static Future<SimpleKeyPair?> _getPrivateKey() async {
    final keyString = await _storage.read(key: _privateKeyKey);
    if (keyString == null) return null;
    
    final privateBytes = base64Decode(keyString);
    final algorithm = X25519();
    return await algorithm.newKeyPairFromSeed(privateBytes);
  }

  // Encrypt a message for a specific user (Pastor/User)
  static Future<String?> encryptMessage(String recipientId, String plaintext) async {
    try {
      // 1. Get recipient public key from DB
      final res = await Supabase.instance.client
          .from('user_public_keys')
          .select('public_key')
          .eq('user_id', recipientId)
          .maybeSingle();
      
      if (res == null) return null; // Recipient not enrolled in E2EE
      
      final recipientPublicBytes = base64Decode(res['public_key']);
      final recipientPublicKey = SimplePublicKey(recipientPublicBytes, type: KeyPairType.x25519);
      
      // 2. Get our private key
      final ourKeyPair = await _getPrivateKey();
      if (ourKeyPair == null) return null;

      // 3. Diffie-Hellman Key Exchange to get shared secret
      final algorithm = X25519();
      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: ourKeyPair,
        remotePublicKey: recipientPublicKey,
      );

      // 4. Encrypt with AES-GCM using shared secret
      final aesGcm = AesGcm.with256bits();
      final secretBox = await aesGcm.encrypt(
        utf8.encode(plaintext),
        secretKey: sharedSecret,
      );
      
      // Return IV + CipherText + MAC as base64
      return base64Encode(secretBox.concatenation());
    } catch (e) {
      return null;
    }
  }

  // Decrypt a message sent to us
  static Future<String?> decryptMessage(String senderId, String encryptedMessageBase64) async {
    try {
      // 1. Get sender public key from DB
      final res = await Supabase.instance.client
          .from('user_public_keys')
          .select('public_key')
          .eq('user_id', senderId)
          .maybeSingle();
          
      if (res == null) return null;
      final senderPublicBytes = base64Decode(res['public_key']);
      final senderPublicKey = SimplePublicKey(senderPublicBytes, type: KeyPairType.x25519);
      
      // 2. Get our private key
      final ourKeyPair = await _getPrivateKey();
      if (ourKeyPair == null) return null;

      // 3. Shared Secret
      final algorithm = X25519();
      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: ourKeyPair,
        remotePublicKey: senderPublicKey,
      );

      // 4. Decrypt
      final aesGcm = AesGcm.with256bits();
      final secretBox = SecretBox.fromConcatenation(
        base64Decode(encryptedMessageBase64),
        nonceLength: aesGcm.nonceLength,
        macLength: aesGcm.macAlgorithm.macLength,
      );
      
      final clearTextBytes = await aesGcm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );
      
      return utf8.decode(clearTextBytes);
    } catch (e) {
      return null; // Could not decrypt (wrong key, tampered, etc)
    }
  }
}
