import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class EditAccountJemaat extends StatefulWidget {
  final int idJemaat;

  EditAccountJemaat({required this.idJemaat});

  @override
  _EditAccountJemaatState createState() => _EditAccountJemaatState();
}

class _EditAccountJemaatState extends State<EditAccountJemaat> {
  TextEditingController _namaDepanController = TextEditingController();
  TextEditingController _namaBelakangController = TextEditingController();
  int? _selectedKepalaKeluarga;
  int? _selectedHubunganKeluarga;

  List<Map<String, dynamic>> hubkeluarga = [
    {"id": 1, "name": "Kepala Keluarga"},
    {"id": 2, "name": "Isteri"},
    {"id": 3, "name": "Anak"},
  ];

  List<Map<String, dynamic>> pelayanIbadah = [];

  @override
  void initState() {
    super.initState();
    _fetchPelayanIbadah().then((data) {
      setState(() {
        pelayanIbadah = data;
      });
    }).catchError((error) {
      print('Error fetching data: $error');
    });
    _fetchJemaatData(widget.idJemaat);
  }

  Future<List<Map<String, dynamic>>> _fetchPelayanIbadah() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/registrasi-keluarga'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Fetched Pelayan Ibadah: $data'); // Debug print
      return data.map((e) => {
        'id': e['id_registrasi_keluarga'],
        'name': e['nama_kepala_keluarga'],
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _fetchJemaatData(int idJemaat) async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/account/$idJemaat'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Fetched Jemaat Data: $data'); // Debug print
      setState(() {
        _namaDepanController.text = data['nama_depan'];
        _namaBelakangController.text = data['nama_belakang'];
        _selectedKepalaKeluarga = data['no_registrasi_keluarga'];
        _selectedHubunganKeluarga = data['id_hub_keluarga'];
      });
    } else {
      throw Exception('Failed to load jemaat data');
    }
  }

  Future<void> _updateAccountJemaat() async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.11.31:2005/jemaat/account/edit/${widget.idJemaat}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_jemaat": widget.idJemaat,
          "nama_depan": _namaDepanController.text,
          "nama_belakang": _namaBelakangController.text,
          "no_registrasi_keluarga": _selectedKepalaKeluarga,
          "id_hub_keluarga": _selectedHubunganKeluarga,
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
            message: "Berhasil Mengupdate Data Account Jemaat",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message']; // assuming the error message key is 'message'
        var snackBar = SnackBar(
          content: Text(errorMessage ?? 'Failed to update jemaat account'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        throw Exception('Failed to update jemaat account: $errorMessage');
      }
    } catch (e) {
      print('Error updating jemaat account: $e');
      var snackBar = SnackBar(
        content: Text('Failed to update jemaat account. Please try again later.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception('Failed to update jemaat account: $e');
    }
  }

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                            "Edit Jemaat",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Edit Jemaat Palmarum",
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
                            labelText: 'Pilih Kepala Keluarga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          value: _selectedKepalaKeluarga,
                          items: pelayanIbadah.map((pelayan) {
                            return DropdownMenuItem<int>(
                              value: pelayan['id'],
                              child: Text(pelayan['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKepalaKeluarga = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _namaDepanController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nama Depan',
                            hintText: 'Isi Nama Depan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: TextFormField(
                          controller: _namaBelakangController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Nama Belakang',
                            hintText: 'Isi Nama Belakang',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Hubungan Keluarga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          value: _selectedHubunganKeluarga,
                          items: hubkeluarga.map((hubungan) {
                            return DropdownMenuItem<int>(
                              value: hubungan['id'],
                              child: Text(hubungan['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHubunganKeluarga = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_selectedKepalaKeluarga != null &&
                              _selectedHubunganKeluarga != null &&
                              _namaDepanController.text.isNotEmpty &&
                              _namaBelakangController.text.isNotEmpty) {
                            _updateAccountJemaat();
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
                              Icon(Icons.update, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Update',
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
                              Icon(Icons.cancel, color: Colors.white),
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
