import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/storage/contact_group_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  test('malformed groups do not discard valid records', () async {
    await PrefsManager.instance.setString(
      'contact_groups',
      jsonEncode([
        {
          'name': 'Team',
          'members': ['aa', 'bb'],
        },
        {'name': 42, 'members': 'bad'},
        'not-a-map',
        {'name': 'Solo', 'members': null},
      ]),
    );

    final groups = await ContactGroupStore().loadGroups();

    expect(groups.map((group) => group.name), ['Team', 'Solo']);
    expect(groups.first.memberKeys, ['aa', 'bb']);
    expect(groups.last.memberKeys, isEmpty);
  });
}
