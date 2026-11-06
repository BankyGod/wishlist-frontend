import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _ctrl = TextEditingController();
  static const _length = 6;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _verify() {
    if (_ctrl.text.length < _length) return;
    ref.read(demoStoreProvider).signIn();
    context.go('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter code')),
      body: Padding(
        padding: context.wishScrollPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'We sent a 6-digit code (demo: type anything)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_length, (i) {
                final char = i < _ctrl.text.length ? _ctrl.text[i] : '';
                return Container(
                  width: 44,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.wishOutline,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.wishInk.withValues(alpha: 0.12),
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    char,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                );
              }),
            ),
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 0,
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: _length,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const Gap(8),
            TextButton(
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: const Text('Tap bubbles to focus hidden field'),
            ),
            const Spacer(),
            StickerButton(
              label: 'Verify',
              expand: true,
              onPressed: _ctrl.text.length >= _length ? _verify : null,
            ),
          ],
        ),
      ),
    );
  }
}
