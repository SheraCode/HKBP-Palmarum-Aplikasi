import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/admin/KelolaPemasukan.dart';
import 'package:hkbp_palmarum_app/admin/TambahPemasukan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart'; // Import intl package for number formatting

class pemasukan extends StatefulWidget {
  @override


  _PemasukanState createState() => _PemasukanState();
}
String? userRole;

class _PemasukanState extends State<pemasukan> {
  var height, width;
  List<String> imgSrc = [];
  List<String> titles = [];
  List<int> pemasukanIds = [];
  int totalPemasukan = 0;
  bool isApiActive = true; // Flag to check if API is active

  Future<void> fetchData() async {
    final Uri url = Uri.parse('http://192.168.11.31:2005/pemasukan');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          imgSrc = List<String>.generate(data.length, (index) => "assets/pemasukan.png");
          titles = List<String>.generate(data.length, (index) => data[index]['kategori_pemasukan'].toString());
          pemasukanIds = List<int>.generate(data.length, (index) => data[index]['id_pemasukan']);
          totalPemasukan = data.fold<int>(0, (sum, item) => sum + (item['total_pemasukan'] ?? 0) as int);
          isApiActive = true; // Set flag to true if API call succeeds
        });
      } else {
        setState(() {
          isApiActive = false; // Set flag to false if API call fails
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isApiActive = false; // Set flag to false if API call throws an exception
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    getTokenAndDecodeToken();
  }

  void getTokenAndDecodeToken() async {
    try {
      String? token = await getTokenFromSharedPreferences();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userRole = decodedToken['role_jemaat'];
        });
        print('Role Jemaat: $userRole');
      } else {
        print('Token not found in SharedPreferences');
      }
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  Future<String?> getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }



  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    // Format totalPemasukan as Indonesian Rupiah (IDR)
    final NumberFormat formatCurrency = NumberFormat.currency(locale: 'id_IDR', symbol: 'IDR ');

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                      Padding(padding: EdgeInsets.only(top: 25, left: 15, right: 15)),
                      Row(
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
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pemasukan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Pemasukan HKBP Palmarum Tarutung",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: isApiActive
                        ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: imgSrc.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // Handle item tap
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 6),
                              ],
                            ),
                            child: Row(
                              children: [

                                Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                child: Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        titles[index] ?? '', // Display title from API
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Banggal ni Uhur dari ${titles[index] ?? ''}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 16, bottom: 8),
                                          child: userRole == 'bendahara' || userRole == 'Bendahara'
                                              ? ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => KelolaPemasukan(idPemasukan: pemasukanIds[index]),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                            child: Text('Kelola', style: TextStyle(
                                                fontSize: 16
                                            ),),
                                          )
                                              : SizedBox(), // Hide the button if user is not 'bendahara' or 'Bendahara'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : Center(
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Total Pemasukan :",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 15),
                Text(
                  formatCurrency.format(totalPemasukan), // Format totalPemasukan as IDR currency
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: isApiActive && (userRole == 'bendahara' || userRole == 'Bendahara')
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahPemasukan()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      )
          : FloatingActionButton(
        onPressed: () {
          // Show AlertDialog because user role is not 'bendahara' or 'Bendahara'
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Akses Ditolak'),
                content: Text('Anda tidak memiliki izin untuk menambah pemasukan.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo, // Change FloatingActionButton color to grey
      ),

// Hide FloatingActionButton when isApiActive is false
      drawer: DrawerWidget(),
    );
  }
}
