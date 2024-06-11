import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/home.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:hkbp_palmarum_app/user/register.dart';

class kategori extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Box Decoration dengan Shadow
            Container(
              height: MediaQuery.of(context).size.height / 4, // 1/4 dari tinggi layar
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Warna bayangan
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // Perubahan posisi bayangan
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
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0), // Padding untuk tulisan
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
            // Kategori
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Content di bawah kategori
            Container(
              height: 150, // Sesuaikan tinggi gambar sesuai kebutuhan
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Tambahkan logika sesuai dengan kebutuhan
                      },
                      child: Container(
                        width: 150, // Sesuaikan lebar gambar sesuai kebutuhan
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.9),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/bglogin.JPG'), // Ganti dengan path gambar Anda
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
