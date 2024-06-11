import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:hkbp_palmarum_app/user/register.dart';

class roleRegister extends StatefulWidget {
  @override
  _RoleRegisterState createState() => _RoleRegisterState();
}

class _RoleRegisterState extends State<roleRegister> {
  TextEditingController registerController = TextEditingController();
  List<String> _dropdownItems = [];
  String? selectedName; // Remove underscore

  @override
  void initState() {
    super.initState();
  }

  void _getNames(String noRegister) async {
    var url = Uri.parse('http://localhost:2005/jemaat');
    var response = await http.post(url, body: {'id_jemaat': noRegister});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _dropdownItems = List<String>.from(data['nama_depan']);
      });
    } else {
      print('Failed to load jemaat names');
    }
  }

  void _login() {
    String noRegister = registerController.text.trim();

    if (noRegister.isEmpty) {
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Registrasi Gagal",
          message: "Nomor Registrasi Harus Diisi",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _getNames(noRegister);
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Nama Pemilik Akun',
                      hintText: 'Pilih Role Keluarga',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    value: selectedName,
                    onChanged: (newValue) {
                      setState(() {
                        selectedName = newValue;
                      });
                    },
                    items: _dropdownItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
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
                        Icon(Icons.add_circle_rounded, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Registrasi',
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
                    padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 1.0),
                    child: Container(
                      child: Text(
                        "Kamu Mempunyai Akun? Login Sekarang",
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
