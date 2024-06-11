import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TambahAnggotaJemaat extends StatefulWidget {
  @override
  _TambahAnggotaJemaatState createState() => _TambahAnggotaJemaatState();
}

class _TambahAnggotaJemaatState extends State<TambahAnggotaJemaat> {
  TextEditingController _namaDepanController = TextEditingController();
  TextEditingController _namaBelakangController = TextEditingController();
  int? _selectedHubunganKeluarga;
  int? _idRegistrasiKeluarga;

  List<Map<String, dynamic>> hubkeluarga = [
    {"id": 3, "name": "Anak"},
  ];

  @override
  void initState() {
    super.initState();
    _loadIdRegistrasiKeluarga();
  }

  Future<void> _loadIdRegistrasiKeluarga() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token: $token');
    if (token != null && token.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          _idRegistrasiKeluarga = decodedToken['id_registrasi_keluarga'];
        });
      } catch (error) {
        print('Error decoding token: $error');
      }
    }
  }



  Future<void> _createAccountJemaat() async {
    if (_idRegistrasiKeluarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID Registrasi Keluarga tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    final response = await http.post(
      Uri.parse('http://192.168.11.31:2005/registrasi-anak/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "nama_depan": _namaDepanController.text,
        "nama_belakang": _namaBelakangController.text,
        "id_hub_keluarga": _selectedHubunganKeluarga,
        "id_registrasi_keluarga": _idRegistrasiKeluarga,
      }),
    );

    if (response.statusCode == 200) {
      print('Jemaat account successfully created');
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Berhasil",
          message: "Berhasil Request Tambah Anggota Jemaat",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } else {
      var snackBar = SnackBar(
        content: Text('Failed to create jemaat account'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception('Failed to create jemaat account');
    }
  }

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.indigo,
          child: Column(
            children: [
              Container(
                height: height * 0.22,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tambah \nAnggota Keluarga",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tambah Jemaat Palmarum",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _namaDepanController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nama Depan',
                            hintText: 'Isi Nama Depan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _namaBelakangController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nama Belakang',
                            hintText: 'Isi Nama Belakang',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Hubungan Keluarga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          value: _selectedHubunganKeluarga,
                          items: hubkeluarga.map((hubungan) {
                            return DropdownMenuItem<int>(
                              value: hubungan['id'],
                              child: Text(hubungan['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHubunganKeluarga = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_selectedHubunganKeluarga != null &&
                              _namaDepanController.text.isNotEmpty &&
                              _namaBelakangController.text.isNotEmpty) {
                            _createAccountJemaat();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Harap lengkapi semua informasi'),
                              ),
                            );
                          }
                        },
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
                                'Tambah',
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
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Batal',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: DrawerWidget(),
    );
  }
}
