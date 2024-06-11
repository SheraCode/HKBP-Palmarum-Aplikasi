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



class DetailConfirmPernikahan extends StatefulWidget {
  @override
  _DetailConfirmPernikahanState createState() => _DetailConfirmPernikahanState();
  final int idRegistrasiNikah;

  DetailConfirmPernikahan({required this.idRegistrasiNikah});

}

bool isFileAvailable = false;

class _DetailConfirmPernikahanState extends State<DetailConfirmPernikahan> {
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
  final TextEditingController _keteranganController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchData();
  }


  int? _selectedStatus;
  Map<int, String> _statusMap = {};
  Map<String, int> _churchMap = {
    'Menunggu Persetujuan': 11,
    'Ditolak': 12,
    'Disetujui':13
  };

  void _showStatusAlert(BuildContext context, int idStatus) {
    String alertTitle = '';
    String alertMessage = '';

    switch (idStatus) {
      case 11:
        alertTitle = 'Notification';
        alertMessage = 'Request Pernikahan Sedang Di Proses';
        break;
      case 12:
        alertTitle = 'Notification';
        alertMessage = 'Request Pernikahan Ditolak';
        break;
      case 13:
        alertTitle = 'Notification';
        alertMessage = 'Request Pernikahan Di Setujui';
        break;
      default:
        alertTitle = 'Notification';
        alertMessage = 'Status tidak valid';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alertTitle),
          content: Text(alertMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.31:2005/pernikahan/${widget.idRegistrasiNikah}'), // Use widget.idRegistrasiSidi here
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          _namaGerejaLakiController.text = jsonResponse['nama_gereja_laki'];
          _namaLakiController.text = jsonResponse['nama_laki'];
          _namaAyahLakiController.text = jsonResponse['nama_ayah_laki'];
          _namaIbuLakiController.text = jsonResponse['nama_ibu_laki'];
          _namaGerejaPerempuanController.text = jsonResponse['nama_gereja_perempuan'];
          _namaPerempuanController.text = jsonResponse['nama_perempuan'];
          _namaAyahPerempuanController.text = jsonResponse['nama_ayah_perempuan'];
          _namaIbuPerempuanController.text = jsonResponse['nama_ibu_perempuan'];
          _selectedStatus = jsonResponse['id_status'];
          _keteranganController.text = jsonResponse['keterangan'];

          int idStatus = jsonResponse['id_status'];
          _showStatusAlert(context, idStatus);

          String Keterangan = jsonResponse['keterangan'] ?? '';
          if (Keterangan.isNotEmpty) {
            isFileAvailable = true;

          } else {
            isFileAvailable = false;
          }

        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }


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
                            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _namaGerejaLakiController,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Nama Ibu Perempuan',
                                hintText: 'Isi Nama Ibu Perempuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                            child: Column(
                              children: [
                                DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: 'Status Request',
                                    hintText: 'Status Request Pernikahan',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  value: _selectedStatus,
                                  onChanged: null,
                                  items: _churchMap.entries.map((entry) {
                                    return DropdownMenuItem<int>(
                                      value: entry.value,
                                      child: Text(entry.key),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                                if (_showOtherChurchTextField)
                                  TextFormField(
                                    controller: _otherChurchController,
                                    decoration: InputDecoration(
                                      labelText: 'Nama Gereja',
                                      hintText: 'Masukkan nama gereja',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if(isFileAvailable)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              controller: _keteranganController,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Keterangan',
                                hintText: 'Keterangan Request Pernikahan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          SizedBox(height: 10,),

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
