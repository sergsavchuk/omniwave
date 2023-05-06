import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/common.dart';
import 'package:omniwave/profile/profile.dart';
import 'package:omniwave/styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ProfilePage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: NavBarItem.profile,
      body: BlocProvider(
        create: (context) => ProfileBloc(),
        child: const ProfileView(),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Insets.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<AppSettingsBloc, AppSettingsState>(
            builder: (context, state) => state.spotifyConnected
                ? Text(AppLocalizations.of(context)!.spotifyConnected)
                : TextButton(
                    child: Text(AppLocalizations.of(context)!.connectSpotify),
                    onPressed: () => context.read<AppSettingsBloc>().add(
                          AppSettingsSpotifyConnectRequested(),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}
