import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';

/// Demo OTP — accept the fixed code [demoCode].
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    this.channel,
    this.value,
    this.pendingProfile,
  });

  final String? channel;
  final String? value;
  final Map<String, dynamic>? pendingProfile;

  /// Fixed demo verification code (shown on screen).
  static const demoCode = '123456';

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  static const _length = 6;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _ctrl.text.trim();
    if (code.length < _length) return;
    if (code != OtpScreen.demoCode) {
      setState(() => _error = 'Wrong code — use ${OtpScreen.demoCode}');
      return;
    }

    final pending = widget.pendingProfile;
    final channel = widget.channel;
    final value = widget.value;
    final store = ref.read(demoStoreProvider);

    store.signIn(
      displayName: pending?['displayName'] as String?,
      handle: pending?['handle'] as String?,
      email: pending?['email'] as String? ??
          (channel == 'email' ? value : null),
      phone: pending?['phone'] as String? ??
          (channel == 'phone' ? value : null),
    );

    if (pending?['currencyDefault'] is String) {
      store.updateProfile(
        store.profile.copyWith(
          currencyDefault: pending!['currencyDefault'] as String,
          isGuest: false,
        ),
      );
    }

    context.go('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.value?.isNotEmpty == true
        ? widget.value!
        : 'your contact';
    final creating = widget.pendingProfile != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(creating ? 'Verify email' : 'Enter code'),
      ),
      body: Padding(
        padding: context.wishScrollPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              creating
                  ? 'Confirm your new account with the code sent to $destination.'
                  : 'Enter the 6-digit code we sent to $destination.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(8),
            Text(
              'Demo code: ${OtpScreen.demoCode}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const Gap(24),
            GestureDetector(
              onTap: () => _focus.requestFocus(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_length, (i) {
                  final char = i < _ctrl.text.length ? _ctrl.text[i] : '';
                  final filled = char.isNotEmpty;
                  return Container(
                    width: 44,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: filled
                            ? Theme.of(context).colorScheme.primary
                            : context.wishOutline,
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
            ),
            SizedBox(
              height: 0,
              width: 0,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: _length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
            if (_error != null) ...[
              const Gap(12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            StickerButton(
              label: creating ? 'Create account' : 'Verify',
              expand: true,
              onPressed: _ctrl.text.length >= _length ? _verify : null,
            ),
          ],
        ),
      ),
    );
  }
}
