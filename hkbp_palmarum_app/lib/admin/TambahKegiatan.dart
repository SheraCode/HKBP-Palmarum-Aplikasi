import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/kegiatan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahKegiatan extends StatefulWidget {
  @override
  _TambahKegiatanState createState() => _TambahKegiatanState();
}

class _TambahKegiatanState extends State<TambahKegiatan> {
  var height, width;
  File? _image;
  int _selectedKegiatanType = 1; // Default value: Kegiatan Diluar Gereja (1)
  TextEditingController _namaKegiatanController = TextEditingController();
  TextEditingController _lokasiKegiatanController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _printDropdownValue(int? value) {
    setState(() {
      _selectedKegiatanType = value!;
      print('Nilai dropdown: $_selectedKegiatanType');
    });
  }

  Future<void> _createKegiatan() async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        // Token tidak tersedia, handle error atau minta pengguna login ulang
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
        );
        return;
      }

      // Dekode token untuk mendapatkan id_jemaat
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int idJemaat = decodedToken['id_jemaat'];

      final uri = Uri.parse('http://192.168.11.31:2005/berita/create');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields to the request
      request.fields['IDJenisKegiatan'] = _selectedKegiatanType.toString();
      request.fields['IDJemaat'] = idJemaat.toString();
      request.fields['NamaKegiatan'] = _namaKegiatanController.text;
      request.fields['LokasiKegiatan'] = _lokasiKegiatanController.text;
      request.fields['Keterangan'] = _keteranganController.text;

      // Add image file if available
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Kegiatan berhasil dibuat.');
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Membuat Kegiatan",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => kegiatan()),
        );

        // Handle success response here
      } else {
        print('Gagal membuat kegiatan. Status code: ${response.statusCode}');
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Failed",
            message: "Gagal Membuat Kegiatan",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Handle error response here
      }
    } catch (e) {
      print('Error saat membuat kegiatan: $e');
      // Handle exception/error here
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                      Padding(padding: EdgeInsets.only(top: 25, left: 15, right: 15)),
                      Row(
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
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          left: 15,
                          right: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tambah Kegiatan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tambah Kegiatan HKBP Palmarum Tarutung",
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
                        GestureDetector(
                          onTap: () {
                            _getImage(ImageSource.gallery);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _image != null
                                ? ClipOval(
                              child: Image.file(
                                _image!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : ClipOval(
                              child: Image.asset(
                                "assets/bglogin.JPG",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _getImage(ImageSource.gallery);
                                },
                                child: Text('Ambil dari Galeri'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _getImage(ImageSource.camera);
                                },
                                child: Text('Ambil dari Kamera'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: DropdownButtonFormField<int>(
                            value: _selectedKegiatanType,
                            decoration: InputDecoration(
                              labelText: 'Jenis Kegiatan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            items: <int>[
                              1, // Kegiatan Diluar Gereja
                              2, // Kegiatan didalam Gereja
                            ].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  value == 1 ? 'Kegiatan Diluar Gereja' : 'Kegiatan didalam Gereja',
                                ),
                              );
                            }).toList(),
                            onChanged: _printDropdownValue,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _namaKegiatanController,
                            decoration: InputDecoration(
                              labelText: 'Nama Kegiatan',
                              hintText: 'Enter your Name of Activity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _lokasiKegiatanController,
                            decoration: InputDecoration(
                              labelText: 'Lokasi Kegiatan',
                              hintText: 'Enter the Location of Activity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _keteranganController,
                            maxLines: null, // Untuk membuat TextFormField bisa multi-line
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              hintText: 'Masukkan keterangan kegiatan...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: _createKegiatan,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: DrawerWidget(),
    );
  }
}

