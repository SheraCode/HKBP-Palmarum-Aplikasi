import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/Pengeluaran.dart';
import 'package:hkbp_palmarum_app/admin/home.dart';
import 'package:hkbp_palmarum_app/admin/kegiatan.dart';
import 'package:hkbp_palmarum_app/user/CobaREQBaptis.dart';
import 'package:hkbp_palmarum_app/user/ConfirmBaptis.dart';
import 'package:hkbp_palmarum_app/user/ConfirmSidi.dart';
import 'package:hkbp_palmarum_app/user/PilihSidi.dart';
import 'package:hkbp_palmarum_app/user/RegistrasiSidi.dart';
import 'package:hkbp_palmarum_app/user/TambahAnggotaKeluarga.dart';
import 'package:hkbp_palmarum_app/user/UlangTahunJemaat.dart';
import 'package:hkbp_palmarum_app/user/WartaJemaat.dart';
import 'package:hkbp_palmarum_app/user/createBaptis.dart';
import 'package:hkbp_palmarum_app/user/createPernikahan.dart';
import 'package:hkbp_palmarum_app/user/detail_pemasukan.dart';
import 'package:hkbp_palmarum_app/user/isikegiatan.dart';
import 'package:hkbp_palmarum_app/user/isiwartajemaat.dart';
import 'package:hkbp_palmarum_app/user/kegiatan.dart';
import 'package:hkbp_palmarum_app/user/pelayangereja.dart';
import 'package:hkbp_palmarum_app/user/pelayanharian.dart';
import 'package:hkbp_palmarum_app/user/pemasukan.dart';
import 'package:hkbp_palmarum_app/user/pengeluaran.dart';
import 'package:hkbp_palmarum_app/user/sejarahGereja.dart';
import 'package:hkbp_palmarum_app/user/uploadfoto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'profil.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:hkbp_palmarum_app/user/register.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();

  final token;

  const home({@required this.token, Key? key}) : super(key: key);
}



class _homeState extends State<home> {
  List<dynamic> beritaList = [];
  List<dynamic> wartaList = [];

  void _launchMaps() async {
    // URL untuk tautan Google Maps yang ingin dibuka
    final url = 'https://maps.app.goo.gl/wjU1e8J66M8Jg1iS8';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Tidak dapat membuka Google Maps') ;
    }
  }


  String? _name;
late String namaDepan = '';
late int _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadNamaDepanFromSharedPreferences(); // Coba memuat nama dari SharedPreferences
    fetchData();
    fetchWarta();
  }


  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/berita/home'));
    if (response.statusCode == 200) {
      setState(() {


        beritaList = json.decode(response.body);
        print(beritaList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchWarta() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/warta/home'));
    if (response.statusCode == 200) {
      setState(() {
        wartaList = json.decode(response.body);
        print(wartaList);
      });
    } else {
      throw Exception('Failed to load data');
    }
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
          _selectedStatus = decodedToken['id_hub_keluarga']; // Setel _selectedStatus menggunakan token yang disimpan
        });
      } catch (error) {
        print('Error decoding token: $error');
      }
    }
  }



  List<String> imagePaths = [
    'assets/userbaptis.jpg',
    'assets/userpernikahan.jpg',
    'assets/angkatsidi.jpeg',
    'assets/wartauser.png',
    'assets/pelayan.JPG',
    'assets/bglogin.JPG',
  ];

  List<String> teks = [
    'Baptis',
    'Pernikahan',
    'Naik Sidi',
    'Warta Jemaat',
    'Pelayan Harian',
    'Pelayan Gereja',
  ];

  final List<String> imageInformation = [
    'assets/money.png',
    'assets/money.png',
    'assets/bglogin.JPG',
    'assets/cake.png',
    'assets/jemaat.png',
    // Tambahkan path gambar lainnya sesuai kebutuhan
  ];


  void printName() {
    print(_name);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            // Text(
            //   'Hello, $namaDepan!',
            //   style: TextStyle(fontSize: 20),
            // ),
            // Box Decoration dengan Shadow
            Container(
              height: MediaQuery.of(context).size.height / 5, // 1/4 dari tinggi layar
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.0), // Warna bayangan
                    spreadRadius: 0,
                    blurRadius: 9,
                    offset: Offset(0, 9), // Perubahan posisi bayangan
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/bglogin.JPG'), // Ganti dengan path gambar Anda
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(25.0), // Padding untuk tulisan
                child: Text(
                  'Selamat Datang di\nAplikasi Administrasi dan Keuangan\nHKBP Palmarum Tarutung',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'fira'
                  ),
                ),
              ),
            ),
            // Kategori yang ada

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: GridView.count(
                crossAxisCount: 3, // 3 kolom
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(
                  6, // Jumlah gambar (3 baris x 2 kolom)
                      (index) {
                    return GestureDetector(
                      onTap: () {
                        // Cek nilai id_hub_keluarga
                        if (_selectedStatus == 3) {
                          // Jika nilainya 3, tampilkan alert Akses Ditolak jika bukan halaman Warta Jemaat, Pelayan Harian, atau Pelayan Gereja
                          if (index != 3 && index != 4 && index != 5) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Akses Ditolak'),
                                  content: Text('Anda tidak memiliki akses untuk melakukan tindakan ini.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Jika nilainya 3 dan index adalah 3 (Warta Jemaat), 4 (Pelayan Harian), atau 5 (Pelayan Gereja), maka navigasikan ke halaman yang sesuai
                            switch (index) {
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => craetePernikahan(),
                                  ),
                                );
                                break;
                              case 3:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WartaJemaat(token: widget.token),
                                  ),
                                );
                                break;
                              case 4:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => pelayanharian(),
                                  ),
                                );
                                break;
                              case 5:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => pelayangereja(),
                                  ),
                                );
                                break;
                              default:
                                break;
                            }
                          }
                        } else {
                          // Jika nilainya bukan 3, navigasi ke halaman yang sesuai
                          switch (index) {
                            case 0:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CobaBaptis(),
                                ),
                              );
                              break;
                            case 1:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => craetePernikahan(),
                                ),
                              );
                              break;
                            case 2:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PilihSidi(),
                                ),
                              );
                              break;
                          // Tambahkan logika lainnya sesuai dengan kebutuhan
                            case 3:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WartaJemaat(token: widget.token),
                                ),
                              );
                              break;
                            case 4:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pelayanharian(),
                                ),
                              );
                              break;
                            case 5:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pelayangereja(),
                                ),
                              );
                              break;
                            default:
                              break;
                          }
                        }
                      },


                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.9), // Warna bayangan
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 6), // Perubahan posisi bayangan
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(imagePaths[index]), // Mengambil path gambar dari daftar berdasarkan indeks item
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            teks[index], // Mengambil teks dari daftar berdasarkan indeks item
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 18),// Tulisan "Kegiatan"
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kegiatan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'fira',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => kegiatanGereja()),
                      );
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),
            // Single Child Scroll View
// Single Child Scroll View
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.0, bottom: 0), // Tambahkan padding hanya di bagian atas dan bawah
                    child: Row(
                      children: beritaList.map((berita) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IsiKegiatan(
                                  idKegiatan: berita['id_waktu_kegiatan'],
                                  berita: berita,
                                ),
                              ),
                            );
                          },

                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.9),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 6),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage('http://192.168.11.31:2005/kegiatan/${berita['id_waktu_kegiatan']}/image'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.6),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  left: 5.0,
                                  bottom: 5.0,
                                  child: Text(
                                    '${berita['nama_kegiatan']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'fira',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // warna garis
            width: 1, // lebar garis
          ),
          borderRadius: BorderRadius.circular(10), // sudut lengkung
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // warna bayangan
              spreadRadius: 2, // penyebaran bayangan
              blurRadius: 5, // radius blur
              offset: Offset(0, 3), // offset bayangan
            ),
          ],
          image: DecorationImage(
            image: AssetImage('assets/bglogin.JPG'), // gambar latar belakang
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),// penyesuaian gambar
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(
                      'HKBP Palmarum Ressort Tarutung Berada di Kabupaten Tapanuli Utara, Provinsi Sumatera Utara, Indonesia', // teks
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'fira'
                      ),// penataan teks
                    ),
                  ),
                  SizedBox(height: 10), // spasi antara teks dan tombol
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          _launchMaps(); // Panggil fungsi untuk membuka Google Maps
                        },
                        child: Text('Telusuri'),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10), // spasi antara teks dan gambar
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Container(
                width: 170, // lebar gambar
                height: 200, // tinggi gambar
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // sudut lengkung
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/bglogin.JPG', // path gambar
                    fit: BoxFit.cover, // penyesuaian gambar
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Warta Jemaat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'fira',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WartaJemaat(token: widget.token)),
                      );
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),
            // Single Child Scroll View
// Single Child Scroll View
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.0), // Add padding only at the top
                    child: Row(
                      children: wartaList.map((warta) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to IsiWartaJemaat screen when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IsiWartaJemaat(
                                  token: widget.token,
                                  id: warta['id_warta'].toString(), // Assuming 'id' is the key for the ID of each warta
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.3,
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.9),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 6),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage('assets/bglogin.JPG'), // Replace with the image data from wartaList
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.6),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  left: 5.0,
                                  bottom: 5.0,
                                  child: Text(
                                    'Warta Jemaat \n${warta['create_at']}', // Replace with the data from wartaList
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'fira',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Infromasi Umum',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'fira'
                ),
              ),
            ),

            Container(

              padding: EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white,
              child: GridView.count(
                crossAxisCount: 2, // 3 kolom
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(
                  5, // Jumlah gambar (3 baris x 2 kolom)
                      (index) {
                    String text = '';
                    IconData iconData;

                    // Tentukan teks dan ikon berdasarkan indeks
                    switch (index) {
                      case 0:
                        text = 'Pemasukan \Keuangan';
                        iconData = Icons.monetization_on_outlined;
                        break;
                      case 1:
                        text = 'Pengeluaran \Keuangan';
                        iconData = Icons.monetization_on_outlined;
                        break;
                      case 2:
                        text = 'Sejarah Gereja';
                        iconData = Icons.account_balance;
                        break;
                      case 3:
                        text = 'Jemaat\nBerulang Tahun';
                        iconData = Icons.cake_rounded;
                        break;
                      case 4:
                        text = 'Tambah\nAnggota Keluarga';
                        iconData = Icons.supervised_user_circle;
                        break;
                    // Tambahkan konfigurasi untuk kotak lainnya
                      default:
                        text = 'Default Text';
                        iconData = Icons.error;
                        break;
                    }

                    return GestureDetector(
                      onTap: () {
                        // Ganti dengan logika navigasi ke halaman yang sesuai dengan setiap item
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Pemasukan(),
                              ),
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Pengeluaran(),
                              ),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => sejarahGereja(),
                              ),
                            );
                            break;
                          case 3:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UlangTahunJemaat(),
                              ),
                            );
                          case 4:
                            if (_selectedStatus == 1 || _selectedStatus == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TambahAnggotaJemaat()),
                              );
                            } else {
                              var snackBar = SnackBar(
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 240),
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: "Gagal",
                                  message: "Anda tidak memiliki izin untuk menambah anggota keluarga.",
                                  contentType: ContentType.warning,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                            break;


                        // Tambahkan logika lainnya sesuai dengan kebutuhan
                          default:
                            break;
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.9), // Warna bayangan
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 6), // Perubahan posisi bayangan
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(imageInformation[index]),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.7),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                iconData,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => riwayat()),
              );
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
  Future<Map<String, dynamic>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      Map<String, dynamic> userData = jsonDecode(userDataString);
      return userData;
    } else {
      throw 'Data profil tidak ditemukan di Shared Preferences';
    }
  }
}


