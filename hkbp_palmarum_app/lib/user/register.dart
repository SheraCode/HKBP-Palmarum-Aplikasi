import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<register> with TickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _register() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();
    String address = addressController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || address.isEmpty) {
      var snackBar = SnackBar(
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height -
                155), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Register Gagal",
          message: "Pastikan Anda Mengisi Semua Form",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Perform login logic
      var snackBar = SnackBar(
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height -
                155), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Register Berhasil",
          message: "Anda Berhasil Register Akun",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                login()), // Ganti LoginPage dengan halaman login yang sesuai
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              "assets/bglogin.JPG", // Ganti dengan path gambar Anda
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Image.asset(
                    'assets/logo_hkbp.png', // Ganti dengan path gambar Anda
                    // Sesuaikan bagaimana gambar ditampilkan dalam kontainer
                    width: 280.0,
                  ),
                ),
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
                    prefixIcon: Icon(Icons.email), // Icon surat untuk email
                  ),
                ).p4().px24(),
                HeightBox(10),
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.lock), // Icon surat untuk email
                  ),
                ).p4().px24(),
                HeightBox(10),
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Nama",
                    errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.person), // Icon surat untuk email
                  ),
                ).p4().px24(),
                HeightBox(10),
                TextField(
                  controller: addressController,
                  keyboardType: TextInputType
                      .multiline, // Mengatur jenis keyboard sebagai multiline
                  // maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Alamat",
                    errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    prefixIcon: Icon(Icons.home), // Icon surat untuk email
                  ),
                ).p4().px24(),
                HeightBox(10),
                GestureDetector(
                  onTap: _register,
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
                        Icon(Icons.add_circle, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Register',
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
                        MaterialPageRoute(builder: (context) => login()),
                      );
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 7.0, horizontal: 1.0),
                      child: Container(
                        child: new Text(
                          "Kamu Mempunyai Akun? Login Sekarang",
                          style: new TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
