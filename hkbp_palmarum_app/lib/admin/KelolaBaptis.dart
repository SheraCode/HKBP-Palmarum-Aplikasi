import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:hkbp_palmarum_app/admin/baptis.dart';
import 'package:hkbp_palmarum_app/user/RiwayatBaptis.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hkbp_palmarum_app/user/createBaptis.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;



class kelolaBaptis extends StatefulWidget {
  final int idRegistrasiBaptis;

  kelolaBaptis({required this.idRegistrasiBaptis});

  @override
  _DetailConfirmBaptisState createState() => _DetailConfirmBaptisState();
}

class _DetailConfirmBaptisState extends State<kelolaBaptis> {
  var height, width;
  List<String> _dropdownItems = [
    'Johannes Bastian Jasa Sipayung, S.Tr.Kom',
    'Christia Otenia Br Purba, S.M',
    'Bastian Otenia Sipayung',
    // Tambahkan nama lainnya sesuai kebutuhan
  ];

  File? _selectedFile;
  String? _fileName;


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

    // Membuat request multipart
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://192.168.11.31:2005/baptis'),
    );

    // Menambahkan data ke dalam request
    request.fields['id_registasi_baptis'] = widget.idRegistrasiBaptis.toString();
    request.fields['no_surat_baptis'] = _noSuratBaptisController.text;
    request.fields['nama_pendeta_baptis'] = _NamaPendetaController.text;
    request.fields['tanggal_baptis'] = _dateBaptisController.text;
    request.fields['id_status'] = _selectedNamaMinggu.toString();

    // Menambahkan file surat baptis (jika ada)
    if (_selectedFile != null) {
      String fileName = path.basename(_selectedFile!.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file_surat_baptis',
          _selectedFile!.path,
          filename: fileName,
        ),
      );
    }

    // Mengatur header Authorization dengan token
    request.headers['Authorization'] = 'Bearer $token';

    try {
      // Mengirimkan request
      var response = await request.send();
      if (response.statusCode == 200) {
        // Berhasil
        var responseData = await response.stream.bytesToString();
        print('Response: $responseData');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 205), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Update Data Baptis Jemaat",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => baptis()),
        );
        // Redirect atau lakukan sesuatu setelah pengiriman berhasil
      } else {
        // Gagal
        print('Failed to send data. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim data')),
        );
      }
    } catch (e) {
      print('Error sending data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengirim data')),
      );
    }
  }






  Future<void> _pickFile() async {
    PermissionStatus status = await Permission.storage.status;

    // Jika izin akses belum diberikan, maka minta izin akses
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    // Memilih file setelah izin akses diberikan
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      setState(() {
        _fileName = file.name; // Menampilkan nama file yang dipilih
        _selectedFile = File(file.path!); // Mendapatkan file yang dipilih
      });
      // Anda dapat mengunggah file ke server atau menyimpannya sesuai kebutuhan
    } else {
      // User canceled the picker
    }
  }








  int? _selectedNamaMinggu;
  String? _selectedSesi;

  List<Map<String, dynamic>> namaMinggu = [
    {"id": 11, "name": "Menunggu Persetujuan"},
    {"id": 12, "name": "Ditolak"},
    {"id": 13, "name": "Diterima"},
  ];

  bool isFileAvailable = false;

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  Future<void> _launchURL() async {
    // URL yang ingin dibuka di browser
    final url = 'http://192.168.11.31:2005/download/baptis?id_registrasi_baptis=1';

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false, // Gunakan false untuk membuka di browser default
        forceWebView: false, // Gunakan false untuk membuka di browser default
        // Tambahkan opsi lain yang diperlukan, seperti:
        // universalLinksOnly: true,
      );
    } else {
      print('Tidak dapat membuka URL: $url');
    }
  }


  Future<void> downloadFile(String url, String fileName) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = "${appDocDir.path}/$fileName";
      print("Saving file to: $savePath");

      // Menggunakan Dio untuk mengunduh file
      await Dio().download(url, savePath);

      print("File downloaded to: $savePath");
      _openFile(savePath);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }


  void downloadFILE() async {
    var time = DateTime.now().millisecondsSinceEpoch;
    var path = "/storage/emulated/0/Download/baptis-$time.pdf";
    var file = File(path);

    try {
      var res = await http.get(Uri.parse("http://192.168.11.31:2005/download/baptis?id_registrasi_baptis=${widget.idRegistrasiBaptis}"));
      await file.writeAsBytes(res.bodyBytes);
      print("File downloaded to: $path");
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Berhasil Download File Baptis",
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
          message: "Gagal Download File Baptis",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }



  Future<void> downloadBaptisFile() async {
    String url = 'http://192.168.11.31:2005/download/baptis?id_registrasi_baptis=1';
    String fileName = 'baptis.pdf';

    await downloadFile(url, fileName);
  }

  Future<void> _openURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error opening URL: $e');
      // Show a snackbar or display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }



  void _openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print("Error opening file: $e");
    }
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
  TextEditingController _dateBaptisController = TextEditingController();
  TextEditingController _noSuratBaptisController = TextEditingController();
  TextEditingController _NamaPendetaController = TextEditingController();
  TextEditingController _FileBaptisController = TextEditingController();
  TextEditingController _statusController = TextEditingController();



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

  Future<void> _tglBaptis(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateBaptisController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }


  Future<void> fetchBaptisDetail(int idRegistrasiBaptis) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, harap login ulang')),
      );
      return;
    }

    final url = 'http://192.168.11.31:2005/registrasi-baptis/$idRegistrasiBaptis';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _namaLengkapController.text = data['nama_lengkap'] ?? '';
        _jenisKelaminController.text = data['jenis_kelamin'] ?? '';
        _tempatLahirController.text = data['tempat_lahir'] ?? '';
        _dateController.text = data['tanggal_lahir'] ?? '';
        _ayahController.text = data['nama_ayah'] ?? '';
        _ibuController.text = data['nama_ibu'] ?? '';
        _selectedChurchValue = data['id_hub_keluarga'] ?? '';
        _dateBaptisController.text = data['tanggal_baptis'] ?? '';
        _noSuratBaptisController.text = data['no_surat_baptis'] ?? '';
        _NamaPendetaController.text = data['nama_pendeta_baptis'] ?? '';
        _statusController.text = data['status'] ?? '';



        // Check if file URL is provided
        String fileUrl = data['file_surat_baptis'] ?? '';
        if (fileUrl.isNotEmpty) {
          // If file URL is provided, download the file
          isFileAvailable = true;
          downloadFile(fileUrl, 'surat_baptis.pdf');
        } else {
          isFileAvailable = false;
          var snackBar = SnackBar(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: "Notification",
              message: "File Baptis Belum Di Upload",
              contentType: ContentType.warning,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        // _FileBaptisController.text = 'http://192.168.11.31:2005/download/baptis?id_registrasi_baptis=${widget.idRegistrasiBaptis}';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail baptis')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchBaptisDetail(widget.idRegistrasiBaptis);
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
                              "Request Surat Baptis Jemaat ",
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
                            controller: _dateController,
                            enabled: false,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                            },
                            decoration: InputDecoration(
                              labelText: 'Tanggal Lahir',
                              fillColor: Colors.grey.shade200,
                              hintText: 'Pilih Tanggal Lahir',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          TextField(
                            controller: _ayahController,
                            enabled: false,
                            keyboardType: TextInputType.text,
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
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                            child: Column(
                              children: [
                                DropdownButtonFormField<int>(

                                  decoration: InputDecoration(
                                    enabled: false,
                                    labelText: 'Hubungan Keluarga',
                                    fillColor: Colors.grey.shade200,
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
                              controller: _dateBaptisController,
                              readOnly: true,
                              onTap: () {
                                _tglBaptis(context); // Panggil method _selectDate saat input tanggal diklik
                              },
                              decoration: InputDecoration(
                                labelText: 'Tanggal Baptis',
                                hintText: 'Pilih Tanggal Baptis',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                            ).p4().px24(),

                            SizedBox(height: 10),

                            TextField(
                              controller: _noSuratBaptisController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Nomor Surat Baptis',
                                hintText: "Nomor Surat Baptis",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.confirmation_number), // Icon surat untuk email
                              ),
                            ).p4().px24(),

                            SizedBox(height: 10),

                            TextField(
                              controller: _NamaPendetaController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Nama Pendeta',
                                hintText: "Nama Pendeta",
                                errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                prefixIcon: Icon(Icons.person), // Icon surat untuk email
                              ),
                            ).p4().px24(),

                            SizedBox(height: 10),
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Pilih Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            value: _selectedNamaMinggu,
                            items: namaMinggu.map((minggu) {
                              return DropdownMenuItem<int>(
                                value: minggu['id'],
                                child: Text(minggu['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedNamaMinggu = value;
                              });
                            },
                          ).p4().px24(),
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

                          SizedBox(height: 10),
                          // Tombol upload file

                          SizedBox(height: 10),

                            GestureDetector(
                              onTap: () {
                               _submitData();
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
                                    Icon(Icons.update, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Update Data Baptis',
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
                                MaterialPageRoute(builder: (context) => baptis()),
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

    );
  }
}
