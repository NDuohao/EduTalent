import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String _senderEmail = 'duohao1024@gmail.com';
  static const String _appPassword = 'nvbt nvsd iknh oslt';

  static Future<bool> sendOtpEmail(String recipientEmail, String otp) async {
    final smtpServer = gmail(_senderEmail, _appPassword);

    final message = Message()
      ..from = Address(_senderEmail, 'EduTalent Auth')
      ..recipients.add(recipientEmail)
      ..subject = 'EduTalent - Your Verification Code'
      ..text = 'Your verification code is: $otp\n\nThis code will expire in 5 minutes.'
      ..html = "<h1>EduTalent Verification</h1><p>Your verification code is: <b>$otp</b></p><p>This code will expire in 5 minutes.</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('Other error: $e');
      return false;
    }
  }
}
