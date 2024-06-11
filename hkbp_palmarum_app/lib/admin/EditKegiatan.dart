import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/kegiatan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditKegiatan extends StatefulWidget {
  final String namaKegiatan;
  final String fotoKegiatan;
  final String kegiatan;
  final int? idKegiatan;
  final String gambarKegiatan;

  EditKegiatan({
    required this.namaKegiatan,
    required this.fotoKegiatan,
    required this.kegiatan,
    required this.gambarKegiatan,
    this.idKegiatan,
  });

  @override
  _EditKegiatanState createState() => _EditKegiatanState();
}

class _EditKegiatanState extends State<EditKegiatan> {
  var height, width;
  File? _image;
  List<DropdownMenuItem<String>> _jenisKegiatanOptions = [
    DropdownMenuItem(
      value: '1',
      child: Text('Kegiatan Diluar Gereja'),
    ),
    DropdownMenuItem(
      value: '2',
      child: Text('Kegiatan Didalam Gereja'),
    ),
  ];
  String _selectedJenisKegiatan = '';

  TextEditingController _namaKegiatanController = TextEditingController();
  TextEditingController _kegiatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaKegiatanController.text = widget.namaKegiatan;
    _kegiatanController.text = widget.kegiatan;
    _selectedJenisKegiatan = widget.idKegiatan.toString();
    print(_image);
    print(widget.gambarKegiatan);
  }

  Future<void> _updateKegiatan() async {
    try {
      if (_image == null) {
        // Tampilkan pesan kesalahan jika gambar tidak dipilih
        var snackBar = SnackBar(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 215), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Failed",
            message: "Thumbnail Harus Dipilih Kembali",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return; // Jangan lanjutkan proses jika gambar tidak dipilih
      }

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

      var url = 'http://192.168.11.31:2005/berita/${widget.fotoKegiatan}';
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Tambahkan gambar baru jika dipilih oleh pengguna
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_kegiatan',
          _image!.path,
          // Sesuaikan dengan tipe gambar jika diperlukan
        ));
      }

      // Tambahkan data teks
      request.fields['NamaKegiatan'] = _namaKegiatanController.text;
      request.fields['IDJemaat'] = idJemaat.toString();
      request.fields['Keterangan'] = _kegiatanController.text;
      request.fields['IDJenisKegiatan'] = _selectedJenisKegiatan;

      var response = await request.send();

      // Konversi response menjadi string untuk debugging
      String responseString = await response.stream.bytesToString();
      print('Response: $responseString');

      if (response.statusCode == 200) {
        print('Pembaruan berhasil');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 235), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Kegiatan Berhasil di Perbaharui",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => kegiatan()), // Kembali ke layar sebelumnya setelah berhasil menyimpan
        );
      } else {
        print('Gagal melakukan pembaruan. Status: ${response.statusCode}');
        // Tampilkan pesan atau tindakan yang sesuai
      }
    } catch (e) {
      print('Error: $e');
      // Tampilkan pesan error atau tindakan yang sesuai
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        // Tampilkan pesan toast jika gambar tidak dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gambar tidak dipilih.'),
            duration: Duration(seconds: 2),
          ),
        );
        print('No image selected.');
      }
    });
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
                              "Edit Kegiatan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Edit Kegiatan HKBP Palmarum Tarutung",
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
                              child: Image.network(
                                'http://192.168.11.31:2005/kegiatan/${widget.fotoKegiatan}/image',
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
                          padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: DropdownButtonFormField<String>(
                            value: _selectedJenisKegiatan,
                            decoration: InputDecoration(
                              labelText: 'Jenis Kegiatan',
                              hintText: 'Pilih Jenis Kegiatan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            items: _jenisKegiatanOptions,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedJenisKegiatan = newValue ?? '';
                                print(
                                    'Nilai Dropdown Dipilih: $_selectedJenisKegiatan');
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _namaKegiatanController,
                            decoration: InputDecoration(
                              labelText: 'Nama Kegiatan',
                              hintText: 'Masukkan Nama Kegiatan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _kegiatanController,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Kegiatan',
                              hintText: 'Masukkan Detail Kegiatan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _updateKegiatan(); // Panggil fungsi _updateKegiatan saat tombol "Edit" ditekan
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
                                Icon(Icons.edit_calendar_outlined,
                                    color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Edit',
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
      ),
    );
  }
}
