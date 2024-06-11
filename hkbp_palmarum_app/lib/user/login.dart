import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/home.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/noRegistrasi.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<login> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late String email = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      var snackBar =  SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Gagal",
          message: "Email Atau Password Harus Diisi",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      try {
        // Membuat body untuk permintaan POST
        Map<String, dynamic> body = {
          'email': email,
          'password': password,
        };

        // Melakukan permintaan POST ke endpoint login
        final response = await http.post(
          Uri.parse('http://192.168.11.31:2005/jemaat/login'),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        );

        // Mendapatkan respon dari permintaan
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Jika login berhasil, tampilkan pesan sukses


          // Mendapatkan token dari respons
          String? token = responseData['token'];

          // Simpan token ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token!);

          Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
          String? role = decodedToken['role_jemaat'];

          print('ROLE $role');

          if(role == 'jemaat') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => home(token: token),
              ),
            );

            var snackBar =  SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
              title: "Success",
              message: "Anda Berhasil Login",
              contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          if(role == 'Bendahara') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => admin(token: token),
              ),
            );

            var snackBar =  SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Success",
                message: "Anda Berhasil Login",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          if(role == 'bendahara') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => admin(token: token),
              ),
            );

            var snackBar =  SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Success",
                message: "Anda Berhasil Login",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          if (role == 'majelis') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => admin(token: token),
              ),
            );

            var snackBar =  SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 169), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Success",
                message: "Anda Berhasil Login",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }


        } else {
          // Jika login gagal, tampilkan pesan gagal dari server
          var snackBar =  SnackBar(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155), // Menempatkan snackbar di atas layar
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: "Gagal",
              message: "Email Atau Password Salah",
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (error) {
        // Jika terjadi kesalahan dalam melakukan permintaan HTTP
        print('Error: $error');
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              "assets/bglogin.JPG",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),

            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Image.asset(
                    'assets/logo_hkbp.png',
                    width: 280.0,
                  ),
                ),
                SizedBox(height: 50),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ).p4().px24(),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ).p4().px24(),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => noRegister()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 1.0),
                    child: Container(
                      child: Text(
                        "Kamu Belum Terdaftar? Register Sekarang",
                        style: TextStyle(
                          fontSize: 18.0,
                          height: 2.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Raleway'
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
