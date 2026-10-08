import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String readableError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'This email address is already registered.',
      'weak-password' => 'Use a stronger password (at least 6 characters).',
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' || 'wrong-password' || 'user-not-found' => 'Incorrect email address or password.',
      'network-request-failed' => 'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
  return error.toString().replaceFirst('Exception: ', '');
}

void showError(BuildContext context, Object error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(readableError(error))));
}
