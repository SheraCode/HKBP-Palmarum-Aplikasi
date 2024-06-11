import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hkbp_palmarum_app/user/login.dart';
import 'package:hkbp_palmarum_app/user/uploadfoto.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:hkbp_palmarum_app/user/roleRegister.dart';
import 'package:intl/intl.dart';

class noRegister extends StatefulWidget {
  @override
  _NoRegisterState createState() => _NoRegisterState();
}

class _NoRegisterState extends State<noRegister> {

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  String? selectedPendidikan;
  String? tglLahir;
  String? _selectedGender;
  String? _selectedBaptis;
  String? selectedGolDarah;
  String? selectedStatusPernikahan;
  String? selectedStatusSidi;
  bool _isRegistered = false;
  int? selectedPendidikanIndex;
  int? selectedBidangPendidikanIndex;
  int? selectedStatusIndex;
  int? selectedKecamatanIndex;
  int? selectedPekerjaanIndex; // Tambahkan variabel untuk menyimpan indeks

  List<String> kecamatanList = [
    'Pilih Kecamatan Anda',
    'Kecamatan Adian Koting',
    'Kecamatan Garoga',
    'Kecamatan Muara',
    'kecamatan Pagaran',
    'Kecamatan Pahae Jae',
    'Kecamatan Pahae Julu',
    'Kecamatan Pangaribuan',
    'Kecamatan Parmonangan',
    'Kecamatan Purba Tua',
    'Kecamatan Siatas Barita',
    'Kecamatan Siborongborong',
    'Kecamatan Sipangumban',
    'Kecamatan Sipahutar',
    'Kecamatan Sipoholon',
    'Kecamatan Tarutung'
  ];


  List<String> pekerjaanList = [
    'Tidak Bekerja',
    'Petani',
    'Pegawai Negara Sipil',
    'Pegawai Swasta',
    'Pegawai BUMN',
    'Pekerjaan Lainnya'
  ];


  List<String> statusList = ['Pilih Status', 'Ama','Ina','Anak']; // List opsi status





// Kemudian buat list opsi jenis kelamin
  List<String> genders = ['Laki-laki', 'Perempuan'];
  List<String> bidangPendidikanList = ['Bidang Pendidikan Lainnya', 'Pendidikan Formal(SD,SMP,SMA/SMK)', 'Pendidikan Profesi', 'Pendidikan Vokasi', 'Pendidikan Keagamaan','Pendidikan Khusus'];
  List<String> pendidikanList = ['Pilih Pendidikan Anda','Tidak Sekolah', 'Sekolah Dasar', 'SMP/SLTP','SMA/SLTA','Diploma','Strata 1','Strata 2','Strata 3'];

  TextEditingController registerController = TextEditingController();
  TextEditingController namaDepanController = TextEditingController();
  TextEditingController namaBelakangController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noTeleponController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bidangPendidikanLainnyaController = TextEditingController();
  TextEditingController pekerjaanLainnyaController = TextEditingController();
  TextEditingController _dateController = TextEditingController();



  void _login() async {
    String noRegister = registerController.text.trim();
    print(noRegister);

    if (noRegister.isEmpty) {
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Gagal",
          message: "Nomor Registrasi Harus Diisi",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("Nomor Registrasi Harus Diisi");
      return;
    }

    // Ubah nilai noRegister menjadi tipe data int
    int idJemaat;
    try {
      idJemaat = int.parse(noRegister);
    } catch (e) {
      print("Gagal mengonversi nilai ke tipe data int: $e");
      return;
    }

    var url = Uri.parse('http://192.168.11.31:2005/jemaat');

    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json", // Tentukan tipe konten sebagai JSON
      },
      body: jsonEncode({'id_jemaat': idJemaat}), // Encode data sebagai JSON
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      // Parse JSON response
      _isRegistered = true;
      var responseData = jsonDecode(response.body);
      String namaDepan = responseData['nama_depan'] ?? ''; // Ambil nama depan dari respons JSON
      String namaBelakang = responseData['nama_belakang'] ?? ''; // Ambil nama depan dari respons JSON

      // Set nilai namaDepanController
      setState(() {
        namaDepanController.text = namaDepan;
        namaBelakangController.text = namaBelakang;
      });

      // Tambahkan logika untuk menangani respons dari server di sini
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Nomor Registrasi Terdaftar",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => roleRegister()),
      // );
    } else {
      print('Failed with status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      var snackBar =  SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 155), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Gagal",
          message: "Nomor Registrasi Tidak Terdaftar",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Tambahkan logika untuk menangani kesalahan komunikasi dengan server di sini
    }
  }




  void _Registrasi() async {
    String noRegister = registerController.text.trim();
    int jemaatId = int.tryParse(noRegister) ?? 0; // Assuming noRegister is the jemaatId
    String tgl_lahirjemaat = _dateController.text.trim();
    String namaDepan = namaDepanController.text.trim();
    String namaBelakang = namaBelakangController.text.trim();
    String? jenisKelamin = _selectedGender;
    String alamat = alamatController.text.trim();
    int idPendidikan = selectedPendidikanIndex ?? 0;
    int idBidangPendidikan = selectedBidangPendidikanIndex ?? 0;
    int idPekerjaan = selectedPekerjaanIndex ?? 0;
    String noTelepon = noTeleponController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String? statusBaptis = _selectedBaptis;
    String? statusPernikahan = selectedStatusPernikahan;
    String? golonganDarah = selectedGolDarah;
    int status = selectedStatusIndex ?? 0;
    int kecamatan = selectedKecamatanIndex ?? 0;
    String? Sidi = selectedStatusSidi ?? "Tidak Sidi";
    String namaBidangPendidikanLainnya = bidangPendidikanLainnyaController.text.trim();
    String namaPekerjaanLainnya = pekerjaanLainnyaController.text.trim();

    // Mengonversi noTelepon menjadi tipe data integer
    int parsedNoTelepon = int.tryParse(noTelepon) ?? 0; // Gunakan nilai default jika parsing gagal

    // Buat body untuk dikirim ke server
    Map<String, dynamic> body = {
      'nama_depan': namaDepan,
      'nama_belakang': namaBelakang,
      'tgl_lahir': tgl_lahirjemaat,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'id_pendidikan': idPendidikan,
      'id_bidang_pendidikan': idBidangPendidikan,
      'id_pekerjaan': idPekerjaan,
      'no_hp': parsedNoTelepon, // Gunakan nilai yang telah di-parse ke integer
      'email': email,
      'password': password,
      'isBaptis': statusBaptis,
      'isMenikah': statusPernikahan,
      'gol_darah': golonganDarah,
      'bidang_pendidikan_lainnya': namaBidangPendidikanLainnya,
      'nama_pekerjaan_lainnya': namaPekerjaanLainnya,
      'id_kecamatan': kecamatan,
      'isSidi': Sidi,
    };

    // Encode body menjadi JSON
    String jsonBody = jsonEncode(body);

    // Buat URL untuk request PUT atau PATCH
    var url = Uri.parse('http://192.168.11.31:2005/jemaat/$jemaatId');

    // Kirim request PUT atau PATCH
    var response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json", // Tentukan tipe konten sebagai JSON
      },
      body: jsonBody, // Kirim body dalam format JSON
    );

    // Periksa kode status respons
    if (response.statusCode == 200) {
      // Berhasil mengedit data jemaat
      print('Data jemaat berhasil diubah');
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Success",
          message: "Berhasil Registrasi Jemaat",
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Navigate to uploadfoto after a delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => uploadfoto(idJemaat: jemaatId)),
        );
      });
    } else {
      // Gagal mengedit data jemaat
      print('Gagal mengedit data jemaat');
      print('Error response body: ${response.body}');
      var snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150), // Menempatkan snackbar di atas layar
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: "Gagal",
          message: "Gagal Registrasi Jemaat",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Tambahkan logika penanganan kesalahan jika diperlukan
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/bglogin.JPG",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 70),
                    child: Image.asset(
                      'assets/logo_hkbp.png',
                      width: 280.0,
                    ),
                  ),
                  SizedBox(height:0),
                  TextField(
                    controller: registerController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: "Nomor Registrasi",
                      fillColor: Colors.white,
                      hintText: "Nomor Registrasi",
                      errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                  ).p4().px24(),
                  SizedBox(height: 10),
                  if (!_isRegistered)
                    GestureDetector(
                      onTap: _login,
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
                            SizedBox(width: 5),
                            Text(
                              'Check Nomor Registrasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Icon(Icons.question_mark_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 10,),
                  if (_isRegistered)
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
                        prefixIcon: Icon(Icons.person),
                      ),
                    ).p4().px24(),
                  SizedBox(height: 10,),
                  if (_isRegistered)
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
                        prefixIcon: Icon(Icons.person),
                      ),
                    ).p4().px24(),
                  SizedBox(height: 10,),

                  if(_isRegistered)
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          filled: true,
                          prefix: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                      readOnly: true,
                      onTap: (){
                        _selectDate();
                      },
                    ).p4().px24(),
                  SizedBox(height: 10,),

                  if (_isRegistered)
                    DropdownButtonFormField(
                      value: _selectedGender, // Nilai yang terpilih saat ini
                      items: genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? value) { // Ubah tipe parameter menjadi nullable (String?)
                        setState(() {
                          _selectedGender = value; // Gunakan value yang dapat bernilai null
                          print(_selectedGender);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Jenis Kelamin",
                        hintText: "Pilih Jenis Kelamin",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                    )
                        .p4().px24(),
                  SizedBox(height: 10,),
                  if (_isRegistered)
                    TextField(
                      controller: alamatController,
                      keyboardType: TextInputType.multiline, // Mengatur jenis keyboard sebagai multiline
                      maxLines: null, // Atau bisa juga dihilangkan karena null adalah defaultnya
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
                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<int>(
                      value: selectedPendidikanIndex, // Tidak perlu menambah 1 pada nilai value
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedPendidikanIndex = newValue; // Tetapkan nilai newValue ke selectedPendidikanIndex tanpa mengubahnya
                          print(selectedPendidikanIndex);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Pendidikan",
                        hintText: "Pilih Pendidikan",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: pendidikanList.asMap().entries.map<DropdownMenuItem<int>>(
                            (MapEntry<int, String> entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key, // Gunakan nilai indeks sebagai nilai DropdownMenuItem
                            child: Text(entry.value),
                          );
                        },
                      ).toList(),
                    ).p4().px24(),

                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<int>(
                      value: selectedBidangPendidikanIndex,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedBidangPendidikanIndex = newValue;
                          print(selectedBidangPendidikanIndex);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Bidang Pendidikan",
                        hintText: "Pilih Bidang Pendidikan",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: bidangPendidikanList.asMap().entries.map<DropdownMenuItem<int>>(
                            (MapEntry<int, String> entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        },
                      ).toList(),
                    ).p8().px2(),

                  SizedBox(height: 10,),
                  if (_isRegistered)
                    if (selectedBidangPendidikanIndex == 0)
                      TextField(
                        controller: bidangPendidikanLainnyaController,
                        // Tambahkan controller atau gunakan nilai dari TextField sesuai kebutuhan
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Bidang Pendidikan Lainnya",
                          hintText: "Masukkan Bidang Pendidikan Lainnya",
                          errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                          prefixIcon: Icon(Icons.school),
                        ),
                      ).p4().px24(),
                  SizedBox(height: 10,),
                  if (_isRegistered)
                    TextField(
                      controller: noTeleponController, // Atau bisa juga dihilangkan karena null adalah defaultnya
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Nomor Telepon",
                        hintText: "Nomor Telepon",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.phone_android_rounded), // Icon surat untuk email
                      ),
                    ).p4().px24(),
                  SizedBox(height: 10,),
                  if (_isRegistered)
                    TextField(
                      controller: emailController, // Atau bisa juga dihilangkan karena null adalah defaultnya
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Email",
                        hintText: "Email",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.mail_outline_rounded), // Icon surat untuk email
                      ),
                    ).p4().px24(),
                  SizedBox(height: 10,),
                  if (_isRegistered)
                    TextField(
                      controller: passwordController, // Atau bisa juga dihilangkan karena null adalah defaultnya
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Password",
                        hintText: "Password",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.lock), // Icon surat untuk email
                      ),
                    ).p4().px24(),

                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<String>(
                      value: _selectedBaptis,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBaptis = newValue!;
                          print(_selectedBaptis);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Status Baptis",
                        hintText: "Pilih Status Baptis",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.church),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: "Baptis",
                          child: Text("Baptis"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Belum Baptis",
                          child: Text("Belum Baptis"),
                        ),
                      ],
                    ).p4().px24(),

                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<String>(
                      value: selectedStatusPernikahan,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatusPernikahan = newValue!;
                          print(selectedStatusPernikahan);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Status Pernikahan",
                        hintText: "Pilih Status Pernikahan",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.favorite),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: "Menikah",
                          child: Text("Menikah"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Belum Menikah",
                          child: Text("Belum Menikah"),
                        ),
                      ],
                    ).p4().px24(),



                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<String>(
                      value: selectedStatusSidi,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatusSidi = newValue!;
                          print(selectedStatusSidi);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Status Sidi",
                        hintText: "Pilih Status Sidi",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.favorite),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: "Sidi",
                          child: Text("Sidi"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Belum Sidi",
                          child: Text("Belum Sidi"),
                        ),
                      ],
                    ).p4().px24(),




                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<String>(
                      value: selectedGolDarah,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGolDarah = newValue!;
                          print(selectedGolDarah);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Golongan Darah",
                        hintText: "Pilih Golongan Darah",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: "A",
                          child: Text("Golongan A"),
                        ),
                        DropdownMenuItem<String>(
                          value: "B",
                          child: Text("Golongan B"),
                        ),
                        DropdownMenuItem<String>(
                          value: "AB",
                          child: Text("Golongan AB"),
                        ),
                        DropdownMenuItem<String>(
                          value: "O",
                          child: Text("Golongan O"),
                        ),
                      ],
                    ).p4().px24(),


                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<int>(
                      value: selectedPekerjaanIndex, // Gunakan variabel untuk nilai dropdown
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedPekerjaanIndex = newValue; // Tetapkan nilai newValue ke variabel
                          print(selectedPekerjaanIndex);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Pekerjaan",
                        hintText: "Pilih Pekerjaan",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.work),
                      ),
                      items: pekerjaanList.asMap().entries.map<DropdownMenuItem<int>>(
                            (MapEntry<int, String> entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key, // Gunakan indeks sebagai nilai DropdownMenuItem
                            child: Text(entry.value),
                          );
                        },
                      ).toList(),
                    ).p4().px24(),


                  SizedBox(height: 10,),
                  if (_isRegistered)
                    if (selectedPekerjaanIndex == 5)
                      TextField(
                        controller: pekerjaanLainnyaController,
                        // Tambahkan controller atau gunakan nilai dari TextField sesuai kebutuhan
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Pekerjaan Lainnya",
                          hintText: "Masukkan Pekerjaan Lainnya",
                          errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                          prefixIcon: Icon(Icons.work),
                        ),
                      ).p4().px24(),



                  SizedBox(height: 10,),
                  if (_isRegistered)
                    DropdownButtonFormField<int>(
                      value: selectedKecamatanIndex, // Gunakan variabel untuk nilai dropdown status
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedKecamatanIndex = newValue; // Tetapkan nilai newValue ke variabel
                          print(selectedKecamatanIndex);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Kecamatan",
                        hintText: "Pilih Kecamatan",
                        errorStyle: TextStyle(fontSize: 15, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        prefixIcon: Icon(Icons.account_balance_sharp), // Icon sesuaikan dengan jenis status
                      ),
                      items: kecamatanList.asMap().entries.map<DropdownMenuItem<int>>(
                            (MapEntry<int, String> entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key, // Gunakan indeks sebagai nilai DropdownMenuItem
                            child: Text(entry.value),
                          );
                        },
                      ).toList(),
                    ).p4().px24(),



                  SizedBox(height: 10),
                  if (_isRegistered)
                    GestureDetector(
                      onTap: _Registrasi,
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
                            SizedBox(width: 5),
                            Text(
                              'Registrasi Jemaat ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Icon(Icons.add_circle_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),




                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => login()),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 1.0),
                      child: Container(
                        child: Text(
                          "Kamu Mempunyai Akun? Login Sekarang",
                          style: TextStyle(
                              fontSize: 18.0,
                              height: 2.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Raleway'
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
