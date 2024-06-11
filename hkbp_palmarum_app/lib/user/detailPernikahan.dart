import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/DrawerWidget.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';

class detailPernikahan extends StatefulWidget {
  @override
  _createdetailPernikahanState createState() => _createdetailPernikahanState();
}

class _createdetailPernikahanState extends State<detailPernikahan> {
  var height, width;
  List<String> _dropdownItems = [
    'Johannes Bastian Jasa Sipayung, S.Tr.Kom',
    'Christia Otenia Br Purba, S.M',
    'Bastian Otenia Sipayung',

    // Tambahkan nama lainnya sesuai kebutuhan
  ];

  String? _selectedName; // inisialisasi _selectedName

  String? _selectedChurch;
  String? _otherChurchName;

  List<String> _churchList = ['HKBP', 'Gereja lain'];
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  DateTime _selectedDated = DateTime.now();
  TextEditingController _datePemberkatan = TextEditingController();

  bool _showOtherChurchTextField = false;
  TextEditingController _otherChurchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
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
            child: Column(
              children: [
                Container(
                  height: height * 0.22,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding:
                          EdgeInsets.only(top: 25, left: 15, right: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Widget yang Anda ingin masukkan di sini
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          left: 15,
                          right: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Detail Pernikahan",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Request Surat Pernikahan Johannes Bastian Jasa Sipayung & Christia Otenia br Purba",
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
                    //   coding diisini
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tambahan widget lainnya
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Martumpol',
                                hintText: 'Pilih Tanggal Martumpol',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              controller: _dateController,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                  DateTime.now(), // Tanggal hari ini
                                  firstDate: DateTime
                                      .now(), // Batasan tanggal dimulai dari hari ini
                                  lastDate: DateTime(
                                      2100), // Batasan tanggal di masa depan
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate!;
                                    _dateController.text =
                                        _selectedDate.toString();
                                  });
                                }
                              },
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nama Gereja Martumpol',
                                hintText: 'Isi Nama Gereja Martumpol',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Ubah nilai radius sesuai keinginan Anda
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nama Gereja Pemberkatan',
                                hintText: 'Isi Nama Gereja Pemberkatan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Ubah nilai radius sesuai keinginan Anda
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 18),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Pemberkatan',
                                hintText: 'Pilih Tanggal Martumpol',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              controller: _datePemberkatan,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                  DateTime.now(), // Tanggal hari ini
                                  firstDate: DateTime
                                      .now(), // Batasan tanggal dimulai dari hari ini
                                  lastDate: DateTime(
                                      2100), // Batasan tanggal di masa depan
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDated = pickedDate!;
                                    _datePemberkatan.text =
                                        _selectedDated.toString();
                                  });
                                }
                              },
                              readOnly: true,
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 30),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Terkonfirmasi',
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
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => riwayat()),
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
                                  Icon(Icons.navigate_before,
                                      color: Colors.white),
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
}
