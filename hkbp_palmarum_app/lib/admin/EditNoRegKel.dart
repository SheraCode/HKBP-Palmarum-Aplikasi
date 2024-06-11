import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/noRegistrasiKeluarga.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class EditNoRegKel extends StatefulWidget {
  final String id_noReg_kel; // Pastikan parameter ini ada di constructor

  EditNoRegKel({required this.id_noReg_kel});

  @override
  _EditNoRegKelState createState() => _EditNoRegKelState();
}

var height,width;
class _EditNoRegKelState extends State<EditNoRegKel> {
  late TextEditingController _NamaKepalaKeluargaController;
  late TextEditingController _NoKKController;

  @override
  void initState() {
    super.initState();
    _NamaKepalaKeluargaController = TextEditingController();
    _NoKKController = TextEditingController();
    fetchData();
  }

  @override
  void dispose() {
    _NamaKepalaKeluargaController.dispose();
    _NoKKController.dispose();
    super.dispose();
  }


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.11.31:2005/registrasi-keluarga/${widget.id_noReg_kel}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Received JSON Data: $jsonData'); // Print JSON data for debugging

        if (jsonData is List && jsonData.isNotEmpty) {
          final wartaData = jsonData[0]; // Get the first element from the list
          final NamaText = wartaData['nama_kepala_keluarga'] ?? ''; // Extract 'warta' text
          final nokk = wartaData['no_kk'].toString() ?? ''; // Extract 'warta' text

          setState(() {
            _NamaKepalaKeluargaController.text = NamaText;
            _NoKKController.text = nokk;
          });
        } else {
          throw Exception('Empty or invalid JSON data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }


  Future<void> _updateRegistrasiKeluarga() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
        );
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int idJemaat = decodedToken['id_jemaat'];

      final response = await http.put(
        Uri.parse('http://192.168.11.31:2005/registrasi-keluarga/update/${widget.id_noReg_kel}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_registrasi_keluarga': int.parse(widget.id_noReg_kel),
          'id_jemaat':idJemaat,
          'no_kk': int.parse(_NoKKController.text),
          'nama_kepala_keluarga': _NamaKepalaKeluargaController.text,
        }),
      );

      if (response.statusCode == 200) {
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Berhasil",
            message: "Berhasil Mengupdate Data Registrasi Keluarga",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => noRegKel()),
        );
      } else {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        String errorMessage = jsonData['message'] ?? 'Terjadi kesalahan saat memperbarui data';
        print('Failed to update data: $errorMessage');
        throw Exception('Failed to update data: $errorMessage');
      }
    } catch (e) {
      print('Error updating data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

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
                      padding: EdgeInsets.only(top: 25, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Builder(
                              builder: (BuildContext context) {
                                return InkWell(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Icon(
                                    Icons.sort,
                                    color: Colors.white,
                                    size: 45,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Edit Registrasi Keluarga",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Edit Registrasi Keluarga",
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
                          controller: _NoKKController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nomor Kartu Keluarga',
                            hintText: 'Isi Nomor Kartu Keluarga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _NamaKepalaKeluargaController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nama Kepala Keluarga',
                            hintText: 'Isi Nama Kepala Keluarga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_NoKKController.text.isNotEmpty && _NamaKepalaKeluargaController.text.isNotEmpty) {
                            _updateRegistrasiKeluarga();
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
                                'Update',
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
