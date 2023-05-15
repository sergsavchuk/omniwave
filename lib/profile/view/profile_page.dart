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
            buildWhen: (prev, curr) =>
                prev.spotifyConnected != curr.spotifyConnected,
            builder: (context, state) => TextButton(
              statesController: state.spotifyConnected
                  ? MaterialStatesController({MaterialState.disabled})
                  : null,
              onPressed: () => context
                  .read<AppSettingsBloc>()
                  .add(AppSettingsSpotifyConnectRequested()),
              child: state.spotifyConnected
                  ? Text(AppLocalizations.of(context)!.spotifyConnected)
                  : Text(AppLocalizations.of(context)!.connectSpotify),
            ),
          ),
          BlocBuilder<AppSettingsBloc, AppSettingsState>(
            buildWhen: (prev, curr) =>
                prev.syncInProgress != curr.syncInProgress,
            builder: (context, state) => TextButton(
              statesController: state.syncInProgress
                  ? MaterialStatesController({MaterialState.disabled})
                  : null,
              onPressed: () => context
                  .read<AppSettingsBloc>()
                  .add(AppSettingsSyncRequested()),
              child: state.syncInProgress
                  ? Text(AppLocalizations.of(context)!.syncInProgress)
                  : Text(AppLocalizations.of(context)!.synchronize),
            ),
          ),
          Row(
            children: [
              BlocBuilder<AppSettingsBloc, AppSettingsState>(
                buildWhen: (prev, curr) =>
                    prev.syncOnStartup != curr.syncOnStartup,
                builder: (context, state) => Checkbox(
                  value: state.syncOnStartup,
                  onChanged: (value) => context.read<AppSettingsBloc>().add(
                        AppSettingsSyncOnStartupToggled(syncOnStartup: value!),
                      ),
                ),
              ),
              Text(AppLocalizations.of(context)!.syncOnStartup),
            ],
          ),
        ],
      ),
    );
  }
}
