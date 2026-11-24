import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MindCareApp());
  } catch (e, st) {
    debugPrint('Firebase initialization error: $e\n$st');
    runApp(FirebaseStartupError(error: e.toString()));
  }
}

// ==========================================
// WARNA RESMI MINDCARE
// ==========================================
const Color backgroundColor = Color(0xFFFFFFFF);
const Color softGreen = Color(0xFFEAF5EF);
const Color primaryColor = Color(0xFF39866A);
const Color accentBlue = Color(0xFF245A75);
const Color textPrimary = Color(0xFF273746);

class FirebaseStartupError extends StatelessWidget {
  final String error;
  const FirebaseStartupError({super.key, required this.error});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: Colors.red, size: 54),
                  const SizedBox(height: 16),
                  const Text('MindCare gagal terhubung ke Firebase',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MindCare',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: accentBlue,
            surface: backgroundColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: backgroundColor,
            foregroundColor: textPrimary,
            elevation: 0,
          ),
        ),
        home: const AuthGate(),
      );
}

// Mempertahankan sesi login: pengguna tidak perlu login ulang setiap membuka app.

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Gagal memeriksa akun: ${snapshot.error}',
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const WelcomePage();
        }

        return DashboardPage(
          key: ValueKey(user.uid),
          user: user,
        );
      },
    );
  }
}


// ==========================================
// WELCOME PAGE
// ==========================================
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology_rounded,
                        color: primaryColor, size: 36),
                    SizedBox(width: 8),
                    Text('MindCare',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Peduli Kesehatan Mental Anda',
                    style: TextStyle(color: accentBlue, fontSize: 12)),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/mindcare_illustration.png',
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 270,
                    decoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(24)),
                    child: const Center(
                        child: Icon(Icons.favorite_rounded,
                            color: primaryColor, size: 100)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Selamat Datang di MindCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                const SizedBox(height: 12),
                const Text(
                  'Jaga kesehatan mentalmu dan temukan ketenangan dalam menjalani kehidupan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: textPrimary, height: 1.6),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Mulai Sekarang',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('MindCare - Peduli Kesehatan Mental Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
}

// ==========================================
// AUTHENTICATION
// ==========================================
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'operation-not-allowed':
        return 'Metode Email/Password belum diaktifkan di Firebase Authentication.';
      default:
        return e.message ?? 'Autentikasi gagal (${e.code}).';
    }
  }

  
Future<void> submitForm() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!isLogin && name.isEmpty) {
      showMessage('Nama lengkap wajib diisi.');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email dan password wajib diisi.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password minimal 6 karakter.');
      return;
    }

    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      UserCredential credential;

      if (isLogin) {
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user == null) {
          throw Exception('UID pengguna tidak ditemukan.');
        }

        await user.updateDisplayName(name);

        // Simpan profil. Jika gagal, akun Firebase tetap sudah dibuat.
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase tidak mengembalikan data pengguna.');
      }

      await user.reload();

      if (!mounted) return;

      // PENTING:
      // AuthPage dibuka dari WelcomePage menggunakan Navigator.push.
      // AuthGate berada di route pertama dan akan otomatis membangun
      // DashboardPage setelah authStateChanges() menerima sesi login.
      // Karena itu, tutup AuthPage dan kembali ke route pertama.
      Navigator.of(context).popUntil((route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      showMessage('Login gagal: ${authErrorMessage(e)}');
    } on FirebaseException catch (e) {
      showMessage('Kesalahan Firebase: ${e.code} - ${e.message}');
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  InputDecoration inputDecoration(String label, IconData icon) =>
      InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor, size: 21),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: textPrimary)),
                    const Spacer(),
                    const Text('MindCare',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 190,
                  child: Image.asset(
                    'assets/images/mindcare_illustration.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.favorite_rounded,
                        color: primaryColor,
                        size: 90),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isLogin ? 'Selamat Datang Kembali!' : 'Buat Akun Baru',
                    key: ValueKey(isLogin),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  isLogin
                      ? 'Senang melihatmu kembali. Mari jaga kesehatan mentalmu hari ini.'
                      : 'Mulai perjalanan mengenali diri dan menjaga kesehatan mentalmu.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: accentBlue, height: 1.5),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Informasi Akun',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                      const SizedBox(height: 18),
                      if (!isLogin) ...[
                        TextField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                              'Nama Lengkap', Icons.person_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: inputDecoration(
                            'Alamat Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        onSubmitted: (_) => isLoading ? null : submitForm(),
                        decoration: inputDecoration(
                                'Password', Icons.lock_outline_rounded)
                            .copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => obscurePassword = !obscurePassword),
                            icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: accentBlue,
                                size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primaryColor.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : Text(
                                  isLogin ? 'Masuk Sekarang' : 'Daftar Sekarang',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                        style: const TextStyle(
                            fontSize: 13, color: textPrimary)),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => setState(() {
                                isLogin = !isLogin;
                                obscurePassword = true;
                              }),
                      child: Text(isLogin ? 'Daftar' : 'Login',
                          style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded,
                        color: primaryColor, size: 14),
                    SizedBox(width: 6),
                    Text('MindCare - Peduli Kesehatan Mental Anda',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      );
}

// ==========================================
// DASHBOARD
// ==========================================
class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  String selectedMood = '';
  bool savingReport = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get userRef =>
      _db.collection('users').doc(widget.user.uid);

  CollectionReference<Map<String, dynamic>> get reportsRef =>
      userRef.collection('laporan');

  final List<Map<String, dynamic>> moods = const [
    {'name': 'Senang', 'icon': '😊', 'score': 5},
    {'name': 'Tenang', 'icon': '😌', 'score': 4},
    {'name': 'Biasa', 'icon': '😐', 'score': 3},
    {'name': 'Sedih', 'icon': '😔', 'score': 2},
    {'name': 'Cemas', 'icon': '😟', 'score': 1},
  ];

  @override
  void initState() {
    super.initState();
    _ensureUserProfile();
  }

  Future<void> _ensureUserProfile() async {
    try {
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'uid': widget.user.uid,
          'name': widget.user.displayName ??
              widget.user.email?.split('@').first ??
              'Pengguna MindCare',
          'email': widget.user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.set({
          'email': widget.user.email ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> saveReport() async {
    if (selectedMood.isEmpty) {
      showMessage('Silakan pilih kondisi perasaanmu.', error: true);
      return;
    }
    setState(() => savingReport = true);
    try {
      final selected = moods.firstWhere((m) => m['name'] == selectedMood);
      await reportsRef.add({
        'userId': widget.user.uid,
        'mood': selected['name'],
        'moodScore': selected['score'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() => selectedMood = '');
      showMessage('Laporan berhasil disimpan.');
    } on FirebaseException catch (e) {
      showMessage(
          'Gagal menyimpan laporan: ${e.message ?? e.code}. Periksa koneksi dan Firestore Rules.',
          error: true);
    } catch (e) {
      showMessage('Terjadi kesalahan saat menyimpan laporan: $e',
          error: true);
    } finally {
      if (mounted) setState(() => savingReport = false);
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate akan kembali ke WelcomePage.
    } on FirebaseAuthException catch (e) {
      showMessage('Gagal keluar: ${e.message ?? e.code}', error: true);
    } catch (e) {
      showMessage('Gagal keluar: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      _buildSelfReporting(),
      _buildAnalysis(),
      _buildProfile(),
    ];
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('MindCare',
            style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => showMessage('Belum ada notifikasi baru.'),
            icon: const Icon(Icons.notifications_none_rounded,
                color: accentBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            setState(() => currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: softGreen,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon:
                  Icon(Icons.home_rounded, color: primaryColor),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.edit_note_rounded),
              selectedIcon:
                  Icon(Icons.edit_note_rounded, color: primaryColor),
              label: 'Laporan'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: primaryColor),
              label: 'Analisis'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: primaryColor),
              label: 'Profil'),
        ],
      ),
    );
  }

  String get displayName {
    final name = widget.user.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return widget.user.email?.split('@').first ?? 'Teman';
  }

  Widget _buildHome() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, $displayName 👋',
                style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 6),
            const Text('Bagaimana perasaanmu hari ini?',
                style: TextStyle(fontSize: 14, color: accentBlue)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: softGreen, borderRadius: BorderRadius.circular(22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.spa_rounded,
                      color: primaryColor, size: 35),
                  const SizedBox(height: 12),
                  const Text('Luangkan Waktu untuk Dirimu',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Kenali kondisi emosimu dan pantau kesehatan mentalmu secara berkala.',
                    style: TextStyle(
                        fontSize: 13, color: textPrimary, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => currentIndex = 1),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Mulai Self-Reporting'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Fitur MindCare',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _featureCard('Self-Reporting',
                        Icons.assignment_outlined, primaryColor,
                        () => setState(() => currentIndex = 1))),
                const SizedBox(width: 12),
                Expanded(
                    child: _featureCard('Analisis Grafik',
                        Icons.analytics_outlined, accentBlue,
                        () => setState(() => currentIndex = 2))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _featureCard('Artikel', Icons.menu_book_rounded,
                        primaryColor, _showArticles)),
                const SizedBox(width: 12),
                Expanded(
                    child: _featureCard('Profil', Icons.person_outline_rounded,
                        accentBlue, () => setState(() => currentIndex = 3))),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Artikel Kesehatan Mental',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 14),
            _articleCard(Icons.spa_rounded,
                'Pentingnya Menjaga Kesehatan Mental',
                'Kenali pentingnya merawat kesehatan mental dalam kehidupan sehari-hari.'),
            const SizedBox(height: 12),
            _articleCard(Icons.self_improvement_rounded, 'Cara Mengelola Stres',
                'Pelajari langkah sederhana untuk mengelola stres dan menjaga ketenangan.'),
            const SizedBox(height: 20),
          ],
        ),
      );

  Widget _featureCard(
          String title, IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 115,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: softGreen, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textPrimary)),
            ],
          ),
        ),
      );

  Widget _articleCard(IconData icon, String title, String description) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: softGreen)),
        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                  color: softGreen, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: primaryColor, size: 29),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          fontSize: 13)),
                  const SizedBox(height: 5),
                  Text(description,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );

  // =====================================
  // SELF REPORTING - SIMPAN KE FIRESTORE
  // =====================================
  Widget _buildSelfReporting() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Self-Reporting',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 8),
            const Text('Ceritakan bagaimana kondisi perasaanmu hari ini.',
                style: TextStyle(color: accentBlue)),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: softGreen, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bagaimana perasaanmu?',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 9,
                    runSpacing: 12,
                    children: moods.map((mood) {
                      final name = mood['name'] as String;
                      final icon = mood['icon'] as String;
                      return ChoiceChip(
                        label: Text('$icon $name'),
                        selected: selectedMood == name,
                        selectedColor: const Color(0xFFB9DCCB),
                        onSelected: savingReport
                            ? null
                            : (selected) => setState(
                                () => selectedMood = selected ? name : ''),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: savingReport ? null : saveReport,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: savingReport
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Laporan'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Laporan Terakhir',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 10),
            _recentReports(),
          ],
        ),
      );

  Widget _recentReports() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: reportsRef
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _messageCard(
                'Tidak dapat memuat laporan: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(color: primaryColor)));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return _messageCard('Belum ada laporan tersimpan.');
          return Column(
            children: docs.map((doc) {
              final data = doc.data();
              final mood = data['mood'] as String? ?? 'Tidak diketahui';
              final date = data['createdAt'] as Timestamp?;
              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: softGreen)),
                child: Row(
                  children: [
                    const Icon(Icons.mood_rounded,
                        color: primaryColor, size: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mood,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary)),
                          Text(_formatDate(date),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      );

  // =====================================
  // ANALISIS DARI DATA FIRESTORE
  // =====================================
  Widget _buildAnalysis() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analisis Kesehatan Mental',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 8),
            const Text('Ringkasan berdasarkan laporan mood yang kamu simpan.',
                style: TextStyle(color: accentBlue)),
            const SizedBox(height: 25),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: reportsRef
                  .orderBy('createdAt', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _messageCard(
                      'Gagal memuat analisis: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: primaryColor)));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _messageCard(
                      'Belum ada data. Simpan laporan mood terlebih dahulu untuk melihat analisis.');
                }

                final scores = List<int>.filled(7, 0);
                final counts = List<int>.filled(7, 0);
                final now = DateTime.now();
                for (final doc in docs) {
                  final data = doc.data();
                  final timestamp = data['createdAt'];
                  final score = data['moodScore'];
                  if (timestamp is! Timestamp || score is! num) continue;
                  final date = timestamp.toDate();
                  final daysAgo = DateTime(now.year, now.month, now.day)
                      .difference(DateTime(date.year, date.month, date.day))
                      .inDays;
                  if (daysAgo >= 0 && daysAgo < 7) {
                    final index = 6 - daysAgo;
                    scores[index] += score.toInt();
                    counts[index]++;
                  }
                }
                final labels = ['6h lalu', '5h lalu', '4h lalu', '3h lalu',
                  '2h lalu', 'Kemarin', 'Hari ini'];
                final averages = List<double>.generate(
                    7, (i) => counts[i] == 0 ? 0 : scores[i] / counts[i]);
                final total = counts.fold<int>(0, (a, b) => a + b);
                final overallCount = docs.length;
                final average = docs
                        .map((d) => d.data()['moodScore'])
                        .whereType<num>()
                        .isEmpty
                    ? 0.0
                    : docs
                            .map((d) => d.data()['moodScore'])
                            .whereType<num>()
                            .fold<double>(0, (a, b) => a + b.toDouble()) /
                        docs
                            .map((d) => d.data()['moodScore'])
                            .whereType<num>()
                            .length;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: softGreen,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Grafik Mood 7 Hari Terakhir',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textPrimary)),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 180,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(7, (i) {
                                final height = averages[i] == 0
                                    ? 4.0
                                    : 130 * averages[i] / 5;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 23,
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: counts[i] == 0
                                            ? Colors.grey.shade400
                                            : primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(labels[i],
                                        style: const TextStyle(
                                            fontSize: 9, color: textPrimary)),
                                  ],
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Skor suasana hati: Senang 5, Tenang 4, Biasa 3, Sedih 2, Cemas 1. Ini adalah ringkasan suasana hati, bukan diagnosis klinis.',
                            style: TextStyle(
                                fontSize: 11,
                                color: textPrimary,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                            child: _statCard('Total laporan',
                                '$overallCount', Icons.assignment_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _statCard('Rata-rata skor',
                                average.toStringAsFixed(1), Icons.insights)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$total laporan tercatat dalam 7 hari terakhir.',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _statCard(String title, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: softGreen, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            Text(title,
                style: const TextStyle(fontSize: 11, color: accentBlue)),
          ],
        ),
      );

  Widget _messageCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: softGreen, borderRadius: BorderRadius.circular(15)),
        child: Text(text,
            style: const TextStyle(color: textPrimary, height: 1.4)),
      );

  // =====================================
  // PROFIL
  // =====================================
  Widget _buildProfile() => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          final profile = snapshot.data?.data() ?? {};
          final name = (profile['name'] as String?)?.trim().isNotEmpty == true
              ? profile['name'] as String
              : displayName;
          final email = widget.user.email ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Container(
                  width: 105,
                  height: 105,
                  decoration: const BoxDecoration(
                      color: softGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded,
                      size: 65, color: primaryColor),
                ),
                const SizedBox(height: 15),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                const SizedBox(height: 6),
                Text(email,
                    style: const TextStyle(color: accentBlue),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                const Text('Pengguna MindCare',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 30),
                _profileMenu(Icons.person_outline, 'Informasi Profil',
                    subtitle: 'Nama dan email akun'),
                _profileMenu(Icons.verified_user_outlined, 'Akun Terautentikasi',
                    subtitle: 'Login dikelola Firebase Authentication'),
                _profileMenu(Icons.info_outline, 'Tentang MindCare',
                    subtitle: 'Peduli Kesehatan Mental Anda'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor),
                        padding: const EdgeInsets.all(14)),
                  ),
                ),
                if (snapshot.hasError) ...[
                  const SizedBox(height: 10),
                  Text('Gagal memuat profil: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ],
            ),
          );
        },
      );

  Widget _profileMenu(IconData icon, String title, {String? subtitle}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: softGreen, borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: primaryColor),
          title: Text(title,
              style: const TextStyle(color: textPrimary, fontSize: 14)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: accentBlue)),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: accentBlue),
        ),
      );

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final date = timestamp.toDate().toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }

  void _showArticles() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Artikel Kesehatan Mental',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: textPrimary)),
            const SizedBox(height: 15),
            _articleCard(Icons.spa_rounded,
                'Pentingnya Kesehatan Mental',
                'Kenali dan rawat kesehatan mentalmu.'),
            const SizedBox(height: 12),
            _articleCard(Icons.self_improvement_rounded, 'Mengelola Stres',
                'Pelajari cara mengelola stres.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
