import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';

class UlangTahunJemaat extends StatefulWidget {
  @override
  _UlangTahunJemaatState createState() => _UlangTahunJemaatState();
}

class _UlangTahunJemaatState extends State<UlangTahunJemaat> {
  List<dynamic> ulangTahunList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/jemaat/berulang-tahun'));
    if (response.statusCode == 200) {
      setState(() {
        ulangTahunList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String calculateAge(String birthDate) {
    DateTime today = DateTime.now();
    DateTime parsedDate = DateTime.parse(formatDate(birthDate));
    int age = today.year - parsedDate.year;
    if (today.month < parsedDate.month ||
        (today.month == parsedDate.month && today.day < parsedDate.day)) {
      age--;
    }
    return age.toString();
  }

  String formatDate(String dateStr) {
    List<String> parts = dateStr.split('-');
    if (parts.length == 3) {
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);
      return DateTime(year, month, day).toString();
    }
    return dateStr; // Return original string if format is invalid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jemaat Ulang Tahun',
          style: TextStyle(
            fontFamily: 'fira',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF03A9F3),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ulangTahunList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/nodata.png", width: 190),
            SizedBox(height: 20),
            Text(
              'Tidak ada Jemaat yang berulang tahun hari ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundprofil.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 60),
          child: GridView.count(
            crossAxisCount: 1, // Jumlah kolom dalam GridView
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
              ulangTahunList.length,
                  (index) {
                final jemaat = ulangTahunList[index];
                final String imagePath = jemaat['foto_jemaat'];
                final String birthDate = jemaat['tgl_lahir'];

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar jemaat
                      Image.network(
                        'http://192.168.11.31:2005/jemaat/${jemaat['id_jemaat']}/image',
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      // Teks di bagian bawah gambar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${jemaat['nama_depan']} ${jemaat['nama_belakang']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'fira',
                                ),
                              ),
                              SizedBox(height: 4), // Spasi antara nama dan tanggal lahir
                              Text(
                                'Tanggal Lahir: $birthDate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'fira',
                                ),
                              ),
                              SizedBox(height: 4), // Spasi antara tanggal lahir dan umur
                              Text(
                                'Umur: ${calculateAge(birthDate)} tahun',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'fira',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
              break;
            case 1:
            // Handle index 1
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
