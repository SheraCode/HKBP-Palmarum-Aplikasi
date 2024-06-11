import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/JadwalIbadah.dart';
import 'package:hkbp_palmarum_app/admin/WartaJemaat.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditJadwalIbadah extends StatefulWidget {
  final String idJadwalIbadah;

  EditJadwalIbadah(this.idJadwalIbadah);

  @override
  _EditJadwalIbadahState createState() => _EditJadwalIbadahState();
}

class _EditJadwalIbadahState extends State<EditJadwalIbadah> {
  late TextEditingController _sesiIbadahController;
  late TextEditingController _keteranganIbadahController;
  late TextEditingController _controller;
  var height, width;
  TextEditingController _dateController = TextEditingController();
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

  Future<void> fetchData(String idJadwalIbadah) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.11.31:2005/jadwal-ibadah/$idJadwalIbadah'));
      if (response.statusCode == 200) {
        // Ambil data jadwal ibadah berdasarkan idJadwalIbadah
        var jadwalIbadah = jsonDecode(response.body);
        setState(() {
          // Isi controller sesiIbadah dan keteranganIbadah dengan data yang diambil
          _sesiIbadahController.text = jadwalIbadah['sesi_ibadah'];
          _keteranganIbadahController.text = jadwalIbadah['keterangan'];
          // Assign nilai _selectedNamaMinggu berdasarkan id_jenis_minggu dari data
          _selectedNamaMinggu = jadwalIbadah['id_jenis_minggu'];
          // Isi _dateController dengan tanggal ibadah yang diambil
          _dateController.text = jadwalIbadah['tgl_ibadah'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _updateJadwalIbadah() async {
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
        Uri.parse('http://192.168.11.31:2005/jadwal-ibadah/${widget.idJadwalIbadah}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_jemaat': idJemaat,
          'id_jenis_minggu': _selectedNamaMinggu,
          'tgl_ibadah': _dateController.text,
          'sesi_ibadah': _sesiIbadahController.text,
          'keterangan': _keteranganIbadahController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Berhasil memperbarui jadwal ibadah
        print('Jadwal Ibadah berhasil diperbarui');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 255),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Jadwal Ibadah Berhasil di Perbaharui",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JadwalIbadah()),
        );
        // Tambahkan logika atau tindakan lanjutan setelah berhasil memperbarui
      } else {
        // Gagal memperbarui jadwal ibadah
        print('Gagal memperbarui jadwal ibadah');
        // Tambahkan logika atau tindakan lanjutan jika gagal memperbarui
      }
    } catch (e) {
      print('Error updating jadwal ibadah: $e');
      // Handle error
    }
  }


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _sesiIbadahController = TextEditingController();
    _keteranganIbadahController = TextEditingController();
    fetchData(widget.idJadwalIbadah);
  }

  @override
  void dispose() {
    _controller.dispose();
    _sesiIbadahController.dispose();
    _keteranganIbadahController.dispose();
    super.dispose();
  }

  int? _selectedNamaMinggu;

  List<Map<String, dynamic>> namaMinggu = [
    {"id": 1, "name": "Advent I – IV"},
    {"id": 2, "name": "Natal"},
    {"id": 3, "name": "Setelah Tahun Baru"},
    {"id": 4, "name": "I – IV Setelah Epifani / Hapapatar"},
    {"id": 5, "name": "Septuagesima / Sexagesima"},
    {"id": 6, "name": "Estomihi"},
    {"id": 7, "name": "Invocavit"},
    {"id": 8, "name": "Reminiscere"},
    {"id": 9, "name": "Okuli"},
    {"id": 10, "name": "Letare"},
    {"id": 11, "name": "Judika"},
    {"id": 12, "name": "Palmarum (Maremare)"},
    {"id": 13, "name": "Paskah Pertama / Paskah"},
    {"id": 14, "name": "Quasimodo Geniti"},
    {"id": 15, "name": "Miserekordias Domini"},
    {"id": 16, "name": "Jubilate"},
    {"id": 17, "name": "Kantate"},
    {"id": 18, "name": "Rogate"},
    {"id": 19, "name": "Exaudi"},
    {"id": 20, "name": "Pentakosta"},
    {"id": 21, "name": "Trinitatis"},
    {"id": 22, "name": "I – XXIV Setelah Trinitatis"},
  ];


  int? _nameSunday;

  Future<void> _createWarta(String sesiIbadahText, String keteranganIbadahText) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.11.31:2005/jadwal-ibadah/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_jenis_minggu': _selectedNamaMinggu,
          'tgl_ibadah': _dateController.text,
          'sesi_ibadah': sesiIbadahText,
          'keterangan': keteranganIbadahText,
        }),
      );

      if (response.statusCode == 200) {
        print('Jadwal Ibadah berhasil dibuat');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Jadwal Ibadah Berhasil di Perbaharui",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JadwalIbadah()),
        );
        // Tambahkan kode untuk menampilkan pesan sukses
      } else {
        print('Gagal membuat jadwal ibadah');
        // Tambahkan kode untuk menampilkan pesan gagal
      }
    } catch (e) {
      print('Error creating warta: $e');
      // Handle error
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
                              "Tambah Jadwal Ibadah",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tambah Jadwal Ibadah",
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
                              labelText: 'Pilih Nama Minggu',
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
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                          child: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context); // Panggil method _selectDate saat input tanggal diklik
                            },
                            decoration: InputDecoration(
                              labelText: 'Tanggal',
                              hintText: 'Pilih Tanggal',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
                          child: TextFormField(
                            controller: _sesiIbadahController,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Sesi Ibadah',
                              hintText: 'Isi Sesi Ibadah',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
                          child: TextFormField(
                            controller: _keteranganIbadahController,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Keterangan Ibadah',
                              hintText: 'Isi Keterangan Ibadah',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            String sesiIbadahText = _sesiIbadahController.text.trim();
                            String keteranganIbadahText = _keteranganIbadahController.text.trim();

                            if (sesiIbadahText.isNotEmpty && keteranganIbadahText.isNotEmpty) {
                              _updateJadwalIbadah(); // Memanggil fungsi _updateJadwalIbadah saat data valid
                            } else {
                              var snackBar = SnackBar(
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155),
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: "Gagal",
                                  message: "Sesi Ibadah dan Keterangan Ibadah harus diisi",
                                  contentType: ContentType.failure,
                                ),
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
                                Icon(Icons.save, color: Colors.white), // Ganti icon menjadi save
                                SizedBox(width: 5),
                                Text(
                                  'Simpan', // Ganti teks menjadi "Simpan"
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
      drawer: DrawerWidget(),
    );
  }
}
