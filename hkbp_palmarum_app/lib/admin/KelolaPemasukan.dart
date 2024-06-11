import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/pemasukan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KelolaPemasukan extends StatefulWidget {
  final int idPemasukan;

  const KelolaPemasukan({Key? key, required this.idPemasukan}) : super(key: key);

  @override
  _KelolaPemasukanState createState() => _KelolaPemasukanState();
}

class _KelolaPemasukanState extends State<KelolaPemasukan> {
  var height, width;
  File? _image;
  TextEditingController _totalPemasukanController = TextEditingController();
  TextEditingController _bentukPemasukanController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  // Dropdown data
  List<String> kategoriPemasukanList = [];
  List<String> bankList = [];
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

  int? selectedKategori;
  String selectedBank = '';

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
    {"id": 1, "name": "Bantuan Dana Organisasi"},
    {"id": 2, "name": "Persembahan Kebaktian"},
    {"id": 3, "name": "Sumbangan Jemaat"},
  ];

  int? _category;
  int? idPemasukan;

  Future<void> fetchData() async {
    try {
      final Uri url = Uri.parse('http://192.168.11.31:2005/pemasukan/${widget.idPemasukan}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _dateController.text = data['tanggal_pemasukan'].toString();
          _totalPemasukanController.text = data['total_pemasukan'].toString();
          _bentukPemasukanController.text = data['bentuk_pemasukan'].toString();
          selectedKategori = data['id_kategori_pemasukan'];
          _category = data['id_kategori_pemasukan'];
          idPemasukan = data['id_pemasukan'];
          selectedBank = data['id_bank'].toString();
          _selectedBank = int.tryParse(selectedBank) ?? 3;
          print('Nilai kategori_pemasukan: ${selectedKategori ?? 'Belum dipilih'}');
          print('Nilai id_bank: ${selectedBank ?? 'Belum dipilih'}');
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _updateKegiatan() async {
    try {
      if (_image == null) {
        // Tampilkan pesan kesalahan jika gambar tidak dipilih
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 215),
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

      var url = 'http://192.168.11.31:2005/pemasukan';
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Tambahkan gambar baru jika dipilih oleh pengguna
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'bukti_pemasukan',
          _image!.path,
        ));
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


      // Tambahkan data teks
      request.fields['id_jemaat'] = idJemaat.toString();
      request.fields['total_pemasukan'] = _totalPemasukanController.text;
      request.fields['tanggal_pemasukan'] = _dateController.text;
      request.fields['bentuk_pemasukan'] = _bentukPemasukanController.text;
      request.fields['id_kategori_pemasukan'] = _category.toString();
      request.fields['id_bank'] = _selectedBank.toString();
      request.fields['id_pemasukan'] = idPemasukan.toString();

      var response = await request.send();

      // Baca response JSON dari server
      if (response.statusCode == 200) {
        var jsonResponse = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(jsonResponse);

        // Ambil pesan dari JSON response
        var message = decodedResponse['message'];
        print('Message from server: $message');

        // Tampilkan pesan sukses menggunakan SnackBar
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 295),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: message ?? "Kegiatan Berhasil di Perbaharui",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Kembali ke layar sebelumnya setelah berhasil menyimpan
        Navigator.pop(context);
      } else {
        print('Gagal melakukan pembaruan. Status: ${response.statusCode}');
        var jsonResponse = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(jsonResponse);
        var message = decodedResponse['message'];
        print('Message from server: $message');
      }
    } catch (e) {
      print('Error: $e');
      // Tangani error ketika terjadi
    }
  }



  @override
  void initState() {
    super.initState();
    fetchData();
    print(_selectedBank);
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
                              "Kelola Pemasukan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Kelola Detail Pemasukan",
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
                          'Bukti Pemasukan',
                          style: TextStyle(
                            fontSize: 20, // Ukuran teks sesuai kebutuhan
                            fontWeight: FontWeight.bold, // Gaya teks sesuai kebutuhan
                          ),
                        ),
                        SizedBox(height: 20,),
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
                                'http://192.168.11.31:2005/pemasukan/image/$idPemasukan',
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
                        Padding(padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                            },
                            decoration: InputDecoration(
                              labelText: 'Tanggal Pemasukan',
                              hintText: 'Pilih Tanggal Tanggal Pemasukan',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _totalPemasukanController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total Pemasukan',
                              hintText: 'Masukkan total pemasukan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _bentukPemasukanController,
                            decoration: InputDecoration(
                              labelText: 'Bentuk Pemasukan',
                              hintText: 'Masukkan bentuk pemasukan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _updateKegiatan();
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
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Simpan Perubahan',
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
