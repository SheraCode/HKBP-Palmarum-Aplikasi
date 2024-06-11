import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hkbp_palmarum_app/user/home.dart';
import 'package:hkbp_palmarum_app/user/profil.dart';
import 'package:hkbp_palmarum_app/user/riwayat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IsiWartaJemaat extends StatefulWidget {
  final String token;
  final String id;
  const IsiWartaJemaat({required this.token, required this.id, Key? key}) : super(key: key);


  _IsiWartaJemaatState createState() => _IsiWartaJemaatState();
}

class _IsiWartaJemaatState extends State<IsiWartaJemaat> {
  // Define a variable to hold the detail of the warta jemaat
  List<Map<String, dynamic>>? wartaDetail;

  // Method to fetch the detail of the warta jemaat from the server
  Future<void> fetchWartaDetail() async {
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/warta/${widget.id}'));
    if (response.statusCode == 200) {
      // Convert the response body to a List<Map<String, dynamic>>
      final List<dynamic> responseData = json.decode(response.body);
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(responseData);
      setState(() {
        wartaDetail = data;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWartaDetail();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the wartaDetail is null or not before using it to prevent errors
    if (wartaDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detail Warta Jemaat'),
          backgroundColor: Color(0xFF03A9F3), // Ubah warna AppBar menjadi transparan
          elevation: 0, // Hilangkan bayangan AppBar
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Build the UI with the wartaDetail
      return Scaffold(
        appBar: AppBar(
          title: Text('Detail Warta Jemaat',  style: TextStyle(
              fontFamily: 'fira',
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),),
          backgroundColor: Color(0xFF03A9F3), // Ubah warna AppBar menjadi transparan
          elevation: 0,
          // Hilangkan bayangan AppBar
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Display the detail of the warta jemaat
              for (var warta in wartaDetail!)
                Column(
                  children: [
                    Text('Warta Jemaat: ${warta['create_at']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    SizedBox(height: 10,),
                    Padding(padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                    child: Text('${warta['warta']}', textAlign: TextAlign.justify, style: TextStyle(fontSize: 15),),
                    )
                    // Add more widgets to display other details as needed
                  ],
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
                  MaterialPageRoute(builder: (context) => home(token: widget.token)),
                );
                break;
              case 1:
              // Handle index 1
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => riwayat()),
                );
                break;
              case 2:
              // Handle index 2
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profil(token: widget.token)),
                );
                break;
            }
          },
          index: 0,
        ),

      );
    }
  }
}
