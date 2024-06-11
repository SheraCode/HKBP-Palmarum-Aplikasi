import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/DetailConfirmBaptis.dart';
// Ensure this import matches your file structure
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fungsi untuk mengambil daftar pemasukan dari endpoint
Future<List<dynamic>> fetchPemasukanList(String idJemaat) async {
  final response = await http.get(Uri.parse('http://192.168.11.31:2005/baptis/$idJemaat'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load pemasukan list');
  }
}

// Fungsi untuk mendapatkan id_jemaat dari token
Future<String> getIdJemaatFromToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  if (token != null) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['id_jemaat'].toString();
  } else {
    throw Exception('Token not found');
  }
}

// Widget Pemasukan untuk menampilkan daftar pemasukan
class RiwayatBaptis extends StatefulWidget {
  @override
  _RiwayatBaptisState createState() => _RiwayatBaptisState();
}

class _RiwayatBaptisState extends State<RiwayatBaptis> {
  late Future<List<dynamic>> _pemasukanListFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String idJemaat = await getIdJemaatFromToken();
      setState(() {
        _pemasukanListFuture = fetchPemasukanList(idJemaat);
      });
    } catch (e) {
      setState(() {
        _pemasukanListFuture = Future.error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Riwayat Baptis',
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
      body: FutureBuilder<List<dynamic>>(
        future: _pemasukanListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Tidak Ada Data Riwayat Baptis'),
            );
          } else {
            List<dynamic> pemasukanList = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgroundprofil.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: GridView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: pemasukanList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> pemasukan = pemasukanList[index];
                  return GestureDetector(
                    onTap: () {
                      int pemasukanId = pemasukan['id_registrasi_baptis'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailConfirmBaptis(idRegistrasiBaptis: pemasukanId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage('assets/userbaptis.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.6),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pemasukan['nama_lengkap'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'fira',
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
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
        index: 1,
      ),
    );
  }

  String _getBankImage(String namaBank) {
    switch (namaBank.toLowerCase()) {
      case 'bri':
        return 'assets/bri.png';
      case 'bni':
        return 'assets/bni.png';
      case 'bank mayapada':
        return 'assets/bank_mayapada.png';
      case 'bca':
        return 'assets/bca.png';
      case 'dana':
        return 'assets/dana.png';
      case 'mandiri':
        return 'assets/mandiri.png';
      case 'bsi':
        return 'assets/bsi.png';
      case 'bank aceh':
        return 'assets/bank_aceh.png';
      case 'bank lainnya':
        return 'assets/bank_lainnya.png';
      case 'tunai':
        return 'assets/tunai_nobg.png';
      default:
        return 'assets/default_bank.png';
    }
  }
}
