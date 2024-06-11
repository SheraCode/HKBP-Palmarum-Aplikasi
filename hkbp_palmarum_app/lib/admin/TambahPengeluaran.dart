import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class TambahPengeluaran extends StatefulWidget {
  @override
  _TambahPemasukanState createState() => _TambahPemasukanState();
}

class _TambahPemasukanState extends State<TambahPengeluaran> {
  var height, width;
  File? _image; // Variabel untuk menyimpan gambar yang dipilih
  TextEditingController totalPemasukanController = TextEditingController();
  TextEditingController bentukPemasukanController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> banks = [
    {"id": 1, "name": "BRI"},
    {"id": 2, "name": "BNI"},
    {"id": 3, "name": "BCA"},
    {"id": 4, "name": "Mandiri"},
    {"id": 5, "name": "Bank Mayapada"},
    {"id": 6, "name": "Bank Lainnya"},
    {"id": 7, "name": "Dana"},
    {"id": 8, "name": "Bank Aceh"},
    {"id": 9, "name": "Bank Syariah Indonesia"},
    {"id": 10, "name": "Tunai"},
  ];

  int? _selectedBank;

  List<Map<String, dynamic>> category = [
    {"id": 1, "name": "Perbaikan Gereja"},
    {"id": 2, "name": "Acara Gereja"},
    {"id": 3, "name": "Acara Diluar Gereja"},
    {"id": 4, "name": "Bantuan Dana ke Organisasi"},
    {"id": 5, "name": "Dana Sosial"},
    {"id": 6, "name": "Lainnya"},
  ];

  int? _category;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

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

  Future<void> _createPemasukan() async {
    try {
      final apiUrl = 'http://192.168.11.31:2005/pengeluaran/create';

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


      // Prepare the request
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add text fields
      request.fields['id_jemaat'] = idJemaat.toString();
      request.fields['jumlah_pengeluaran'] = totalPemasukanController.text;
      request.fields['tanggal_pengeluaran'] = _dateController.text;

      request.fields['keterangan_pengeluaran'] = bentukPemasukanController.text;
      request.fields['id_kategori_pengeluaran'] = _category.toString();
      request.fields['id_bank'] = _selectedBank.toString();

      // Add image file if available
      if (_image != null) {
        final fileStream = http.ByteStream(_image!.openRead());
        final fileLength = await _image!.length();

        final fileName = _image!.path.split('/').last;

        request.files.add(http.MultipartFile(
          'bukti_pengeluaran',
          fileStream,
          fileLength,
          filename: fileName,
        ));
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Pemasukan berhasil ditambahkan.');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 295),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Pengeluaran Berhasil di Tambahkan",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Kembali ke layar sebelumnya setelah berhasil menyimpan
        Navigator.pop(context);
        // Tampilkan snackbar atau feedback sukses
      } else {
        // Parse response body to extract the message
      print("Gagal Menambahkan Pengeluaran");
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 295),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Failed",
          message: "Pengeluaran Gagal di Tambahkan",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Tampilkan snackbar atau feedback gagal
      }

    } catch (e) {
      print('Error saat menambahkan pemasukan: $e');
      // Tangani error atau exception
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
                        padding: EdgeInsets.only(
                          top: 20,
                          left: 15,
                          right: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tambah Pengeluaran",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tambah Pengeluaran HKBP Palmarum",
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
                        Text(
                          'Bukti Pengeluaran',
                          style: TextStyle(
                            fontSize: 20, // Ukuran teks sesuai kebutuhan
                            fontWeight: FontWeight.bold, // Gaya teks sesuai kebutuhan
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _getImage(ImageSource.gallery); // Ambil dari galeri
                          },

                          child: Container(
                            alignment: Alignment.center,
                            child: _image == null
                                ? ClipOval(
                              child: Image.asset(
                                "assets/pemasukan.png",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                                : ClipOval(
                              child: Image.file(
                                _image!,
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
                                  _getImage(ImageSource.gallery); // Ambil dari galeri
                                },
                                child: Text('Ambil dari Galeri'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _getImage(ImageSource.camera); // Ambil dari kamera
                                },
                                child: Text('Ambil dari Kamera'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                        Padding(padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                            },
                            decoration: InputDecoration(
                              labelText: 'Tanggal Pengeluaran',
                              hintText: 'Pilih Tanggal Tanggal Pengeluaran',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: totalPemasukanController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: 'Total Pengeluaran',
                              hintText: 'Masukkan jumlah Pengeluaran',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: bentukPemasukanController,
                            decoration: InputDecoration(
                              labelText: 'Keterangan Pengeluaran',
                              hintText: 'Masukkan Keterangan Pengeluaran',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        // Dropdown untuk memilih bank
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Pilih Bank',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            value: _selectedBank,
                            items: banks.map((bank) {
                              return DropdownMenuItem<int>(
                                value: bank['id'],
                                child: Text(bank['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBank = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Pilih Kategori Pengeluaran',
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
                          onTap: () {
                            _createPemasukan(); // Panggil fungsi untuk membuat pemasukan
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
