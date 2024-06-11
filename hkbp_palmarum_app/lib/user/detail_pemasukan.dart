import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/pemasukan.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// Fungsi untuk mengambil detail pemasukan dari endpoint berdasarkan ID
Future<Map<String, dynamic>> fetchPemasukanDetails(int pemasukanId) async {
  final response = await http.get(Uri.parse('http://192.168.11.31:2005/pemasukan/$pemasukanId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load pemasukan detail');
  }
}

// Widget DetailPemasukan untuk menampilkan detail pemasukan
class DetailPemasukan extends StatefulWidget {
  final int pemasukanId;

  DetailPemasukan({required this.pemasukanId});

  @override
  _DetailPemasukanState createState() => _DetailPemasukanState();
}

class _DetailPemasukanState extends State<DetailPemasukan> {
  late Future<Map<String, dynamic>> _pemasukanFuture;
  late Map<String, dynamic> _pemasukanData;

  TextEditingController _totalController = TextEditingController();
  TextEditingController _kategoriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pemasukanFuture = fetchPemasukanDetails(widget.pemasukanId);
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

      body: FutureBuilder<Map<String, dynamic>>(
        future: _pemasukanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load pemasukan details'),
            );
          } else {
            _pemasukanData = snapshot.data!;
            _totalController.text = _pemasukanData['total_pemasukan'].toString();
            _kategoriController.text = _pemasukanData['kategori_pemasukan'] ?? '';

            return _buildPemasukanDetails();
          }
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xFF03A9F3),
        index: 1,
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
      ),
    );
  }

  Widget _buildPemasukanDetails() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bglogin.JPG"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Tanggal Pemasukan:',
              value: _pemasukanData['tanggal_pemasukan'] ?? '',
            ),
            _buildTextField(
              label: 'Total Pemasukan:',
              value: _pemasukanData['total_pemasukan'].toString(),
            ),
            _buildTextField(
              label: 'Bentuk Pemasukan:',
              value: _pemasukanData['bentuk_pemasukan'] ?? '',
            ),
            _buildTextField(
              label: 'Nama Bank:',
              value: _pemasukanData['nama_bank'] ?? '',
            ),
            _buildTextField(
              label: 'Kategori Pemasukan:',
              value: _pemasukanData['kategori_pemasukan'] ?? '',
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Pemasukan()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
