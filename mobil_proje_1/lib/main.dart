import 'package:flutter/material.dart';
import 'anasayfa.dart'; // Giriş ekranı dosyasını çağırıyoruz


void main() {
  runApp(ToplantiUygulamasi());
}

class ToplantiUygulamasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GirisEkrani(),
    );
  }
}
