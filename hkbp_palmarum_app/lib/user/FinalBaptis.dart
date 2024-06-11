import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/CobaREQBaptis.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hkbp_palmarum_app/user/createBaptis.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class FinalBaptis extends StatefulWidget {
  @override
  final int idJemaat, id_no_registrasi; // Accept the parameter

  FinalBaptis({required this.idJemaat, required this.id_no_registrasi});
  _FinalBaptisState createState() => _FinalBaptisState();
}

class _FinalBaptisState extends State<FinalBaptis> {
  var height, width;
  List<String> _dropdownItems = [
    'Johannes Bastian Jasa Sipayung, S.Tr.Kom',
    'Christia Otenia Br Purba, S.M',
    'Bastian Otenia Sipayung',
    // Tambahkan nama lainnya sesuai kebutuhan
  ];

  void initState() {
    print('id jemaat anak: ${widget.idJemaat}');
    print('no reg keluarga: ${widget.id_no_registrasi}');
    _fetchDataSuami();
    _fetchDataIsteri();
    _fetchJemaatData(widget.idJemaat); // Pass the idJemaat parameter here
  }


  Future<void> _fetchJemaatData(int idJemaat) async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat-all/anak-keluarga/$idJemaat'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Jemaat Data: $data'); // Debug print

      setState(() {
        _namaLengkapController.text = '${data['nama_depan'] ?? ''} ${data['nama_belakang'] ?? ''}';
        _jenisKelaminController.text = data['jenis_kelamin'] ?? '';
        _tempatLahirController.text = data['tempat_lahir'] ?? '';
        _TanggalLahirController.text = data['tgl_lahir'] ?? '';
        _category = data['id_hub_keluarga']; // Assuming 0 is the default value
        _noRegKeluarga = data['no_registrasi_keluarga']; // Assuming 0 is the default value

      });
    } else {
      throw Exception('Failed to load jemaat data');
    }
  }



  Future<void> _submitData() async {
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

    final url = 'http://192.168.11.31:2005/baptis/create';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({
        'id_jemaat': idJemaat,
        'nama_ayah': _ayahController.text,
        'nama_ibu': _ibuController.text,
        'nama_lengkap': _namaLengkapController.text,
        'tempat_lahir': _tempatLahirController.text,
        'tanggal_lahir': _TanggalLahirController.text,
        'jenis_kelamin': _jenisKelaminController.text,
        'id_hub_keluarga': _category,
      }),
    );

    if (response.statusCode == 200) {
      // Handle response jika berhasil
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Berhasil Request Baptis Jemaat",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => home()),
      );
    } else {
      // Handle response jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim data')),
      );
    }
  }






  Future<void> _fetchDataSuami() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/kepala-keluarga/${widget.id_no_registrasi}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Suami Data: $data'); // Debug print
      setState(() {
        _ayahController.text = '${data[0]['nama_depan'] ?? ''} ${data[0]['nama_belakang'] ?? ''}';
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _fetchDataIsteri() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/isteri-keluarga/${widget.id_no_registrasi}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Istri Data: $data'); // Debug print
      setState(() {
       // Set the value of ayah controller with the husband's name
        _ibuController.text = '${data[0]['nama_depan'] ?? ''} ${data[0]['nama_belakang'] ?? ''}'; // Set the value of ibu controller with the wife's name
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  List<Map<String, dynamic>> category = [
    {"id": 3, "name": "Anak"},
    {"id": 4, "name": "Saudara Kandung"}
  ];

  int? _category;



  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  String? _selectedName; // inisialisasi _selectedName

  int? _selectedChurchValue;
  String? _otherChurchName;


  Map<String, int> _churchMap = {
    'Anak': 3,
    'Saudara': 4,
  };

  bool _showOtherChurchTextField = false;
  TextEditingController _otherChurchController = TextEditingController();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _ayahController = TextEditingController();
  TextEditingController _ibuController = TextEditingController();
  TextEditingController _namaLengkapController = TextEditingController();
  TextEditingController _tempatLahirController = TextEditingController();
  TextEditingController _jenisKelaminController = TextEditingController();
  TextEditingController _TanggalLahirController = TextEditingController();
  TextEditingController _noRegKeluarga = TextEditingController();






  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _TanggalLahirController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
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
                image: AssetImage("assets/userbaptis.jpg"),
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
                      Padding(padding: EdgeInsets.only(top: 25, left: 15, right: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Widget yang Anda ingin masukkan di sini
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pembaptisan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Request Surat Baptis Jemaat",
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
                          TextField(
                            controller: _namaLengkapController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Nama Calon Baptis',
                              hintText: "Nama Calon Baptis",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextField(
                            controller: _jenisKelaminController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Jenis Kelamin',
                              hintText: "Jenis Kelamin",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.male_sharp), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextField(
                            controller: _tempatLahirController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Tempat Lahir',
                              hintText: "Tempat Lahir",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _TanggalLahirController,
                            readOnly: true,
                            enabled: false,
                            onTap: () {
                              _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Tanggal',
                              hintText: 'Pilih Tanggal',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextField(
                            controller: _ayahController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Nama Ayah',
                              hintText: "Nama Ayah",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextField(
                            controller: _ibuController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Nama Ibu',
                              hintText: "Nama Ibu",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 26),
                            child: DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Pilih Hubungan Keluarga',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              value: _category,
                              items: category.map((kategori) {
                                return DropdownMenuItem<int>(
                                  value: kategori['id'],
                                  child: Text(kategori['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _category = value;
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _submitData,
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
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CobaBaptis()),
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
                                  Icon(Icons.navigate_before, color: Colors.white),
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
