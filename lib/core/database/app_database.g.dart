// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _universitasMeta = const VerificationMeta(
    'universitas',
  );
  @override
  late final GeneratedColumn<String> universitas = GeneratedColumn<String>(
    'universitas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _programStudiMeta = const VerificationMeta(
    'programStudi',
  );
  @override
  late final GeneratedColumn<String> programStudi = GeneratedColumn<String>(
    'program_studi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BUYER'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendUpdatedAtMeta = const VerificationMeta(
    'backendUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> backendUpdatedAt = GeneratedColumn<int>(
    'backend_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    email,
    username,
    name,
    bio,
    photo,
    universitas,
    programStudi,
    role,
    isActive,
    isMe,
    createdAt,
    backendUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('universitas')) {
      context.handle(
        _universitasMeta,
        universitas.isAcceptableOrUnknown(
          data['universitas']!,
          _universitasMeta,
        ),
      );
    }
    if (data.containsKey('program_studi')) {
      context.handle(
        _programStudiMeta,
        programStudi.isAcceptableOrUnknown(
          data['program_studi']!,
          _programStudiMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('backend_updated_at')) {
      context.handle(
        _backendUpdatedAtMeta,
        backendUpdatedAt.isAcceptableOrUnknown(
          data['backend_updated_at']!,
          _backendUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      )!,
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      )!,
      universitas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}universitas'],
      )!,
      programStudi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_studi'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      backendUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Campus email; only filled for the signed-in account.
  final String email;

  /// @dev Handle shown on the marketplace.
  final String username;

  /// @dev Display name.
  final String name;

  /// @dev Seller bio; empty for buyers.
  final String bio;

  /// @dev URL of the profile photo.
  final String photo;

  /// @dev Campus name.
  final String universitas;

  /// @dev Study program.
  final String programStudi;

  /// @dev BUYER, SELLER or ADMIN.
  final String role;

  /// @dev Whether the account is active on the backend.
  final bool isActive;

  /// @dev Local-only marker for the signed-in account's row.
  final bool isMe;

  /// @dev UTC millis when the backend created the account.
  final int createdAt;

  /// @dev UTC millis of the last backend update to the row.
  final int backendUpdatedAt;
  const UserRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.bio,
    required this.photo,
    required this.universitas,
    required this.programStudi,
    required this.role,
    required this.isActive,
    required this.isMe,
    required this.createdAt,
    required this.backendUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    map['name'] = Variable<String>(name);
    map['bio'] = Variable<String>(bio);
    map['photo'] = Variable<String>(photo);
    map['universitas'] = Variable<String>(universitas);
    map['program_studi'] = Variable<String>(programStudi);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['is_me'] = Variable<bool>(isMe);
    map['created_at'] = Variable<int>(createdAt);
    map['backend_updated_at'] = Variable<int>(backendUpdatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      email: Value(email),
      username: Value(username),
      name: Value(name),
      bio: Value(bio),
      photo: Value(photo),
      universitas: Value(universitas),
      programStudi: Value(programStudi),
      role: Value(role),
      isActive: Value(isActive),
      isMe: Value(isMe),
      createdAt: Value(createdAt),
      backendUpdatedAt: Value(backendUpdatedAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      name: serializer.fromJson<String>(json['name']),
      bio: serializer.fromJson<String>(json['bio']),
      photo: serializer.fromJson<String>(json['photo']),
      universitas: serializer.fromJson<String>(json['universitas']),
      programStudi: serializer.fromJson<String>(json['programStudi']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isMe: serializer.fromJson<bool>(json['isMe']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      backendUpdatedAt: serializer.fromJson<int>(json['backendUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'username': serializer.toJson<String>(username),
      'name': serializer.toJson<String>(name),
      'bio': serializer.toJson<String>(bio),
      'photo': serializer.toJson<String>(photo),
      'universitas': serializer.toJson<String>(universitas),
      'programStudi': serializer.toJson<String>(programStudi),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'isMe': serializer.toJson<bool>(isMe),
      'createdAt': serializer.toJson<int>(createdAt),
      'backendUpdatedAt': serializer.toJson<int>(backendUpdatedAt),
    };
  }

  UserRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? email,
    String? username,
    String? name,
    String? bio,
    String? photo,
    String? universitas,
    String? programStudi,
    String? role,
    bool? isActive,
    bool? isMe,
    int? createdAt,
    int? backendUpdatedAt,
  }) => UserRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    name: name ?? this.name,
    bio: bio ?? this.bio,
    photo: photo ?? this.photo,
    universitas: universitas ?? this.universitas,
    programStudi: programStudi ?? this.programStudi,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    isMe: isMe ?? this.isMe,
    createdAt: createdAt ?? this.createdAt,
    backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      name: data.name.present ? data.name.value : this.name,
      bio: data.bio.present ? data.bio.value : this.bio,
      photo: data.photo.present ? data.photo.value : this.photo,
      universitas: data.universitas.present
          ? data.universitas.value
          : this.universitas,
      programStudi: data.programStudi.present
          ? data.programStudi.value
          : this.programStudi,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      backendUpdatedAt: data.backendUpdatedAt.present
          ? data.backendUpdatedAt.value
          : this.backendUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('bio: $bio, ')
          ..write('photo: $photo, ')
          ..write('universitas: $universitas, ')
          ..write('programStudi: $programStudi, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('isMe: $isMe, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    email,
    username,
    name,
    bio,
    photo,
    universitas,
    programStudi,
    role,
    isActive,
    isMe,
    createdAt,
    backendUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.name == this.name &&
          other.bio == this.bio &&
          other.photo == this.photo &&
          other.universitas == this.universitas &&
          other.programStudi == this.programStudi &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.isMe == this.isMe &&
          other.createdAt == this.createdAt &&
          other.backendUpdatedAt == this.backendUpdatedAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String> name;
  final Value<String> bio;
  final Value<String> photo;
  final Value<String> universitas;
  final Value<String> programStudi;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<bool> isMe;
  final Value<int> createdAt;
  final Value<int> backendUpdatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.bio = const Value.absent(),
    this.photo = const Value.absent(),
    this.universitas = const Value.absent(),
    this.programStudi = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isMe = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.bio = const Value.absent(),
    this.photo = const Value.absent(),
    this.universitas = const Value.absent(),
    this.programStudi = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isMe = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? name,
    Expression<String>? bio,
    Expression<String>? photo,
    Expression<String>? universitas,
    Expression<String>? programStudi,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<bool>? isMe,
    Expression<int>? createdAt,
    Expression<int>? backendUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (photo != null) 'photo': photo,
      if (universitas != null) 'universitas': universitas,
      if (programStudi != null) 'program_studi': programStudi,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (isMe != null) 'is_me': isMe,
      if (createdAt != null) 'created_at': createdAt,
      if (backendUpdatedAt != null) 'backend_updated_at': backendUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? email,
    Value<String>? username,
    Value<String>? name,
    Value<String>? bio,
    Value<String>? photo,
    Value<String>? universitas,
    Value<String>? programStudi,
    Value<String>? role,
    Value<bool>? isActive,
    Value<bool>? isMe,
    Value<int>? createdAt,
    Value<int>? backendUpdatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      universitas: universitas ?? this.universitas,
      programStudi: programStudi ?? this.programStudi,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isMe: isMe ?? this.isMe,
      createdAt: createdAt ?? this.createdAt,
      backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (universitas.present) {
      map['universitas'] = Variable<String>(universitas.value);
    }
    if (programStudi.present) {
      map['program_studi'] = Variable<String>(programStudi.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (backendUpdatedAt.present) {
      map['backend_updated_at'] = Variable<int>(backendUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('bio: $bio, ')
          ..write('photo: $photo, ')
          ..write('universitas: $universitas, ')
          ..write('programStudi: $programStudi, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('isMe: $isMe, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellerIdMeta = const VerificationMeta(
    'sellerId',
  );
  @override
  late final GeneratedColumn<String> sellerId = GeneratedColumn<String>(
    'seller_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _imageUrlsMeta = const VerificationMeta(
    'imageUrls',
  );
  @override
  late final GeneratedColumn<String> imageUrls = GeneratedColumn<String>(
    'image_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationLabelMeta = const VerificationMeta(
    'locationLabel',
  );
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
    'location_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<int> soldAt = GeneratedColumn<int>(
    'sold_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendUpdatedAtMeta = const VerificationMeta(
    'backendUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> backendUpdatedAt = GeneratedColumn<int>(
    'backend_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    sellerId,
    title,
    description,
    price,
    stock,
    imageUrls,
    category,
    latitude,
    longitude,
    locationLabel,
    status,
    soldAt,
    createdAt,
    backendUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seller_id')) {
      context.handle(
        _sellerIdMeta,
        sellerId.isAcceptableOrUnknown(data['seller_id']!, _sellerIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('image_urls')) {
      context.handle(
        _imageUrlsMeta,
        imageUrls.isAcceptableOrUnknown(data['image_urls']!, _imageUrlsMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_label')) {
      context.handle(
        _locationLabelMeta,
        locationLabel.isAcceptableOrUnknown(
          data['location_label']!,
          _locationLabelMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sold_at')) {
      context.handle(
        _soldAtMeta,
        soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('backend_updated_at')) {
      context.handle(
        _backendUpdatedAtMeta,
        backendUpdatedAt.isAcceptableOrUnknown(
          data['backend_updated_at']!,
          _backendUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sellerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seller_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      imageUrls: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_urls'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      locationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_label'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      soldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sold_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      backendUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_updated_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Identifier of the student selling the item.
  final String sellerId;

  /// @dev Item name.
  final String title;

  /// @dev Long description text.
  final String description;

  /// @dev Price in rupiah, integer as stored by the backend.
  final int price;

  /// @dev Units still available.
  final int stock;

  /// @dev JSON-encoded image URLs.
  final String imageUrls;

  /// @dev Category label.
  final String category;

  /// @dev Meeting-point latitude.
  final double latitude;

  /// @dev Meeting-point longitude.
  final double longitude;

  /// @dev Human-readable location label.
  final String locationLabel;

  /// @dev ACTIVE, SOLD or ARCHIVED.
  final String status;

  /// @dev UTC millis when the item was sold; 0 when still active.
  final int soldAt;

  /// @dev UTC millis when the backend created the listing.
  final int createdAt;

  /// @dev UTC millis of the last backend update to the row.
  final int backendUpdatedAt;
  const ProductRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrls,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.status,
    required this.soldAt,
    required this.createdAt,
    required this.backendUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['seller_id'] = Variable<String>(sellerId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['price'] = Variable<int>(price);
    map['stock'] = Variable<int>(stock);
    map['image_urls'] = Variable<String>(imageUrls);
    map['category'] = Variable<String>(category);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['location_label'] = Variable<String>(locationLabel);
    map['status'] = Variable<String>(status);
    map['sold_at'] = Variable<int>(soldAt);
    map['created_at'] = Variable<int>(createdAt);
    map['backend_updated_at'] = Variable<int>(backendUpdatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      sellerId: Value(sellerId),
      title: Value(title),
      description: Value(description),
      price: Value(price),
      stock: Value(stock),
      imageUrls: Value(imageUrls),
      category: Value(category),
      latitude: Value(latitude),
      longitude: Value(longitude),
      locationLabel: Value(locationLabel),
      status: Value(status),
      soldAt: Value(soldAt),
      createdAt: Value(createdAt),
      backendUpdatedAt: Value(backendUpdatedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      sellerId: serializer.fromJson<String>(json['sellerId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      price: serializer.fromJson<int>(json['price']),
      stock: serializer.fromJson<int>(json['stock']),
      imageUrls: serializer.fromJson<String>(json['imageUrls']),
      category: serializer.fromJson<String>(json['category']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      locationLabel: serializer.fromJson<String>(json['locationLabel']),
      status: serializer.fromJson<String>(json['status']),
      soldAt: serializer.fromJson<int>(json['soldAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      backendUpdatedAt: serializer.fromJson<int>(json['backendUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'sellerId': serializer.toJson<String>(sellerId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'price': serializer.toJson<int>(price),
      'stock': serializer.toJson<int>(stock),
      'imageUrls': serializer.toJson<String>(imageUrls),
      'category': serializer.toJson<String>(category),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'locationLabel': serializer.toJson<String>(locationLabel),
      'status': serializer.toJson<String>(status),
      'soldAt': serializer.toJson<int>(soldAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'backendUpdatedAt': serializer.toJson<int>(backendUpdatedAt),
    };
  }

  ProductRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? sellerId,
    String? title,
    String? description,
    int? price,
    int? stock,
    String? imageUrls,
    String? category,
    double? latitude,
    double? longitude,
    String? locationLabel,
    String? status,
    int? soldAt,
    int? createdAt,
    int? backendUpdatedAt,
  }) => ProductRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    sellerId: sellerId ?? this.sellerId,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    imageUrls: imageUrls ?? this.imageUrls,
    category: category ?? this.category,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    locationLabel: locationLabel ?? this.locationLabel,
    status: status ?? this.status,
    soldAt: soldAt ?? this.soldAt,
    createdAt: createdAt ?? this.createdAt,
    backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      sellerId: data.sellerId.present ? data.sellerId.value : this.sellerId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      stock: data.stock.present ? data.stock.value : this.stock,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      category: data.category.present ? data.category.value : this.category,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      status: data.status.present ? data.status.value : this.status,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      backendUpdatedAt: data.backendUpdatedAt.present
          ? data.backendUpdatedAt.value
          : this.backendUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('sellerId: $sellerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('stock: $stock, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('status: $status, ')
          ..write('soldAt: $soldAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    sellerId,
    title,
    description,
    price,
    stock,
    imageUrls,
    category,
    latitude,
    longitude,
    locationLabel,
    status,
    soldAt,
    createdAt,
    backendUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.sellerId == this.sellerId &&
          other.title == this.title &&
          other.description == this.description &&
          other.price == this.price &&
          other.stock == this.stock &&
          other.imageUrls == this.imageUrls &&
          other.category == this.category &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationLabel == this.locationLabel &&
          other.status == this.status &&
          other.soldAt == this.soldAt &&
          other.createdAt == this.createdAt &&
          other.backendUpdatedAt == this.backendUpdatedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> sellerId;
  final Value<String> title;
  final Value<String> description;
  final Value<int> price;
  final Value<int> stock;
  final Value<String> imageUrls;
  final Value<String> category;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> locationLabel;
  final Value<String> status;
  final Value<int> soldAt;
  final Value<int> createdAt;
  final Value<int> backendUpdatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.sellerId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.stock = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.category = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    this.sellerId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.stock = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.category = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<ProductRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? sellerId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? price,
    Expression<int>? stock,
    Expression<String>? imageUrls,
    Expression<String>? category,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? locationLabel,
    Expression<String>? status,
    Expression<int>? soldAt,
    Expression<int>? createdAt,
    Expression<int>? backendUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (sellerId != null) 'seller_id': sellerId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (category != null) 'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'location_label': locationLabel,
      if (status != null) 'status': status,
      if (soldAt != null) 'sold_at': soldAt,
      if (createdAt != null) 'created_at': createdAt,
      if (backendUpdatedAt != null) 'backend_updated_at': backendUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? sellerId,
    Value<String>? title,
    Value<String>? description,
    Value<int>? price,
    Value<int>? stock,
    Value<String>? imageUrls,
    Value<String>? category,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? locationLabel,
    Value<String>? status,
    Value<int>? soldAt,
    Value<int>? createdAt,
    Value<int>? backendUpdatedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      status: status ?? this.status,
      soldAt: soldAt ?? this.soldAt,
      createdAt: createdAt ?? this.createdAt,
      backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sellerId.present) {
      map['seller_id'] = Variable<String>(sellerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(imageUrls.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<int>(soldAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (backendUpdatedAt.present) {
      map['backend_updated_at'] = Variable<int>(backendUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('sellerId: $sellerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('stock: $stock, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('status: $status, ')
          ..write('soldAt: $soldAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [productId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  /// @dev Saved catalogue item id.
  final String productId;

  /// @dev UTC millis when the item was saved.
  final int createdAt;
  const FavoriteRow({required this.productId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      productId: Value(productId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      productId: serializer.fromJson<String>(json['productId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FavoriteRow copyWith({String? productId, int? createdAt}) => FavoriteRow(
    productId: productId ?? this.productId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('productId: $productId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.productId == this.productId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> productId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.productId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String productId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? productId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? productId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('productId: $productId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, ConversationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _buyerIdMeta = const VerificationMeta(
    'buyerId',
  );
  @override
  late final GeneratedColumn<String> buyerId = GeneratedColumn<String>(
    'buyer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sellerIdMeta = const VerificationMeta(
    'sellerId',
  );
  @override
  late final GeneratedColumn<String> sellerId = GeneratedColumn<String>(
    'seller_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _agreedLatitudeMeta = const VerificationMeta(
    'agreedLatitude',
  );
  @override
  late final GeneratedColumn<double> agreedLatitude = GeneratedColumn<double>(
    'agreed_latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _agreedLongitudeMeta = const VerificationMeta(
    'agreedLongitude',
  );
  @override
  late final GeneratedColumn<double> agreedLongitude = GeneratedColumn<double>(
    'agreed_longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _agreedLocationLabelMeta =
      const VerificationMeta('agreedLocationLabel');
  @override
  late final GeneratedColumn<String> agreedLocationLabel =
      GeneratedColumn<String>(
        'agreed_location_label',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
    'last_message_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendUpdatedAtMeta = const VerificationMeta(
    'backendUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> backendUpdatedAt = GeneratedColumn<int>(
    'backend_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    productId,
    buyerId,
    sellerId,
    agreedLatitude,
    agreedLongitude,
    agreedLocationLabel,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('buyer_id')) {
      context.handle(
        _buyerIdMeta,
        buyerId.isAcceptableOrUnknown(data['buyer_id']!, _buyerIdMeta),
      );
    }
    if (data.containsKey('seller_id')) {
      context.handle(
        _sellerIdMeta,
        sellerId.isAcceptableOrUnknown(data['seller_id']!, _sellerIdMeta),
      );
    }
    if (data.containsKey('agreed_latitude')) {
      context.handle(
        _agreedLatitudeMeta,
        agreedLatitude.isAcceptableOrUnknown(
          data['agreed_latitude']!,
          _agreedLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('agreed_longitude')) {
      context.handle(
        _agreedLongitudeMeta,
        agreedLongitude.isAcceptableOrUnknown(
          data['agreed_longitude']!,
          _agreedLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('agreed_location_label')) {
      context.handle(
        _agreedLocationLabelMeta,
        agreedLocationLabel.isAcceptableOrUnknown(
          data['agreed_location_label']!,
          _agreedLocationLabelMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('backend_updated_at')) {
      context.handle(
        _backendUpdatedAtMeta,
        backendUpdatedAt.isAcceptableOrUnknown(
          data['backend_updated_at']!,
          _backendUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      buyerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_id'],
      )!,
      sellerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seller_id'],
      )!,
      agreedLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}agreed_latitude'],
      )!,
      agreedLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}agreed_longitude'],
      )!,
      agreedLocationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agreed_location_label'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      backendUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_updated_at'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationRow extends DataClass implements Insertable<ConversationRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Product the room is about.
  final String productId;

  /// @dev Identifier of the buyer in the room.
  final String buyerId;

  /// @dev Identifier of the seller in the room.
  final String sellerId;

  /// @dev Agreed COD latitude.
  final double agreedLatitude;

  /// @dev Agreed COD longitude.
  final double agreedLongitude;

  /// @dev Agreed COD location label.
  final String agreedLocationLabel;

  /// @dev UTC millis of the last message; drives inbox ordering.
  final int lastMessageAt;

  /// @dev UTC millis when the backend created the room.
  final int createdAt;

  /// @dev UTC millis of the last backend update to the row.
  final int backendUpdatedAt;
  const ConversationRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.agreedLatitude,
    required this.agreedLongitude,
    required this.agreedLocationLabel,
    required this.lastMessageAt,
    required this.createdAt,
    required this.backendUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['buyer_id'] = Variable<String>(buyerId);
    map['seller_id'] = Variable<String>(sellerId);
    map['agreed_latitude'] = Variable<double>(agreedLatitude);
    map['agreed_longitude'] = Variable<double>(agreedLongitude);
    map['agreed_location_label'] = Variable<String>(agreedLocationLabel);
    map['last_message_at'] = Variable<int>(lastMessageAt);
    map['created_at'] = Variable<int>(createdAt);
    map['backend_updated_at'] = Variable<int>(backendUpdatedAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      productId: Value(productId),
      buyerId: Value(buyerId),
      sellerId: Value(sellerId),
      agreedLatitude: Value(agreedLatitude),
      agreedLongitude: Value(agreedLongitude),
      agreedLocationLabel: Value(agreedLocationLabel),
      lastMessageAt: Value(lastMessageAt),
      createdAt: Value(createdAt),
      backendUpdatedAt: Value(backendUpdatedAt),
    );
  }

  factory ConversationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      buyerId: serializer.fromJson<String>(json['buyerId']),
      sellerId: serializer.fromJson<String>(json['sellerId']),
      agreedLatitude: serializer.fromJson<double>(json['agreedLatitude']),
      agreedLongitude: serializer.fromJson<double>(json['agreedLongitude']),
      agreedLocationLabel: serializer.fromJson<String>(
        json['agreedLocationLabel'],
      ),
      lastMessageAt: serializer.fromJson<int>(json['lastMessageAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      backendUpdatedAt: serializer.fromJson<int>(json['backendUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'buyerId': serializer.toJson<String>(buyerId),
      'sellerId': serializer.toJson<String>(sellerId),
      'agreedLatitude': serializer.toJson<double>(agreedLatitude),
      'agreedLongitude': serializer.toJson<double>(agreedLongitude),
      'agreedLocationLabel': serializer.toJson<String>(agreedLocationLabel),
      'lastMessageAt': serializer.toJson<int>(lastMessageAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'backendUpdatedAt': serializer.toJson<int>(backendUpdatedAt),
    };
  }

  ConversationRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? productId,
    String? buyerId,
    String? sellerId,
    double? agreedLatitude,
    double? agreedLongitude,
    String? agreedLocationLabel,
    int? lastMessageAt,
    int? createdAt,
    int? backendUpdatedAt,
  }) => ConversationRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    productId: productId ?? this.productId,
    buyerId: buyerId ?? this.buyerId,
    sellerId: sellerId ?? this.sellerId,
    agreedLatitude: agreedLatitude ?? this.agreedLatitude,
    agreedLongitude: agreedLongitude ?? this.agreedLongitude,
    agreedLocationLabel: agreedLocationLabel ?? this.agreedLocationLabel,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    createdAt: createdAt ?? this.createdAt,
    backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
  );
  ConversationRow copyWithCompanion(ConversationsCompanion data) {
    return ConversationRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      buyerId: data.buyerId.present ? data.buyerId.value : this.buyerId,
      sellerId: data.sellerId.present ? data.sellerId.value : this.sellerId,
      agreedLatitude: data.agreedLatitude.present
          ? data.agreedLatitude.value
          : this.agreedLatitude,
      agreedLongitude: data.agreedLongitude.present
          ? data.agreedLongitude.value
          : this.agreedLongitude,
      agreedLocationLabel: data.agreedLocationLabel.present
          ? data.agreedLocationLabel.value
          : this.agreedLocationLabel,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      backendUpdatedAt: data.backendUpdatedAt.present
          ? data.backendUpdatedAt.value
          : this.backendUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('buyerId: $buyerId, ')
          ..write('sellerId: $sellerId, ')
          ..write('agreedLatitude: $agreedLatitude, ')
          ..write('agreedLongitude: $agreedLongitude, ')
          ..write('agreedLocationLabel: $agreedLocationLabel, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    productId,
    buyerId,
    sellerId,
    agreedLatitude,
    agreedLongitude,
    agreedLocationLabel,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.buyerId == this.buyerId &&
          other.sellerId == this.sellerId &&
          other.agreedLatitude == this.agreedLatitude &&
          other.agreedLongitude == this.agreedLongitude &&
          other.agreedLocationLabel == this.agreedLocationLabel &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.backendUpdatedAt == this.backendUpdatedAt);
}

class ConversationsCompanion extends UpdateCompanion<ConversationRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> productId;
  final Value<String> buyerId;
  final Value<String> sellerId;
  final Value<double> agreedLatitude;
  final Value<double> agreedLongitude;
  final Value<String> agreedLocationLabel;
  final Value<int> lastMessageAt;
  final Value<int> createdAt;
  final Value<int> backendUpdatedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.buyerId = const Value.absent(),
    this.sellerId = const Value.absent(),
    this.agreedLatitude = const Value.absent(),
    this.agreedLongitude = const Value.absent(),
    this.agreedLocationLabel = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    this.productId = const Value.absent(),
    this.buyerId = const Value.absent(),
    this.sellerId = const Value.absent(),
    this.agreedLatitude = const Value.absent(),
    this.agreedLongitude = const Value.absent(),
    this.agreedLocationLabel = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ConversationRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? buyerId,
    Expression<String>? sellerId,
    Expression<double>? agreedLatitude,
    Expression<double>? agreedLongitude,
    Expression<String>? agreedLocationLabel,
    Expression<int>? lastMessageAt,
    Expression<int>? createdAt,
    Expression<int>? backendUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (buyerId != null) 'buyer_id': buyerId,
      if (sellerId != null) 'seller_id': sellerId,
      if (agreedLatitude != null) 'agreed_latitude': agreedLatitude,
      if (agreedLongitude != null) 'agreed_longitude': agreedLongitude,
      if (agreedLocationLabel != null)
        'agreed_location_label': agreedLocationLabel,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (backendUpdatedAt != null) 'backend_updated_at': backendUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? productId,
    Value<String>? buyerId,
    Value<String>? sellerId,
    Value<double>? agreedLatitude,
    Value<double>? agreedLongitude,
    Value<String>? agreedLocationLabel,
    Value<int>? lastMessageAt,
    Value<int>? createdAt,
    Value<int>? backendUpdatedAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      agreedLatitude: agreedLatitude ?? this.agreedLatitude,
      agreedLongitude: agreedLongitude ?? this.agreedLongitude,
      agreedLocationLabel: agreedLocationLabel ?? this.agreedLocationLabel,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (buyerId.present) {
      map['buyer_id'] = Variable<String>(buyerId.value);
    }
    if (sellerId.present) {
      map['seller_id'] = Variable<String>(sellerId.value);
    }
    if (agreedLatitude.present) {
      map['agreed_latitude'] = Variable<double>(agreedLatitude.value);
    }
    if (agreedLongitude.present) {
      map['agreed_longitude'] = Variable<double>(agreedLongitude.value);
    }
    if (agreedLocationLabel.present) {
      map['agreed_location_label'] = Variable<String>(
        agreedLocationLabel.value,
      );
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (backendUpdatedAt.present) {
      map['backend_updated_at'] = Variable<int>(backendUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('buyerId: $buyerId, ')
          ..write('sellerId: $sellerId, ')
          ..write('agreedLatitude: $agreedLatitude, ')
          ..write('agreedLongitude: $agreedLongitude, ')
          ..write('agreedLocationLabel: $agreedLocationLabel, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TEXT'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationLabelMeta = const VerificationMeta(
    'locationLabel',
  );
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
    'location_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<int> readAt = GeneratedColumn<int>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    conversationId,
    senderId,
    type,
    body,
    imageUrl,
    latitude,
    longitude,
    locationLabel,
    isRead,
    readAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_label')) {
      context.handle(
        _locationLabelMeta,
        locationLabel.isAcceptableOrUnknown(
          data['location_label']!,
          _locationLabelMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      locationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_label'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Conversation this bubble belongs to.
  final String conversationId;

  /// @dev Identifier of the student who sent it.
  final String senderId;

  /// @dev TEXT, IMAGE, LOCATION or SYSTEM.
  final String type;

  /// @dev Message body; stored as the backend `text` column.
  final String body;

  /// @dev Image URL for IMAGE bubbles.
  final String imageUrl;

  /// @dev Latitude for LOCATION bubbles.
  final double latitude;

  /// @dev Longitude for LOCATION bubbles.
  final double longitude;

  /// @dev Location label for LOCATION bubbles.
  final String locationLabel;

  /// @dev Whether the recipient has read the bubble.
  final bool isRead;

  /// @dev UTC millis when the bubble was read; 0 while unread.
  final int readAt;

  /// @dev UTC millis when the backend created the bubble.
  final int createdAt;
  const MessageRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.body,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['type'] = Variable<String>(type);
    map['text'] = Variable<String>(body);
    map['image_url'] = Variable<String>(imageUrl);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['location_label'] = Variable<String>(locationLabel);
    map['is_read'] = Variable<bool>(isRead);
    map['read_at'] = Variable<int>(readAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      type: Value(type),
      body: Value(body),
      imageUrl: Value(imageUrl),
      latitude: Value(latitude),
      longitude: Value(longitude),
      locationLabel: Value(locationLabel),
      isRead: Value(isRead),
      readAt: Value(readAt),
      createdAt: Value(createdAt),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      type: serializer.fromJson<String>(json['type']),
      body: serializer.fromJson<String>(json['body']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      locationLabel: serializer.fromJson<String>(json['locationLabel']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<int>(json['readAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'type': serializer.toJson<String>(type),
      'body': serializer.toJson<String>(body),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'locationLabel': serializer.toJson<String>(locationLabel),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<int>(readAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MessageRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? conversationId,
    String? senderId,
    String? type,
    String? body,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? locationLabel,
    bool? isRead,
    int? readAt,
    int? createdAt,
  }) => MessageRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    type: type ?? this.type,
    body: body ?? this.body,
    imageUrl: imageUrl ?? this.imageUrl,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    locationLabel: locationLabel ?? this.locationLabel,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    createdAt: createdAt ?? this.createdAt,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    conversationId,
    senderId,
    type,
    body,
    imageUrl,
    latitude,
    longitude,
    locationLabel,
    isRead,
    readAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.type == this.type &&
          other.body == this.body &&
          other.imageUrl == this.imageUrl &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationLabel == this.locationLabel &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String> type;
  final Value<String> body;
  final Value<String> imageUrl;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> locationLabel;
  final Value<bool> isRead;
  final Value<int> readAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    required String conversationId,
    this.senderId = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId);
  static Insertable<MessageRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? type,
    Expression<String>? body,
    Expression<String>? imageUrl,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? locationLabel,
    Expression<bool>? isRead,
    Expression<int>? readAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (type != null) 'type': type,
      if (body != null) 'text': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'location_label': locationLabel,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? senderId,
    Value<String>? type,
    Value<String>? body,
    Value<String>? imageUrl,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? locationLabel,
    Value<bool>? isRead,
    Value<int>? readAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<int>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HelpTopicsTable extends HelpTopics
    with TableInfo<$HelpTopicsTable, HelpTopicRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HelpTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    title,
    answer,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'help_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<HelpTopicRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HelpTopicRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HelpTopicRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $HelpTopicsTable createAlias(String alias) {
    return $HelpTopicsTable(attachedDatabase, alias);
  }
}

class HelpTopicRow extends DataClass implements Insertable<HelpTopicRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Label shown on the expandable row.
  final String title;

  /// @dev Guidance shown when the row is expanded.
  final String answer;

  /// @dev Position kept so the FAQ matches the backend order.
  final int sortOrder;
  const HelpTopicRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.title,
    required this.answer,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['answer'] = Variable<String>(answer);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  HelpTopicsCompanion toCompanion(bool nullToAbsent) {
    return HelpTopicsCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      title: Value(title),
      answer: Value(answer),
      sortOrder: Value(sortOrder),
    );
  }

  factory HelpTopicRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HelpTopicRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      answer: serializer.fromJson<String>(json['answer']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'answer': serializer.toJson<String>(answer),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  HelpTopicRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? title,
    String? answer,
    int? sortOrder,
  }) => HelpTopicRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    title: title ?? this.title,
    answer: answer ?? this.answer,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  HelpTopicRow copyWithCompanion(HelpTopicsCompanion data) {
    return HelpTopicRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      answer: data.answer.present ? data.answer.value : this.answer,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HelpTopicRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('answer: $answer, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(updatedAt, lastFetched, id, title, answer, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HelpTopicRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.title == this.title &&
          other.answer == this.answer &&
          other.sortOrder == this.sortOrder);
}

class HelpTopicsCompanion extends UpdateCompanion<HelpTopicRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> title;
  final Value<String> answer;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const HelpTopicsCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.answer = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HelpTopicsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    required String title,
    required String answer,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       answer = Value(answer);
  static Insertable<HelpTopicRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? answer,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (answer != null) 'answer': answer,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HelpTopicsCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? title,
    Value<String>? answer,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return HelpTopicsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      title: title ?? this.title,
      answer: answer ?? this.answer,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HelpTopicsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('answer: $answer, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupportTicketsTable extends SupportTickets
    with TableInfo<$SupportTicketsTable, SupportTicketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportTicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketNoMeta = const VerificationMeta(
    'ticketNo',
  );
  @override
  late final GeneratedColumn<String> ticketNo = GeneratedColumn<String>(
    'ticket_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LAINNYA'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN'),
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
    'last_message_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendUpdatedAtMeta = const VerificationMeta(
    'backendUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> backendUpdatedAt = GeneratedColumn<int>(
    'backend_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    ticketNo,
    userId,
    category,
    status,
    subject,
    description,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportTicketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ticket_no')) {
      context.handle(
        _ticketNoMeta,
        ticketNo.isAcceptableOrUnknown(data['ticket_no']!, _ticketNoMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('backend_updated_at')) {
      context.handle(
        _backendUpdatedAtMeta,
        backendUpdatedAt.isAcceptableOrUnknown(
          data['backend_updated_at']!,
          _backendUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupportTicketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportTicketRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ticketNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_no'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      backendUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_updated_at'],
      )!,
    );
  }

  @override
  $SupportTicketsTable createAlias(String alias) {
    return $SupportTicketsTable(attachedDatabase, alias);
  }
}

class SupportTicketRow extends DataClass
    implements Insertable<SupportTicketRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Human-readable ticket number, e.g. KSP-1234.
  final String ticketNo;

  /// @dev Identifier of the student who opened the ticket.
  final String userId;

  /// @dev Problem category.
  final String category;

  /// @dev OPEN or CLOSED.
  final String status;

  /// @dev Subject shown as the inbox-style username line.
  final String subject;

  /// @dev First message body.
  final String description;

  /// @dev UTC millis of the last message.
  final int lastMessageAt;

  /// @dev UTC millis when the backend created the ticket.
  final int createdAt;

  /// @dev UTC millis of the last backend update to the row.
  final int backendUpdatedAt;
  const SupportTicketRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.ticketNo,
    required this.userId,
    required this.category,
    required this.status,
    required this.subject,
    required this.description,
    required this.lastMessageAt,
    required this.createdAt,
    required this.backendUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['ticket_no'] = Variable<String>(ticketNo);
    map['user_id'] = Variable<String>(userId);
    map['category'] = Variable<String>(category);
    map['status'] = Variable<String>(status);
    map['subject'] = Variable<String>(subject);
    map['description'] = Variable<String>(description);
    map['last_message_at'] = Variable<int>(lastMessageAt);
    map['created_at'] = Variable<int>(createdAt);
    map['backend_updated_at'] = Variable<int>(backendUpdatedAt);
    return map;
  }

  SupportTicketsCompanion toCompanion(bool nullToAbsent) {
    return SupportTicketsCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      ticketNo: Value(ticketNo),
      userId: Value(userId),
      category: Value(category),
      status: Value(status),
      subject: Value(subject),
      description: Value(description),
      lastMessageAt: Value(lastMessageAt),
      createdAt: Value(createdAt),
      backendUpdatedAt: Value(backendUpdatedAt),
    );
  }

  factory SupportTicketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportTicketRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      ticketNo: serializer.fromJson<String>(json['ticketNo']),
      userId: serializer.fromJson<String>(json['userId']),
      category: serializer.fromJson<String>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      subject: serializer.fromJson<String>(json['subject']),
      description: serializer.fromJson<String>(json['description']),
      lastMessageAt: serializer.fromJson<int>(json['lastMessageAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      backendUpdatedAt: serializer.fromJson<int>(json['backendUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'ticketNo': serializer.toJson<String>(ticketNo),
      'userId': serializer.toJson<String>(userId),
      'category': serializer.toJson<String>(category),
      'status': serializer.toJson<String>(status),
      'subject': serializer.toJson<String>(subject),
      'description': serializer.toJson<String>(description),
      'lastMessageAt': serializer.toJson<int>(lastMessageAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'backendUpdatedAt': serializer.toJson<int>(backendUpdatedAt),
    };
  }

  SupportTicketRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? ticketNo,
    String? userId,
    String? category,
    String? status,
    String? subject,
    String? description,
    int? lastMessageAt,
    int? createdAt,
    int? backendUpdatedAt,
  }) => SupportTicketRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    ticketNo: ticketNo ?? this.ticketNo,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    status: status ?? this.status,
    subject: subject ?? this.subject,
    description: description ?? this.description,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    createdAt: createdAt ?? this.createdAt,
    backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
  );
  SupportTicketRow copyWithCompanion(SupportTicketsCompanion data) {
    return SupportTicketRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      ticketNo: data.ticketNo.present ? data.ticketNo.value : this.ticketNo,
      userId: data.userId.present ? data.userId.value : this.userId,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      subject: data.subject.present ? data.subject.value : this.subject,
      description: data.description.present
          ? data.description.value
          : this.description,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      backendUpdatedAt: data.backendUpdatedAt.present
          ? data.backendUpdatedAt.value
          : this.backendUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportTicketRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('ticketNo: $ticketNo, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    ticketNo,
    userId,
    category,
    status,
    subject,
    description,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportTicketRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.ticketNo == this.ticketNo &&
          other.userId == this.userId &&
          other.category == this.category &&
          other.status == this.status &&
          other.subject == this.subject &&
          other.description == this.description &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.backendUpdatedAt == this.backendUpdatedAt);
}

class SupportTicketsCompanion extends UpdateCompanion<SupportTicketRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> ticketNo;
  final Value<String> userId;
  final Value<String> category;
  final Value<String> status;
  final Value<String> subject;
  final Value<String> description;
  final Value<int> lastMessageAt;
  final Value<int> createdAt;
  final Value<int> backendUpdatedAt;
  final Value<int> rowid;
  const SupportTicketsCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.ticketNo = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.subject = const Value.absent(),
    this.description = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupportTicketsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    this.ticketNo = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.subject = const Value.absent(),
    this.description = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<SupportTicketRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? ticketNo,
    Expression<String>? userId,
    Expression<String>? category,
    Expression<String>? status,
    Expression<String>? subject,
    Expression<String>? description,
    Expression<int>? lastMessageAt,
    Expression<int>? createdAt,
    Expression<int>? backendUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (ticketNo != null) 'ticket_no': ticketNo,
      if (userId != null) 'user_id': userId,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (subject != null) 'subject': subject,
      if (description != null) 'description': description,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (backendUpdatedAt != null) 'backend_updated_at': backendUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupportTicketsCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? ticketNo,
    Value<String>? userId,
    Value<String>? category,
    Value<String>? status,
    Value<String>? subject,
    Value<String>? description,
    Value<int>? lastMessageAt,
    Value<int>? createdAt,
    Value<int>? backendUpdatedAt,
    Value<int>? rowid,
  }) {
    return SupportTicketsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      ticketNo: ticketNo ?? this.ticketNo,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ticketNo.present) {
      map['ticket_no'] = Variable<String>(ticketNo.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (backendUpdatedAt.present) {
      map['backend_updated_at'] = Variable<int>(backendUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportTicketsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('ticketNo: $ticketNo, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupportMessagesTable extends SupportMessages
    with TableInfo<$SupportMessagesTable, SupportMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<String> ticketId = GeneratedColumn<String>(
    'ticket_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _senderRoleMeta = const VerificationMeta(
    'senderRole',
  );
  @override
  late final GeneratedColumn<String> senderRole = GeneratedColumn<String>(
    'sender_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USER'),
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isInternalMeta = const VerificationMeta(
    'isInternal',
  );
  @override
  late final GeneratedColumn<bool> isInternal = GeneratedColumn<bool>(
    'is_internal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_internal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<int> readAt = GeneratedColumn<int>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    ticketId,
    senderId,
    senderRole,
    senderName,
    body,
    imageUrl,
    isInternal,
    isRead,
    readAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('sender_role')) {
      context.handle(
        _senderRoleMeta,
        senderRole.isAcceptableOrUnknown(data['sender_role']!, _senderRoleMeta),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_internal')) {
      context.handle(
        _isInternalMeta,
        isInternal.isAcceptableOrUnknown(data['is_internal']!, _isInternalMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupportMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportMessageRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_role'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      isInternal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_internal'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupportMessagesTable createAlias(String alias) {
    return $SupportMessagesTable(attachedDatabase, alias);
  }
}

class SupportMessageRow extends DataClass
    implements Insertable<SupportMessageRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Ticket this bubble belongs to.
  final String ticketId;

  /// @dev Identifier of the sender.
  final String senderId;

  /// @dev Sender role, e.g. USER or ADMIN.
  final String senderRole;

  /// @dev Display name of the sender.
  final String senderName;

  /// @dev Message body; stored as the backend `text` column.
  final String body;

  /// @dev Image URL when the bubble carries a photo.
  final String imageUrl;

  /// @dev Admin-only internal note.
  final bool isInternal;

  /// @dev Whether the reporter has read the bubble.
  final bool isRead;

  /// @dev UTC millis when the bubble was read; 0 while unread.
  final int readAt;

  /// @dev UTC millis when the backend created the bubble.
  final int createdAt;
  const SupportMessageRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.body,
    required this.imageUrl,
    required this.isInternal,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['ticket_id'] = Variable<String>(ticketId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_role'] = Variable<String>(senderRole);
    map['sender_name'] = Variable<String>(senderName);
    map['text'] = Variable<String>(body);
    map['image_url'] = Variable<String>(imageUrl);
    map['is_internal'] = Variable<bool>(isInternal);
    map['is_read'] = Variable<bool>(isRead);
    map['read_at'] = Variable<int>(readAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SupportMessagesCompanion toCompanion(bool nullToAbsent) {
    return SupportMessagesCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      ticketId: Value(ticketId),
      senderId: Value(senderId),
      senderRole: Value(senderRole),
      senderName: Value(senderName),
      body: Value(body),
      imageUrl: Value(imageUrl),
      isInternal: Value(isInternal),
      isRead: Value(isRead),
      readAt: Value(readAt),
      createdAt: Value(createdAt),
    );
  }

  factory SupportMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportMessageRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      ticketId: serializer.fromJson<String>(json['ticketId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderRole: serializer.fromJson<String>(json['senderRole']),
      senderName: serializer.fromJson<String>(json['senderName']),
      body: serializer.fromJson<String>(json['body']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      isInternal: serializer.fromJson<bool>(json['isInternal']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<int>(json['readAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'ticketId': serializer.toJson<String>(ticketId),
      'senderId': serializer.toJson<String>(senderId),
      'senderRole': serializer.toJson<String>(senderRole),
      'senderName': serializer.toJson<String>(senderName),
      'body': serializer.toJson<String>(body),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'isInternal': serializer.toJson<bool>(isInternal),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<int>(readAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SupportMessageRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? ticketId,
    String? senderId,
    String? senderRole,
    String? senderName,
    String? body,
    String? imageUrl,
    bool? isInternal,
    bool? isRead,
    int? readAt,
    int? createdAt,
  }) => SupportMessageRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    ticketId: ticketId ?? this.ticketId,
    senderId: senderId ?? this.senderId,
    senderRole: senderRole ?? this.senderRole,
    senderName: senderName ?? this.senderName,
    body: body ?? this.body,
    imageUrl: imageUrl ?? this.imageUrl,
    isInternal: isInternal ?? this.isInternal,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    createdAt: createdAt ?? this.createdAt,
  );
  SupportMessageRow copyWithCompanion(SupportMessagesCompanion data) {
    return SupportMessageRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderRole: data.senderRole.present
          ? data.senderRole.value
          : this.senderRole,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      body: data.body.present ? data.body.value : this.body,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isInternal: data.isInternal.present
          ? data.isInternal.value
          : this.isInternal,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportMessageRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('senderId: $senderId, ')
          ..write('senderRole: $senderRole, ')
          ..write('senderName: $senderName, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isInternal: $isInternal, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    ticketId,
    senderId,
    senderRole,
    senderName,
    body,
    imageUrl,
    isInternal,
    isRead,
    readAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportMessageRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.senderId == this.senderId &&
          other.senderRole == this.senderRole &&
          other.senderName == this.senderName &&
          other.body == this.body &&
          other.imageUrl == this.imageUrl &&
          other.isInternal == this.isInternal &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt);
}

class SupportMessagesCompanion extends UpdateCompanion<SupportMessageRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> ticketId;
  final Value<String> senderId;
  final Value<String> senderRole;
  final Value<String> senderName;
  final Value<String> body;
  final Value<String> imageUrl;
  final Value<bool> isInternal;
  final Value<bool> isRead;
  final Value<int> readAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SupportMessagesCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.senderName = const Value.absent(),
    this.body = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isInternal = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupportMessagesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    required String ticketId,
    this.senderId = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.senderName = const Value.absent(),
    this.body = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isInternal = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ticketId = Value(ticketId);
  static Insertable<SupportMessageRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? ticketId,
    Expression<String>? senderId,
    Expression<String>? senderRole,
    Expression<String>? senderName,
    Expression<String>? body,
    Expression<String>? imageUrl,
    Expression<bool>? isInternal,
    Expression<bool>? isRead,
    Expression<int>? readAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (senderId != null) 'sender_id': senderId,
      if (senderRole != null) 'sender_role': senderRole,
      if (senderName != null) 'sender_name': senderName,
      if (body != null) 'text': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isInternal != null) 'is_internal': isInternal,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupportMessagesCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? ticketId,
    Value<String>? senderId,
    Value<String>? senderRole,
    Value<String>? senderName,
    Value<String>? body,
    Value<String>? imageUrl,
    Value<bool>? isInternal,
    Value<bool>? isRead,
    Value<int>? readAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SupportMessagesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      isInternal: isInternal ?? this.isInternal,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<String>(ticketId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderRole.present) {
      map['sender_role'] = Variable<String>(senderRole.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isInternal.present) {
      map['is_internal'] = Variable<bool>(isInternal.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<int>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportMessagesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('senderId: $senderId, ')
          ..write('senderRole: $senderRole, ')
          ..write('senderName: $senderName, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isInternal: $isInternal, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiConversationsTable extends AiConversations
    with TableInfo<$AiConversationsTable, AiConversationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
    'last_message_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendUpdatedAtMeta = const VerificationMeta(
    'backendUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> backendUpdatedAt = GeneratedColumn<int>(
    'backend_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    userId,
    title,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiConversationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('backend_updated_at')) {
      context.handle(
        _backendUpdatedAtMeta,
        backendUpdatedAt.isAcceptableOrUnknown(
          data['backend_updated_at']!,
          _backendUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiConversationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiConversationRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      backendUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_updated_at'],
      )!,
    );
  }

  @override
  $AiConversationsTable createAlias(String alias) {
    return $AiConversationsTable(attachedDatabase, alias);
  }
}

class AiConversationRow extends DataClass
    implements Insertable<AiConversationRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Identifier of the owning student.
  final String userId;

  /// @dev Heading shown on the overlay and the Home list.
  final String title;

  /// @dev UTC millis of the last message; drives history ordering.
  final int lastMessageAt;

  /// @dev UTC millis when the backend created the conversation.
  final int createdAt;

  /// @dev UTC millis of the last backend update to the row.
  final int backendUpdatedAt;
  const AiConversationRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.userId,
    required this.title,
    required this.lastMessageAt,
    required this.createdAt,
    required this.backendUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['last_message_at'] = Variable<int>(lastMessageAt);
    map['created_at'] = Variable<int>(createdAt);
    map['backend_updated_at'] = Variable<int>(backendUpdatedAt);
    return map;
  }

  AiConversationsCompanion toCompanion(bool nullToAbsent) {
    return AiConversationsCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      lastMessageAt: Value(lastMessageAt),
      createdAt: Value(createdAt),
      backendUpdatedAt: Value(backendUpdatedAt),
    );
  }

  factory AiConversationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiConversationRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      lastMessageAt: serializer.fromJson<int>(json['lastMessageAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      backendUpdatedAt: serializer.fromJson<int>(json['backendUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'lastMessageAt': serializer.toJson<int>(lastMessageAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'backendUpdatedAt': serializer.toJson<int>(backendUpdatedAt),
    };
  }

  AiConversationRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? userId,
    String? title,
    int? lastMessageAt,
    int? createdAt,
    int? backendUpdatedAt,
  }) => AiConversationRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    createdAt: createdAt ?? this.createdAt,
    backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
  );
  AiConversationRow copyWithCompanion(AiConversationsCompanion data) {
    return AiConversationRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      backendUpdatedAt: data.backendUpdatedAt.present
          ? data.backendUpdatedAt.value
          : this.backendUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiConversationRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    userId,
    title,
    lastMessageAt,
    createdAt,
    backendUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiConversationRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.backendUpdatedAt == this.backendUpdatedAt);
}

class AiConversationsCompanion extends UpdateCompanion<AiConversationRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<int> lastMessageAt;
  final Value<int> createdAt;
  final Value<int> backendUpdatedAt;
  final Value<int> rowid;
  const AiConversationsCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiConversationsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.backendUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AiConversationRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<int>? lastMessageAt,
    Expression<int>? createdAt,
    Expression<int>? backendUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (backendUpdatedAt != null) 'backend_updated_at': backendUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiConversationsCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<int>? lastMessageAt,
    Value<int>? createdAt,
    Value<int>? backendUpdatedAt,
    Value<int>? rowid,
  }) {
    return AiConversationsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      backendUpdatedAt: backendUpdatedAt ?? this.backendUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (backendUpdatedAt.present) {
      map['backend_updated_at'] = Variable<int>(backendUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiConversationsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('backendUpdatedAt: $backendUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiMessagesTable extends AiMessages
    with TableInfo<$AiMessagesTable, AiMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USER'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    lastFetched,
    id,
    conversationId,
    role,
    content,
    model,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMessageRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiMessagesTable createAlias(String alias) {
    return $AiMessagesTable(attachedDatabase, alias);
  }
}

class AiMessageRow extends DataClass implements Insertable<AiMessageRow> {
  /// @dev UTC millis of the last write to this row.
  final int updatedAt;

  /// @dev UTC millis of the last successful backend refresh.
  final int lastFetched;

  /// @dev Stable identifier from the backend.
  final String id;

  /// @dev Conversation this bubble belongs to.
  final String conversationId;

  /// @dev USER, ASSISTANT or SYSTEM.
  final String role;

  /// @dev Message body.
  final String content;

  /// @dev Model that produced an assistant bubble.
  final String model;

  /// @dev UTC millis when the backend created the bubble.
  final int createdAt;
  const AiMessageRow({
    required this.updatedAt,
    required this.lastFetched,
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.model,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['model'] = Variable<String>(model);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AiMessagesCompanion toCompanion(bool nullToAbsent) {
    return AiMessagesCompanion(
      updatedAt: Value(updatedAt),
      lastFetched: Value(lastFetched),
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      model: Value(model),
      createdAt: Value(createdAt),
    );
  }

  factory AiMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMessageRow(
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      model: serializer.fromJson<String>(json['model']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'model': serializer.toJson<String>(model),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AiMessageRow copyWith({
    int? updatedAt,
    int? lastFetched,
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? model,
    int? createdAt,
  }) => AiMessageRow(
    updatedAt: updatedAt ?? this.updatedAt,
    lastFetched: lastFetched ?? this.lastFetched,
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    model: model ?? this.model,
    createdAt: createdAt ?? this.createdAt,
  );
  AiMessageRow copyWithCompanion(AiMessagesCompanion data) {
    return AiMessageRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMessageRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    lastFetched,
    id,
    conversationId,
    role,
    content,
    model,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMessageRow &&
          other.updatedAt == this.updatedAt &&
          other.lastFetched == this.lastFetched &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.model == this.model &&
          other.createdAt == this.createdAt);
}

class AiMessagesCompanion extends UpdateCompanion<AiMessageRow> {
  final Value<int> updatedAt;
  final Value<int> lastFetched;
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> model;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AiMessagesCompanion({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiMessagesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.lastFetched = const Value.absent(),
    required String id,
    required String conversationId,
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId);
  static Insertable<AiMessageRow> custom({
    Expression<int>? updatedAt,
    Expression<int>? lastFetched,
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? model,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiMessagesCompanion copyWith({
    Value<int>? updatedAt,
    Value<int>? lastFetched,
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? model,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AiMessagesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetched: lastFetched ?? this.lastFetched,
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiMessagesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $HelpTopicsTable helpTopics = $HelpTopicsTable(this);
  late final $SupportTicketsTable supportTickets = $SupportTicketsTable(this);
  late final $SupportMessagesTable supportMessages = $SupportMessagesTable(
    this,
  );
  late final $AiConversationsTable aiConversations = $AiConversationsTable(
    this,
  );
  late final $AiMessagesTable aiMessages = $AiMessagesTable(this);
  late final CatalogDao catalogDao = CatalogDao(this as AppDatabase);
  late final InboxDao inboxDao = InboxDao(this as AppDatabase);
  late final SupportDao supportDao = SupportDao(this as AppDatabase);
  late final AiChatDao aiChatDao = AiChatDao(this as AppDatabase);
  late final AccountDao accountDao = AccountDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    products,
    favorites,
    conversations,
    messages,
    helpTopics,
    supportTickets,
    supportMessages,
    aiConversations,
    aiMessages,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  required String id,
  Value<String> email,
  Value<String> username,
  Value<String> name,
  Value<String> bio,
  Value<String> photo,
  Value<String> universitas,
  Value<String> programStudi,
  Value<String> role,
  Value<bool> isActive,
  Value<bool> isMe,
  Value<int> createdAt,
  Value<int> backendUpdatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  Value<String> id,
  Value<String> email,
  Value<String> username,
  Value<String> name,
  Value<String> bio,
  Value<String> photo,
  Value<String> universitas,
  Value<String> programStudi,
  Value<String> role,
  Value<bool> isActive,
  Value<bool> isMe,
  Value<int> createdAt,
  Value<int> backendUpdatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get universitas => $composableBuilder(
    column: $table.universitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programStudi => $composableBuilder(
    column: $table.programStudi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get universitas => $composableBuilder(
    column: $table.universitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programStudi => $composableBuilder(
    column: $table.programStudi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<String> get universitas => $composableBuilder(
    column: $table.universitas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get programStudi => $composableBuilder(
    column: $table.programStudi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String> photo = const Value.absent(),
                Value<String> universitas = const Value.absent(),
                Value<String> programStudi = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                email: email,
                username: username,
                name: name,
                bio: bio,
                photo: photo,
                universitas: universitas,
                programStudi: programStudi,
                role: role,
                isActive: isActive,
                isMe: isMe,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                Value<String> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String> photo = const Value.absent(),
                Value<String> universitas = const Value.absent(),
                Value<String> programStudi = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                email: email,
                username: username,
                name: name,
                bio: bio,
                photo: photo,
                universitas: universitas,
                programStudi: programStudi,
                role: role,
                isActive: isActive,
                isMe: isMe,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, UserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  required String id,
  Value<String> sellerId,
  required String title,
  Value<String> description,
  Value<int> price,
  Value<int> stock,
  Value<String> imageUrls,
  Value<String> category,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> locationLabel,
  Value<String> status,
  Value<int> soldAt,
  Value<int> createdAt,
  Value<int> backendUpdatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  Value<String> id,
  Value<String> sellerId,
  Value<String> title,
  Value<String> description,
  Value<int> price,
  Value<int> stock,
  Value<String> imageUrls,
  Value<String> category,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> locationLabel,
  Value<String> status,
  Value<int> soldAt,
  Value<int> createdAt,
  Value<int> backendUpdatedAt,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellerId => $composableBuilder(
    column: $table.sellerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrls => $composableBuilder(
    column: $table.imageUrls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellerId => $composableBuilder(
    column: $table.sellerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrls => $composableBuilder(
    column: $table.imageUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sellerId =>
      $composableBuilder(column: $table.sellerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get imageUrls =>
      $composableBuilder(column: $table.imageUrls, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => column,
  );
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sellerId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String> imageUrls = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> locationLabel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> soldAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                sellerId: sellerId,
                title: title,
                description: description,
                price: price,
                stock: stock,
                imageUrls: imageUrls,
                category: category,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                status: status,
                soldAt: soldAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                Value<String> sellerId = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String> imageUrls = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> locationLabel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> soldAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                sellerId: sellerId,
                title: title,
                description: description,
                price: price,
                stock: stock,
                imageUrls: imageUrls,
                category: category,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                status: status,
                soldAt: soldAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String productId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> productId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                productId: productId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                productId: productId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      required String id,
      Value<String> productId,
      Value<String> buyerId,
      Value<String> sellerId,
      Value<double> agreedLatitude,
      Value<double> agreedLongitude,
      Value<String> agreedLocationLabel,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      Value<String> id,
      Value<String> productId,
      Value<String> buyerId,
      Value<String> sellerId,
      Value<double> agreedLatitude,
      Value<double> agreedLongitude,
      Value<String> agreedLocationLabel,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyerId => $composableBuilder(
    column: $table.buyerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellerId => $composableBuilder(
    column: $table.sellerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get agreedLatitude => $composableBuilder(
    column: $table.agreedLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get agreedLongitude => $composableBuilder(
    column: $table.agreedLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agreedLocationLabel => $composableBuilder(
    column: $table.agreedLocationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyerId => $composableBuilder(
    column: $table.buyerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellerId => $composableBuilder(
    column: $table.sellerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get agreedLatitude => $composableBuilder(
    column: $table.agreedLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get agreedLongitude => $composableBuilder(
    column: $table.agreedLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agreedLocationLabel => $composableBuilder(
    column: $table.agreedLocationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get buyerId =>
      $composableBuilder(column: $table.buyerId, builder: (column) => column);

  GeneratedColumn<String> get sellerId =>
      $composableBuilder(column: $table.sellerId, builder: (column) => column);

  GeneratedColumn<double> get agreedLatitude => $composableBuilder(
    column: $table.agreedLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get agreedLongitude => $composableBuilder(
    column: $table.agreedLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agreedLocationLabel => $composableBuilder(
    column: $table.agreedLocationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => column,
  );
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          ConversationRow,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            ConversationRow,
            BaseReferences<_$AppDatabase, $ConversationsTable, ConversationRow>,
          ),
          ConversationRow,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> buyerId = const Value.absent(),
                Value<String> sellerId = const Value.absent(),
                Value<double> agreedLatitude = const Value.absent(),
                Value<double> agreedLongitude = const Value.absent(),
                Value<String> agreedLocationLabel = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                productId: productId,
                buyerId: buyerId,
                sellerId: sellerId,
                agreedLatitude: agreedLatitude,
                agreedLongitude: agreedLongitude,
                agreedLocationLabel: agreedLocationLabel,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                Value<String> productId = const Value.absent(),
                Value<String> buyerId = const Value.absent(),
                Value<String> sellerId = const Value.absent(),
                Value<double> agreedLatitude = const Value.absent(),
                Value<double> agreedLongitude = const Value.absent(),
                Value<String> agreedLocationLabel = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                productId: productId,
                buyerId: buyerId,
                sellerId: sellerId,
                agreedLatitude: agreedLatitude,
                agreedLongitude: agreedLongitude,
                agreedLocationLabel: agreedLocationLabel,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConversationsTable, ConversationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConversationsTable,
                    ConversationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      ConversationRow,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        ConversationRow,
        BaseReferences<_$AppDatabase, $ConversationsTable, ConversationRow>,
      ),
      ConversationRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  required String id,
  required String conversationId,
  Value<String> senderId,
  Value<String> type,
  Value<String> body,
  Value<String> imageUrl,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> locationLabel,
  Value<bool> isRead,
  Value<int> readAt,
  Value<int> createdAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  Value<String> id,
  Value<String> conversationId,
  Value<String> senderId,
  Value<String> type,
  Value<String> body,
  Value<String> imageUrl,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> locationLabel,
  Value<bool> isRead,
  Value<int> readAt,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> locationLabel = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> readAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                type: type,
                body: body,
                imageUrl: imageUrl,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                isRead: isRead,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                required String conversationId,
                Value<String> senderId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> locationLabel = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> readAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                type: type,
                body: body,
                imageUrl: imageUrl,
                latitude: latitude,
                longitude: longitude,
                locationLabel: locationLabel,
                isRead: isRead,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$HelpTopicsTableCreateCompanionBuilder = HelpTopicsCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  required String id,
  required String title,
  required String answer,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$HelpTopicsTableUpdateCompanionBuilder = HelpTopicsCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  Value<String> id,
  Value<String> title,
  Value<String> answer,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$HelpTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $HelpTopicsTable> {
  $$HelpTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HelpTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $HelpTopicsTable> {
  $$HelpTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HelpTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HelpTopicsTable> {
  $$HelpTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$HelpTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HelpTopicsTable,
          HelpTopicRow,
          $$HelpTopicsTableFilterComposer,
          $$HelpTopicsTableOrderingComposer,
          $$HelpTopicsTableAnnotationComposer,
          $$HelpTopicsTableCreateCompanionBuilder,
          $$HelpTopicsTableUpdateCompanionBuilder,
          (
            HelpTopicRow,
            BaseReferences<_$AppDatabase, $HelpTopicsTable, HelpTopicRow>,
          ),
          HelpTopicRow,
          PrefetchHooks Function()
        > {
  $$HelpTopicsTableTableManager(_$AppDatabase db, $HelpTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HelpTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HelpTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HelpTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HelpTopicsCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                title: title,
                answer: answer,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                required String title,
                required String answer,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HelpTopicsCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                title: title,
                answer: answer,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HelpTopicsTable, HelpTopicRow>(table),
                  BaseReferences<_$AppDatabase, $HelpTopicsTable, HelpTopicRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HelpTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HelpTopicsTable,
      HelpTopicRow,
      $$HelpTopicsTableFilterComposer,
      $$HelpTopicsTableOrderingComposer,
      $$HelpTopicsTableAnnotationComposer,
      $$HelpTopicsTableCreateCompanionBuilder,
      $$HelpTopicsTableUpdateCompanionBuilder,
      (
        HelpTopicRow,
        BaseReferences<_$AppDatabase, $HelpTopicsTable, HelpTopicRow>,
      ),
      HelpTopicRow,
      PrefetchHooks Function()
    >;
typedef $$SupportTicketsTableCreateCompanionBuilder =
    SupportTicketsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      required String id,
      Value<String> ticketNo,
      Value<String> userId,
      Value<String> category,
      Value<String> status,
      Value<String> subject,
      Value<String> description,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });
typedef $$SupportTicketsTableUpdateCompanionBuilder =
    SupportTicketsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      Value<String> id,
      Value<String> ticketNo,
      Value<String> userId,
      Value<String> category,
      Value<String> status,
      Value<String> subject,
      Value<String> description,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });

class $$SupportTicketsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportTicketsTable> {
  $$SupportTicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketNo => $composableBuilder(
    column: $table.ticketNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupportTicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportTicketsTable> {
  $$SupportTicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketNo => $composableBuilder(
    column: $table.ticketNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupportTicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportTicketsTable> {
  $$SupportTicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ticketNo =>
      $composableBuilder(column: $table.ticketNo, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => column,
  );
}

class $$SupportTicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportTicketsTable,
          SupportTicketRow,
          $$SupportTicketsTableFilterComposer,
          $$SupportTicketsTableOrderingComposer,
          $$SupportTicketsTableAnnotationComposer,
          $$SupportTicketsTableCreateCompanionBuilder,
          $$SupportTicketsTableUpdateCompanionBuilder,
          (
            SupportTicketRow,
            BaseReferences<
              _$AppDatabase,
              $SupportTicketsTable,
              SupportTicketRow
            >,
          ),
          SupportTicketRow,
          PrefetchHooks Function()
        > {
  $$SupportTicketsTableTableManager(
    _$AppDatabase db,
    $SupportTicketsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportTicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupportTicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupportTicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ticketNo = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupportTicketsCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                ticketNo: ticketNo,
                userId: userId,
                category: category,
                status: status,
                subject: subject,
                description: description,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                Value<String> ticketNo = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupportTicketsCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                ticketNo: ticketNo,
                userId: userId,
                category: category,
                status: status,
                subject: subject,
                description: description,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupportTicketsTable, SupportTicketRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SupportTicketsTable,
                    SupportTicketRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupportTicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportTicketsTable,
      SupportTicketRow,
      $$SupportTicketsTableFilterComposer,
      $$SupportTicketsTableOrderingComposer,
      $$SupportTicketsTableAnnotationComposer,
      $$SupportTicketsTableCreateCompanionBuilder,
      $$SupportTicketsTableUpdateCompanionBuilder,
      (
        SupportTicketRow,
        BaseReferences<_$AppDatabase, $SupportTicketsTable, SupportTicketRow>,
      ),
      SupportTicketRow,
      PrefetchHooks Function()
    >;
typedef $$SupportMessagesTableCreateCompanionBuilder =
    SupportMessagesCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      required String id,
      required String ticketId,
      Value<String> senderId,
      Value<String> senderRole,
      Value<String> senderName,
      Value<String> body,
      Value<String> imageUrl,
      Value<bool> isInternal,
      Value<bool> isRead,
      Value<int> readAt,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$SupportMessagesTableUpdateCompanionBuilder =
    SupportMessagesCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      Value<String> id,
      Value<String> ticketId,
      Value<String> senderId,
      Value<String> senderRole,
      Value<String> senderName,
      Value<String> body,
      Value<String> imageUrl,
      Value<bool> isInternal,
      Value<bool> isRead,
      Value<int> readAt,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SupportMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $SupportMessagesTable> {
  $$SupportMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInternal => $composableBuilder(
    column: $table.isInternal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupportMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportMessagesTable> {
  $$SupportMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInternal => $composableBuilder(
    column: $table.isInternal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupportMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportMessagesTable> {
  $$SupportMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ticketId =>
      $composableBuilder(column: $table.ticketId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isInternal => $composableBuilder(
    column: $table.isInternal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupportMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportMessagesTable,
          SupportMessageRow,
          $$SupportMessagesTableFilterComposer,
          $$SupportMessagesTableOrderingComposer,
          $$SupportMessagesTableAnnotationComposer,
          $$SupportMessagesTableCreateCompanionBuilder,
          $$SupportMessagesTableUpdateCompanionBuilder,
          (
            SupportMessageRow,
            BaseReferences<
              _$AppDatabase,
              $SupportMessagesTable,
              SupportMessageRow
            >,
          ),
          SupportMessageRow,
          PrefetchHooks Function()
        > {
  $$SupportMessagesTableTableManager(
    _$AppDatabase db,
    $SupportMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupportMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupportMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ticketId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderRole = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> isInternal = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> readAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupportMessagesCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                ticketId: ticketId,
                senderId: senderId,
                senderRole: senderRole,
                senderName: senderName,
                body: body,
                imageUrl: imageUrl,
                isInternal: isInternal,
                isRead: isRead,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                required String ticketId,
                Value<String> senderId = const Value.absent(),
                Value<String> senderRole = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> isInternal = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> readAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupportMessagesCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                ticketId: ticketId,
                senderId: senderId,
                senderRole: senderRole,
                senderName: senderName,
                body: body,
                imageUrl: imageUrl,
                isInternal: isInternal,
                isRead: isRead,
                readAt: readAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupportMessagesTable, SupportMessageRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SupportMessagesTable,
                    SupportMessageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupportMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportMessagesTable,
      SupportMessageRow,
      $$SupportMessagesTableFilterComposer,
      $$SupportMessagesTableOrderingComposer,
      $$SupportMessagesTableAnnotationComposer,
      $$SupportMessagesTableCreateCompanionBuilder,
      $$SupportMessagesTableUpdateCompanionBuilder,
      (
        SupportMessageRow,
        BaseReferences<_$AppDatabase, $SupportMessagesTable, SupportMessageRow>,
      ),
      SupportMessageRow,
      PrefetchHooks Function()
    >;
typedef $$AiConversationsTableCreateCompanionBuilder =
    AiConversationsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      required String id,
      Value<String> userId,
      Value<String> title,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });
typedef $$AiConversationsTableUpdateCompanionBuilder =
    AiConversationsCompanion Function({
      Value<int> updatedAt,
      Value<int> lastFetched,
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<int> lastMessageAt,
      Value<int> createdAt,
      Value<int> backendUpdatedAt,
      Value<int> rowid,
    });

class $$AiConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get backendUpdatedAt => $composableBuilder(
    column: $table.backendUpdatedAt,
    builder: (column) => column,
  );
}

class $$AiConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiConversationsTable,
          AiConversationRow,
          $$AiConversationsTableFilterComposer,
          $$AiConversationsTableOrderingComposer,
          $$AiConversationsTableAnnotationComposer,
          $$AiConversationsTableCreateCompanionBuilder,
          $$AiConversationsTableUpdateCompanionBuilder,
          (
            AiConversationRow,
            BaseReferences<
              _$AppDatabase,
              $AiConversationsTable,
              AiConversationRow
            >,
          ),
          AiConversationRow,
          PrefetchHooks Function()
        > {
  $$AiConversationsTableTableManager(
    _$AppDatabase db,
    $AiConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiConversationsCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                userId: userId,
                title: title,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> lastMessageAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> backendUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiConversationsCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                userId: userId,
                title: title,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                backendUpdatedAt: backendUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiConversationsTable, AiConversationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiConversationsTable,
                    AiConversationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiConversationsTable,
      AiConversationRow,
      $$AiConversationsTableFilterComposer,
      $$AiConversationsTableOrderingComposer,
      $$AiConversationsTableAnnotationComposer,
      $$AiConversationsTableCreateCompanionBuilder,
      $$AiConversationsTableUpdateCompanionBuilder,
      (
        AiConversationRow,
        BaseReferences<_$AppDatabase, $AiConversationsTable, AiConversationRow>,
      ),
      AiConversationRow,
      PrefetchHooks Function()
    >;
typedef $$AiMessagesTableCreateCompanionBuilder = AiMessagesCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  required String id,
  required String conversationId,
  Value<String> role,
  Value<String> content,
  Value<String> model,
  Value<int> createdAt,
  Value<int> rowid,
});
typedef $$AiMessagesTableUpdateCompanionBuilder = AiMessagesCompanion Function({
  Value<int> updatedAt,
  Value<int> lastFetched,
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<String> model,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$AiMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiMessagesTable,
          AiMessageRow,
          $$AiMessagesTableFilterComposer,
          $$AiMessagesTableOrderingComposer,
          $$AiMessagesTableAnnotationComposer,
          $$AiMessagesTableCreateCompanionBuilder,
          $$AiMessagesTableUpdateCompanionBuilder,
          (
            AiMessageRow,
            BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessageRow>,
          ),
          AiMessageRow,
          PrefetchHooks Function()
        > {
  $$AiMessagesTableTableManager(_$AppDatabase db, $AiMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiMessagesCompanion(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                model: model,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> updatedAt = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                required String id,
                required String conversationId,
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiMessagesCompanion.insert(
                updatedAt: updatedAt,
                lastFetched: lastFetched,
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                model: model,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiMessagesTable, AiMessageRow>(table),
                  BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessageRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiMessagesTable,
      AiMessageRow,
      $$AiMessagesTableFilterComposer,
      $$AiMessagesTableOrderingComposer,
      $$AiMessagesTableAnnotationComposer,
      $$AiMessagesTableCreateCompanionBuilder,
      $$AiMessagesTableUpdateCompanionBuilder,
      (
        AiMessageRow,
        BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessageRow>,
      ),
      AiMessageRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$HelpTopicsTableTableManager get helpTopics =>
      $$HelpTopicsTableTableManager(_db, _db.helpTopics);
  $$SupportTicketsTableTableManager get supportTickets =>
      $$SupportTicketsTableTableManager(_db, _db.supportTickets);
  $$SupportMessagesTableTableManager get supportMessages =>
      $$SupportMessagesTableTableManager(_db, _db.supportMessages);
  $$AiConversationsTableTableManager get aiConversations =>
      $$AiConversationsTableTableManager(_db, _db.aiConversations);
  $$AiMessagesTableTableManager get aiMessages =>
      $$AiMessagesTableTableManager(_db, _db.aiMessages);
}
