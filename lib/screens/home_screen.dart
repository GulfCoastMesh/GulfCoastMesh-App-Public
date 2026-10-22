import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/adaptive_layout.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/contact.dart';
import '../services/app_settings_service.dart';
import '../services/mesh_analyzer_state.dart';
import '../utils/disconnect_navigation_mixin.dart';
import '../widgets/contact_detail_panel.dart';
import '../widgets/chats_overflow_menu_button.dart';
import '../widgets/connection_overflow_menu_button.dart';
import 'channel_chat_screen.dart';
import 'chat_screen.dart';
import 'chats_screen.dart';
import 'contacts_screen.dart';
import 'map_screen.dart';
import 'mesh_analyzer_screen.dart';
import 'settings_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with DisconnectNavigationMixin {
  static const double _listColumnWidth = 320;

  int _currentIndex = 0;
  Conversation? _selectedConversation;
  Contact? _selectedContact;

  bool _showAnalyzerTab(BuildContext context, AppSettings settings) {
    final width = MediaQuery.of(context).size.width;
    if (useWideAdaptiveLayout(settings.layoutMode, width)) return true;
    return settings.meshAnalyzerEnabled;
  }

  bool _isWide(BuildContext context, AppSettings settings) {
    final width = MediaQuery.of(context).size.width;
    return useWideAdaptiveLayout(settings.layoutMode, width);
  }

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final analyzerState = context.watch<MeshAnalyzerState>();
    final settings = context.watch<AppSettingsService>().settings;
    final showAnalyzer = _showAnalyzerTab(context, settings);
    final showWeather =
        connector.isDemoMode || settings.experimentalWeatherEnabled;
    final isWide = _isWide(context, settings);

    final analyzerFullScreen =
        showAnalyzer &&
        _currentIndex == (showAnalyzer ? 3 : -1) &&
        analyzerState.isFullScreen;

    if (!checkConnectionAndNavigate(connector)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allowBack = !connector.shouldKeepHub;
    final screenCount = 3 + (showAnalyzer ? 1 : 0) + (showWeather ? 1 : 0);
    final safeIndex = _currentIndex >= screenCount ? 0 : _currentIndex;
    if (safeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final nextSettings = context.read<AppSettingsService>().settings;
        final nextCount =
            3 +
            (_showAnalyzerTab(context, nextSettings) ? 1 : 0) +
            (nextSettings.experimentalWeatherEnabled ? 1 : 0);
        if (_currentIndex >= nextCount) {
          setState(() => _currentIndex = 0);
        }
      });
    }
    final isAnalyzerTabActive = showAnalyzer && safeIndex == 3;

    if (isWide) {
      return PopScope(
        canPop: allowBack,
        child: Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                _buildNavigationRail(
                  context,
                  showAnalyzer,
                  showWeather,
                  safeIndex,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _buildWideBody(
                    context,
                    safeIndex,
                    showAnalyzer,
                    showWeather,
                    isAnalyzerTabActive,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = <Widget>[
      const ChatsScreen(),
      const ContactsScreen(hideBackButton: true),
      const MapScreen(hideBackButton: true),
      if (showAnalyzer) MeshAnalyzerScreen(isTabActive: isAnalyzerTabActive),
      if (showWeather)
        WeatherScreen(isTabActive: safeIndex == 3 + (showAnalyzer ? 1 : 0)),
    ];

    return PopScope(
      canPop: allowBack,
      child: Scaffold(
        // The nav bar is fully opaque, so let Scaffold reserve exactly the
        // space it needs above it instead of guessing with a magic-number
        // bottom padding in every tab's own scroll view.
        body: IndexedStack(index: safeIndex, children: screens),
        bottomNavigationBar: analyzerFullScreen
            ? null
            : SafeArea(
                top: false,
                child: _buildNavigationBar(
                  context,
                  showAnalyzer,
                  showWeather,
                  safeIndex,
                ),
              ),
      ),
    );
  }

  Widget _buildWideBody(
    BuildContext context,
    int safeIndex,
    bool showAnalyzer,
    bool showWeather,
    bool isAnalyzerTabActive,
  ) {
    switch (safeIndex) {
      case 0:
        return _buildChatsSplit(context);
      case 1:
        return _buildNodesSplit(context);
      case 2:
        return const MapScreen(hideBackButton: true);
      case 3:
        if (showAnalyzer) {
          return MeshAnalyzerScreen(isTabActive: isAnalyzerTabActive);
        }
        if (showWeather) return const WeatherScreen(isTabActive: true);
        return const SizedBox.shrink();
      case 4:
        if (showAnalyzer && showWeather) {
          return const WeatherScreen(isTabActive: true);
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChatsSplit(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _listColumnWidth,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.nav_chats),
              automaticallyImplyLeading: false,
              actions: const [ChatsOverflowMenuButton()],
            ),
            body: ChatsScreen(
              hideScaffold: true,
              selectedId: _selectedConversation?.id,
              onSelected: (conv) {
                setState(() => _selectedConversation = conv);
                final connector = context.read<MeshCoreConnector>();
                if (conv.contact != null) {
                  connector.markContactRead(conv.contact!.publicKeyHex);
                } else if (conv.channel != null) {
                  connector.markChannelRead(conv.channel!.index);
                }
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildChatDetail(context)),
      ],
    );
  }

  Widget _buildChatDetail(BuildContext context) {
    final conv = _selectedConversation;
    if (conv == null) {
      return _EmptyDetail(
        icon: Icons.chat_bubble_outline,
        message: context.l10n.chats_selectConversation,
      );
    }
    if (conv.type == ConvType.contact && conv.contact != null) {
      return ChatScreen(
        key: ValueKey('dm_${conv.contact!.publicKeyHex}'),
        contact: conv.contact!,
        embedded: true,
      );
    }
    if (conv.type == ConvType.channel && conv.channel != null) {
      return ChannelChatScreen(
        key: ValueKey('ch_${conv.channel!.index}'),
        channel: conv.channel!,
        embedded: true,
      );
    }
    return _EmptyDetail(
      icon: Icons.chat_bubble_outline,
      message: context.l10n.chats_selectConversation,
    );
  }

  Widget _buildNodesSplit(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _listColumnWidth,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.nav_nodes),
              automaticallyImplyLeading: false,
              actions: const [ConnectionOverflowMenuButton()],
            ),
            body: ContactsScreen(
              hideBackButton: true,
              hideScaffold: true,
              selectedContactKey: _selectedContact?.publicKeyHex,
              onSelected: (contact) {
                setState(() => _selectedContact = contact);
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedContact == null
              ? _EmptyDetail(
                  icon: Icons.people_outline,
                  message: context.l10n.nodes_selectNode,
                )
              : ContactDetailPanel(
                  key: ValueKey(_selectedContact!.publicKeyHex),
                  contact: _selectedContact!,
                ),
        ),
      ],
    );
  }

  Widget _buildNavigationRail(
    BuildContext context,
    bool showAnalyzer,
    bool showWeather,
    int safeIndex,
  ) {
    final l10n = context.l10n;
    return NavigationRail(
      selectedIndex: safeIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: Text(l10n.nav_chats),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: Text(l10n.nav_nodes),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.map),
          label: Text(l10n.nav_map),
        ),
        if (showAnalyzer)
          NavigationRailDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: Text(l10n.nav_analyzer),
          ),
        if (showWeather)
          NavigationRailDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud),
            label: Text(l10n.nav_weather),
          ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              tooltip: l10n.nav_settings,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(
    BuildContext context,
    bool showAnalyzer,
    bool showWeather,
    int safeIndex,
  ) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: NavigationBar(
          height: 64,
          selectedIndex: safeIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: const Icon(Icons.chat_bubble),
              label: l10n.nav_chats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l10n.nav_nodes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: l10n.nav_map,
            ),
            if (showAnalyzer)
              NavigationDestination(
                icon: const Icon(Icons.analytics_outlined),
                selectedIcon: const Icon(Icons.analytics),
                label: l10n.nav_analyzer,
              ),
            if (showWeather)
              NavigationDestination(
                icon: const Icon(Icons.cloud_outlined),
                selectedIcon: const Icon(Icons.cloud),
                label: l10n.nav_weather,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyDetail({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
