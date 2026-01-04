import 'package:flutter/material.dart';

class Aboutadminscreen extends StatelessWidget {
  const Aboutadminscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমাদের সম্পর্কে'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/admin.png'),
              // ignore: unnecessary_underscores
              onBackgroundImageError: (_, __) =>
                  const Icon(Icons.person, size: 80),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Md. Nafiul Islam',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            // পদবী,
            Text(
              'অ্যাডমিন',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const Divider(height: 30, thickness: 2),
            // বিস্তারিত তথ্য,
            _buildInfoCard(
              icon: Icons.info,
              title: 'সাধারণ তথ্য',
              content:
                  'Md. Nafiul Islam একজন অভিজ্ঞ প্রশাসক যিনি প্রতিষ্ঠানের সার্বিক কার্যক্রম তত্ত্বাবধান করেন।',
            ),
            _buildInfoCard(
              icon: Icons.school,
              title: 'শিক্ষাগত যোগ্যতা',
              content: 'কম্পিউটার সায়েন্সে স্নাতকোত্তর ডিগ্রি অর্জন করেছেন।',
            ),
            _buildInfoCard(
              icon: Icons.work,
              title: 'অভিজ্ঞতা',
              content:
                  '৫+ বছরের অভিজ্ঞতা প্রশাসনিক কাজে এবং টিম ম্যানেজমেন্টে।',
            ),
            _buildInfoCard(
              icon: Icons.email,
              title: 'যোগাযোগ',
              content: 'ইমেইল: nafiul773@gmail.com\nফোন: +৮৮০১৭৭০০৬০৫৭৯',
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Text(content, style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),)
        ],
      ),
      ),
    );
  }
}
