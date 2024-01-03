import 'dart:io';

import 'package:axalta/constants/indicator.dart';
import 'package:axalta/services/blue_tooth/blue_tooth_service.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/views/bluetooth/blue_tooth_view.dart';
import 'package:axalta/views/home_view.dart';
import 'package:axalta/views/indicator/indicator_view.dart';
import 'package:axalta/views/login/bloc/login_bloc.dart';
import 'package:axalta/views/login/login_screen.dart';
import 'package:axalta/views/register/update_password_view.dart';
import 'package:axalta/views/weigihing/cumulative_view.dart';
import 'package:axalta/views/weigihing/middle_view.dart';
import 'package:axalta/views/weigihing/pigment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'blocs/auth/auth_bloc.dart';
import 'constants/routes.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
  Future.delayed(Duration.zero, () async {
    await BlueToothService.autoBtConnect();
    var indicator = await IndicatorService().loadIndicatorIdFromDevice();
    indicatorName = indicator['indicatorName'];
    indicatorId = indicator['indicatorId'];
  });
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'Home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is LoginSuccessState) {
              return const HomeView();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          homeRoute: (context) => const HomeView(),
          loginRoute: (context) => const LoginScreen(),
          pigmentRoute: (context) => const PigmentView(),
          bluetoothRoute: (context) => const BlueToothView(),
          indicatorRoute: (context) => const IndicatorView(),
          cumulativeRoute: (context) => const CumulativeView(),
          middleRoute: (context) => const MiddeleView(),
          changePasswordRoute: (context) => const UpdatePasswordView(),
        },
        localizationsDelegates: const [
          FormBuilderLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
