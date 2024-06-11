import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class pelayangereja extends StatefulWidget {
  @override
  _PelayanGerejaState createState() => _PelayanGerejaState();
}

class _PelayanGerejaState extends State<pelayangereja> {
  late List<dynamic> pelayanGerejaList;
  late List<dynamic> pelayanMajelisList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDataALL();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/pelayan-gereja'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        pelayanGerejaList = responseData != null ? List.from(responseData) : [];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataALL() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('http://192.168.11.31:2005/pelayan-majelis'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        pelayanMajelisList = responseData != null ? List.from(responseData) : [];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget buildTable(String title, List<dynamic> data) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.black,
          ),
          child: DataTable(
            columns: <DataColumn>[
              DataColumn(
                label: Text(
                  'Nama',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (title == 'Pelayan Majelis') // Add additional columns conditionally
                DataColumn(
                  label: Text(
                    'Tgl Tahbis',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (title == 'Pelayan Majelis') // Add additional columns conditionally
                DataColumn(
                  label: Text(
                    'Tgl Akhir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (title == 'Pelayan Gereja') // Add additional column for 'keterangan'
                DataColumn(
                  label: Text(
                    'Keterangan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
            rows: data.map<DataRow>((pelayan) {
              final namaPelayan = title == 'Pelayan Majelis' ? pelayan['nama_depan'] ?? 'Unknown' : pelayan['nama_pelayan'] ?? 'Unknown';
              final tglTahbis = title == 'Pelayan Majelis' ? pelayan['tgl_tahbis'] ?? 'Unknown' : '';
              final tglAkhir = title == 'Pelayan Majelis' ? pelayan['tgl_akhir_jabatan'] ?? 'Unknown' : '';
              final keterangan = title == 'Pelayan Gereja' ? pelayan['keterangan'] ?? 'Unknown' : '';

              return DataRow(cells: <DataCell>[
                DataCell(Text(
                  namaPelayan,
                  style: TextStyle(color: Colors.white),
                )),
                if (title == 'Pelayan Majelis') // Add additional cells conditionally
                  DataCell(Text(
                    tglTahbis,
                    style: TextStyle(color: Colors.white),
                  )),
                if (title == 'Pelayan Majelis') // Add additional cells conditionally
                  DataCell(Text(
                    tglAkhir,
                    style: TextStyle(color: Colors.white),
                  )),
                if (title == 'Pelayan Gereja') // Add additional cell for 'keterangan'
                  DataCell(Text(
                    keterangan,
                    style: TextStyle(color: Colors.white),
                  )),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pelayan Gereja',
          style: TextStyle(
            fontFamily: 'fira',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF03A9F3),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgroundprofil.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
                BlendMode.darken,
              ),
            ),
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              if (pelayanGerejaList.isNotEmpty)
                buildTable(
                  'Pelayan Majelis',
                  pelayanGerejaList,
                ),
              if (pelayanMajelisList.isNotEmpty)
                buildTable(
                  'Pelayan Gereja',
                  pelayanMajelisList,
                ),
            ],
          ),
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
          // Handle navigation here
        },
        index: 0,
      ),
    );
  }
}

