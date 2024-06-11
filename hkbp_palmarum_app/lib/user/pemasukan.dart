import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/detail_pemasukan.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// Fungsi untuk mengambil daftar pemasukan dari endpoint
Future<List<dynamic>> fetchPemasukanList() async {
  final response = await http.get(Uri.parse('http://192.168.11.31:2005/pemasukan'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load pemasukan list');
  }
}

// Widget Pemasukan untuk menampilkan daftar pemasukan
class Pemasukan extends StatefulWidget {
  @override
  _PemasukanState createState() => _PemasukanState();
}

class _PemasukanState extends State<Pemasukan> {
  late Future<List<dynamic>> _pemasukanListFuture;

  @override
  void initState() {
    super.initState();
    _pemasukanListFuture = fetchPemasukanList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pemasukan',
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
              child: Text('Failed to load pemasukan list'),
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
              child: ListView.builder(
                itemCount: pemasukanList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> pemasukan = pemasukanList[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0), // Tambahkan padding di sini
                    child: GestureDetector(
                      onTap: () {
                        int pemasukanId = pemasukan['id_pemasukan'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPemasukan(pemasukanId: pemasukanId),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16.0), // Padding di dalam Card
                          child: ListTile(
                            leading: _buildBankImage(pemasukan['nama_bank']),
                            title: Text(
                              pemasukan['kategori_pemasukan'] ?? '',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'fira',
                              ),
                            ),
                            subtitle: Text(
                              'Nama Bank: ${pemasukan['nama_bank']}\nJumlah: Rp ${pemasukan['total_pemasukan']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'fira',
                              ),
                            ),
                          ),
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
        index: 0,
      ),
    );
  }

  Widget _buildBankImage(String namaBank) {
    String bankImage;

    switch (namaBank.toLowerCase()) {
      case 'bri':
        bankImage = 'assets/bri.png';
        break;
      case 'bni':
        bankImage = 'assets/bni.png';
        break;
      case 'bank mayapada':
        bankImage = 'assets/bank_mayapada.png';
        break;
      case 'bca':
        bankImage = 'assets/bca.png';
        break;
      case 'dana':
        bankImage = 'assets/dana.png';
        break;
      case 'mandiri':
        bankImage = 'assets/mandiri.png';
        break;
      case 'bsi':
        bankImage = 'assets/bsi.png';
        break;
      case 'bank aceh':
        bankImage = 'assets/bank_aceh.png';
        break;
      case 'bank lainnya':
        bankImage = 'assets/bank_lainnya.png';
        break;
      case 'tunai':
        bankImage = 'assets/tunai_nobg.png';
        break;
      default:
        bankImage = 'assets/default_bank.png';
    }

    return Image.asset(
      bankImage,
      width: 50,
      fit: BoxFit.cover,
    );
  }
}
