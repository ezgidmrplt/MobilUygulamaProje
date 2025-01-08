import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketini ekledik.
import 'anaekran.dart'; // Anaekran dosyasını dahil ediyoruz.

class GirisEkrani extends StatefulWidget {
  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _animationController;
  late Animation<Color?> _usernameBackgroundAnimation;
  late Animation<Color?> _passwordBackgroundAnimation;
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _usernameBackgroundAnimation = ColorTween(
      begin: Color(0xFFFFEBEE), // Açık pembe
      end: Color(0xFFFFCDD2), // Daha koyu açık pembe
    ).animate(_animationController);

    _passwordBackgroundAnimation = ColorTween(
      begin: Color(0xFFFFEBEE), // Açık pembe
      end: Color(0xFFFFCDD2), // Daha koyu açık pembe
    ).animate(_animationController);

    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BoardScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı adı veya şifre hatalı!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/gorsel.png',
              fit: BoxFit.cover, // Görselin ekranı kaplamasını sağlar
            ),
          ),
          // Transparan pembe arka plan ekliyoruz
          Positioned.fill(
            child: Container(
              color: Color(0xA8FFCDD2), // Çok açık pembe rengi ve opaklık
            ),
          ),
          // Ön plan içerikleri
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalama
                crossAxisAlignment: CrossAxisAlignment.center, // Yatayda ortalama
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
                  SizedBox(height: 20), // Aradaki boşluğu azalttık
                  // Resme zoom efekti ekliyoruz
                  ClipRect(
                    child: Align(
                      alignment: Alignment(0.0, 0.4), // Y eksenini daha fazla kaydırdık
                      heightFactor: 2, // Resmin yukarıdan aşağıya büyütülmesi
                      child: Transform.scale(
                        scale: 3.0, // Resmi daha fazla büyütüyoruz
                        child: Image.asset(
                          'assets/logogibi.png', // Resim dosyasının yolu
                          height: 150, // Resmin boyutu
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30), // Resim ile giriş formu arasındaki boşluk
                  AnimatedBuilder(
                    animation: _usernameBackgroundAnimation,
                    builder: (context, child) {
                      return TextField(
                        focusNode: _usernameFocusNode,
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _usernameBackgroundAnimation.value,
                          labelText: 'Kullanıcı Adı',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _usernameBackgroundAnimation.value!,
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
                  SizedBox(height: 8), // Kullanıcı adı ile şifre arasındaki boşluğu azalttık
                  AnimatedBuilder(
                    animation: _passwordBackgroundAnimation,
                    builder: (context, child) {
                      return TextField(
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _passwordBackgroundAnimation.value,
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _passwordBackgroundAnimation.value!,
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
                  SizedBox(height: 16), // Şifre ile buton arasındaki boşluğu azalttık
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCDD2), // Açık pembe
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
