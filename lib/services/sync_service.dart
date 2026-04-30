import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current user's UID or signs in anonymously if needed.
  static Future<String?> _getUserId() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        final credential = await _auth.signInAnonymously();
        user = credential.user;
      }
      return user?.uid;
    } catch (e) {
      debugPrint('Sync Error (Auth): $e');
      return null;
    }
  }

  /// Pushes all local Hive data to Firestore
  static Future<bool> pushToCloud() async {
    final uid = await _getUserId();
    if (uid == null) return false;

    try {
      final batch = _firestore.batch();
      final userDoc = _firestore.collection('users').doc(uid);

      // 1. Settings & Profile
      final settingsBox = HiveService.getSettingsBox();
      final userBox = HiveService.getUserBox();
      
      final settingsData = settingsBox.toMap();
      final profileData = userBox.toMap();

      batch.set(userDoc, {
        'lastSync': FieldValue.serverTimestamp(),
        'settings': settingsData,
        'profile': profileData,
      }, SetOptions(merge: true));

      // 2. Transactions
      final txBox = await HiveService.openBox();
      final txData = txBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
      batch.set(userDoc.collection('data').doc('transactions'), {'list': txData});

      // 3. Investments
      final invBox = HiveService.getInvestmentsBox();
      final invData = invBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
      batch.set(userDoc.collection('data').doc('investments'), {'list': invData});

      // 4. Rough Plans
      final roughBox = HiveService.getRoughPlansBox();
      final roughData = roughBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
      batch.set(userDoc.collection('data').doc('rough_plans'), {'list': roughData});

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Sync Error (Push): $e');
      return false;
    }
  }

  /// Pulls data from Firestore and overwrites local Hive data
  static Future<bool> pullFromCloud() async {
    final uid = await _getUserId();
    if (uid == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data()!;
      
      // 1. Restore Settings & Profile
      final settingsBox = HiveService.getSettingsBox();
      final userBox = HiveService.getUserBox();

      if (data['settings'] != null) {
        await settingsBox.putAll(Map<String, dynamic>.from(data['settings']));
      }
      if (data['profile'] != null) {
        await userBox.putAll(Map<String, dynamic>.from(data['profile']));
      }

      // 2. Restore Sub-collections
      final collections = ['transactions', 'investments', 'rough_plans'];
      for (var coll in collections) {
        final doc = await _firestore.collection('users').doc(uid).collection('data').doc(coll).get();
        if (doc.exists && doc.data()?['list'] != null) {
          final list = List<Map>.from(doc.data()!['list']);
          Box box;
          if (coll == 'transactions') {
            box = await HiveService.openBox();
          } else if (coll == 'investments') {
            box = HiveService.getInvestmentsBox();
          } else {
            box = HiveService.getRoughPlansBox();
          }
          
          await box.clear();
          for (var item in list) {
            await box.put(item['id'], Map<String, dynamic>.from(item));
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Sync Error (Pull): $e');
      return false;
    }
  }

  /// Exports all data to a JSON string for manual backup
  static Future<String> exportToJson() async {
    final Map<String, dynamic> fullData = {};
    
    fullData['settings'] = HiveService.getSettingsBox().toMap();
    fullData['profile'] = HiveService.getUserBox().toMap();
    
    final txBox = await HiveService.openBox();
    fullData['transactions'] = txBox.values.toList();
    
    fullData['investments'] = HiveService.getInvestmentsBox().values.toList();
    fullData['rough_plans'] = HiveService.getRoughPlansBox().values.toList();
    
    return jsonEncode(fullData);
  }

  /// Imports data from a JSON string
  static Future<void> importFromJson(String json) async {
    final Map<String, dynamic> data = jsonDecode(json);
    
    if (data['settings'] != null) await HiveService.getSettingsBox().putAll(Map<String, dynamic>.from(data['settings']));
    if (data['profile'] != null) await HiveService.getUserBox().putAll(Map<String, dynamic>.from(data['profile']));
    
    if (data['transactions'] != null) {
      final box = await HiveService.openBox();
      await box.clear();
      for (var item in data['transactions']) await box.put(item['id'], Map<String, dynamic>.from(item));
    }
    
    if (data['investments'] != null) {
      final box = HiveService.getInvestmentsBox();
      await box.clear();
      for (var item in data['investments']) await box.put(item['id'], Map<String, dynamic>.from(item));
    }

    if (data['rough_plans'] != null) {
      final box = HiveService.getRoughPlansBox();
      await box.clear();
      for (var item in data['rough_plans']) await box.put(item['id'], Map<String, dynamic>.from(item));
    }
  }
}
