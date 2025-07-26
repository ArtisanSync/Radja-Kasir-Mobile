import 'package:share_plus/share_plus.dart';

class ShareUtils{
  Future<void> shareFile(XFile file)async{
    await Share.shareXFiles([file], text: 'Receipt ${file.name}');
    return;
  }
}