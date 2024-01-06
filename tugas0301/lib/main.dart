import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ulbi Application',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => _getPageRoute(settings),
        );
      },
    );
  }

  Widget _getPageRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/listmhs':
        return MahasiswaListScreen();
      case '/addmhs':
        return AddMahasiswaScreen();
      case '/detailmhs':
        return DetailMahasiswaScreen(
          mahasiswa: settings.arguments as Mahasiswa,
        );
      case '/listdsn':
        return DosenListScreen();
      case '/adddsn':
        return AddDosenScreen();
      case '/detaildsn':
        return DetailDosenScreen(
          dosen: settings.arguments as Dosen,
        );
      case '/listrgn':
        return RuanganListScreen();
      case '/addrgn':
        return AddRuanganScreen();
      case '/detailrgn':
        return DetailRuanganScreen(
          ruangan: settings.arguments as Ruangan,
        );
      case '/listmk':
        return MatkulListScreen();
      case '/addmk':
        return AddMatkulScreen();
      case '/detailmk':
        return DetailMatkulScreen(
          matkul: settings.arguments as Matkul,
        );
      default:
        return MahasiswaListScreen();
    }
  }
}

class Mahasiswa {
  final String npm;
  final String namaLengkap;
  final String alamat;

  Mahasiswa({
    required this.npm,
    required this.namaLengkap,
    required this.alamat,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      npm: json['npm'],
      namaLengkap: json['nama_lengkap'],
      alamat: json['alamat'],
    );
  }
}

class MahasiswaListScreen extends StatefulWidget {
  const MahasiswaListScreen({Key? key}) : super(key: key);

  @override
  _MahasiswaListScreenState createState() => _MahasiswaListScreenState();
}

class _MahasiswaListScreenState extends State<MahasiswaListScreen> {
  List<Mahasiswa> mahasiswas = [];

  Future<void> fetchMahasiswas() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1/flutter/mahasiswa.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        mahasiswas =
            list.map((model) => Mahasiswa.fromJson(model)).toList();
      });
    }
  }

  Future<void> deleteMahasiswa(String npm) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1/flutter/mahasiswa.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'npm': npm}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dihapus");
      fetchMahasiswas(); // Refresh the list after deletion
    } else {
      Fluttertoast.showToast(msg: "Data gagal dihapus");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMahasiswas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
      ),
      body: ListView.builder(
        itemCount: mahasiswas.length,
        itemBuilder: (context, index) {
          final mahasiswa = mahasiswas[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: ListTile(
              title: Text(mahasiswa.namaLengkap),
              subtitle: Text('NPM: ${mahasiswa.npm}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detailmhs',
                  arguments: mahasiswa,
                ).then((value) {
                  if (value == true) {
                    fetchMahasiswas();
                  }
                });
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteMahasiswa(mahasiswa.npm);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addmhs').then((value) {
            if (value == true) {
              fetchMahasiswas();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 0, 60, 255),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mahasiswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Dosen', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Ruangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mata Kuliah',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigate to the list screen
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            // Navigate to the Dosen screen
            Navigator.pushReplacementNamed(context, '/listdsn');
          } else if (index == 2) {
            // Navigate to the Ruangan screen
            Navigator.pushReplacementNamed(context, '/listrgn');
          } else if (index == 3) {
            // Navigate to the matkul screen
            Navigator.pushReplacementNamed(context, '/listmk');
          }
        },
      ),
    );
  }
}

class DetailMahasiswaScreen extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const DetailMahasiswaScreen({Key? key, required this.mahasiswa})
      : super(key: key);

  @override
  _DetailMahasiswaScreenState createState() => _DetailMahasiswaScreenState();
}

class _DetailMahasiswaScreenState extends State<DetailMahasiswaScreen> {
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namaLengkapController.text = widget.mahasiswa.namaLengkap;
    alamatController.text = widget.mahasiswa.alamat;
  }

  Future<void> updateMahasiswa() async {
    final String npm = widget.mahasiswa.npm;
    final String namaLengkap = namaLengkapController.text;
    final String alamat = alamatController.text;

    final response = await http.put(
      Uri.parse('http://127.0.0.1/flutter/mahasiswa.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'npm': npm,
        'nama_lengkap': namaLengkap,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil diperbarui");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal diperbarui");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'NPM: ${widget.mahasiswa.npm}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaLengkapController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateMahasiswa();
              },
              child: const Text('Simpan Perubahan'),
            )
          ],
        ),
      ),
    );
  }
}

class AddMahasiswaScreen extends StatefulWidget {
  const AddMahasiswaScreen({Key? key}) : super(key: key);

  @override
  _AddMahasiswaScreenState createState() => _AddMahasiswaScreenState();
}

class _AddMahasiswaScreenState extends State<AddMahasiswaScreen> {
  final TextEditingController npmController = TextEditingController();
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  Future<void> addMahasiswa() async {
    final String npm = npmController.text;
    final String namaLengkap = namaLengkapController.text;
    final String alamat = alamatController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1/flutter/mahasiswa.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'npm': npm,
        'nama_lengkap': namaLengkap,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dimasukkan");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal dimasukkan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah data mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: npmController,
              decoration: const InputDecoration(labelText: 'NPM'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaLengkapController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addMahasiswa();
              },
              child: const Text('Tambah Mahasiswa'),
            )
          ],
        ),
      ),
    );
  }
}


class Dosen {
  final String nik;
  final String namaLengkap;
  final String alamat;

  Dosen({
    required this.nik,
    required this.namaLengkap,
    required this.alamat,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      nik: json['nik'],
      namaLengkap: json['nama_lengkap'],
      alamat: json['alamat'],
    );
  }
}

class DosenListScreen extends StatefulWidget {
  const DosenListScreen({Key? key}) : super(key: key);

  @override
  _DosenListScreenState createState() => _DosenListScreenState();
}

class _DosenListScreenState extends State<DosenListScreen> {
  List<Dosen> dosens = [];

  Future<void> fetchDosens() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1/flutter/dosen.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        dosens =
            list.map((model) => Dosen.fromJson(model)).toList();
      });
    }
  }

  Future<void> deleteDosen(String nik) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1/flutter/dosen.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'nik': nik}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dihapus");
      fetchDosens(); // Refresh the list after deletion
    } else {
      Fluttertoast.showToast(msg: "Data gagal dihapus");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDosens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Dosen'),
      ),
      body: ListView.builder(
        itemCount: dosens.length,
        itemBuilder: (context, index) {
          final dosen = dosens[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: ListTile(
              title: Text(dosen.namaLengkap),
              subtitle: Text('NIK: ${dosen.nik}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detaildsn',
                  arguments: dosen,
                ).then((value) {
                  if (value == true) {
                    fetchDosens();
                  }
                });
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteDosen(dosen.nik);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/adddsn').then((value) {
            if (value == true) {
              fetchDosens();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 0, 60, 255),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mahasiswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Dosen', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Ruangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mata Kuliah',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigate to the list screen
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listdsn');
          }else if (index == 2) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listrgn');
          } else if (index == 3) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listmk');
          } 
        },
      ),
    );
  }
}

class DetailDosenScreen extends StatefulWidget {
  final Dosen dosen;

  const DetailDosenScreen({Key? key, required this.dosen})
      : super(key: key);

  @override
  _DetailDosenScreenState createState() => _DetailDosenScreenState();
}

class _DetailDosenScreenState extends State<DetailDosenScreen> {
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namaLengkapController.text = widget.dosen.namaLengkap;
    alamatController.text = widget.dosen.alamat;
  }

  Future<void> updateDosen() async {
    final String nik = widget.dosen.nik;
    final String namaLengkap = namaLengkapController.text;
    final String alamat = alamatController.text;

    final response = await http.put(
      Uri.parse('http://127.0.0.1/flutter/dosen.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil diperbarui");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal diperbarui");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Dosen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'NIK: ${widget.dosen.nik}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaLengkapController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateDosen();
              },
              child: const Text('Simpan Perubahan'),
            )
          ],
        ),
      ),
    );
  }
}

class AddDosenScreen extends StatefulWidget {
  const AddDosenScreen({Key? key}) : super(key: key);

  @override
  _AddDosenScreenState createState() => _AddDosenScreenState();
}

class _AddDosenScreenState extends State<AddDosenScreen> {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  Future<void> addDosen() async {
    final String nik = nikController.text;
    final String namaLengkap = namaLengkapController.text;
    final String alamat = alamatController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1/flutter/dosen.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dimasukkan");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal dimasukkan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah data dosen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nikController,
              decoration: const InputDecoration(labelText: 'NIK'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaLengkapController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addDosen();
              },
              child: const Text('Tambah Dosen'),
            )
          ],
        ),
      ),
    );
  }
}

class Ruangan {
  final String noruang;
  final String gedung;
  final String lantai;

  Ruangan({
    required this.noruang,
    required this.gedung,
    required this.lantai,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      noruang: json['noruang'],
      gedung: json['gedung'],
      lantai: json['lantai'],
    );
  }
}

class RuanganListScreen extends StatefulWidget {
  const RuanganListScreen({Key? key}) : super(key: key);

  @override
  _RuanganListScreenState createState() => _RuanganListScreenState();
}

class _RuanganListScreenState extends State<RuanganListScreen> {
  List<Ruangan> ruangans = [];

  Future<void> fetchRuangans() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1/flutter/ruangan.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        ruangans =
            list.map((model) => Ruangan.fromJson(model)).toList();
      });
    }
  }

  Future<void> deleteRuangan(String noruang) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1/flutter/ruangan.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'noruang': noruang}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dihapus");
      fetchRuangans(); // Refresh the list after deletion
    } else {
      Fluttertoast.showToast(msg: "Data gagal dihapus");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRuangans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Ruangan'),
      ),
      body: ListView.builder(
        itemCount: ruangans.length,
        itemBuilder: (context, index) {
          final ruangan = ruangans[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: ListTile(
              title: Text(ruangan.gedung),
              subtitle: Text('No Ruang: ${ruangan.noruang}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detailrgn',
                  arguments: ruangan,
                ).then((value) {
                  if (value == true) {
                    fetchRuangans();
                  }
                });
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteRuangan(ruangan.noruang);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addrgn').then((value) {
            if (value == true) {
              fetchRuangans();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 0, 60, 255),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mahasiswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Dosen', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Ruangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mata Kuliah',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigate to the list screen
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listdsn');
          } else if (index == 2) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listrgn');
          } else if (index == 3) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listmk');
          } 
        },
      ),
    );
  }
}

class DetailRuanganScreen extends StatefulWidget {
  final Ruangan ruangan;

  const DetailRuanganScreen({Key? key, required this.ruangan})
      : super(key: key);

  @override
  _DetailRuanganScreenState createState() => _DetailRuanganScreenState();
}

class _DetailRuanganScreenState extends State<DetailRuanganScreen> {
  final TextEditingController gedungController = TextEditingController();
  final TextEditingController lantaiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    gedungController.text = widget.ruangan.gedung;
    lantaiController.text = widget.ruangan.lantai;
  }

  Future<void> updateRuangan() async {
    final String noruang = widget.ruangan.noruang;
    final String gedung = gedungController.text;
    final String lantai = lantaiController.text;

    final response = await http.put(
      Uri.parse('http://127.0.0.1/flutter/ruangan.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'noruang': noruang,
        'gedung': gedung,
        'lantai': lantai,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil diperbarui");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal diperbarui");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Ruangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'No Ruang: ${widget.ruangan.noruang}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: gedungController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lantaiController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateRuangan();
              },
              child: const Text('Simpan Perubahan'),
            )
          ],
        ),
      ),
    );
  }
}

class AddRuanganScreen extends StatefulWidget {
  const AddRuanganScreen({Key? key}) : super(key: key);

  @override
  _AddRuanganScreenState createState() => _AddRuanganScreenState();
}

class _AddRuanganScreenState extends State<AddRuanganScreen> {
  final TextEditingController noruangController = TextEditingController();
  final TextEditingController gedungController = TextEditingController();
  final TextEditingController lantaiController = TextEditingController();

  Future<void> addRuangan() async {
    final String noruang = noruangController.text;
    final String gedung = gedungController.text;
    final String lantai = lantaiController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1/flutter/ruangan.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'noruang': noruang,
        'gedung': gedung,
        'lantai': lantai,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dimasukkan");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal dimasukkan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah data ruangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: noruangController,
              decoration: const InputDecoration(labelText: 'No Ruang'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: gedungController,
              decoration: const InputDecoration(labelText: 'Gedung'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lantaiController,
              decoration: const InputDecoration(labelText: 'Lantai'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addRuangan();
              },
              child: const Text('Tambah Ruangan'),
            )
          ],
        ),
      ),
    );
  }
}

class Matkul {
  final String kodeMatkul;
  final String namaMatkul;
  final String dosen;

  Matkul({
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.dosen,
  });

  factory Matkul.fromJson(Map<String, dynamic> json) {
    return Matkul(
      kodeMatkul: json['kode_matkul'],
      namaMatkul: json['nama_matkul'],
      dosen: json['dosen'],
    );
  }
}

class MatkulListScreen extends StatefulWidget {
  const MatkulListScreen({Key? key}) : super(key: key);

  @override
  _MatkulListScreenState createState() => _MatkulListScreenState();
}

class _MatkulListScreenState extends State<MatkulListScreen> {
  List<Matkul> matkuls = [];

  Future<void> fetchMatkuls() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1/flutter/matkkul.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        matkuls =
            list.map((model) => Matkul.fromJson(model)).toList();
      });
    }
  }

  Future<void> deleteMatkul(String kodeMatkul) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1/flutter/matkul.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'kode_matkul': kodeMatkul}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dihapus");
      fetchMatkuls(); // Refresh the list after deletion
    } else {
      Fluttertoast.showToast(msg: "Data gagal dihapus");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMatkuls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Matkul'),
      ),
      body: ListView.builder(
        itemCount: matkuls.length,
        itemBuilder: (context, index) {
          final matkul = matkuls[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: ListTile(
              title: Text(matkul.namaMatkul),
              subtitle: Text('Kode Matkul: ${matkul.kodeMatkul}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detailmk',
                  arguments: matkul,
                ).then((value) {
                  if (value == true) {
                    fetchMatkuls();
                  }
                });
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteMatkul(matkul.kodeMatkul);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addmk').then((value) {
            if (value == true) {
              fetchMatkuls();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color.fromARGB(255, 0, 60, 255),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mahasiswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Dosen', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Ruangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mata Kuliah',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigate to the list screen
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listdsn');
          } else if (index == 2) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listrgn');
          } else if (index == 3) {
            // Navigate to the add screen
            Navigator.pushReplacementNamed(context, '/listmk');
          }
        },
      ),
    );
  }
}

class DetailMatkulScreen extends StatefulWidget {
  final Matkul matkul;

  const DetailMatkulScreen({Key? key, required this.matkul})
      : super(key: key);

  @override
  _DetailMatkulScreenState createState() => _DetailMatkulScreenState();
}

class _DetailMatkulScreenState extends State<DetailMatkulScreen> {
  final TextEditingController namaMatkulController = TextEditingController();
  final TextEditingController dosenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namaMatkulController.text = widget.matkul.namaMatkul;
    dosenController.text = widget.matkul.dosen;
  }

  Future<void> updateMatkul() async {
    final String kodeMatkul = widget.matkul.kodeMatkul;
    final String namaMatkul = namaMatkulController.text;
    final String dosen = dosenController.text;

    final response = await http.put(
      Uri.parse('http://127.0.0.1/flutter/matkul.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'kode_matkul': kodeMatkul,
        'namaMatkul': namaMatkul,
        'dosen': dosen,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil diperbarui");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal diperbarui");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Matkul'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Kode Matkul: ${widget.matkul.kodeMatkul}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaMatkulController,
              decoration: const InputDecoration(labelText: 'Nama Matkul'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosenController,
              decoration: const InputDecoration(labelText: 'Dosen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateMatkul();
              },
              child: const Text('Simpan Perubahan'),
            )
          ],
        ),
      ),
    );
  }
}

class AddMatkulScreen extends StatefulWidget {
  const AddMatkulScreen({Key? key}) : super(key: key);

  @override
  _AddMatkulScreenState createState() => _AddMatkulScreenState();
}

class _AddMatkulScreenState extends State<AddMatkulScreen> {
  final TextEditingController kodeMatkulController = TextEditingController();
  final TextEditingController namaMatkulController = TextEditingController();
  final TextEditingController dosenController = TextEditingController();

  Future<void> addMatkul() async {
    final String kodeMatkul = kodeMatkulController.text;
    final String namaMatkul = namaMatkulController.text;
    final String dosen = dosenController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1/flutter/matkul.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'kode_matkul': kodeMatkul,
        'nama_matkul': namaMatkul,
        'dosen': dosen,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Data berhasil dimasukkan");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Data gagal dimasukkan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah data matkul'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: kodeMatkulController,
              decoration: const InputDecoration(labelText: 'Kode Matkul'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaMatkulController,
              decoration: const InputDecoration(labelText: 'Nama Matkul'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosenController,
              decoration: const InputDecoration(labelText: 'Dosen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addMatkul();
              },
              child: const Text('Tambah Matkul'),
            )
          ],
        ),
      ),
    );
  }
}
