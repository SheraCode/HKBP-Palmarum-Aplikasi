import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class pelayanharian extends StatefulWidget {
  @override
  _PelayanHarianState createState() => _PelayanHarianState();
}

class _PelayanHarianState extends State<pelayanharian> {
  late Map<String, List<dynamic>> pelayanGerejaMap;
  bool isLoading = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response =
    await http.get(Uri.parse('http://192.168.11.31:2005/pelayan-ibadah'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('pelayanGerejaList: $responseData'); // Tambahkan ini

      final Map<String, List<dynamic>> tempMap = {};
      responseData.forEach((data) {
        final String sesiIbadah = data['sesi_ibadah'];
        if (tempMap.containsKey(sesiIbadah)) {
          tempMap[sesiIbadah]!.add(data);
        } else {
          tempMap[sesiIbadah] = [data];
        }
      });

      setState(() {
        pelayanGerejaMap = tempMap;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pelayan Harian',
          style: TextStyle(
            fontFamily: 'fira',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        backgroundColor: Color(0xFF03A9F3), // Ubah warna AppBar menjadi transparan
        elevation: 0, // Hilangkan bayangan AppBar
      ),
      body: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFFB3E5FC),
              image: DecorationImage(
                image: AssetImage(
                    'assets/backgroundprofil.png'), // Ganti dengan path gambar latar belakang Anda
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
              // Warna biru muda
            ),
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            child: Column(
              children: pelayanGerejaMap.keys.map((sesi) {
                return Column(
                  children: [
                    Text(
                      'Ibadah $sesi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.black, // Warna garis menjadi hitam
                      ),
                      child: DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Pelayanan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nama Pelayanan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        rows: pelayanGerejaMap[sesi]!.map((pelayan) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  pelayan['keterangan'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataCell(
                                Text(
                                  pelayan['nama_pelayanan_ibadah'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }).toList(),
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
              Navigator.pop(context); // Kembali ke halaman sebelumnya
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => profil()),
              );
              break;
          }
        },
        index: 0,
      ),
    );
  }
}
