import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/detailProfil.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/splashscreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';

class profil extends StatefulWidget {

  @override
  final token;
  const profil({@required this.token, Key? key}) : super(key: key);
  State<profil> createState() => _profilState();
}

class _profilState extends State<profil> {

  late String namaDepan = '';
  late String namaBelakang = '';
  late String namaHubunganKeluarga = '';
  late int id_jemaat;
  late int id_hubkeluarga;
  late int nohp;
  late String email = '';

  @override
  void initState() {
    super.initState();
    _loadNamaDepanFromSharedPreferences(); // Coba memuat nama dari SharedPreferences
  }

  Future<void> _loadNamaDepanFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token'); // Mengambil token dari SharedPreferences
    print(savedToken);
    if (savedToken != null && savedToken.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(savedToken);
        setState(() {
          namaDepan = decodedToken['nama_depan']; // Setel namaDepan menggunakan token yang disimpan
          namaBelakang = decodedToken['nama_belakang']; // Setel namaDepan menggunakan token yang disimpan
          id_jemaat = decodedToken['id_jemaat']; // Setel namaDepan menggunakan token yang disimpan
          id_hubkeluarga = decodedToken['id_hub_keluarga']; // Setel namaDepan menggunakan token yang disimpan
          email = decodedToken['email']; // Setel namaDepan menggunakan token yang disimpan
          nohp = decodedToken['no_hp']; // Setel namaDepan menggunakan token yang disimpan
        });
      } catch (error) {
        print('Error decoding token: $error');
      }
    }
  }

  Future<void> _removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari SharedPreferences
    // Setel kembali nilai-nilai state menjadi default atau kosong
    setState(() {
      namaDepan = '';
      namaBelakang = '';
      id_jemaat = 0;
      id_hubkeluarga = 0;
      email = '';
      nohp = 0;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => splashscreen()), // Ganti SplashScreen dengan nama kelas halaman splash screen Anda
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Content Container
          Positioned(
            top: 120,
            left: 15,
            right: 15,
            child: Center(
              child: Container(
                width: 450,
                height: 250, // Menambah tinggi agar muat dengan konten baru
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 9,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('http://192.168.11.31:2005/jemaat/$id_jemaat/image'),
                    ),
                    SizedBox(height: 20),

                    Text(
                      '$namaDepan $namaBelakang',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'fira',
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      height: 20,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    if(id_hubkeluarga == 1)
                      Text(
                        'Kepala Keluarga',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: 'fira',
                        ),
                      ),

                    if(id_hubkeluarga == 2)
                      Text(
                        'Isteri',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: 'fira',
                        ),
                      ),

                    if(id_hubkeluarga == 3)
                      Text(
                        'Anak',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: 'fira',
                        ),
                      ),

                    if(id_hubkeluarga == 4)
                      Text(
                        'Saudara Kandung',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: 'fira',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Box Decoration Baru di luar konten utama
          Positioned(
            bottom: 10,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 9,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman home() ketika ikon diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => detailProfil()),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profil Lengkap',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Icon(Icons.arrow_circle_right_outlined),

                        ],

                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
          // Box Decoration Baru di luar konten utama
          Positioned(
            bottom: 120,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 9,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 10), // Berikan jarak antara ikon dan teks
                        Text(
                          '$email',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone_android_rounded),
                        SizedBox(width: 10), // Berikan jarak antara ikon dan teks
                        Text(
                          '$nohp',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),

                      ],
                    ),


                  ],
                ),
              ),
            ),
          ),
          // Tombol Logout
          Positioned(
            bottom: 230,
            left: 15,
            right: 15,
            child: GestureDetector(
              onTap: () {
                _removeToken(); // Panggil fungsi untuk menghapus token saat tombol ditekan
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 9,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Icon(Icons.logout, color: Colors.white,),
                    ],
                  ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => riwayat()),
              );
              break;
            case 2:
          }
        },
        index: 2,
      ),
    );
  }
}
