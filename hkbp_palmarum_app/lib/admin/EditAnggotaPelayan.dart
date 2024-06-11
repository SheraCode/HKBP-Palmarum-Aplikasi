import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAnggotaPelayan extends StatefulWidget {
  final String id;

  EditAnggotaPelayan(this.id);

  @override
  _EditAnggotaPelayanState createState() => _EditAnggotaPelayanState();
}

class _EditAnggotaPelayanState extends State<EditAnggotaPelayan> {
  late TextEditingController _controllerNama;
  late TextEditingController _controllerKeterangan;
  var height, width;

  @override
  void initState() {
    super.initState();
    _controllerNama = TextEditingController();
    _controllerKeterangan = TextEditingController();
    fetchData();
  }

  @override
  void dispose() {
    _controllerNama.dispose();
    _controllerKeterangan.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.31:2005/pelayanan-ibadah/${widget.id}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _controllerNama.text = data['nama_pelayanan_ibadah'];
        _controllerKeterangan.text = data['keterangan'];
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _updatePelayananIbadah(String namaPelayanan, String keterangan) async {
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
        Uri.parse('http://192.168.11.31:2005/pelayanan_ibadah/${widget.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_jemaat': idJemaat,
          'nama_pelayanan_ibadah': namaPelayanan,
          'keterangan': keterangan,
        }),
      );

      if (response.statusCode == 200) {
        var snackBar =  SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 225), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Mengubah Data Pelayan Ibadah",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context); // Kembali ke halaman sebelumnya setelah update berhasil
      } else {
        throw Exception('Failed to update pelayanan ibadah');
      }
    } catch (e) {
      var snackBar = SnackBar(
        content: Text('Gagal memperbarui pelayanan ibadah'),
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
                                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
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
                              "Edit Pelayan Kebaktian",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Edit Pelayan Kebaktian",
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
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Nama Pelayanan',
                              hintText: 'Nama Pelayanan Ibadah',
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
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            String namaPelayanan = _controllerNama.text.trim();
                            String keterangan = _controllerKeterangan.text.trim();
                            if (namaPelayanan.isNotEmpty && keterangan.isNotEmpty) {
                              _updatePelayananIbadah(namaPelayanan, keterangan);
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
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Simpan',
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
                            Navigator.pop(context); // Kembali ke halaman sebelumnya
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
