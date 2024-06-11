import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/admin/malua.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
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

class KelolaConfirmSidi extends StatefulWidget {
  @override

  final int idRegistrasiSidi;

  KelolaConfirmSidi({required this.idRegistrasiSidi});

  _KelolaDetailConfirmSidiState createState() => _KelolaDetailConfirmSidiState();
}

class _KelolaDetailConfirmSidiState extends State<KelolaConfirmSidi> {
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
  TextEditingController _idStatusController = TextEditingController();

  String? _selectedChurch;
  int? _selectedChurchValue;
  int? _IDStatus;

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

  Map<int, String> _statusMap = {
    11: 'Menunggu Persetujuan',
    12: 'Ditolak',
    13: 'Diterima',
    // Tambahkan status lainnya sesuai kebutuhan
  };

  int? _selectedStatus;


  void downloadFILE() async {
    var time = DateTime.now().millisecondsSinceEpoch;
    var path = "/storage/emulated/0/Download/sidi-$time.pdf";
    var file = File(path);

    try {
      var res = await http.get(Uri.parse("http://192.168.11.31:2005/download/sidi?id_registrasi_sidi=${widget.idRegistrasiSidi}"));
      await file.writeAsBytes(res.bodyBytes);
      print("File downloaded to: $path");
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Berhasil Download File Sidi Jemaat",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("Error downloading file: $e");
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Failed",
          message: "Gagal Download File Sidi Jemaat",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  @override
  void initState() {
    super.initState();
    _loadIdJemaat();
    _fetchData();
  }

  Future<void> _selectDateSidi(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        tanggaSidiController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
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
          _selectedStatus = jsonResponse['id_status'];


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

    var uri = Uri.parse('http://192.168.11.31:2005/sidi/update');

    var requestBody = {
      "id_jemaat": idJemaat,
      "id_registrasi_sidi": widget.idRegistrasiSidi,
      "tanggal_sidi": tanggaSidiController.text,
      "nats_sidi": natsSidiController.text,
      "nomor_surat_sidi": noSuratSidiController.text,
      "nama_pendeta_sidi": namaPendetaSidiController.text,
      "id_status": _selectedStatus,
    };

    var headers = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var message = jsonResponse['error'];

        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Berhasil",
            message: "Berhasil Update Sidi",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => malua()),
        );
      } else {
        var jsonResponse = json.decode(response.body);
        var message = jsonResponse['error'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Gagal memperbarui data')),
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

                            TextFormField(
                              controller: tanggaSidiController,
                              readOnly: true,
                              onTap: () {
                                _selectDateSidi(context); // Panggil method _selectDate saat input tanggal diklik
                              },
                              decoration: InputDecoration(
                                labelText: 'Tanggal Sidi',
                                fillColor: Colors.white,
                                hintText: 'Pilih Tanggal Sidi',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                            ).p4().px24(),
                            SizedBox(height: 10),



                              TextField(
                                controller: natsSidiController,
                                keyboardType: TextInputType.text,

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Nats Sidi',
                                  hintText: "Nats Sidi",
                                  errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  prefixIcon: Icon(Icons.book),
                                ),
                              ).p4().px24(),

                              SizedBox(height: 10),

                              TextField(
                                controller: noSuratSidiController,
                                keyboardType: TextInputType.text,

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Nomor Surat Sidi',
                                  hintText: "Nomor Surat Sidi",
                                  errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                              ).p4().px24(),

                              SizedBox(height: 10),

                              TextField(
                                controller: namaPendetaSidiController,
                                keyboardType: TextInputType.text,

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
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
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Status',
                                hintText: 'Pilih Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              value: _selectedStatus,
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              },
                              items: _statusMap.entries.map((entry) {
                                return DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                            ).p4().px24(),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () {
                                downloadFILE();
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
                                    Icon(Icons.download, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Download File Sidi Jemaat',
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
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () {
                                _submitData();
                              },
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.update, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Update Kelola Sidi',
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
                                  MaterialPageRoute(builder: (context) => malua()),
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
