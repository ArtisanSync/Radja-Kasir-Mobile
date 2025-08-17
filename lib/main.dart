import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radja Kasir',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        ScreenUtil.init(context);
        return Theme(
          data: _buildTheme(context),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    // Primary color scheme
    const seedColor = Color(0xFF171717); // Dark color from your original theme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: seedColor,
      secondary: const Color(0xFF404040),
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      error: const Color(0xFFDC3545),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        // Custom text styles for consistency
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.poppins(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        helperStyle: GoogleFonts.poppins(
          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
          fontSize: 12,
        ),
        errorStyle: GoogleFonts.poppins(
          color: colorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
        modalElevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: GoogleFonts.poppins(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        pressElevation: 1,
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.poppins(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.2),
        circularTrackColor: colorScheme.primary.withOpacity(0.2),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      
      // ListTile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface.withOpacity(0.7),
          fontSize: 14,
        ),
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.outline;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surfaceVariant;
          },
        ),
      ),
    );
  }
}
