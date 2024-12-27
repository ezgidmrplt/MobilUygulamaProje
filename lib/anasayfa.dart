import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'anaekran.dart'; // Anaekran dosyasını dahil ediyoruz.

class GirisEkrani extends StatefulWidget {
  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _colorController;

  late List<AnimationController> _letterControllers;
  late List<Animation<double>> _letterAnimations;
  late List<String> _titleText;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _titleText = ['W', 'o', 'r', 'k', 'A', 'g', 'e', 'n', 'd', 'a'];

    _letterControllers = List.generate(_titleText.length, (index) {
      return AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
      );
    });

    _letterAnimations = List.generate(_letterControllers.length, (index) {
      return Tween<double>(begin: 1.0, end: 0.5).animate(
        CurvedAnimation(
          parent: _letterControllers[index],
          curve: Curves.easeInOut,
        ),
      );
    });

    _opacityController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _colorController.repeat(reverse: true);

    _startLetterAnimations();
    _opacityController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _startLetterAnimations() async {
    for (int i = 0; i < _letterControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 300 * i));
      _letterControllers[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _colorController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    for (var controller in _letterControllers) {
      controller.dispose();
    }
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
      backgroundColor: Color(0xFFD4F6FF),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_titleText.length, (index) {
            return AnimatedBuilder(
              animation: _letterControllers[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _letterAnimations[index].value,
                  child: Text(
                    _titleText[index],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                );
              },
            );
          }),
        ),
        backgroundColor: Color(0xFFAE445A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacityController,
              child: Image.asset(
                'assets/avatar.png',
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24),
            SlideTransition(
              position: Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
                  .animate(_slideController),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFAE445A), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFAE445A), width: 1.0),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFAE445A), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFAE445A), width: 1.0),
                      ),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _scaleController,
                curve: Curves.easeOut,
              ),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFAE445A),
                ),
                child: Text('Giriş Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
