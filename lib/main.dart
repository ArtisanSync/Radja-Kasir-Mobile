import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/store/cart_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Radja kasir',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          ScreenUtil.init(context);
          return Theme(
            data: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.black),
                color: Colors.deepPurpleAccent,
                foregroundColor: Colors.black,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),
            ),
            child: child!,
          );
        },
        home: const LoginPage(),
      ),
    );
  }
}
