import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/admin/home.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/isikegiatan.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/register.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class kegiatanGereja extends StatefulWidget {
  @override
  _WartaJemaatState createState() => _WartaJemaatState();
}

final List<Map<String, dynamic>> items = [
  {
    'text': 'Acara Sombusihol bersama \nBapak Bobby Nasution',
    'iconData': Icons.access_time,
    'imagePath': 'assets/sombusihol.jpg', // Ganti dengan path gambar yang sesuai
  },
  {
    'text': 'Kerja Tahun HKBP Palmarum 2024',
    'iconData': Icons.access_time,
    'imagePath': 'assets/kerjatahun.jpg', // Ganti dengan path gambar yang sesuai
  },
  {
    'text': 'Perayaan Hari Palmarum se Kota Tarutung',
    'iconData': Icons.access_time,
    'imagePath': 'assets/palmarum.jpg', // Ganti dengan path gambar yang sesuai
  },
];

class _WartaJemaatState extends State<kegiatanGereja> {
  bool _isScrolled = false;
  List<dynamic> beritaList = [];



  @override
  void initState() {
    super.initState();
    fetchData();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ScrollableState scrollableState = Scrollable.of(context)!;
      scrollableState.position.addListener(() {
        setState(() {
          _isScrolled = scrollableState.position.pixels > 0;
        });
      });
    });
  }




  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/berita'));
    if (response.statusCode == 200) {
      setState(() {
        beritaList = json.decode(response.body);
        print(beritaList);
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
          'Kegiatan',
          style: TextStyle(
              fontFamily: 'fira',
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => home()),
            ); // Kembali ke halaman sebelumnya
          },
        ),
        backgroundColor: Color(0xFF03A9F3), // Ubah warna AppBar menjadi transparan
        elevation: 0, // Hilangkan bayangan AppBar
      ),
      body: Stack(
        children: [
          // Background Container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundprofil.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 60),
            child: Container(
              child: GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(
                  beritaList.length,
                      (index) {
                    String text = beritaList[index]['nama_kegiatan']; // Ambil judul dari data
                    String imagePath = beritaList[index]['foto_kegiatan'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IsiKegiatan(idKegiatan: beritaList[index]['id_waktu_kegiatan'], berita: beritaList[index])),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 13 / 13, // Proporsi yang diinginkan (contoh: 16:9)
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'http://192.168.11.31:2005/kegiatan/${beritaList[index]['id_waktu_kegiatan']}/image',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'fira',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                      },
                ),
              ),
            ),
          ),

        ],
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
