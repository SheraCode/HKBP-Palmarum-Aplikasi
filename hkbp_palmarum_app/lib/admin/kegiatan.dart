import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hkbp_palmarum_app/admin/EditKegiatan.dart';
import 'package:hkbp_palmarum_app/admin/TambahKegiatan.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';

class kegiatan extends StatefulWidget {
  @override
  _KegiatanScreenState createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<kegiatan> {
  var height, width;
  List<Map<String, dynamic>> kegiatanList = [];
  bool isApiActive = true;

  @override
  void initState() {
    super.initState();
    fetchKegiatan();
  }

  Future<void> fetchKegiatan() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.11.31:2005/berita'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          kegiatanList = data.map((item) {
            return {
              'id_jenis_kegiatan': item['id_jenis_kegiatan'],
              'kegiatan': item['keterangan'],
              'nama_kegiatan': item['nama_kegiatan'],
              'foto_kegiatan': item['foto_kegiatan'],
              'id_waktu_kegiatan': item['id_waktu_kegiatan']
            };
          }).toList();
        });
      } else {
        setState(() {
          isApiActive = false; // Set flag to false if API call fails
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isApiActive = false; // Set flag to false if API call throws an exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.indigo,
          child: Column(
            children: [
              Container(
                height: height * 0.22,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Builder(
                              builder: (BuildContext context) {
                                return InkWell(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Icon(
                                    Icons.sort,
                                    color: Colors.white,
                                    size: 45,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kegiatan",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Kegiatan HKBP Palmarum Tarutung",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (!isApiActive)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.2, // Gunakan persentase dari tinggi layar
                        horizontal: MediaQuery.of(context).size.width * 0.1, // Gunakan persentase dari lebar layar
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/server-down.png',
                              width: MediaQuery.of(context).size.width * 0.5, // Gunakan persentase dari lebar layar untuk lebar gambar
                              height: MediaQuery.of(context).size.width * 0.5, // Gunakan persentase yang sama untuk tinggi gambar
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Spasi vertikal menggunakan persentase tinggi layar
                            Text(
                              'Server tidak aktif',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (isApiActive)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ListView.builder(
                      itemCount: kegiatanList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditKegiatan(
                                  namaKegiatan: kegiatanList[index]['nama_kegiatan'],
                                  fotoKegiatan: kegiatanList[index]['id_waktu_kegiatan'].toString(),
                                  kegiatan: kegiatanList[index]['kegiatan'],
                                  idKegiatan: kegiatanList[index]['id_jenis_kegiatan'],
                                  gambarKegiatan: kegiatanList[index]['foto_kegiatan'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    'http://192.168.11.31:2005/kegiatan/${kegiatanList[index]['id_waktu_kegiatan']}/image',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        kegiatanList[index]['nama_kegiatan'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 16, bottom: 8),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              int idKegiatan = kegiatanList[index]['id_jenis_kegiatan'] ?? 1;
                                              print('ID Kegiatan: $idKegiatan');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditKegiatan(
                                                    namaKegiatan: kegiatanList[index]['nama_kegiatan'],
                                                    fotoKegiatan: kegiatanList[index]['id_waktu_kegiatan'].toString(),
                                                    kegiatan: kegiatanList[index]['kegiatan'],
                                                    gambarKegiatan: kegiatanList[index]['foto_kegiatan'],
                                                    idKegiatan: idKegiatan,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                            child: Text('Edit'),
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
      drawer: DrawerWidget(),
      floatingActionButton: Visibility(
        // Show FAB only when API is active
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TambahKegiatan()),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }
}
