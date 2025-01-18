import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin.dart'; // Admin ekranı için import.
import 'anaekran.dart'; // Anaekran dosyasını dahil ediyoruz.

// Giriş ekranını temsil eden sınıf.
class GirisEkrani extends StatefulWidget {
  @override
  _GirisEkraniDurumu createState() => _GirisEkraniDurumu();
}

// Giriş ekranının durumu sınıfı.
class _GirisEkraniDurumu extends State<GirisEkrani>
    with SingleTickerProviderStateMixin {
  // Kullanıcı adı ve şifre için kontrolcüler.
  final TextEditingController _kullaniciAdiKontrolcu = TextEditingController();
  final TextEditingController _sifreKontrolcu = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _animasyonKontrolcu;
  late Animation<Color?> _kullaniciAdiArkaPlanAnimasyonu;
  late Animation<Color?> _sifreArkaPlanAnimasyonu;
  late FocusNode _kullaniciAdiOdakNoktasi;
  late FocusNode _sifreOdakNoktasi;

  @override
  void initState() {
    super.initState();
    _kullaniciAdiOdakNoktasi = FocusNode();
    _sifreOdakNoktasi = FocusNode();

    _animasyonKontrolcu = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _kullaniciAdiArkaPlanAnimasyonu = ColorTween(
      begin: Color(0xFFFFEBEE),
      end: Color(0xFFFFCDD2),
    ).animate(_animasyonKontrolcu);

    _sifreArkaPlanAnimasyonu = ColorTween(
      begin: Color(0xFFFFEBEE),
      end: Color(0xFFFFCDD2),
    ).animate(_animasyonKontrolcu);

    // Kullanıcı adı alanına odaklanıldığında animasyon başlat.
    _kullaniciAdiOdakNoktasi.addListener(() {
      if (_kullaniciAdiOdakNoktasi.hasFocus) {
        _animasyonKontrolcu.forward();
      } else {
        _animasyonKontrolcu.reverse();
      }
    });

    // Şifre alanına odaklanıldığında animasyon başlat.
    _sifreOdakNoktasi.addListener(() {
      if (_sifreOdakNoktasi.hasFocus) {
        _animasyonKontrolcu.forward();
      } else {
        _animasyonKontrolcu.reverse();
      }
    });
  }

  @override
  void dispose() {
    _kullaniciAdiKontrolcu.dispose();
    _sifreKontrolcu.dispose();
    _animasyonKontrolcu.dispose();
    _kullaniciAdiOdakNoktasi.dispose();
    _sifreOdakNoktasi.dispose();
    super.dispose();
  }

  // Kullanıcı giriş işlemi.
  Future<void> _girisYap() async {
    try {
      UserCredential kullaniciBilgisi = await _auth.signInWithEmailAndPassword(
        email: _kullaniciAdiKontrolcu.text.trim(),
        password: _sifreKontrolcu.text.trim(),
      );
      if (kullaniciBilgisi.user != null) {
        // Eğer yönetici ise yönetici ekranına yönlendir.
        if (kullaniciBilgisi.user!.email == "admin@gmail.com") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminEkrani()),
          );
        } else {
          // Diğer kullanıcılar için ana ekrana yönlendir.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Anaekran()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı adı veya şifre hatalı!', style: GoogleFonts.lobster())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/gorsel.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Color(0xA8FFCDD2),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'WorkAgenda',
                      style: GoogleFonts.lobster(
                        textStyle: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ClipRect(
                    child: Align(
                      alignment: Alignment(0.0, 0.4),
                      heightFactor: 2,
                      child: Transform.scale(
                        scale: 3.0,
                        child: Image.asset(
                          'assets/logogibi.png',
                          height: 150,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _kullaniciAdiArkaPlanAnimasyonu,
                    builder: (context, child) {
                      return TextField(
                        focusNode: _kullaniciAdiOdakNoktasi,
                        controller: _kullaniciAdiKontrolcu,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _kullaniciAdiArkaPlanAnimasyonu.value,
                          labelText: 'Kullanıcı Adı',
                          labelStyle: GoogleFonts.lobster(),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _kullaniciAdiArkaPlanAnimasyonu.value!,
                                width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1.0),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _sifreArkaPlanAnimasyonu,
                    builder: (context, child) {
                      return TextField(
                        focusNode: _sifreOdakNoktasi,
                        controller: _sifreKontrolcu,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _sifreArkaPlanAnimasyonu.value,
                          labelText: 'Şifre',
                          labelStyle: GoogleFonts.lobster(),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _sifreArkaPlanAnimasyonu.value!,
                                width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1.0),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _girisYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCDD2),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Giriş Yap',
                      style: GoogleFonts.lobster(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
