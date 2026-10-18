// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_dao.dart';

// ignore_for_file: type=lint
mixin _$SupportDaoMixin on DatabaseAccessor<AppDatabase> {
  $HelpTopicsTable get helpTopics => attachedDatabase.helpTopics;
  $SupportTicketsTable get supportTickets => attachedDatabase.supportTickets;
  $SupportMessagesTable get supportMessages => attachedDatabase.supportMessages;
  SupportDaoManager get managers => SupportDaoManager(this);
}

class SupportDaoManager {
  final _$SupportDaoMixin _db;
  SupportDaoManager(this._db);
  $$HelpTopicsTableTableManager get helpTopics =>
      $$HelpTopicsTableTableManager(_db.attachedDatabase, _db.helpTopics);
  $$SupportTicketsTableTableManager get supportTickets =>
      $$SupportTicketsTableTableManager(
        _db.attachedDatabase,
        _db.supportTickets,
      );
  $$SupportMessagesTableTableManager get supportMessages =>
      $$SupportMessagesTableTableManager(
        _db.attachedDatabase,
        _db.supportMessages,
      );
}
