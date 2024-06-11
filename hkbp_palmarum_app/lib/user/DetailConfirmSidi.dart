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
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailConfirmSidi extends StatefulWidget {
  @override

  final int idRegistrasiSidi;

  DetailConfirmSidi({required this.idRegistrasiSidi});

  _createDetailConfirmSidiState createState() => _createDetailConfirmSidiState();
}

class _createDetailConfirmSidiState extends State<DetailConfirmSidi> {
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
  bool _showOtherChurchTextField = false;
  bool isFileAvailable = false;
  File? _selectedFile;
  String? _fileName;

  String? _idJemaat;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _birthPlaceController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  TextEditingController _motherNameController = TextEditingController();
  TextEditingController tanggaSidiController = TextEditingController();
  TextEditingController natsSidiController = TextEditingController();
  TextEditingController noSuratSidiController = TextEditingController();
  TextEditingController namaPendetaSidiController = TextEditingController();
  TextEditingController _otherChurchController = TextEditingController();
  TextEditingController _statusController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadIdJemaat();
    _fetchData();
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
        Uri.parse('http://192.168.11.31:2005/sidi/byid/${widget.idRegistrasiSidi}'), // Use widget.idRegistrasiSidi here
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          _nameController.text = jsonResponse['nama_lengkap'];
          _genderController.text = jsonResponse['jenis_kelamin'];
          _dateController.text = jsonResponse['tanggal_lahir'];
          _birthPlaceController.text = jsonResponse['tempat_lahir'];
          _fatherNameController.text = jsonResponse['nama_ayah'];
          _motherNameController.text = jsonResponse['nama_ibu'];
          tanggaSidiController.text = jsonResponse['tanggal_sidi'];
          natsSidiController.text = jsonResponse['nats_sidi'];
          _statusController.text = jsonResponse['status'];
          noSuratSidiController.text = jsonResponse['nomor_surat_sidi'];
          namaPendetaSidiController.text = jsonResponse['nama_pendeta_sidi'];
          _selectedChurchValue = jsonResponse['id_hub_keluarga'];



          String fileUrl = jsonResponse['tanggal_sidi'] ?? '';
          if (fileUrl.isNotEmpty) {
            // If file URL is provided, download the file
            isFileAvailable = true;
            var snackBar = SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Notification",
                message: "Sudah Diproses Oleh Majelis",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
             isFileAvailable = false;
            var snackBar = SnackBar(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: "Notification",
                message: "Belum Diproses Oleh Majelis",
                contentType: ContentType.warning,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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


  Future<void> _loadIdJemaat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idJemaat = prefs.getString('id_jemaat');
    });
  }

  Future<void> _submitData() async {
    if (_selectedFile == null ||
        _nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _birthPlaceController.text.isEmpty ||
        _fatherNameController.text.isEmpty ||
        _motherNameController.text.isEmpty ||
        _selectedChurchValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua data dan pilih file')),
      );
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
    int idJemaat = decodedToken['id_jemaat'];

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.11.31:2005/sidi/create'),
    );

    request.fields['id_jemaat'] = idJemaat.toString(); // Convert to String
    request.fields['nama_ayah'] = _fatherNameController.text;
    request.fields['nama_ibu'] = _motherNameController.text;
    request.fields['nama_lengkap'] = _nameController.text;
    request.fields['tempat_lahir'] = _birthPlaceController.text;
    request.fields['tanggal_lahir'] = _dateController.text;
    request.fields['jenis_kelamin'] = _genderController.text;
    request.fields['status'] = _genderController.text;
    request.fields['id_hub_keluarga'] = _selectedChurchValue.toString(); // Convert to String
    request.fields['id_status'] = '11';
    // Convert to String

    if (_selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file_baptis',
        _selectedFile!.path,
        filename: path.basename(_selectedFile!.path),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File belum dipilih')),
      );
      return;
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Baca respons dari API
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        var message = jsonResponse['error'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Data berhasil dikirim')),
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
                              enabled: false,
                              readOnly: true,
                              onTap: () {
                                _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                              },
                              decoration: InputDecoration(
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
                              enabled: false,
                              keyboardType: TextInputType.text,
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
                              enabled: false,
                              keyboardType: TextInputType.text,
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
                              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Hubungan Keluarga',
                                      hintText: 'Pilih Hubungan Keluarga',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    value: _selectedChurchValue,
                                    onChanged: null,
                                    items: _churchMap.entries.map((entry) {
                                      return DropdownMenuItem<int>(
                                        value: entry.value,
                                        child: Text(entry.key),
                                      );
                                    }).toList(),
                                  ).p1().px4(),
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
                                    ).p4().px4(),
                                ],
                              ),
                            ),

                            TextField(
                              controller: _statusController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Status Request',
                                hintText: "Status Request Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.check_box),
                              ),
                            ).p4().px24(),
                            if (isFileAvailable)
                            TextField(
                              controller: tanggaSidiController,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Tanggal Sidi',
                                hintText: "Tanggal Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                            ).p4().px24(),
                            if (isFileAvailable)
                            SizedBox(height: 10,),
                            if (isFileAvailable)
                            TextField(
                              controller: natsSidiController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Nats Sidi',
                                hintText: "Nats Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.book),
                              ),
                            ).p4().px24(),
                            if (isFileAvailable)
                            SizedBox(height: 10),
                            if (isFileAvailable)
                            TextField(
                              controller: noSuratSidiController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Nomor Surat Sidi',
                                hintText: "Nomor Surat Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                            ).p4().px24(),
                            if (isFileAvailable)
                            SizedBox(height: 10),
                            if (isFileAvailable)
                            TextField(
                              controller: namaPendetaSidiController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: 'Nama Pendeta Sidi',
                                hintText: "Nama Pendeta Sidi",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ).p4().px24(),
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RiwayatSidi()),
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
