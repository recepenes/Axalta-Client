import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Başarılı'),
      content: const Text('Şifreniz başarıyla güncellendi.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  ErrorDialog(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hata'),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}
