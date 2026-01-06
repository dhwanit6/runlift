import 'package:flutter/material.dart';
import '../../../shared/widgets/atmospheric_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const AtmosphericBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '''
Last updated: [Date]

RunLift ("us", "we", or "our") operates the RunLift mobile application (the "Service").

This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.

We use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy.

Information Collection and Use
----------------------------------

We collect several different types of information for various purposes to provide and improve our Service to you.

Types of Data Collected:
- Personal Data: While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data").
- Usage Data: We may also collect information on how the Service is accessed and used ("Usage Data").
- Location Data: We use location data to track your runs and calculate distance and pace. This data is stored locally on your device and is not shared with third parties.

Use of Data
------------

RunLift uses the collected data for various purposes:
- To provide and maintain our Service
- To notify you about changes to our Service
- To provide customer support
- To gather analysis or valuable information so that we can improve our Service

Security of Data
------------------

The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

Changes to This Privacy Policy
----------------------------------

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

Contact Us
------------

If you have any questions about this Privacy Policy, please contact us.
            ''',
            style: TextStyle(color: Colors.white70, height: 1.6),
          ),
        ),
      ),
    );
  }
}
