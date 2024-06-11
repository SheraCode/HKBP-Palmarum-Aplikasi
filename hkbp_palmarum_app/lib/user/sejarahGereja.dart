import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class sejarahGereja extends StatefulWidget {


  @override
  _IsiKegiatanState createState() => _IsiKegiatanState();
}

class _IsiKegiatanState extends State<sejarahGereja> {
  bool _isScrolled = false;
  Map<String, dynamic>? sejarahData;


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
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/sejarah-gereja'));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      if (responseData.isNotEmpty) {
        setState(() {
          sejarahData = responseData.first; // Ambil objek pertama dari daftar sebagai data sejarah
        });
      } else {
        throw Exception('Data response is empty');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sejarah Gereja',
          style: TextStyle(
            fontFamily: 'fira',
            color: Colors.white,
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
        child: Column(
          children: [
            // Widget untuk menampilkan gambar dan informasi kegiatan
            sejarahData != null
                ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Mengubah gambar menjadi bulat
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/banner_sejarah.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30), // Spasi antara gambar dan teks// Spasi antara judul dan teks paragraf
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20), // Padding untuk teks paragraf
                  child: Text(
                    sejarahData!['sejarah'],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
                : CircularProgressIndicator(), // Tampilkan indikator loading jika data belum diambil
          ],
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
