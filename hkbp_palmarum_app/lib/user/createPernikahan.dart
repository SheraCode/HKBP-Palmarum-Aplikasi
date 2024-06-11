import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';



class craetePernikahan extends StatefulWidget {
  @override
  _CreatePernikahanState createState() => _CreatePernikahanState();
}

class _CreatePernikahanState extends State<craetePernikahan> {
  var height, width;
  List<String> _dropdownItems = [
    'Johannes Bastian Jasa Sipayung, S.Tr.Kom',
    'Christia Otenia Br Purba, S.M',
    'Bastian Otenia Sipayung',
  ];

  String? _selectedName;
  String? _selectedChurch;
  String? _otherChurchName;
  List<String> _churchList = ['HKBP', 'Gereja lain'];
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDated = DateTime.now();
  TextEditingController _datePemberkatan = TextEditingController();
  bool _showOtherChurchTextField = false;
  TextEditingController _otherChurchController = TextEditingController();

  // TextEditingControllers
  final TextEditingController _namaGerejaLakiController = TextEditingController();
  final TextEditingController _namaLakiController = TextEditingController();
  final TextEditingController _namaAyahLakiController = TextEditingController();
  final TextEditingController _namaIbuLakiController = TextEditingController();
  final TextEditingController _namaGerejaPerempuanController = TextEditingController();
  final TextEditingController _namaPerempuanController = TextEditingController();
  final TextEditingController _namaAyahPerempuanController = TextEditingController();
  final TextEditingController _namaIbuPerempuanController = TextEditingController();

  // Fungsi untuk mendapatkan ID Jemaat dari token
  Future<int?> getIdJemaatFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Token tidak tersedia, handle error atau minta pengguna login ulang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
      );
      return null;
    }

    // Dekode token untuk mendapatkan id_jemaat
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int idJemaat = decodedToken['id_jemaat'];
    return idJemaat;
  }

  // Fungsi untuk mengirim data ke API
  Future<void> submitPernikahan() async {
    final int? idJemaat = await getIdJemaatFromToken();
    if (idJemaat == null) {
      return;
    }

    final String url = 'http://192.168.11.31:2005/pernikahan/create';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id_jemaat': idJemaat,
        'nama_gereja_laki': _namaGerejaLakiController.text,
        'nama_laki': _namaLakiController.text,
        'nama_ayah_laki': _namaAyahLakiController.text,
        'nama_ibu_laki': _namaIbuLakiController.text,
        'nama_gereja_perempuan': _namaGerejaPerempuanController.text,
        'nama_perempuan': _namaPerempuanController.text,
        'nama_ayah_perempuan': _namaAyahPerempuanController.text,
        'nama_ibu_perempuan': _namaIbuPerempuanController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Jika berhasil, tampilkan pesan sukses
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Berhasil Request Pernikahan Jemaat",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => home()),
      );
    } else {
      // Jika gagal, tampilkan pesan error
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Failed",
          message: "Gagal Request Pernikahan Jemaat",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bglogin.JPG"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: height * 0.22,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding:
                          EdgeInsets.only(top: 25, left: 15, right: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Widget yang Anda ingin masukkan di sini
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
                              "Pernikahan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Request Surat Pernikahan Jemaat",
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
                    //   coding diisini
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tambahan widget lainnya

                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaGerejaLakiController,
                              decoration: InputDecoration(
                                labelText: 'Nama Gereja Laki-Laki',
                                hintText: 'Isi Nama Gereja Laki-laki',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaLakiController,
                              decoration: InputDecoration(
                                labelText: 'Nama Laki Laki',
                                hintText: 'Isi Nama Laki',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaAyahLakiController,
                              decoration: InputDecoration(
                                labelText: 'Nama Ayah Laki-Laki',
                                hintText: 'Isi Nama Ayah Laki-laki',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaIbuLakiController,
                              decoration: InputDecoration(
                                labelText: 'Nama Ibu Laki-Laki',
                                hintText: 'Isi Nama Ibu Laki-Laki',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaGerejaPerempuanController,
                              decoration: InputDecoration(
                                labelText: 'Nama Gereja Perempuan',
                                hintText: 'Isi Nama Gereja Perempuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaPerempuanController,
                              decoration: InputDecoration(
                                labelText: 'Nama Perempuan',
                                hintText: 'Isi Nama Perempuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaAyahPerempuanController,
                              decoration: InputDecoration(
                                labelText: 'Nama Ayah Perempuan',
                                hintText: 'Isi Nama Ayah Perempuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaIbuPerempuanController,
                              decoration: InputDecoration(
                                labelText: 'Nama Ibu Perempuan',
                                hintText: 'Isi Nama Ibu Perempuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              submitPernikahan();
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
                                    'Request',
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
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => home()),
                              );
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
                                  Icon(Icons.navigate_before,
                                      color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Kembali',
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
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xFF03A9F3),
        items: [
          Icon(Icons.home),
          Icon(Icons.history),
          Icon(Icons.person),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => riwayat()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profil()),
              );
              break;
          }
        },
      ),
    );
  }
}
