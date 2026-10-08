import 'package:flutter/material.dart';
import '../core/feedback.dart';
import '../services/auth_service.dart';
import '../theme/evently_theme.dart';
import '../widgets/app_controls.dart';
import '../widgets/evently_brand.dart';
import '../widgets/illustration_panel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.register = false});
  final bool register;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    name.dispose(); email.dispose(); password.dispose(); confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      if (widget.register) {
        await AuthService.instance.register(name.text, email.text, password.text);
      } else {
        await AuthService.instance.login(email.text, password.text);
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() => loading = true);
    try {
      await AuthService.instance.loginWithGoogle();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final register = widget.register;
    final primary = EventlyColors.primary(context);
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 28),
        child: Form(key: formKey, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: EventlyBrand(size: 27)),
            const SizedBox(height: 38),
            Text(register ? 'Create your account' : 'Login to your account',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700,
                  color: EventlyColors.isDark(context) ? Colors.white : primary)),
            const SizedBox(height: 22),
            if (register) ...[
              EventlyTextField(controller: name, hint: 'Enter your name',
                icon: Icons.person_outline,
                validator: (v) => v?.trim().isNotEmpty == true ? null : 'Enter your name'),
              const SizedBox(height: 14),
            ],
            EventlyTextField(controller: email, hint: 'Enter your email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '')
                  ? null : 'Enter a valid email'),
            const SizedBox(height: 14),
            EventlyTextField(controller: password, hint: 'Enter your password',
              icon: Icons.lock_outline, password: true,
              validator: (v) => (v?.length ?? 0) >= 6
                  ? null : 'Password must be at least 6 characters'),
            if (register) ...[
              const SizedBox(height: 14),
              EventlyTextField(controller: confirmation,
                hint: 'Confirm your password', icon: Icons.lock_outline, password: true,
                validator: (v) => v == password.text ? null : 'Passwords do not match'),
              const SizedBox(height: 47),
            ] else ...[
              Align(alignment: Alignment.centerRight, child: TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute<void>(builder: (_) => const PasswordResetScreen())),
                child: const Text('Forget Password?', style: TextStyle(
                    fontSize: 12, decoration: TextDecoration.underline)),
              )),
              const SizedBox(height: 34),
            ],
            EventlyActionButton(label: register ? 'Sign up' : 'Login',
                onPressed: submit, loading: loading),
            const SizedBox(height: 33),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(register ? 'Already have an account? ' : "Don't have an account? ",
                style: TextStyle(fontSize: 12,
                    color: EventlyColors.secondaryText(context))),
              InkWell(onTap: () {
                if (register) {
                  Navigator.of(context).maybePop();
                } else {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const AuthScreen(register: true)));
                }
              }, child: Text(register ? 'Login' : 'Signup',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: primary, decoration: TextDecoration.underline))),
            ]),
            const SizedBox(height: 23),
            Row(children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Or', style: TextStyle(color: primary, fontSize: 12))),
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            ]),
            const SizedBox(height: 17),
            SizedBox(height: 47, width: double.infinity, child: OutlinedButton(
              onPressed: loading ? null : loginWithGoogle,
              style: OutlinedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(color: EventlyColors.outline(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('G', style: TextStyle(color: Color(0xFF4285F4),
                    fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(width: 13),
                Text(register ? 'Sign up with Google' : 'Login with Google',
                    style: TextStyle(color: primary, fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
            )),
          ],
        )),
      )),
    );
  }
}

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});
  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  @override
  void dispose() { email.dispose(); super.dispose(); }

  Future<void> reset() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await AuthService.instance.resetPassword(email.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset email sent. Check your inbox.')));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(children: [
        const ScreenTitle(title: 'Forget Password'),
        const Spacer(),
        const IllustrationPanel(variant: 4),
        const SizedBox(height: 25),
        Form(key: formKey, child: EventlyTextField(
          controller: email, hint: 'Enter your email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '')
              ? null : 'Enter a valid email',
        )),
        const Spacer(),
        EventlyActionButton(label: 'Reset password', loading: busy, onPressed: reset),
      ]),
    )),
  );
}
