import 'package:axalta/blocs/auth/auth_bloc.dart';
import 'package:axalta/constants/routes.dart';
import 'package:axalta/model/update_user_password_dto.dart';
import 'package:axalta/services/auth_service.dart';
import 'package:axalta/widgets/update_passwrod_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Güncelleme'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mevcut Şifre'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Yeni Şifre (Tekrar)'),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    String currentPassword = _currentPasswordController.text;
                    String newPassword = _newPasswordController.text;
                    String confirmPassword = _confirmPasswordController.text;

                    if (newPassword == confirmPassword &&
                        newPassword.isNotEmpty) {
                      UpdateUserPasswordDto dto = UpdateUserPasswordDto(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                        confirmPassword: confirmPassword,
                      );

                      bool response = await AuthService.updateUserPassword(dto);
                      if (response) {
                        await showLogOutDialog(context);

                        context
                            .read<AuthBloc>()
                            .add(AuthLogoutEvent()); //Logout User
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      } else {
                        _showErrorDialog("Şifre Değiştirilirken hata");
                      }
                    } else {
                      _showErrorDialog("Şifre Değiştirilirken hata");
                    }
                  },
                  child: const Text('Şifreyi Güncelle'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Şifre Başarıyla Güncellendi"),
          content: const Text("Lütfen tekrar giriş yapınız."),
          actions: [
            TextButton(onPressed: () {}, child: const Text("Çıkış")),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog();
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(errorMessage);
      },
    );
  }
}
