// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HarnessRecordsTable extends HarnessRecords
    with TableInfo<$HarnessRecordsTable, HarnessRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarnessRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nutrientValueMeta = const VerificationMeta(
    'nutrientValue',
  );
  @override
  late final GeneratedColumn<double> nutrientValue = GeneratedColumn<double>(
    'nutrient_value',
    aliasedName,
    true,
    check: () => ComparableExpr(nutrientValue).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    label,
    amount,
    nutrientValue,
    localDate,
    timeZoneId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harness_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HarnessRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('nutrient_value')) {
      context.handle(
        _nutrientValueMeta,
        nutrientValue.isAcceptableOrUnknown(
          data['nutrient_value']!,
          _nutrientValueMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeZoneIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HarnessRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HarnessRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      nutrientValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nutrient_value'],
      ),
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      )!,
    );
  }

  @override
  $HarnessRecordsTable createAlias(String alias) {
    return $HarnessRecordsTable(attachedDatabase, alias);
  }
}

class HarnessRecord extends DataClass implements Insertable<HarnessRecord> {
  /// Pengenal unik global yang dibuat aplikasi, bukan nomor urut basis data.
  final String id;

  /// Waktu pembuatan (UTC). Tidak pernah berubah setelah record dibuat.
  final DateTime createdAt;

  /// Waktu pembaruan terakhir (UTC).
  final DateTime updatedAt;

  /// Penanda terhapus (UTC). `null` berarti record aktif.
  final DateTime? deletedAt;

  /// Keadaan sinkronisasi. Selalu [kSyncStatusLocal] di MVP 1.
  final String syncStatus;

  /// Nomor revisi; bertambah satu setiap kali record berubah.
  final int revision;
  final String label;

  /// Besaran yang harus bernilai positif (mewakili jumlah/berat).
  final double amount;

  /// Nilai gizi. `null` berarti belum diketahui — dibedakan dari nol.
  final double? nutrientValue;

  /// Tanggal lokal (`YYYY-MM-DD`) saat record dicatat, dipakai untuk
  /// pengelompokan harian dan tidak dihitung ulang kemudian.
  final String localDate;

  /// Pengenal zona waktu perangkat saat record dicatat.
  final String timeZoneId;
  const HarnessRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.revision,
    required this.label,
    required this.amount,
    this.nutrientValue,
    required this.localDate,
    required this.timeZoneId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['revision'] = Variable<int>(revision);
    map['label'] = Variable<String>(label);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || nutrientValue != null) {
      map['nutrient_value'] = Variable<double>(nutrientValue);
    }
    map['local_date'] = Variable<String>(localDate);
    map['time_zone_id'] = Variable<String>(timeZoneId);
    return map;
  }

  HarnessRecordsCompanion toCompanion(bool nullToAbsent) {
    return HarnessRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      revision: Value(revision),
      label: Value(label),
      amount: Value(amount),
      nutrientValue: nutrientValue == null && nullToAbsent
          ? const Value.absent()
          : Value(nutrientValue),
      localDate: Value(localDate),
      timeZoneId: Value(timeZoneId),
    );
  }

  factory HarnessRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HarnessRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      revision: serializer.fromJson<int>(json['revision']),
      label: serializer.fromJson<String>(json['label']),
      amount: serializer.fromJson<double>(json['amount']),
      nutrientValue: serializer.fromJson<double?>(json['nutrientValue']),
      localDate: serializer.fromJson<String>(json['localDate']),
      timeZoneId: serializer.fromJson<String>(json['timeZoneId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'revision': serializer.toJson<int>(revision),
      'label': serializer.toJson<String>(label),
      'amount': serializer.toJson<double>(amount),
      'nutrientValue': serializer.toJson<double?>(nutrientValue),
      'localDate': serializer.toJson<String>(localDate),
      'timeZoneId': serializer.toJson<String>(timeZoneId),
    };
  }

  HarnessRecord copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    int? revision,
    String? label,
    double? amount,
    Value<double?> nutrientValue = const Value.absent(),
    String? localDate,
    String? timeZoneId,
  }) => HarnessRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    revision: revision ?? this.revision,
    label: label ?? this.label,
    amount: amount ?? this.amount,
    nutrientValue: nutrientValue.present
        ? nutrientValue.value
        : this.nutrientValue,
    localDate: localDate ?? this.localDate,
    timeZoneId: timeZoneId ?? this.timeZoneId,
  );
  HarnessRecord copyWithCompanion(HarnessRecordsCompanion data) {
    return HarnessRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      revision: data.revision.present ? data.revision.value : this.revision,
      label: data.label.present ? data.label.value : this.label,
      amount: data.amount.present ? data.amount.value : this.amount,
      nutrientValue: data.nutrientValue.present
          ? data.nutrientValue.value
          : this.nutrientValue,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HarnessRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('nutrientValue: $nutrientValue, ')
          ..write('localDate: $localDate, ')
          ..write('timeZoneId: $timeZoneId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    label,
    amount,
    nutrientValue,
    localDate,
    timeZoneId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HarnessRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.revision == this.revision &&
          other.label == this.label &&
          other.amount == this.amount &&
          other.nutrientValue == this.nutrientValue &&
          other.localDate == this.localDate &&
          other.timeZoneId == this.timeZoneId);
}

class HarnessRecordsCompanion extends UpdateCompanion<HarnessRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> revision;
  final Value<String> label;
  final Value<double> amount;
  final Value<double?> nutrientValue;
  final Value<String> localDate;
  final Value<String> timeZoneId;
  final Value<int> rowid;
  const HarnessRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    this.label = const Value.absent(),
    this.amount = const Value.absent(),
    this.nutrientValue = const Value.absent(),
    this.localDate = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HarnessRecordsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    required String label,
    required double amount,
    this.nutrientValue = const Value.absent(),
    required String localDate,
    required String timeZoneId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       label = Value(label),
       amount = Value(amount),
       localDate = Value(localDate),
       timeZoneId = Value(timeZoneId);
  static Insertable<HarnessRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? revision,
    Expression<String>? label,
    Expression<double>? amount,
    Expression<double>? nutrientValue,
    Expression<String>? localDate,
    Expression<String>? timeZoneId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (revision != null) 'revision': revision,
      if (label != null) 'label': label,
      if (amount != null) 'amount': amount,
      if (nutrientValue != null) 'nutrient_value': nutrientValue,
      if (localDate != null) 'local_date': localDate,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HarnessRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? revision,
    Value<String>? label,
    Value<double>? amount,
    Value<double?>? nutrientValue,
    Value<String>? localDate,
    Value<String>? timeZoneId,
    Value<int>? rowid,
  }) {
    return HarnessRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      nutrientValue: nutrientValue ?? this.nutrientValue,
      localDate: localDate ?? this.localDate,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (nutrientValue.present) {
      map['nutrient_value'] = Variable<double>(nutrientValue.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HarnessRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('nutrientValue: $nutrientValue, ')
          ..write('localDate: $localDate, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HarnessRecordNotesTable extends HarnessRecordNotes
    with TableInfo<$HarnessRecordNotesTable, HarnessRecordNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarnessRecordNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES harness_records (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 280,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    recordId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harness_record_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HarnessRecordNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HarnessRecordNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HarnessRecordNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $HarnessRecordNotesTable createAlias(String alias) {
    return $HarnessRecordNotesTable(attachedDatabase, alias);
  }
}

class HarnessRecordNote extends DataClass
    implements Insertable<HarnessRecordNote> {
  /// Pengenal unik global yang dibuat aplikasi, bukan nomor urut basis data.
  final String id;

  /// Waktu pembuatan (UTC). Tidak pernah berubah setelah record dibuat.
  final DateTime createdAt;

  /// Waktu pembaruan terakhir (UTC).
  final DateTime updatedAt;

  /// Penanda terhapus (UTC). `null` berarti record aktif.
  final DateTime? deletedAt;

  /// Keadaan sinkronisasi. Selalu [kSyncStatusLocal] di MVP 1.
  final String syncStatus;

  /// Nomor revisi; bertambah satu setiap kali record berubah.
  final int revision;
  final String recordId;
  final String note;
  const HarnessRecordNote({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.revision,
    required this.recordId,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['revision'] = Variable<int>(revision);
    map['record_id'] = Variable<String>(recordId);
    map['note'] = Variable<String>(note);
    return map;
  }

  HarnessRecordNotesCompanion toCompanion(bool nullToAbsent) {
    return HarnessRecordNotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      revision: Value(revision),
      recordId: Value(recordId),
      note: Value(note),
    );
  }

  factory HarnessRecordNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HarnessRecordNote(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      revision: serializer.fromJson<int>(json['revision']),
      recordId: serializer.fromJson<String>(json['recordId']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'revision': serializer.toJson<int>(revision),
      'recordId': serializer.toJson<String>(recordId),
      'note': serializer.toJson<String>(note),
    };
  }

  HarnessRecordNote copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    int? revision,
    String? recordId,
    String? note,
  }) => HarnessRecordNote(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    revision: revision ?? this.revision,
    recordId: recordId ?? this.recordId,
    note: note ?? this.note,
  );
  HarnessRecordNote copyWithCompanion(HarnessRecordNotesCompanion data) {
    return HarnessRecordNote(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      revision: data.revision.present ? data.revision.value : this.revision,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HarnessRecordNote(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('recordId: $recordId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    recordId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HarnessRecordNote &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.revision == this.revision &&
          other.recordId == this.recordId &&
          other.note == this.note);
}

class HarnessRecordNotesCompanion extends UpdateCompanion<HarnessRecordNote> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> revision;
  final Value<String> recordId;
  final Value<String> note;
  final Value<int> rowid;
  const HarnessRecordNotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    this.recordId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HarnessRecordNotesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    required String recordId,
    required String note,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       recordId = Value(recordId),
       note = Value(note);
  static Insertable<HarnessRecordNote> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? revision,
    Expression<String>? recordId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (revision != null) 'revision': revision,
      if (recordId != null) 'record_id': recordId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HarnessRecordNotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? revision,
    Value<String>? recordId,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return HarnessRecordNotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      recordId: recordId ?? this.recordId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HarnessRecordNotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('recordId: $recordId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UiPreferencesTable extends UiPreferences
    with TableInfo<$UiPreferencesTable, UiPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UiPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 256,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ui_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UiPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UiPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UiPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UiPreferencesTable createAlias(String alias) {
    return $UiPreferencesTable(attachedDatabase, alias);
  }
}

class UiPreference extends DataClass implements Insertable<UiPreference> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UiPreference({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UiPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UiPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UiPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UiPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UiPreference copyWith({String? key, String? value, DateTime? updatedAt}) =>
      UiPreference(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UiPreference copyWithCompanion(UiPreferencesCompanion data) {
    return UiPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UiPreference(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiPreference &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UiPreferencesCompanion extends UpdateCompanion<UiPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UiPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UiPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<UiPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UiPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UiPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UiPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HarnessRecordsTable harnessRecords = $HarnessRecordsTable(this);
  late final $HarnessRecordNotesTable harnessRecordNotes =
      $HarnessRecordNotesTable(this);
  late final $UiPreferencesTable uiPreferences = $UiPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    harnessRecords,
    harnessRecordNotes,
    uiPreferences,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HarnessRecordsTableCreateCompanionBuilder =
    HarnessRecordsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      required String label,
      required double amount,
      Value<double?> nutrientValue,
      required String localDate,
      required String timeZoneId,
      Value<int> rowid,
    });
typedef $$HarnessRecordsTableUpdateCompanionBuilder =
    HarnessRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      Value<String> label,
      Value<double> amount,
      Value<double?> nutrientValue,
      Value<String> localDate,
      Value<String> timeZoneId,
      Value<int> rowid,
    });

final class $$HarnessRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $HarnessRecordsTable, HarnessRecord> {
  $$HarnessRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HarnessRecordNotesTable, List<HarnessRecordNote>>
  _harnessRecordNotesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.harnessRecordNotes,
        aliasName: 'harness_records__id__harness_record_notes__record_id',
      );

  $$HarnessRecordNotesTableProcessedTableManager get harnessRecordNotesRefs {
    final manager = $$HarnessRecordNotesTableTableManager(
      $_db,
      $_db.harnessRecordNotes,
    ).filter((f) => f.recordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _harnessRecordNotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HarnessRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HarnessRecordsTable> {
  $$HarnessRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nutrientValue => $composableBuilder(
    column: $table.nutrientValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> harnessRecordNotesRefs(
    Expression<bool> Function($$HarnessRecordNotesTableFilterComposer f) f,
  ) {
    final $$HarnessRecordNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.harnessRecordNotes,
      getReferencedColumn: (t) => t.recordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarnessRecordNotesTableFilterComposer(
            $db: $db,
            $table: $db.harnessRecordNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HarnessRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HarnessRecordsTable> {
  $$HarnessRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nutrientValue => $composableBuilder(
    column: $table.nutrientValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HarnessRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarnessRecordsTable> {
  $$HarnessRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get nutrientValue => $composableBuilder(
    column: $table.nutrientValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  Expression<T> harnessRecordNotesRefs<T extends Object>(
    Expression<T> Function($$HarnessRecordNotesTableAnnotationComposer a) f,
  ) {
    final $$HarnessRecordNotesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.harnessRecordNotes,
          getReferencedColumn: (t) => t.recordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HarnessRecordNotesTableAnnotationComposer(
                $db: $db,
                $table: $db.harnessRecordNotes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HarnessRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HarnessRecordsTable,
          HarnessRecord,
          $$HarnessRecordsTableFilterComposer,
          $$HarnessRecordsTableOrderingComposer,
          $$HarnessRecordsTableAnnotationComposer,
          $$HarnessRecordsTableCreateCompanionBuilder,
          $$HarnessRecordsTableUpdateCompanionBuilder,
          (HarnessRecord, $$HarnessRecordsTableReferences),
          HarnessRecord,
          PrefetchHooks Function({bool harnessRecordNotesRefs})
        > {
  $$HarnessRecordsTableTableManager(
    _$AppDatabase db,
    $HarnessRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarnessRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarnessRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarnessRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double?> nutrientValue = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HarnessRecordsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                label: label,
                amount: amount,
                nutrientValue: nutrientValue,
                localDate: localDate,
                timeZoneId: timeZoneId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                required String label,
                required double amount,
                Value<double?> nutrientValue = const Value.absent(),
                required String localDate,
                required String timeZoneId,
                Value<int> rowid = const Value.absent(),
              }) => HarnessRecordsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                label: label,
                amount: amount,
                nutrientValue: nutrientValue,
                localDate: localDate,
                timeZoneId: timeZoneId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HarnessRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({harnessRecordNotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (harnessRecordNotesRefs) db.harnessRecordNotes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (harnessRecordNotesRefs)
                    await $_getPrefetchedData<
                      HarnessRecord,
                      $HarnessRecordsTable,
                      HarnessRecordNote
                    >(
                      currentTable: table,
                      referencedTable: $$HarnessRecordsTableReferences
                          ._harnessRecordNotesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HarnessRecordsTableReferences(
                            db,
                            table,
                            p0,
                          ).harnessRecordNotesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.recordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HarnessRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HarnessRecordsTable,
      HarnessRecord,
      $$HarnessRecordsTableFilterComposer,
      $$HarnessRecordsTableOrderingComposer,
      $$HarnessRecordsTableAnnotationComposer,
      $$HarnessRecordsTableCreateCompanionBuilder,
      $$HarnessRecordsTableUpdateCompanionBuilder,
      (HarnessRecord, $$HarnessRecordsTableReferences),
      HarnessRecord,
      PrefetchHooks Function({bool harnessRecordNotesRefs})
    >;
typedef $$HarnessRecordNotesTableCreateCompanionBuilder =
    HarnessRecordNotesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      required String recordId,
      required String note,
      Value<int> rowid,
    });
typedef $$HarnessRecordNotesTableUpdateCompanionBuilder =
    HarnessRecordNotesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      Value<String> recordId,
      Value<String> note,
      Value<int> rowid,
    });

final class $$HarnessRecordNotesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HarnessRecordNotesTable,
          HarnessRecordNote
        > {
  $$HarnessRecordNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HarnessRecordsTable _recordIdTable(_$AppDatabase db) => db
      .harnessRecords
      .createAlias('harness_record_notes__record_id__harness_records__id');

  $$HarnessRecordsTableProcessedTableManager get recordId {
    final $_column = $_itemColumn<String>('record_id')!;

    final manager = $$HarnessRecordsTableTableManager(
      $_db,
      $_db.harnessRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HarnessRecordNotesTableFilterComposer
    extends Composer<_$AppDatabase, $HarnessRecordNotesTable> {
  $$HarnessRecordNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$HarnessRecordsTableFilterComposer get recordId {
    final $$HarnessRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.harnessRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarnessRecordsTableFilterComposer(
            $db: $db,
            $table: $db.harnessRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HarnessRecordNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $HarnessRecordNotesTable> {
  $$HarnessRecordNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$HarnessRecordsTableOrderingComposer get recordId {
    final $$HarnessRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.harnessRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarnessRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.harnessRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HarnessRecordNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarnessRecordNotesTable> {
  $$HarnessRecordNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HarnessRecordsTableAnnotationComposer get recordId {
    final $$HarnessRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.harnessRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarnessRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.harnessRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HarnessRecordNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HarnessRecordNotesTable,
          HarnessRecordNote,
          $$HarnessRecordNotesTableFilterComposer,
          $$HarnessRecordNotesTableOrderingComposer,
          $$HarnessRecordNotesTableAnnotationComposer,
          $$HarnessRecordNotesTableCreateCompanionBuilder,
          $$HarnessRecordNotesTableUpdateCompanionBuilder,
          (HarnessRecordNote, $$HarnessRecordNotesTableReferences),
          HarnessRecordNote,
          PrefetchHooks Function({bool recordId})
        > {
  $$HarnessRecordNotesTableTableManager(
    _$AppDatabase db,
    $HarnessRecordNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarnessRecordNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarnessRecordNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarnessRecordNotesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HarnessRecordNotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                recordId: recordId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                required String recordId,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) => HarnessRecordNotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                recordId: recordId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HarnessRecordNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recordId,
                                referencedTable:
                                    $$HarnessRecordNotesTableReferences
                                        ._recordIdTable(db),
                                referencedColumn:
                                    $$HarnessRecordNotesTableReferences
                                        ._recordIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HarnessRecordNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HarnessRecordNotesTable,
      HarnessRecordNote,
      $$HarnessRecordNotesTableFilterComposer,
      $$HarnessRecordNotesTableOrderingComposer,
      $$HarnessRecordNotesTableAnnotationComposer,
      $$HarnessRecordNotesTableCreateCompanionBuilder,
      $$HarnessRecordNotesTableUpdateCompanionBuilder,
      (HarnessRecordNote, $$HarnessRecordNotesTableReferences),
      HarnessRecordNote,
      PrefetchHooks Function({bool recordId})
    >;
typedef $$UiPreferencesTableCreateCompanionBuilder =
    UiPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UiPreferencesTableUpdateCompanionBuilder =
    UiPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UiPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UiPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UiPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UiPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UiPreferencesTable,
          UiPreference,
          $$UiPreferencesTableFilterComposer,
          $$UiPreferencesTableOrderingComposer,
          $$UiPreferencesTableAnnotationComposer,
          $$UiPreferencesTableCreateCompanionBuilder,
          $$UiPreferencesTableUpdateCompanionBuilder,
          (
            UiPreference,
            BaseReferences<_$AppDatabase, $UiPreferencesTable, UiPreference>,
          ),
          UiPreference,
          PrefetchHooks Function()
        > {
  $$UiPreferencesTableTableManager(_$AppDatabase db, $UiPreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UiPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UiPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UiPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UiPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UiPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UiPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UiPreferencesTable,
      UiPreference,
      $$UiPreferencesTableFilterComposer,
      $$UiPreferencesTableOrderingComposer,
      $$UiPreferencesTableAnnotationComposer,
      $$UiPreferencesTableCreateCompanionBuilder,
      $$UiPreferencesTableUpdateCompanionBuilder,
      (
        UiPreference,
        BaseReferences<_$AppDatabase, $UiPreferencesTable, UiPreference>,
      ),
      UiPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HarnessRecordsTableTableManager get harnessRecords =>
      $$HarnessRecordsTableTableManager(_db, _db.harnessRecords);
  $$HarnessRecordNotesTableTableManager get harnessRecordNotes =>
      $$HarnessRecordNotesTableTableManager(_db, _db.harnessRecordNotes);
  $$UiPreferencesTableTableManager get uiPreferences =>
      $$UiPreferencesTableTableManager(_db, _db.uiPreferences);
}
