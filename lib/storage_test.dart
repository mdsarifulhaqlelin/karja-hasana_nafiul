import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class StorageTestScreen extends StatefulWidget {
  const StorageTestScreen({super.key});

  @override
  State<StorageTestScreen> createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  String _result = '';
  bool _isTesting = false;

  Future<void> _testStorage() async {
    setState(() {
      _isTesting = true;
      _result = 'Testing Firebase Storage...\n';
    });

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _result += '✅ Firebase initialized\n';
      
      // 2. Get Storage instance
      final storage = FirebaseStorage.instance;
      final bucket = storage.bucket;
      _result += '📦 Storage bucket: $bucket\n';
      
      // 3. Try to list files (if any)
      try {
        final listResult = await storage.ref().listAll();
        _result += '📂 Storage has ${listResult.items.length} files\n';
      } catch (e) {
        _result += '⚠️ Cannot list files: $e\n';
      }
      
      // 4. Upload test file
      final testRef = storage.ref().child('test_${DateTime.now().millisecondsSinceEpoch}.txt');
      await testRef.putString(
        'Test upload from Korje Hasana app at ${DateTime.now()}',
        metadata: SettableMetadata(contentType: 'text/plain'),
      );
      _result += '✅ Test file uploaded\n';
      
      // 5. Get download URL
      final url = await testRef.getDownloadURL();
      _result += '🔗 Download URL: $url\n';
      
      // 6. Download and verify
      final downloadedData = await testRef.getData();
      _result += '✅ File downloaded (${downloadedData?.length ?? 0} bytes)\n';
      
      // 7. Delete test file
      await testRef.delete();
      _result += '🧹 Test file deleted\n';
      
      _result += '\n🎉 Firebase Storage is working perfectly!\n';
      
    } catch (e) {
      _result += '\n❌ Storage test failed:\n$e\n\n';
      _result += '📋 Steps to fix:\n';
      _result += '1. Go to Firebase Console\n';
      _result += '2. Select project: kerja-hasana\n';
      _result += '3. Click "Storage" in left menu\n';
      _result += '4. Click "Get Started"\n';
      _result += '5. Select "Start in test mode"\n';
      _result += '6. Choose location: us-central1\n';
      _result += '7. Click "Done"\n';
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isTesting ? null : _testStorage,
              child: const Text('Test Firebase Storage'),
            ),
            const SizedBox(height: 20),
            if (_isTesting) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}