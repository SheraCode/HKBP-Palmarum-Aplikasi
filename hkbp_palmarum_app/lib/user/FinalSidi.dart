import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/RegistrasiSidi.dart';
import 'package:hkbp_palmarum_app/user/RiwayatSidi.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class FinalSidi extends StatefulWidget {
  @override
  final int idJemaat, id_no_registrasi; // Accept the parameter

  FinalSidi({required this.idJemaat, required this.id_no_registrasi});
  _FinalSidiState createState() => _FinalSidiState();
}

class _FinalSidiState extends State<FinalSidi> {
  var height, width;
  List<String> _dropdownItems = [
    'Johannes Bastian Jasa Sipayung, S.Tr.Kom',
    'Christia Otenia Br Purba, S.M',
    'Bastian Otenia Sipayung',
    // Tambahkan nama lainnya sesuai kebutuhan
  ];
  Map<String, int> _churchMap = {
    'Anak': 3,
    'Saudara': 4,
  };

  Future<void> _fetchJemaatData(int idJemaat) async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat-all/anak-keluarga/$idJemaat'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Jemaat Data: $data'); // Debug print

      setState(() {
        _nameController.text = '${data['nama_depan'] ?? ''} ${data['nama_belakang'] ?? ''}';
        _genderController.text = data['jenis_kelamin'] ?? '';
        _birthPlaceController.text = data['tempat_lahir'] ?? '';
        _dateController.text = data['tgl_lahir'] ?? '';
        _category = data['id_hub_keluarga']; // Assuming 0 is the default value
        _noRegKeluarga = data['no_registrasi_keluarga']; // Assuming 0 is the default value

      });
    } else {
      throw Exception('Failed to load jemaat data');
    }
  }


  Future<void> _submitData() async {
    if (_selectedFile == null ||
        _nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _birthPlaceController.text.isEmpty ||
        _fatherNameController.text.isEmpty ||
        _motherNameController.text.isEmpty ||
        _category == null) {
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Failed",
          message: "Harap Isi Semua Field",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
      );
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int idJemaat = decodedToken['id_jemaat'] as int; // Casting to int

    var url = Uri.parse('http://192.168.11.31:2005/sidi/create');
    var request = http.MultipartRequest('POST', url);

    request.fields['id_jemaat'] = idJemaat.toString(); // Convert to String
    request.fields['nama_ayah'] = _fatherNameController.text;
    request.fields['nama_ibu'] = _motherNameController.text;
    request.fields['nama_lengkap'] = _nameController.text;
    request.fields['tempat_lahir'] = _birthPlaceController.text;
    request.fields['tanggal_lahir'] = _dateController.text;
    request.fields['jenis_kelamin'] = _genderController.text;
    request.fields['id_hub_keluarga'] = _category.toString(); // Convert to String
    request.fields['id_status'] = '11';

    if (_selectedFile != null) {
      var fileBytes = await _selectedFile!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file_baptis',
        fileBytes,
        filename: path.basename(_selectedFile!.path),
      ));
    } else {
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Failed",
          message: "File Baptis Belum Di upload",
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    request.headers['Authorization'] = 'Bearer $token';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        var message = jsonResponse['error'];

        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Berhasil",
            message: "Berhasil Request Sidi",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiwayatSidi()),
        );
      } else {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        var message = jsonResponse['error'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Data berhasil dikirim')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }



  Future<void> _fetchDataSuami() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/kepala-keluarga/${widget.id_no_registrasi}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Suami Data: $data'); // Debug print
      setState(() {
        _fatherNameController.text = '${data[0]['nama_depan'] ?? ''} ${data[0]['nama_belakang'] ?? ''}';
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
        _motherNameController.text = '${data[0]['nama_depan'] ?? ''} ${data[0]['nama_belakang'] ?? ''}'; // Set the value of ibu controller with the wife's name
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool _showOtherChurchTextField = false;

  File? _selectedFile;
  String? _fileName;
  int? _category;
  String? _idJemaat;
  TextEditingController _noRegKeluarga = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _birthPlaceController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  TextEditingController _motherNameController = TextEditingController();
  TextEditingController _otherChurchController = TextEditingController();
  TextEditingController _idJemaatController = TextEditingController();

  String? _selectedChurch;
  int? _selectedChurchValue;
  int? _selectedHubKeluarga;

  List<String> _churchList = ['HKBP', 'Gereja lain'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickFile() async {
    PermissionStatus status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      setState(() {
        _fileName = file.name;
        _selectedFile = File(file.path!);
      });
    }
  }



  void initState() {
    print('id jemaat anak: ${widget.idJemaat}');
    print('no reg keluarga: ${widget.id_no_registrasi}');
    _fetchDataSuami();
    _fetchDataIsteri();
    _loadIdJemaat();
    _fetchJemaatData(widget.idJemaat); // Pass the idJemaat parameter here
  }

  Future<void> _loadIdJemaat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idJemaat = prefs.getString('id_jemaat');
    });
  }

  List<Map<String, dynamic>> category = [
    {"id": 3, "name": "Anak"},
    {"id": 4, "name": "Saudara Kandung"}
  ];



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
                  image: AssetImage("assets/angkatsidi.jpeg"),
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
                                "Naik Sidi",
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
                                "Request Surat Naik Sidi Jemaat",
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Nama Calon Sidi',
                                hintText: "Nama Calon Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ).p4().px24(),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _genderController,
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
                                prefixIcon: Icon(Icons.person),
                              ),
                            ).p4().px24(),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              enabled: false,
                              onTap: () {
                                _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Tanggal Lahir',
                                hintText: 'Pilih Tanggal Lahir',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                            ).p4().px24(),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _birthPlaceController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Tempat Lahir',
                                hintText: "Pilih Tempat Lahir",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.place),
                              ),
                            ).p4().px24(),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _fatherNameController,
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
                                prefixIcon: Icon(Icons.person),
                              ),
                            ).p4().px24(),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _motherNameController,
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
                                prefixIcon: Icon(Icons.person),
                              ),
                            ).p4().px24(),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 26),
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Pilih Kategori Pemasukan',
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
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickFile,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.attach_file, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      _fileName ?? 'Pilih File PDF',
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
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => home()),
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
        )
    );
  }
}
