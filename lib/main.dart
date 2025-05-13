import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fueltrackerapp/FuelEntry.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:fueltrackerapp/fuel-tracker%20cubit.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FuelTrackerCubit()),


          ],


      child: FuelTrackerApp(),
      ),
      );
}

class FuelTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
    designSize: const Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    child: MaterialApp(
      title: 'Fuel Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: FuelTrackerScreen(),
    )
    );
  }
}
