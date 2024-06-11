import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/WartaJemaat.dart';
import 'package:hkbp_palmarum_app/admin/majelis.dart';
import 'package:hkbp_palmarum_app/admin/pelayanIbadah.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class TambahMajelis extends StatefulWidget {
  @override
  _TambahMajelisState createState() => _TambahMajelisState();
}

class _TambahMajelisState extends State<TambahMajelis> {
  late TextEditingController _controller;
  var height, width;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _dateAkhirJabatan = TextEditingController();
  int? _selectedNamaMinggu;
  int? _selectedPelayanIbadah;

  List<Map<String, String>> _dropdownItems = [
    {'value': '9', 'label': 'Majelis Jemaat'},
    {'value': '10', 'label': 'Bendahara'},
    {'value': '14', 'label': 'Bendahara Organisasi'},
    {'value': '15', 'label': 'Sekretaris Organisasi'},
    {'value': '16', 'label': 'Ketua Organisasi'},
    {'value': '17', 'label': 'Wakil Ketua Organisasi'},
    // Tambahkan pasangan nilai dan label lainnya sesuai kebutuhan
  ];

  List<Map<String, dynamic>> pelayanIbadah = [];
  List<Map<String, dynamic>> namaMinggu = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fetchPelayanIbadah().then((data) {
      setState(() {
        pelayanIbadah = data;
      });
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    _dateAkhirJabatan.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPelayanIbadah() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/role-jemaat'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => {
        'id': e['id_jemaat'],
        'name': e['nama_depan'],
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _createMajelis() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.11.31:2005/majelis/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_jemaat': _selectedNamaMinggu,
          'tgl_tahbis': _dateController.text,
          'tgl_akhir_jabatan': _dateAkhirJabatan.text,
          'id_status_pelayan': 9, // Default id_status_pelayan
        }),
      );

      if (response.statusCode == 200) {
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Berhasil",
            message: "Berhasil Membuat Majelis",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Majelis()),
        );
      } else {
        throw Exception('Failed to create majelis');
      }
    } catch (e) {
      print('Error creating majelis: $e');
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Gagal",
          message: "Gagal Membuat Majelis",
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
                            "Tambah Majelis",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tambah Majelis HKBP Palmarum",
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
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Anggota Jemaat',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          value: _selectedNamaMinggu,
                          items: pelayanIbadah.map((jadwal) {
                            return DropdownMenuItem<int>(
                              value: jadwal['id'],
                              child: Text(jadwal['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedNamaMinggu = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () {
                            _selectDate(context, _dateController); // Panggil method _selectDate saat input tanggal diklik
                          },
                          decoration: InputDecoration(
                            labelText: 'Tanggal Tahbis',
                            hintText: 'Pilih Tanggal Tahbis Majelis',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _dateAkhirJabatan,
                          readOnly: true,
                          onTap: () {
                            _selectDate(context, _dateAkhirJabatan); // Panggil method _selectDate saat input tanggal diklik
                          },
                          decoration: InputDecoration(
                            labelText: 'Tanggal Akhir Jabatan',
                            hintText: 'Pilih Tanggal Akhir Jabatan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_selectedNamaMinggu != null && _dateController.text.isNotEmpty && _dateAkhirJabatan.text.isNotEmpty) {
                            _createMajelis();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Harap lengkapi semua informasi'),
                              ),
                            );
                          }
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
      drawer: DrawerWidget(),
    );
  }
}
