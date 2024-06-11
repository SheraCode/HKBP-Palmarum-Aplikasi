import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/PelayanGereja.dart';
import 'package:hkbp_palmarum_app/admin/PelayanIbadahKebaktian.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPelayanGereja extends StatefulWidget {
  final String idPelayanGereja;

  EditPelayanGereja(this.idPelayanGereja);

  @override
  _EditPelayanGerejaState createState() => _EditPelayanGerejaState();
}

class _EditPelayanGerejaState extends State<EditPelayanGereja> {
  late TextEditingController _controllerNama;
  late TextEditingController _controllerKeterangan;
  var height, width;

  @override
  void initState() {
    super.initState();
    _controllerNama = TextEditingController();
    _controllerKeterangan = TextEditingController();
    fetchData(widget.idPelayanGereja);
  }

  int? _selectedPelayanIbadah;

  List<Map<String, String>> _dropdownItems = [
    {'value': '1', 'label': 'isTahbisan'},
    {'value': '0', 'label': 'NoTahbisan'}
    // Tambahkan pasangan nilai dan label lainnya sesuai kebutuhan
  ];

  int? _selectedNamaMinggu;
  Future<void> fetchData(String idJadwalIbadah) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.11.31:2005/pelayan/$idJadwalIbadah'));
      if (response.statusCode == 200) {
        // Ambil data jadwal ibadah berdasarkan idJadwalIbadah
        var pelayanGereja = jsonDecode(response.body);
        print('Data JSON: $pelayanGereja'); // Cetak data JSON
        setState(() {
          // Isi controller sesiIbadah dan keteranganIbadah dengan data yang diambil
          _controllerNama.text = '${pelayanGereja['nama_pelayan']} ${pelayanGereja['nama_belakang']}';
          _controllerKeterangan.text = pelayanGereja['keterangan'];
          _selectedPelayanIbadah = pelayanGereja['isTahbisan'];
          _selectedNamaMinggu = pelayanGereja['id_jemaat']; // Menambahkan id_jemaat ke dalam state
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }




  Future<void> _editPelayanGereja(String idPelayan, String namaPelayanan, String keterangan, int? isTahbisan) async {
    try {
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

      final response = await http.put(
        Uri.parse('http://192.168.11.31:2005/pelayan/edit/$idPelayan'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_jemaat': _selectedNamaMinggu,
          'keterangan': keterangan,
          'isTahbisan': isTahbisan
        }),
      );

      if (response.statusCode == 200) {
        print('Pelayan Gereja berhasil diubah');
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Mengubah Pelayan Gereja",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PelayanGereja()),
        );
      } else {
        print('Gagal mengubah Pelayan Gereja');
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Failed",
            message: "Gagal Mengubah Pelayan Gereja",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error editing Pelayan Gereja: $e');
      var snackBar = SnackBar(
        content: Text('Terjadi kesalahan saat mengubah Pelayan Gereja'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }



  @override
  void dispose() {
    _controllerNama.dispose();
    _controllerKeterangan.dispose();
    super.dispose();
    fetchData(widget.idPelayanGereja);
  }

  Future<void> _createPelayananIbadah(String namaPelayanan, String keterangan) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.11.31:2005/pelayan/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama_pelayan': namaPelayanan,
          'keterangan': keterangan,
          'IsTahbisan': _selectedPelayanIbadah
        }),
      );

      if (response.statusCode == 200) {
        print('Pelayanan Gereja berhasil dibuat');
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Membuat Pelayan Gereja",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PelayanKebaktian()),
        );
        // Navigasi atau tindakan lain setelah berhasil membuat pelayanan ibadah
      } else {
        print('Gagal membuat pelayanan Gereja');
        var snackBar = SnackBar(
          content: Text('Gagal membuat pelayanan Gereja'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error creating pelayanan ibadah: $e');
      var snackBar = SnackBar(
        content: Text('Terjadi kesalahan'),
        backgroundColor: Colors.red,
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
                              child: InkWell(
                                onTap: () {
                                  // Handle drawer tap
                                },
                                child: Icon(
                                  Icons.sort,
                                  color: Colors.white,
                                  size: 45,
                                ),
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
                              "Tambah Pelayan Gereja",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tambah Pelayan Gereja Palmarum",
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
                          child: TextFormField(
                            controller: _controllerNama,
                            enabled: false,
                            maxLines: null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelText: 'Nama Pelayan',
                              hintText: 'Nama Pelayan Gereja Palmarum',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _controllerKeterangan,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              hintText: 'Keterangan Pelayanan Ibadah',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Jenis Pelayan',
                              hintText: 'Pilih Jenis Pelayan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            value: _selectedPelayanIbadah?.toString(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPelayanIbadah = int.tryParse(newValue ?? '');
                              });
                            },
                            items: _dropdownItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['value']!,
                                child: Text(item['label']!),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            String namaPelayanan = _controllerNama.text.trim();
                            String keterangan = _controllerKeterangan.text.trim();
                            if (namaPelayanan.isNotEmpty && keterangan.isNotEmpty) {
                              _editPelayanGereja(widget.idPelayanGereja, namaPelayanan, keterangan, _selectedPelayanIbadah);
                            } else {
                              var snackBar = SnackBar(
                                content: Text('Nama Pelayanan dan Keterangan harus diisi'),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
