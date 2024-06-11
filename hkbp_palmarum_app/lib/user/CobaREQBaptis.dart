import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FinalBaptis.dart'; // Import the FinalBaptis widget

class CobaBaptis extends StatefulWidget {
  @override
  _CobaBaptisState createState() => _CobaBaptisState();
}

class _CobaBaptisState extends State<CobaBaptis> {
  TextEditingController _namaDepanController = TextEditingController();
  TextEditingController _namaBelakangController = TextEditingController();
  int? _selectedKepalaKeluarga;
  int? _selectedHubunganKeluarga;

  List<Map<String, dynamic>> hubkeluarga = [
    {"id": 1, "name": "Kepala Keluarga"},
    {"id": 2, "name": "Isteri"},
    {"id": 3, "name": "Anak"},
  ];

  List<Map<String, dynamic>> pelayanIbadah = [];

  @override
  void initState() {
    super.initState();
    _fetchPelayanIbadah().then((data) {
      setState(() {
        pelayanIbadah = data;
      });
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPelayanIbadah() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Token tidak tersedia, handle error atau minta pengguna login ulang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
      );
      return [];
    }

    // Dekode token untuk mendapatkan id_jemaat
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int noREG = decodedToken['id_registrasi_keluarga'];

    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/anak-keluarga/$noREG'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => {
        'id': e['id_jemaat'],
        'noregkel':e['no_registrasi_keluarga'],
        'name': e['nama_depan'] + ' ' + e['nama_belakang'],
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _createAccountJemaat() async {
    final response = await http.post(
      Uri.parse('http://192.168.11.31:2005/jemaat/create/account'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nama_depan": _namaDepanController.text,
        "nama_belakang": _namaBelakangController.text,
        "no_registrasi_keluarga": _selectedKepalaKeluarga,
        "id_hub_keluarga": _selectedHubunganKeluarga,
      }),
    );

    if (response.statusCode == 200) {
      print('Jemaat account successfully created');
      var snackBar = SnackBar(
        content: Text('Jemaat account successfully created'),
        backgroundColor: Colors.green,
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
                   SizedBox(height: 60,),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Request Baptis",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Request Baptis HKBP Palmarum",
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
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Anak',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          value: _selectedKepalaKeluarga,
                          items: pelayanIbadah.map((pelayan) {
                            return DropdownMenuItem<int>(
                              value: pelayan['id'],
                              child: Text(pelayan['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKepalaKeluarga = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_selectedKepalaKeluarga != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FinalBaptis(
                                  idJemaat: _selectedKepalaKeluarga!,
                                  id_no_registrasi: pelayanIbadah.firstWhere((element) => element['id'] == _selectedKepalaKeluarga)['noregkel'],
                                ),
                              ),
                            );

                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pilih anak terlebih dahulu')),
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
                              Icon(Icons.play_circle, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Selanjutnya',
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
