import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:convert';


class detailProfil extends StatefulWidget {
  @override
  final token;
  const detailProfil({@required this.token, Key? key}) : super(key: key);
  State<detailProfil> createState() => _detailProfilState();
}

class _detailProfilState extends State<detailProfil> {

  TextEditingController namaDepanController = TextEditingController();
  TextEditingController namaBelakangController = TextEditingController();
  TextEditingController tempatLahirController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController emailController = TextEditingController();


  late String namaDepan = '';
  late String namaBelakang = '';
  late String namaHubunganKeluarga = '';
  late int id_jemaat;
  late String email = '';
  late String tempatLahir = '';
  late String telepon = '';
  late String alamat = '';
  // mulai dari sini
  late String bidangPendidikan = '';
  late String foto_jemaat = '';
  late String gol_darah = '';
  late int id_hubkeluarga;
  late int id_kecamatan;
  late int id_pekerjaan;
  late int id_pendidikan;
  late String isBaptis = '';
  late String isMenikah = '';
  late String isRPP = '';
  late String isSidi = '';
  late String nama_pekerjaan_lainnya = '';
  late String jenis_kelamin = '';
  late String password = '';


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
          id_hubkeluarga = decodedToken['id_hub_keluarga'];
          tempatLahir = decodedToken['tempat_lahir'];
          telepon = decodedToken['no_hp'].toString();
          alamat = decodedToken['alamat'];
          email = decodedToken['email'];
          bidangPendidikan = decodedToken['bidang_pendidikan_lainnya'];
          foto_jemaat = decodedToken['foto_jemaat'];
          gol_darah = decodedToken['gol_darah'];
          id_kecamatan = decodedToken['id_kecamatan'];
          id_pekerjaan = decodedToken['id_pekerjaan'];
          id_pendidikan = decodedToken['id_pekerjaan'];
          isBaptis = decodedToken['isBaptis'];
          isMenikah = decodedToken['isMenikah'];
          isRPP = decodedToken['isRPP'];
          isSidi = decodedToken['isSidi'];
          nama_pekerjaan_lainnya = decodedToken['nama_pekerjaan_lainnya'];
          password = decodedToken['password'];



          setState(() {
            namaDepanController.text = namaDepan;
            namaBelakangController.text = namaBelakang;
            tempatLahirController.text = tempatLahir;
            alamatController.text = alamat;
            emailController.text = email;
          });

        });
      } catch (error) {
        print('Error decoding token: $error');
      }
    }
  }



  Future<void> updateJemaatProfile(int jemaatId, String namaDepan, String namaBelakang, String tempatLahir, String telepon, String alamat, String email) async {
    String url = 'http://192.168.11.31:2005/jemaat/profil/$jemaatId';

    String noHp = telepon.replaceAll(RegExp(r'\D+'), ''); // Menghapus karakter selain angka
    int nomorTelepon = int.tryParse(noHp) ?? 0; // Mengonversi ke integer, atau gunakan nilai default jika tidak berhasil

    Map<String, dynamic> data = {
      'nama_depan': namaDepan,
      'nama_belakang': namaBelakang,
      'tempat_lahir': tempatLahir,
      'no_hp': nomorTelepon, // Menggunakan nomor telepon yang telah dikonversi
      'alamat': alamat,
      'email': email,
    };

    print(telepon);


    String jsonBody = jsonEncode(data);

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print('Data berhasil diperbarui');

        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 220), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "Berhasil Mengubah Profil Jemaat, Silahkan Melakukan Logout dan Login Kembali",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Menampilkan snackbar atau memberi tahu pengguna bahwa data berhasil diperbarui
      } else {
        print('Gagal memperbarui data. Kode status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var snackBar = SnackBar(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 220), // Menempatkan snackbar di atas layar
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: "Success",
            message: "${response.body}",
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Menampilkan snackbar atau memberi tahu pengguna bahwa gagal memperbarui data
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      // Menampilkan snackbar atau memberi tahu pengguna bahwa terjadi kesalahan
    }
  }



  // edit data


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Container
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bgprofile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content Containerb
            SingleChildScrollView(
              child: Positioned(
                top: 120,
                left: 15,
                right: 15,
                child: Center(
                  child: Container(
                    width: 450,
                    height: 1050, // Menambah tinggi agar muat dengan konten baru
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
                      padding: const EdgeInsets.all(20.0),
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
                          // Menampilkan hubungan keluarga berdasarkan id_hubkeluarga
                          if (id_hubkeluarga == 1) Text('Kepala Keluarga', style: TextStyle(color: Colors.black, fontSize: 20.0, fontFamily: 'fira')),
                          if (id_hubkeluarga == 2) Text('Isteri', style: TextStyle(color: Colors.black, fontSize: 20.0, fontFamily: 'fira')),
                          if (id_hubkeluarga == 3) Text('Anak', style: TextStyle(color: Colors.black, fontSize: 20.0, fontFamily: 'fira')),
                          if (id_hubkeluarga == 4) Text('Saudara Kandung', style: TextStyle(color: Colors.black, fontSize: 20.0, fontFamily: 'fira')),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Divider( // Garis baru setelah teks
                              color: Colors.black,
                              thickness: 1,
                            ),
                          ),
                          // TextField di sini
                          TextField(
                            controller: namaDepanController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Nama Depan",
                              hintText: "Nama Depan",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          HeightBox(10),
                          TextField(
                            controller: namaBelakangController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Nama Belakang",
                              hintText: "Nama Belakang",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.person), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          HeightBox(10),
                          TextField(
                            controller: tempatLahirController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Tempat Lahir",
                              hintText: "Tempat Lahir",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.place_outlined), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          HeightBox(10),
                          TextField(
                            controller: teleponController, // Gunakan TextEditingController
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Telepon",
                              hintText: "Telepon",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.phone), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          HeightBox(10),
                          TextField(
                            controller: alamatController,
                            maxLines: null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Alamat",
                              hintText: "Alamat",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.home), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          HeightBox(10),
                          TextField(
                            controller: emailController,
                            maxLines: null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Email",
                              hintText: "Email",
                              errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              prefixIcon: Icon(Icons.email_rounded), // Icon surat untuk email
                            ),
                          ).p4().px24(),
                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => profil()),
                              );
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
                                  Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Kembali',
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

                          SizedBox(height: 10,),
                          GestureDetector(

                            onTap: () async {
                              // Navigasi ke layar profil
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => profil()),
                              );

                              try {
                                // Menunggu navigasi selesai sebelum mengirim permintaan HTTP
                                await updateJemaatProfile(id_jemaat, namaDepanController.text, namaBelakangController.text, tempatLahirController.text, teleponController.text, alamatController.text, emailController.text);
                              } catch (error) {
                                print('Terjadi kesalahan saat memperbarui profil: $error');
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
                                  Icon(Icons.edit, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Edit Profil',
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
                ),
              ),

            )
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
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
              break;
            case 2:
              break;
          }
        },
        index: 2,
      ),
    );
  }
}
