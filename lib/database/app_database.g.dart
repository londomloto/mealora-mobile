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

class $ProgramsTable extends Programs with TableInfo<$ProgramsTable, Program> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiresWeightTargetMeta =
      const VerificationMeta('requiresWeightTarget');
  @override
  late final GeneratedColumn<bool> requiresWeightTarget = GeneratedColumn<bool>(
    'requires_weight_target',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_weight_target" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionVersionMeta = const VerificationMeta(
    'definitionVersion',
  );
  @override
  late final GeneratedColumn<int> definitionVersion = GeneratedColumn<int>(
    'definition_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    description,
    requiresWeightTarget,
    isAvailable,
    sortOrder,
    definitionVersion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Program> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('requires_weight_target')) {
      context.handle(
        _requiresWeightTargetMeta,
        requiresWeightTarget.isAcceptableOrUnknown(
          data['requires_weight_target']!,
          _requiresWeightTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requiresWeightTargetMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('definition_version')) {
      context.handle(
        _definitionVersionMeta,
        definitionVersion.isAcceptableOrUnknown(
          data['definition_version']!,
          _definitionVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionVersionMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Program map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Program(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      requiresWeightTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_weight_target'],
      )!,
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      definitionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}definition_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgramsTable createAlias(String alias) {
    return $ProgramsTable(attachedDatabase, alias);
  }
}

class Program extends DataClass implements Insertable<Program> {
  final String id;

  /// Kode mesin stabil (mis. `weight_loss`) — lihat `ProgramCode.stableCode`
  /// di domain.
  final String code;
  final String name;
  final String description;
  final bool requiresWeightTarget;
  final bool isAvailable;
  final int sortOrder;
  final int definitionVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Program({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.requiresWeightTarget,
    required this.isAvailable,
    required this.sortOrder,
    required this.definitionVersion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['requires_weight_target'] = Variable<bool>(requiresWeightTarget);
    map['is_available'] = Variable<bool>(isAvailable);
    map['sort_order'] = Variable<int>(sortOrder);
    map['definition_version'] = Variable<int>(definitionVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgramsCompanion toCompanion(bool nullToAbsent) {
    return ProgramsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      description: Value(description),
      requiresWeightTarget: Value(requiresWeightTarget),
      isAvailable: Value(isAvailable),
      sortOrder: Value(sortOrder),
      definitionVersion: Value(definitionVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Program.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Program(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      requiresWeightTarget: serializer.fromJson<bool>(
        json['requiresWeightTarget'],
      ),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      definitionVersion: serializer.fromJson<int>(json['definitionVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'requiresWeightTarget': serializer.toJson<bool>(requiresWeightTarget),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'definitionVersion': serializer.toJson<int>(definitionVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Program copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    bool? requiresWeightTarget,
    bool? isAvailable,
    int? sortOrder,
    int? definitionVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Program(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description ?? this.description,
    requiresWeightTarget: requiresWeightTarget ?? this.requiresWeightTarget,
    isAvailable: isAvailable ?? this.isAvailable,
    sortOrder: sortOrder ?? this.sortOrder,
    definitionVersion: definitionVersion ?? this.definitionVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Program copyWithCompanion(ProgramsCompanion data) {
    return Program(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      requiresWeightTarget: data.requiresWeightTarget.present
          ? data.requiresWeightTarget.value
          : this.requiresWeightTarget,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      definitionVersion: data.definitionVersion.present
          ? data.definitionVersion.value
          : this.definitionVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Program(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('requiresWeightTarget: $requiresWeightTarget, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    description,
    requiresWeightTarget,
    isAvailable,
    sortOrder,
    definitionVersion,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Program &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.requiresWeightTarget == this.requiresWeightTarget &&
          other.isAvailable == this.isAvailable &&
          other.sortOrder == this.sortOrder &&
          other.definitionVersion == this.definitionVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProgramsCompanion extends UpdateCompanion<Program> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> description;
  final Value<bool> requiresWeightTarget;
  final Value<bool> isAvailable;
  final Value<int> sortOrder;
  final Value<int> definitionVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProgramsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.requiresWeightTarget = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String description,
    required bool requiresWeightTarget,
    this.isAvailable = const Value.absent(),
    required int sortOrder,
    required int definitionVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       description = Value(description),
       requiresWeightTarget = Value(requiresWeightTarget),
       sortOrder = Value(sortOrder),
       definitionVersion = Value(definitionVersion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Program> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? requiresWeightTarget,
    Expression<bool>? isAvailable,
    Expression<int>? sortOrder,
    Expression<int>? definitionVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (requiresWeightTarget != null)
        'requires_weight_target': requiresWeightTarget,
      if (isAvailable != null) 'is_available': isAvailable,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (definitionVersion != null) 'definition_version': definitionVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? description,
    Value<bool>? requiresWeightTarget,
    Value<bool>? isAvailable,
    Value<int>? sortOrder,
    Value<int>? definitionVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProgramsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      requiresWeightTarget: requiresWeightTarget ?? this.requiresWeightTarget,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      definitionVersion: definitionVersion ?? this.definitionVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (requiresWeightTarget.present) {
      map['requires_weight_target'] = Variable<bool>(
        requiresWeightTarget.value,
      );
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (definitionVersion.present) {
      map['definition_version'] = Variable<int>(definitionVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ProgramsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('requiresWeightTarget: $requiresWeightTarget, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProgramsTable extends UserPrograms
    with TableInfo<$UserProgramsTable, UserProgramRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgramsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(kUserProgramStatuses),
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselineWeightKgMeta = const VerificationMeta(
    'baselineWeightKg',
  );
  @override
  late final GeneratedColumn<double> baselineWeightKg = GeneratedColumn<double>(
    'baseline_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyEnergyTargetKcalMeta =
      const VerificationMeta('dailyEnergyTargetKcal');
  @override
  late final GeneratedColumn<double> dailyEnergyTargetKcal =
      GeneratedColumn<double>(
        'daily_energy_target_kcal',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _proteinTargetGMeta = const VerificationMeta(
    'proteinTargetG',
  );
  @override
  late final GeneratedColumn<double> proteinTargetG = GeneratedColumn<double>(
    'protein_target_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbohydrateTargetGMeta =
      const VerificationMeta('carbohydrateTargetG');
  @override
  late final GeneratedColumn<double> carbohydrateTargetG =
      GeneratedColumn<double>(
        'carbohydrate_target_g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatTargetGMeta = const VerificationMeta(
    'fatTargetG',
  );
  @override
  late final GeneratedColumn<double> fatTargetG = GeneratedColumn<double>(
    'fat_target_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberTargetGMeta = const VerificationMeta(
    'fiberTargetG',
  );
  @override
  late final GeneratedColumn<double> fiberTargetG = GeneratedColumn<double>(
    'fiber_target_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputSnapshotJsonMeta = const VerificationMeta(
    'inputSnapshotJson',
  );
  @override
  late final GeneratedColumn<String> inputSnapshotJson =
      GeneratedColumn<String>(
        'input_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calculatorVersionMeta = const VerificationMeta(
    'calculatorVersion',
  );
  @override
  late final GeneratedColumn<String> calculatorVersion =
      GeneratedColumn<String>(
        'calculator_version',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 32,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _policyVersionMeta = const VerificationMeta(
    'policyVersion',
  );
  @override
  late final GeneratedColumn<String> policyVersion = GeneratedColumn<String>(
    'policy_version',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pauseReasonMeta = const VerificationMeta(
    'pauseReason',
  );
  @override
  late final GeneratedColumn<String> pauseReason = GeneratedColumn<String>(
    'pause_reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionReasonMeta = const VerificationMeta(
    'completionReason',
  );
  @override
  late final GeneratedColumn<String> completionReason = GeneratedColumn<String>(
    'completion_reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersedesUserProgramIdMeta =
      const VerificationMeta('supersedesUserProgramId');
  @override
  late final GeneratedColumn<String> supersedesUserProgramId =
      GeneratedColumn<String>(
        'supersedes_user_program_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _supersededByUserProgramIdMeta =
      const VerificationMeta('supersededByUserProgramId');
  @override
  late final GeneratedColumn<String> supersededByUserProgramId =
      GeneratedColumn<String>(
        'superseded_by_user_program_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    profileId,
    programId,
    status,
    startedAt,
    pausedAt,
    endedAt,
    baselineWeightKg,
    targetWeightKg,
    targetDate,
    dailyEnergyTargetKcal,
    proteinTargetG,
    carbohydrateTargetG,
    fatTargetG,
    fiberTargetG,
    inputSnapshotJson,
    calculatorVersion,
    policyVersion,
    pauseReason,
    completionReason,
    supersedesUserProgramId,
    supersededByUserProgramId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgramRow> instance, {
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
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('baseline_weight_kg')) {
      context.handle(
        _baselineWeightKgMeta,
        baselineWeightKg.isAcceptableOrUnknown(
          data['baseline_weight_kg']!,
          _baselineWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('daily_energy_target_kcal')) {
      context.handle(
        _dailyEnergyTargetKcalMeta,
        dailyEnergyTargetKcal.isAcceptableOrUnknown(
          data['daily_energy_target_kcal']!,
          _dailyEnergyTargetKcalMeta,
        ),
      );
    }
    if (data.containsKey('protein_target_g')) {
      context.handle(
        _proteinTargetGMeta,
        proteinTargetG.isAcceptableOrUnknown(
          data['protein_target_g']!,
          _proteinTargetGMeta,
        ),
      );
    }
    if (data.containsKey('carbohydrate_target_g')) {
      context.handle(
        _carbohydrateTargetGMeta,
        carbohydrateTargetG.isAcceptableOrUnknown(
          data['carbohydrate_target_g']!,
          _carbohydrateTargetGMeta,
        ),
      );
    }
    if (data.containsKey('fat_target_g')) {
      context.handle(
        _fatTargetGMeta,
        fatTargetG.isAcceptableOrUnknown(
          data['fat_target_g']!,
          _fatTargetGMeta,
        ),
      );
    }
    if (data.containsKey('fiber_target_g')) {
      context.handle(
        _fiberTargetGMeta,
        fiberTargetG.isAcceptableOrUnknown(
          data['fiber_target_g']!,
          _fiberTargetGMeta,
        ),
      );
    }
    if (data.containsKey('input_snapshot_json')) {
      context.handle(
        _inputSnapshotJsonMeta,
        inputSnapshotJson.isAcceptableOrUnknown(
          data['input_snapshot_json']!,
          _inputSnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputSnapshotJsonMeta);
    }
    if (data.containsKey('calculator_version')) {
      context.handle(
        _calculatorVersionMeta,
        calculatorVersion.isAcceptableOrUnknown(
          data['calculator_version']!,
          _calculatorVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatorVersionMeta);
    }
    if (data.containsKey('policy_version')) {
      context.handle(
        _policyVersionMeta,
        policyVersion.isAcceptableOrUnknown(
          data['policy_version']!,
          _policyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_policyVersionMeta);
    }
    if (data.containsKey('pause_reason')) {
      context.handle(
        _pauseReasonMeta,
        pauseReason.isAcceptableOrUnknown(
          data['pause_reason']!,
          _pauseReasonMeta,
        ),
      );
    }
    if (data.containsKey('completion_reason')) {
      context.handle(
        _completionReasonMeta,
        completionReason.isAcceptableOrUnknown(
          data['completion_reason']!,
          _completionReasonMeta,
        ),
      );
    }
    if (data.containsKey('supersedes_user_program_id')) {
      context.handle(
        _supersedesUserProgramIdMeta,
        supersedesUserProgramId.isAcceptableOrUnknown(
          data['supersedes_user_program_id']!,
          _supersedesUserProgramIdMeta,
        ),
      );
    }
    if (data.containsKey('superseded_by_user_program_id')) {
      context.handle(
        _supersededByUserProgramIdMeta,
        supersededByUserProgramId.isAcceptableOrUnknown(
          data['superseded_by_user_program_id']!,
          _supersededByUserProgramIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgramRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgramRow(
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
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      baselineWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_weight_kg'],
      ),
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      ),
      dailyEnergyTargetKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_energy_target_kcal'],
      ),
      proteinTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_target_g'],
      ),
      carbohydrateTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_target_g'],
      ),
      fatTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_target_g'],
      ),
      fiberTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_target_g'],
      ),
      inputSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_snapshot_json'],
      )!,
      calculatorVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculator_version'],
      )!,
      policyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_version'],
      )!,
      pauseReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pause_reason'],
      ),
      completionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_reason'],
      ),
      supersedesUserProgramId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_user_program_id'],
      ),
      supersededByUserProgramId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superseded_by_user_program_id'],
      ),
    );
  }

  @override
  $UserProgramsTable createAlias(String alias) {
    return $UserProgramsTable(attachedDatabase, alias);
  }
}

class UserProgramRow extends DataClass implements Insertable<UserProgramRow> {
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
  final String profileId;
  final String programId;
  final String status;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? endedAt;
  final double? baselineWeightKg;
  final double? targetWeightKg;

  /// Tanggal tujuan, `YYYY-MM-DD` lokal — selaras dengan `LocalDate.iso`.
  final String? targetDate;
  final double? dailyEnergyTargetKcal;
  final double? proteinTargetG;
  final double? carbohydrateTargetG;
  final double? fatTargetG;
  final double? fiberTargetG;

  /// Salinan JSON dari `ProgramProposalInputs` yang dipakai saat proposal
  /// disetujui (Design D9, change 003) — dibandingkan ulang saat aktivasi,
  /// dibekukan untuk riwayat.
  final String inputSnapshotJson;
  final String calculatorVersion;
  final String policyVersion;

  /// Belum diisi kode manapun di change ini — perintah jeda (change 003)
  /// tidak meminta alasan. Kolom disediakan sesuai assessment §42 untuk
  /// change berikutnya tanpa menuntut migrasi baru.
  final String? pauseReason;
  final String? completionReason;
  final String? supersedesUserProgramId;
  final String? supersededByUserProgramId;
  const UserProgramRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.revision,
    required this.profileId,
    required this.programId,
    required this.status,
    this.startedAt,
    this.pausedAt,
    this.endedAt,
    this.baselineWeightKg,
    this.targetWeightKg,
    this.targetDate,
    this.dailyEnergyTargetKcal,
    this.proteinTargetG,
    this.carbohydrateTargetG,
    this.fatTargetG,
    this.fiberTargetG,
    required this.inputSnapshotJson,
    required this.calculatorVersion,
    required this.policyVersion,
    this.pauseReason,
    this.completionReason,
    this.supersedesUserProgramId,
    this.supersededByUserProgramId,
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
    map['profile_id'] = Variable<String>(profileId);
    map['program_id'] = Variable<String>(programId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || baselineWeightKg != null) {
      map['baseline_weight_kg'] = Variable<double>(baselineWeightKg);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || dailyEnergyTargetKcal != null) {
      map['daily_energy_target_kcal'] = Variable<double>(dailyEnergyTargetKcal);
    }
    if (!nullToAbsent || proteinTargetG != null) {
      map['protein_target_g'] = Variable<double>(proteinTargetG);
    }
    if (!nullToAbsent || carbohydrateTargetG != null) {
      map['carbohydrate_target_g'] = Variable<double>(carbohydrateTargetG);
    }
    if (!nullToAbsent || fatTargetG != null) {
      map['fat_target_g'] = Variable<double>(fatTargetG);
    }
    if (!nullToAbsent || fiberTargetG != null) {
      map['fiber_target_g'] = Variable<double>(fiberTargetG);
    }
    map['input_snapshot_json'] = Variable<String>(inputSnapshotJson);
    map['calculator_version'] = Variable<String>(calculatorVersion);
    map['policy_version'] = Variable<String>(policyVersion);
    if (!nullToAbsent || pauseReason != null) {
      map['pause_reason'] = Variable<String>(pauseReason);
    }
    if (!nullToAbsent || completionReason != null) {
      map['completion_reason'] = Variable<String>(completionReason);
    }
    if (!nullToAbsent || supersedesUserProgramId != null) {
      map['supersedes_user_program_id'] = Variable<String>(
        supersedesUserProgramId,
      );
    }
    if (!nullToAbsent || supersededByUserProgramId != null) {
      map['superseded_by_user_program_id'] = Variable<String>(
        supersededByUserProgramId,
      );
    }
    return map;
  }

  UserProgramsCompanion toCompanion(bool nullToAbsent) {
    return UserProgramsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      revision: Value(revision),
      profileId: Value(profileId),
      programId: Value(programId),
      status: Value(status),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      baselineWeightKg: baselineWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineWeightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      dailyEnergyTargetKcal: dailyEnergyTargetKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyEnergyTargetKcal),
      proteinTargetG: proteinTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinTargetG),
      carbohydrateTargetG: carbohydrateTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbohydrateTargetG),
      fatTargetG: fatTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(fatTargetG),
      fiberTargetG: fiberTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberTargetG),
      inputSnapshotJson: Value(inputSnapshotJson),
      calculatorVersion: Value(calculatorVersion),
      policyVersion: Value(policyVersion),
      pauseReason: pauseReason == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseReason),
      completionReason: completionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(completionReason),
      supersedesUserProgramId: supersedesUserProgramId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesUserProgramId),
      supersededByUserProgramId:
          supersededByUserProgramId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededByUserProgramId),
    );
  }

  factory UserProgramRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgramRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      revision: serializer.fromJson<int>(json['revision']),
      profileId: serializer.fromJson<String>(json['profileId']),
      programId: serializer.fromJson<String>(json['programId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      baselineWeightKg: serializer.fromJson<double?>(json['baselineWeightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      dailyEnergyTargetKcal: serializer.fromJson<double?>(
        json['dailyEnergyTargetKcal'],
      ),
      proteinTargetG: serializer.fromJson<double?>(json['proteinTargetG']),
      carbohydrateTargetG: serializer.fromJson<double?>(
        json['carbohydrateTargetG'],
      ),
      fatTargetG: serializer.fromJson<double?>(json['fatTargetG']),
      fiberTargetG: serializer.fromJson<double?>(json['fiberTargetG']),
      inputSnapshotJson: serializer.fromJson<String>(json['inputSnapshotJson']),
      calculatorVersion: serializer.fromJson<String>(json['calculatorVersion']),
      policyVersion: serializer.fromJson<String>(json['policyVersion']),
      pauseReason: serializer.fromJson<String?>(json['pauseReason']),
      completionReason: serializer.fromJson<String?>(json['completionReason']),
      supersedesUserProgramId: serializer.fromJson<String?>(
        json['supersedesUserProgramId'],
      ),
      supersededByUserProgramId: serializer.fromJson<String?>(
        json['supersededByUserProgramId'],
      ),
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
      'profileId': serializer.toJson<String>(profileId),
      'programId': serializer.toJson<String>(programId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'baselineWeightKg': serializer.toJson<double?>(baselineWeightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'targetDate': serializer.toJson<String?>(targetDate),
      'dailyEnergyTargetKcal': serializer.toJson<double?>(
        dailyEnergyTargetKcal,
      ),
      'proteinTargetG': serializer.toJson<double?>(proteinTargetG),
      'carbohydrateTargetG': serializer.toJson<double?>(carbohydrateTargetG),
      'fatTargetG': serializer.toJson<double?>(fatTargetG),
      'fiberTargetG': serializer.toJson<double?>(fiberTargetG),
      'inputSnapshotJson': serializer.toJson<String>(inputSnapshotJson),
      'calculatorVersion': serializer.toJson<String>(calculatorVersion),
      'policyVersion': serializer.toJson<String>(policyVersion),
      'pauseReason': serializer.toJson<String?>(pauseReason),
      'completionReason': serializer.toJson<String?>(completionReason),
      'supersedesUserProgramId': serializer.toJson<String?>(
        supersedesUserProgramId,
      ),
      'supersededByUserProgramId': serializer.toJson<String?>(
        supersededByUserProgramId,
      ),
    };
  }

  UserProgramRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    int? revision,
    String? profileId,
    String? programId,
    String? status,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> pausedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> baselineWeightKg = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    Value<String?> targetDate = const Value.absent(),
    Value<double?> dailyEnergyTargetKcal = const Value.absent(),
    Value<double?> proteinTargetG = const Value.absent(),
    Value<double?> carbohydrateTargetG = const Value.absent(),
    Value<double?> fatTargetG = const Value.absent(),
    Value<double?> fiberTargetG = const Value.absent(),
    String? inputSnapshotJson,
    String? calculatorVersion,
    String? policyVersion,
    Value<String?> pauseReason = const Value.absent(),
    Value<String?> completionReason = const Value.absent(),
    Value<String?> supersedesUserProgramId = const Value.absent(),
    Value<String?> supersededByUserProgramId = const Value.absent(),
  }) => UserProgramRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    revision: revision ?? this.revision,
    profileId: profileId ?? this.profileId,
    programId: programId ?? this.programId,
    status: status ?? this.status,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    baselineWeightKg: baselineWeightKg.present
        ? baselineWeightKg.value
        : this.baselineWeightKg,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    dailyEnergyTargetKcal: dailyEnergyTargetKcal.present
        ? dailyEnergyTargetKcal.value
        : this.dailyEnergyTargetKcal,
    proteinTargetG: proteinTargetG.present
        ? proteinTargetG.value
        : this.proteinTargetG,
    carbohydrateTargetG: carbohydrateTargetG.present
        ? carbohydrateTargetG.value
        : this.carbohydrateTargetG,
    fatTargetG: fatTargetG.present ? fatTargetG.value : this.fatTargetG,
    fiberTargetG: fiberTargetG.present ? fiberTargetG.value : this.fiberTargetG,
    inputSnapshotJson: inputSnapshotJson ?? this.inputSnapshotJson,
    calculatorVersion: calculatorVersion ?? this.calculatorVersion,
    policyVersion: policyVersion ?? this.policyVersion,
    pauseReason: pauseReason.present ? pauseReason.value : this.pauseReason,
    completionReason: completionReason.present
        ? completionReason.value
        : this.completionReason,
    supersedesUserProgramId: supersedesUserProgramId.present
        ? supersedesUserProgramId.value
        : this.supersedesUserProgramId,
    supersededByUserProgramId: supersededByUserProgramId.present
        ? supersededByUserProgramId.value
        : this.supersededByUserProgramId,
  );
  UserProgramRow copyWithCompanion(UserProgramsCompanion data) {
    return UserProgramRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      revision: data.revision.present ? data.revision.value : this.revision,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      programId: data.programId.present ? data.programId.value : this.programId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      baselineWeightKg: data.baselineWeightKg.present
          ? data.baselineWeightKg.value
          : this.baselineWeightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      dailyEnergyTargetKcal: data.dailyEnergyTargetKcal.present
          ? data.dailyEnergyTargetKcal.value
          : this.dailyEnergyTargetKcal,
      proteinTargetG: data.proteinTargetG.present
          ? data.proteinTargetG.value
          : this.proteinTargetG,
      carbohydrateTargetG: data.carbohydrateTargetG.present
          ? data.carbohydrateTargetG.value
          : this.carbohydrateTargetG,
      fatTargetG: data.fatTargetG.present
          ? data.fatTargetG.value
          : this.fatTargetG,
      fiberTargetG: data.fiberTargetG.present
          ? data.fiberTargetG.value
          : this.fiberTargetG,
      inputSnapshotJson: data.inputSnapshotJson.present
          ? data.inputSnapshotJson.value
          : this.inputSnapshotJson,
      calculatorVersion: data.calculatorVersion.present
          ? data.calculatorVersion.value
          : this.calculatorVersion,
      policyVersion: data.policyVersion.present
          ? data.policyVersion.value
          : this.policyVersion,
      pauseReason: data.pauseReason.present
          ? data.pauseReason.value
          : this.pauseReason,
      completionReason: data.completionReason.present
          ? data.completionReason.value
          : this.completionReason,
      supersedesUserProgramId: data.supersedesUserProgramId.present
          ? data.supersedesUserProgramId.value
          : this.supersedesUserProgramId,
      supersededByUserProgramId: data.supersededByUserProgramId.present
          ? data.supersededByUserProgramId.value
          : this.supersededByUserProgramId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('profileId: $profileId, ')
          ..write('programId: $programId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('baselineWeightKg: $baselineWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('targetDate: $targetDate, ')
          ..write('dailyEnergyTargetKcal: $dailyEnergyTargetKcal, ')
          ..write('proteinTargetG: $proteinTargetG, ')
          ..write('carbohydrateTargetG: $carbohydrateTargetG, ')
          ..write('fatTargetG: $fatTargetG, ')
          ..write('fiberTargetG: $fiberTargetG, ')
          ..write('inputSnapshotJson: $inputSnapshotJson, ')
          ..write('calculatorVersion: $calculatorVersion, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('pauseReason: $pauseReason, ')
          ..write('completionReason: $completionReason, ')
          ..write('supersedesUserProgramId: $supersedesUserProgramId, ')
          ..write('supersededByUserProgramId: $supersededByUserProgramId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    profileId,
    programId,
    status,
    startedAt,
    pausedAt,
    endedAt,
    baselineWeightKg,
    targetWeightKg,
    targetDate,
    dailyEnergyTargetKcal,
    proteinTargetG,
    carbohydrateTargetG,
    fatTargetG,
    fiberTargetG,
    inputSnapshotJson,
    calculatorVersion,
    policyVersion,
    pauseReason,
    completionReason,
    supersedesUserProgramId,
    supersededByUserProgramId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgramRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.revision == this.revision &&
          other.profileId == this.profileId &&
          other.programId == this.programId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.endedAt == this.endedAt &&
          other.baselineWeightKg == this.baselineWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.targetDate == this.targetDate &&
          other.dailyEnergyTargetKcal == this.dailyEnergyTargetKcal &&
          other.proteinTargetG == this.proteinTargetG &&
          other.carbohydrateTargetG == this.carbohydrateTargetG &&
          other.fatTargetG == this.fatTargetG &&
          other.fiberTargetG == this.fiberTargetG &&
          other.inputSnapshotJson == this.inputSnapshotJson &&
          other.calculatorVersion == this.calculatorVersion &&
          other.policyVersion == this.policyVersion &&
          other.pauseReason == this.pauseReason &&
          other.completionReason == this.completionReason &&
          other.supersedesUserProgramId == this.supersedesUserProgramId &&
          other.supersededByUserProgramId == this.supersededByUserProgramId);
}

class UserProgramsCompanion extends UpdateCompanion<UserProgramRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> revision;
  final Value<String> profileId;
  final Value<String> programId;
  final Value<String> status;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> baselineWeightKg;
  final Value<double?> targetWeightKg;
  final Value<String?> targetDate;
  final Value<double?> dailyEnergyTargetKcal;
  final Value<double?> proteinTargetG;
  final Value<double?> carbohydrateTargetG;
  final Value<double?> fatTargetG;
  final Value<double?> fiberTargetG;
  final Value<String> inputSnapshotJson;
  final Value<String> calculatorVersion;
  final Value<String> policyVersion;
  final Value<String?> pauseReason;
  final Value<String?> completionReason;
  final Value<String?> supersedesUserProgramId;
  final Value<String?> supersededByUserProgramId;
  final Value<int> rowid;
  const UserProgramsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    this.profileId = const Value.absent(),
    this.programId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.baselineWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.dailyEnergyTargetKcal = const Value.absent(),
    this.proteinTargetG = const Value.absent(),
    this.carbohydrateTargetG = const Value.absent(),
    this.fatTargetG = const Value.absent(),
    this.fiberTargetG = const Value.absent(),
    this.inputSnapshotJson = const Value.absent(),
    this.calculatorVersion = const Value.absent(),
    this.policyVersion = const Value.absent(),
    this.pauseReason = const Value.absent(),
    this.completionReason = const Value.absent(),
    this.supersedesUserProgramId = const Value.absent(),
    this.supersededByUserProgramId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgramsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    required String profileId,
    required String programId,
    required String status,
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.baselineWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.dailyEnergyTargetKcal = const Value.absent(),
    this.proteinTargetG = const Value.absent(),
    this.carbohydrateTargetG = const Value.absent(),
    this.fatTargetG = const Value.absent(),
    this.fiberTargetG = const Value.absent(),
    required String inputSnapshotJson,
    required String calculatorVersion,
    required String policyVersion,
    this.pauseReason = const Value.absent(),
    this.completionReason = const Value.absent(),
    this.supersedesUserProgramId = const Value.absent(),
    this.supersededByUserProgramId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       profileId = Value(profileId),
       programId = Value(programId),
       status = Value(status),
       inputSnapshotJson = Value(inputSnapshotJson),
       calculatorVersion = Value(calculatorVersion),
       policyVersion = Value(policyVersion);
  static Insertable<UserProgramRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? revision,
    Expression<String>? profileId,
    Expression<String>? programId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? baselineWeightKg,
    Expression<double>? targetWeightKg,
    Expression<String>? targetDate,
    Expression<double>? dailyEnergyTargetKcal,
    Expression<double>? proteinTargetG,
    Expression<double>? carbohydrateTargetG,
    Expression<double>? fatTargetG,
    Expression<double>? fiberTargetG,
    Expression<String>? inputSnapshotJson,
    Expression<String>? calculatorVersion,
    Expression<String>? policyVersion,
    Expression<String>? pauseReason,
    Expression<String>? completionReason,
    Expression<String>? supersedesUserProgramId,
    Expression<String>? supersededByUserProgramId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (revision != null) 'revision': revision,
      if (profileId != null) 'profile_id': profileId,
      if (programId != null) 'program_id': programId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (baselineWeightKg != null) 'baseline_weight_kg': baselineWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (targetDate != null) 'target_date': targetDate,
      if (dailyEnergyTargetKcal != null)
        'daily_energy_target_kcal': dailyEnergyTargetKcal,
      if (proteinTargetG != null) 'protein_target_g': proteinTargetG,
      if (carbohydrateTargetG != null)
        'carbohydrate_target_g': carbohydrateTargetG,
      if (fatTargetG != null) 'fat_target_g': fatTargetG,
      if (fiberTargetG != null) 'fiber_target_g': fiberTargetG,
      if (inputSnapshotJson != null) 'input_snapshot_json': inputSnapshotJson,
      if (calculatorVersion != null) 'calculator_version': calculatorVersion,
      if (policyVersion != null) 'policy_version': policyVersion,
      if (pauseReason != null) 'pause_reason': pauseReason,
      if (completionReason != null) 'completion_reason': completionReason,
      if (supersedesUserProgramId != null)
        'supersedes_user_program_id': supersedesUserProgramId,
      if (supersededByUserProgramId != null)
        'superseded_by_user_program_id': supersededByUserProgramId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgramsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? revision,
    Value<String>? profileId,
    Value<String>? programId,
    Value<String>? status,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? pausedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? baselineWeightKg,
    Value<double?>? targetWeightKg,
    Value<String?>? targetDate,
    Value<double?>? dailyEnergyTargetKcal,
    Value<double?>? proteinTargetG,
    Value<double?>? carbohydrateTargetG,
    Value<double?>? fatTargetG,
    Value<double?>? fiberTargetG,
    Value<String>? inputSnapshotJson,
    Value<String>? calculatorVersion,
    Value<String>? policyVersion,
    Value<String?>? pauseReason,
    Value<String?>? completionReason,
    Value<String?>? supersedesUserProgramId,
    Value<String?>? supersededByUserProgramId,
    Value<int>? rowid,
  }) {
    return UserProgramsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      profileId: profileId ?? this.profileId,
      programId: programId ?? this.programId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      endedAt: endedAt ?? this.endedAt,
      baselineWeightKg: baselineWeightKg ?? this.baselineWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetDate: targetDate ?? this.targetDate,
      dailyEnergyTargetKcal:
          dailyEnergyTargetKcal ?? this.dailyEnergyTargetKcal,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      carbohydrateTargetG: carbohydrateTargetG ?? this.carbohydrateTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
      fiberTargetG: fiberTargetG ?? this.fiberTargetG,
      inputSnapshotJson: inputSnapshotJson ?? this.inputSnapshotJson,
      calculatorVersion: calculatorVersion ?? this.calculatorVersion,
      policyVersion: policyVersion ?? this.policyVersion,
      pauseReason: pauseReason ?? this.pauseReason,
      completionReason: completionReason ?? this.completionReason,
      supersedesUserProgramId:
          supersedesUserProgramId ?? this.supersedesUserProgramId,
      supersededByUserProgramId:
          supersededByUserProgramId ?? this.supersededByUserProgramId,
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
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (baselineWeightKg.present) {
      map['baseline_weight_kg'] = Variable<double>(baselineWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (dailyEnergyTargetKcal.present) {
      map['daily_energy_target_kcal'] = Variable<double>(
        dailyEnergyTargetKcal.value,
      );
    }
    if (proteinTargetG.present) {
      map['protein_target_g'] = Variable<double>(proteinTargetG.value);
    }
    if (carbohydrateTargetG.present) {
      map['carbohydrate_target_g'] = Variable<double>(
        carbohydrateTargetG.value,
      );
    }
    if (fatTargetG.present) {
      map['fat_target_g'] = Variable<double>(fatTargetG.value);
    }
    if (fiberTargetG.present) {
      map['fiber_target_g'] = Variable<double>(fiberTargetG.value);
    }
    if (inputSnapshotJson.present) {
      map['input_snapshot_json'] = Variable<String>(inputSnapshotJson.value);
    }
    if (calculatorVersion.present) {
      map['calculator_version'] = Variable<String>(calculatorVersion.value);
    }
    if (policyVersion.present) {
      map['policy_version'] = Variable<String>(policyVersion.value);
    }
    if (pauseReason.present) {
      map['pause_reason'] = Variable<String>(pauseReason.value);
    }
    if (completionReason.present) {
      map['completion_reason'] = Variable<String>(completionReason.value);
    }
    if (supersedesUserProgramId.present) {
      map['supersedes_user_program_id'] = Variable<String>(
        supersedesUserProgramId.value,
      );
    }
    if (supersededByUserProgramId.present) {
      map['superseded_by_user_program_id'] = Variable<String>(
        supersededByUserProgramId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('profileId: $profileId, ')
          ..write('programId: $programId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('baselineWeightKg: $baselineWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('targetDate: $targetDate, ')
          ..write('dailyEnergyTargetKcal: $dailyEnergyTargetKcal, ')
          ..write('proteinTargetG: $proteinTargetG, ')
          ..write('carbohydrateTargetG: $carbohydrateTargetG, ')
          ..write('fatTargetG: $fatTargetG, ')
          ..write('fiberTargetG: $fiberTargetG, ')
          ..write('inputSnapshotJson: $inputSnapshotJson, ')
          ..write('calculatorVersion: $calculatorVersion, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('pauseReason: $pauseReason, ')
          ..write('completionReason: $completionReason, ')
          ..write('supersedesUserProgramId: $supersedesUserProgramId, ')
          ..write('supersededByUserProgramId: $supersededByUserProgramId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramProgressTable extends ProgramProgress
    with TableInfo<$ProgramProgressTable, ProgramProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userProgramIdMeta = const VerificationMeta(
    'userProgramId',
  );
  @override
  late final GeneratedColumn<String> userProgramId = GeneratedColumn<String>(
    'user_program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_programs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _recordedLocalDateMeta = const VerificationMeta(
    'recordedLocalDate',
  );
  @override
  late final GeneratedColumn<String> recordedLocalDate =
      GeneratedColumn<String>(
        'recorded_local_date',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 10,
          maxTextLength: 10,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightChangeKgMeta = const VerificationMeta(
    'weightChangeKg',
  );
  @override
  late final GeneratedColumn<double> weightChangeKg = GeneratedColumn<double>(
    'weight_change_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetProgressRatioMeta =
      const VerificationMeta('targetProgressRatio');
  @override
  late final GeneratedColumn<double> targetProgressRatio =
      GeneratedColumn<double>(
        'target_progress_ratio',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consumedEnergyKcalMeta =
      const VerificationMeta('consumedEnergyKcal');
  @override
  late final GeneratedColumn<double> consumedEnergyKcal =
      GeneratedColumn<double>(
        'consumed_energy_kcal',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _energyAdherenceRatioMeta =
      const VerificationMeta('energyAdherenceRatio');
  @override
  late final GeneratedColumn<double> energyAdherenceRatio =
      GeneratedColumn<double>(
        'energy_adherence_ratio',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbohydrateGMeta = const VerificationMeta(
    'carbohydrateG',
  );
  @override
  late final GeneratedColumn<double> carbohydrateG = GeneratedColumn<double>(
    'carbohydrate_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedMealsCountMeta = const VerificationMeta(
    'loggedMealsCount',
  );
  @override
  late final GeneratedColumn<int> loggedMealsCount = GeneratedColumn<int>(
    'logged_meals_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _diaryCompleteMeta = const VerificationMeta(
    'diaryComplete',
  );
  @override
  late final GeneratedColumn<bool> diaryComplete = GeneratedColumn<bool>(
    'diary_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("diary_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeDayNumberMeta = const VerificationMeta(
    'activeDayNumber',
  );
  @override
  late final GeneratedColumn<int> activeDayNumber = GeneratedColumn<int>(
    'active_day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricsJsonMeta = const VerificationMeta(
    'metricsJson',
  );
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
    'metrics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _calculationVersionMeta =
      const VerificationMeta('calculationVersion');
  @override
  late final GeneratedColumn<String> calculationVersion =
      GeneratedColumn<String>(
        'calculation_version',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 32,
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
    userProgramId,
    recordedLocalDate,
    recordedAt,
    weightKg,
    weightChangeKg,
    targetProgressRatio,
    consumedEnergyKcal,
    energyAdherenceRatio,
    proteinG,
    carbohydrateG,
    fatG,
    loggedMealsCount,
    diaryComplete,
    activeDayNumber,
    metricsJson,
    calculationVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramProgressRow> instance, {
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
    if (data.containsKey('user_program_id')) {
      context.handle(
        _userProgramIdMeta,
        userProgramId.isAcceptableOrUnknown(
          data['user_program_id']!,
          _userProgramIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userProgramIdMeta);
    }
    if (data.containsKey('recorded_local_date')) {
      context.handle(
        _recordedLocalDateMeta,
        recordedLocalDate.isAcceptableOrUnknown(
          data['recorded_local_date']!,
          _recordedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedLocalDateMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('weight_change_kg')) {
      context.handle(
        _weightChangeKgMeta,
        weightChangeKg.isAcceptableOrUnknown(
          data['weight_change_kg']!,
          _weightChangeKgMeta,
        ),
      );
    }
    if (data.containsKey('target_progress_ratio')) {
      context.handle(
        _targetProgressRatioMeta,
        targetProgressRatio.isAcceptableOrUnknown(
          data['target_progress_ratio']!,
          _targetProgressRatioMeta,
        ),
      );
    }
    if (data.containsKey('consumed_energy_kcal')) {
      context.handle(
        _consumedEnergyKcalMeta,
        consumedEnergyKcal.isAcceptableOrUnknown(
          data['consumed_energy_kcal']!,
          _consumedEnergyKcalMeta,
        ),
      );
    }
    if (data.containsKey('energy_adherence_ratio')) {
      context.handle(
        _energyAdherenceRatioMeta,
        energyAdherenceRatio.isAcceptableOrUnknown(
          data['energy_adherence_ratio']!,
          _energyAdherenceRatioMeta,
        ),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbohydrate_g')) {
      context.handle(
        _carbohydrateGMeta,
        carbohydrateG.isAcceptableOrUnknown(
          data['carbohydrate_g']!,
          _carbohydrateGMeta,
        ),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('logged_meals_count')) {
      context.handle(
        _loggedMealsCountMeta,
        loggedMealsCount.isAcceptableOrUnknown(
          data['logged_meals_count']!,
          _loggedMealsCountMeta,
        ),
      );
    }
    if (data.containsKey('diary_complete')) {
      context.handle(
        _diaryCompleteMeta,
        diaryComplete.isAcceptableOrUnknown(
          data['diary_complete']!,
          _diaryCompleteMeta,
        ),
      );
    }
    if (data.containsKey('active_day_number')) {
      context.handle(
        _activeDayNumberMeta,
        activeDayNumber.isAcceptableOrUnknown(
          data['active_day_number']!,
          _activeDayNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeDayNumberMeta);
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
        _metricsJsonMeta,
        metricsJson.isAcceptableOrUnknown(
          data['metrics_json']!,
          _metricsJsonMeta,
        ),
      );
    }
    if (data.containsKey('calculation_version')) {
      context.handle(
        _calculationVersionMeta,
        calculationVersion.isAcceptableOrUnknown(
          data['calculation_version']!,
          _calculationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculationVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramProgressRow(
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
      userProgramId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_program_id'],
      )!,
      recordedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_local_date'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      weightChangeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_change_kg'],
      ),
      targetProgressRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_progress_ratio'],
      ),
      consumedEnergyKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumed_energy_kcal'],
      ),
      energyAdherenceRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_adherence_ratio'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbohydrateG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
      loggedMealsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_meals_count'],
      )!,
      diaryComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}diary_complete'],
      )!,
      activeDayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_day_number'],
      )!,
      metricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_json'],
      )!,
      calculationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_version'],
      )!,
    );
  }

  @override
  $ProgramProgressTable createAlias(String alias) {
    return $ProgramProgressTable(attachedDatabase, alias);
  }
}

class ProgramProgressRow extends DataClass
    implements Insertable<ProgramProgressRow> {
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
  final String userProgramId;

  /// Tanggal lokal (`YYYY-MM-DD`) saat dicatat — tidak pernah dihitung ulang
  /// dari instan UTC pada waktu baca (spec program-progress, "Zona waktu
  /// berubah").
  final String recordedLocalDate;
  final DateTime recordedAt;
  final double? weightKg;
  final double? weightChangeKg;
  final double? targetProgressRatio;
  final double? consumedEnergyKcal;
  final double? energyAdherenceRatio;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final int loggedMealsCount;
  final bool diaryComplete;

  /// Hari aktif ke berapa sejak program dimulai — hari dalam rentang jeda
  /// tidak menambah angka ini (spec program-progress, "Hari dalam keadaan
  /// jeda").
  final int activeDayNumber;

  /// Ukuran tambahan yang belum punya kolom sendiri (mis. kualitas gizi
  /// Makan Sehat) — lihat design.md, Open Questions.
  final String metricsJson;
  final String calculationVersion;
  const ProgramProgressRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.revision,
    required this.userProgramId,
    required this.recordedLocalDate,
    required this.recordedAt,
    this.weightKg,
    this.weightChangeKg,
    this.targetProgressRatio,
    this.consumedEnergyKcal,
    this.energyAdherenceRatio,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
    required this.loggedMealsCount,
    required this.diaryComplete,
    required this.activeDayNumber,
    required this.metricsJson,
    required this.calculationVersion,
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
    map['user_program_id'] = Variable<String>(userProgramId);
    map['recorded_local_date'] = Variable<String>(recordedLocalDate);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || weightChangeKg != null) {
      map['weight_change_kg'] = Variable<double>(weightChangeKg);
    }
    if (!nullToAbsent || targetProgressRatio != null) {
      map['target_progress_ratio'] = Variable<double>(targetProgressRatio);
    }
    if (!nullToAbsent || consumedEnergyKcal != null) {
      map['consumed_energy_kcal'] = Variable<double>(consumedEnergyKcal);
    }
    if (!nullToAbsent || energyAdherenceRatio != null) {
      map['energy_adherence_ratio'] = Variable<double>(energyAdherenceRatio);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbohydrateG != null) {
      map['carbohydrate_g'] = Variable<double>(carbohydrateG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    map['logged_meals_count'] = Variable<int>(loggedMealsCount);
    map['diary_complete'] = Variable<bool>(diaryComplete);
    map['active_day_number'] = Variable<int>(activeDayNumber);
    map['metrics_json'] = Variable<String>(metricsJson);
    map['calculation_version'] = Variable<String>(calculationVersion);
    return map;
  }

  ProgramProgressCompanion toCompanion(bool nullToAbsent) {
    return ProgramProgressCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      revision: Value(revision),
      userProgramId: Value(userProgramId),
      recordedLocalDate: Value(recordedLocalDate),
      recordedAt: Value(recordedAt),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      weightChangeKg: weightChangeKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightChangeKg),
      targetProgressRatio: targetProgressRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(targetProgressRatio),
      consumedEnergyKcal: consumedEnergyKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(consumedEnergyKcal),
      energyAdherenceRatio: energyAdherenceRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(energyAdherenceRatio),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbohydrateG: carbohydrateG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbohydrateG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      loggedMealsCount: Value(loggedMealsCount),
      diaryComplete: Value(diaryComplete),
      activeDayNumber: Value(activeDayNumber),
      metricsJson: Value(metricsJson),
      calculationVersion: Value(calculationVersion),
    );
  }

  factory ProgramProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramProgressRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      revision: serializer.fromJson<int>(json['revision']),
      userProgramId: serializer.fromJson<String>(json['userProgramId']),
      recordedLocalDate: serializer.fromJson<String>(json['recordedLocalDate']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      weightChangeKg: serializer.fromJson<double?>(json['weightChangeKg']),
      targetProgressRatio: serializer.fromJson<double?>(
        json['targetProgressRatio'],
      ),
      consumedEnergyKcal: serializer.fromJson<double?>(
        json['consumedEnergyKcal'],
      ),
      energyAdherenceRatio: serializer.fromJson<double?>(
        json['energyAdherenceRatio'],
      ),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbohydrateG: serializer.fromJson<double?>(json['carbohydrateG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
      loggedMealsCount: serializer.fromJson<int>(json['loggedMealsCount']),
      diaryComplete: serializer.fromJson<bool>(json['diaryComplete']),
      activeDayNumber: serializer.fromJson<int>(json['activeDayNumber']),
      metricsJson: serializer.fromJson<String>(json['metricsJson']),
      calculationVersion: serializer.fromJson<String>(
        json['calculationVersion'],
      ),
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
      'userProgramId': serializer.toJson<String>(userProgramId),
      'recordedLocalDate': serializer.toJson<String>(recordedLocalDate),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'weightKg': serializer.toJson<double?>(weightKg),
      'weightChangeKg': serializer.toJson<double?>(weightChangeKg),
      'targetProgressRatio': serializer.toJson<double?>(targetProgressRatio),
      'consumedEnergyKcal': serializer.toJson<double?>(consumedEnergyKcal),
      'energyAdherenceRatio': serializer.toJson<double?>(energyAdherenceRatio),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbohydrateG': serializer.toJson<double?>(carbohydrateG),
      'fatG': serializer.toJson<double?>(fatG),
      'loggedMealsCount': serializer.toJson<int>(loggedMealsCount),
      'diaryComplete': serializer.toJson<bool>(diaryComplete),
      'activeDayNumber': serializer.toJson<int>(activeDayNumber),
      'metricsJson': serializer.toJson<String>(metricsJson),
      'calculationVersion': serializer.toJson<String>(calculationVersion),
    };
  }

  ProgramProgressRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    int? revision,
    String? userProgramId,
    String? recordedLocalDate,
    DateTime? recordedAt,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> weightChangeKg = const Value.absent(),
    Value<double?> targetProgressRatio = const Value.absent(),
    Value<double?> consumedEnergyKcal = const Value.absent(),
    Value<double?> energyAdherenceRatio = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbohydrateG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
    int? loggedMealsCount,
    bool? diaryComplete,
    int? activeDayNumber,
    String? metricsJson,
    String? calculationVersion,
  }) => ProgramProgressRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    revision: revision ?? this.revision,
    userProgramId: userProgramId ?? this.userProgramId,
    recordedLocalDate: recordedLocalDate ?? this.recordedLocalDate,
    recordedAt: recordedAt ?? this.recordedAt,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    weightChangeKg: weightChangeKg.present
        ? weightChangeKg.value
        : this.weightChangeKg,
    targetProgressRatio: targetProgressRatio.present
        ? targetProgressRatio.value
        : this.targetProgressRatio,
    consumedEnergyKcal: consumedEnergyKcal.present
        ? consumedEnergyKcal.value
        : this.consumedEnergyKcal,
    energyAdherenceRatio: energyAdherenceRatio.present
        ? energyAdherenceRatio.value
        : this.energyAdherenceRatio,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbohydrateG: carbohydrateG.present
        ? carbohydrateG.value
        : this.carbohydrateG,
    fatG: fatG.present ? fatG.value : this.fatG,
    loggedMealsCount: loggedMealsCount ?? this.loggedMealsCount,
    diaryComplete: diaryComplete ?? this.diaryComplete,
    activeDayNumber: activeDayNumber ?? this.activeDayNumber,
    metricsJson: metricsJson ?? this.metricsJson,
    calculationVersion: calculationVersion ?? this.calculationVersion,
  );
  ProgramProgressRow copyWithCompanion(ProgramProgressCompanion data) {
    return ProgramProgressRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      revision: data.revision.present ? data.revision.value : this.revision,
      userProgramId: data.userProgramId.present
          ? data.userProgramId.value
          : this.userProgramId,
      recordedLocalDate: data.recordedLocalDate.present
          ? data.recordedLocalDate.value
          : this.recordedLocalDate,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      weightChangeKg: data.weightChangeKg.present
          ? data.weightChangeKg.value
          : this.weightChangeKg,
      targetProgressRatio: data.targetProgressRatio.present
          ? data.targetProgressRatio.value
          : this.targetProgressRatio,
      consumedEnergyKcal: data.consumedEnergyKcal.present
          ? data.consumedEnergyKcal.value
          : this.consumedEnergyKcal,
      energyAdherenceRatio: data.energyAdherenceRatio.present
          ? data.energyAdherenceRatio.value
          : this.energyAdherenceRatio,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbohydrateG: data.carbohydrateG.present
          ? data.carbohydrateG.value
          : this.carbohydrateG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      loggedMealsCount: data.loggedMealsCount.present
          ? data.loggedMealsCount.value
          : this.loggedMealsCount,
      diaryComplete: data.diaryComplete.present
          ? data.diaryComplete.value
          : this.diaryComplete,
      activeDayNumber: data.activeDayNumber.present
          ? data.activeDayNumber.value
          : this.activeDayNumber,
      metricsJson: data.metricsJson.present
          ? data.metricsJson.value
          : this.metricsJson,
      calculationVersion: data.calculationVersion.present
          ? data.calculationVersion.value
          : this.calculationVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramProgressRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('userProgramId: $userProgramId, ')
          ..write('recordedLocalDate: $recordedLocalDate, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('weightChangeKg: $weightChangeKg, ')
          ..write('targetProgressRatio: $targetProgressRatio, ')
          ..write('consumedEnergyKcal: $consumedEnergyKcal, ')
          ..write('energyAdherenceRatio: $energyAdherenceRatio, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbohydrateG: $carbohydrateG, ')
          ..write('fatG: $fatG, ')
          ..write('loggedMealsCount: $loggedMealsCount, ')
          ..write('diaryComplete: $diaryComplete, ')
          ..write('activeDayNumber: $activeDayNumber, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('calculationVersion: $calculationVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    revision,
    userProgramId,
    recordedLocalDate,
    recordedAt,
    weightKg,
    weightChangeKg,
    targetProgressRatio,
    consumedEnergyKcal,
    energyAdherenceRatio,
    proteinG,
    carbohydrateG,
    fatG,
    loggedMealsCount,
    diaryComplete,
    activeDayNumber,
    metricsJson,
    calculationVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramProgressRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.revision == this.revision &&
          other.userProgramId == this.userProgramId &&
          other.recordedLocalDate == this.recordedLocalDate &&
          other.recordedAt == this.recordedAt &&
          other.weightKg == this.weightKg &&
          other.weightChangeKg == this.weightChangeKg &&
          other.targetProgressRatio == this.targetProgressRatio &&
          other.consumedEnergyKcal == this.consumedEnergyKcal &&
          other.energyAdherenceRatio == this.energyAdherenceRatio &&
          other.proteinG == this.proteinG &&
          other.carbohydrateG == this.carbohydrateG &&
          other.fatG == this.fatG &&
          other.loggedMealsCount == this.loggedMealsCount &&
          other.diaryComplete == this.diaryComplete &&
          other.activeDayNumber == this.activeDayNumber &&
          other.metricsJson == this.metricsJson &&
          other.calculationVersion == this.calculationVersion);
}

class ProgramProgressCompanion extends UpdateCompanion<ProgramProgressRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> revision;
  final Value<String> userProgramId;
  final Value<String> recordedLocalDate;
  final Value<DateTime> recordedAt;
  final Value<double?> weightKg;
  final Value<double?> weightChangeKg;
  final Value<double?> targetProgressRatio;
  final Value<double?> consumedEnergyKcal;
  final Value<double?> energyAdherenceRatio;
  final Value<double?> proteinG;
  final Value<double?> carbohydrateG;
  final Value<double?> fatG;
  final Value<int> loggedMealsCount;
  final Value<bool> diaryComplete;
  final Value<int> activeDayNumber;
  final Value<String> metricsJson;
  final Value<String> calculationVersion;
  final Value<int> rowid;
  const ProgramProgressCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    this.userProgramId = const Value.absent(),
    this.recordedLocalDate = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.weightChangeKg = const Value.absent(),
    this.targetProgressRatio = const Value.absent(),
    this.consumedEnergyKcal = const Value.absent(),
    this.energyAdherenceRatio = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbohydrateG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.loggedMealsCount = const Value.absent(),
    this.diaryComplete = const Value.absent(),
    this.activeDayNumber = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.calculationVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramProgressCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    required String userProgramId,
    required String recordedLocalDate,
    required DateTime recordedAt,
    this.weightKg = const Value.absent(),
    this.weightChangeKg = const Value.absent(),
    this.targetProgressRatio = const Value.absent(),
    this.consumedEnergyKcal = const Value.absent(),
    this.energyAdherenceRatio = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbohydrateG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.loggedMealsCount = const Value.absent(),
    this.diaryComplete = const Value.absent(),
    required int activeDayNumber,
    this.metricsJson = const Value.absent(),
    required String calculationVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userProgramId = Value(userProgramId),
       recordedLocalDate = Value(recordedLocalDate),
       recordedAt = Value(recordedAt),
       activeDayNumber = Value(activeDayNumber),
       calculationVersion = Value(calculationVersion);
  static Insertable<ProgramProgressRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? revision,
    Expression<String>? userProgramId,
    Expression<String>? recordedLocalDate,
    Expression<DateTime>? recordedAt,
    Expression<double>? weightKg,
    Expression<double>? weightChangeKg,
    Expression<double>? targetProgressRatio,
    Expression<double>? consumedEnergyKcal,
    Expression<double>? energyAdherenceRatio,
    Expression<double>? proteinG,
    Expression<double>? carbohydrateG,
    Expression<double>? fatG,
    Expression<int>? loggedMealsCount,
    Expression<bool>? diaryComplete,
    Expression<int>? activeDayNumber,
    Expression<String>? metricsJson,
    Expression<String>? calculationVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (revision != null) 'revision': revision,
      if (userProgramId != null) 'user_program_id': userProgramId,
      if (recordedLocalDate != null) 'recorded_local_date': recordedLocalDate,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (weightChangeKg != null) 'weight_change_kg': weightChangeKg,
      if (targetProgressRatio != null)
        'target_progress_ratio': targetProgressRatio,
      if (consumedEnergyKcal != null)
        'consumed_energy_kcal': consumedEnergyKcal,
      if (energyAdherenceRatio != null)
        'energy_adherence_ratio': energyAdherenceRatio,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbohydrateG != null) 'carbohydrate_g': carbohydrateG,
      if (fatG != null) 'fat_g': fatG,
      if (loggedMealsCount != null) 'logged_meals_count': loggedMealsCount,
      if (diaryComplete != null) 'diary_complete': diaryComplete,
      if (activeDayNumber != null) 'active_day_number': activeDayNumber,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (calculationVersion != null) 'calculation_version': calculationVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramProgressCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? revision,
    Value<String>? userProgramId,
    Value<String>? recordedLocalDate,
    Value<DateTime>? recordedAt,
    Value<double?>? weightKg,
    Value<double?>? weightChangeKg,
    Value<double?>? targetProgressRatio,
    Value<double?>? consumedEnergyKcal,
    Value<double?>? energyAdherenceRatio,
    Value<double?>? proteinG,
    Value<double?>? carbohydrateG,
    Value<double?>? fatG,
    Value<int>? loggedMealsCount,
    Value<bool>? diaryComplete,
    Value<int>? activeDayNumber,
    Value<String>? metricsJson,
    Value<String>? calculationVersion,
    Value<int>? rowid,
  }) {
    return ProgramProgressCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      userProgramId: userProgramId ?? this.userProgramId,
      recordedLocalDate: recordedLocalDate ?? this.recordedLocalDate,
      recordedAt: recordedAt ?? this.recordedAt,
      weightKg: weightKg ?? this.weightKg,
      weightChangeKg: weightChangeKg ?? this.weightChangeKg,
      targetProgressRatio: targetProgressRatio ?? this.targetProgressRatio,
      consumedEnergyKcal: consumedEnergyKcal ?? this.consumedEnergyKcal,
      energyAdherenceRatio: energyAdherenceRatio ?? this.energyAdherenceRatio,
      proteinG: proteinG ?? this.proteinG,
      carbohydrateG: carbohydrateG ?? this.carbohydrateG,
      fatG: fatG ?? this.fatG,
      loggedMealsCount: loggedMealsCount ?? this.loggedMealsCount,
      diaryComplete: diaryComplete ?? this.diaryComplete,
      activeDayNumber: activeDayNumber ?? this.activeDayNumber,
      metricsJson: metricsJson ?? this.metricsJson,
      calculationVersion: calculationVersion ?? this.calculationVersion,
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
    if (userProgramId.present) {
      map['user_program_id'] = Variable<String>(userProgramId.value);
    }
    if (recordedLocalDate.present) {
      map['recorded_local_date'] = Variable<String>(recordedLocalDate.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (weightChangeKg.present) {
      map['weight_change_kg'] = Variable<double>(weightChangeKg.value);
    }
    if (targetProgressRatio.present) {
      map['target_progress_ratio'] = Variable<double>(
        targetProgressRatio.value,
      );
    }
    if (consumedEnergyKcal.present) {
      map['consumed_energy_kcal'] = Variable<double>(consumedEnergyKcal.value);
    }
    if (energyAdherenceRatio.present) {
      map['energy_adherence_ratio'] = Variable<double>(
        energyAdherenceRatio.value,
      );
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbohydrateG.present) {
      map['carbohydrate_g'] = Variable<double>(carbohydrateG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (loggedMealsCount.present) {
      map['logged_meals_count'] = Variable<int>(loggedMealsCount.value);
    }
    if (diaryComplete.present) {
      map['diary_complete'] = Variable<bool>(diaryComplete.value);
    }
    if (activeDayNumber.present) {
      map['active_day_number'] = Variable<int>(activeDayNumber.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (calculationVersion.present) {
      map['calculation_version'] = Variable<String>(calculationVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramProgressCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('userProgramId: $userProgramId, ')
          ..write('recordedLocalDate: $recordedLocalDate, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('weightChangeKg: $weightChangeKg, ')
          ..write('targetProgressRatio: $targetProgressRatio, ')
          ..write('consumedEnergyKcal: $consumedEnergyKcal, ')
          ..write('energyAdherenceRatio: $energyAdherenceRatio, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbohydrateG: $carbohydrateG, ')
          ..write('fatG: $fatG, ')
          ..write('loggedMealsCount: $loggedMealsCount, ')
          ..write('diaryComplete: $diaryComplete, ')
          ..write('activeDayNumber: $activeDayNumber, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramEventsTable extends ProgramEvents
    with TableInfo<$ProgramEventsTable, ProgramEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userProgramIdMeta = const VerificationMeta(
    'userProgramId',
  );
  @override
  late final GeneratedColumn<String> userProgramId = GeneratedColumn<String>(
    'user_program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_programs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    check: () => eventType.isIn(kProgramEventTypes),
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromStatusMeta = const VerificationMeta(
    'fromStatus',
  );
  @override
  late final GeneratedColumn<String> fromStatus = GeneratedColumn<String>(
    'from_status',
    aliasedName,
    true,
    check: () => fromStatus.isIn(kUserProgramStatuses) | fromStatus.isNull(),
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toStatusMeta = const VerificationMeta(
    'toStatus',
  );
  @override
  late final GeneratedColumn<String> toStatus = GeneratedColumn<String>(
    'to_status',
    aliasedName,
    true,
    check: () => toStatus.isIn(kUserProgramStatuses) | toStatus.isNull(),
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonCodeMeta = const VerificationMeta(
    'reasonCode',
  );
  @override
  late final GeneratedColumn<String> reasonCode = GeneratedColumn<String>(
    'reason_code',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    syncStatus,
    revision,
    userProgramId,
    eventType,
    occurredAt,
    fromStatus,
    toStatus,
    reasonCode,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramEventRow> instance, {
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
    if (data.containsKey('user_program_id')) {
      context.handle(
        _userProgramIdMeta,
        userProgramId.isAcceptableOrUnknown(
          data['user_program_id']!,
          _userProgramIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userProgramIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('from_status')) {
      context.handle(
        _fromStatusMeta,
        fromStatus.isAcceptableOrUnknown(data['from_status']!, _fromStatusMeta),
      );
    }
    if (data.containsKey('to_status')) {
      context.handle(
        _toStatusMeta,
        toStatus.isAcceptableOrUnknown(data['to_status']!, _toStatusMeta),
      );
    }
    if (data.containsKey('reason_code')) {
      context.handle(
        _reasonCodeMeta,
        reasonCode.isAcceptableOrUnknown(data['reason_code']!, _reasonCodeMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      userProgramId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_program_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      fromStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_status'],
      ),
      toStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_status'],
      ),
      reasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_code'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
    );
  }

  @override
  $ProgramEventsTable createAlias(String alias) {
    return $ProgramEventsTable(attachedDatabase, alias);
  }
}

class ProgramEventRow extends DataClass implements Insertable<ProgramEventRow> {
  final String id;
  final DateTime createdAt;
  final String syncStatus;
  final int revision;
  final String userProgramId;
  final String eventType;
  final DateTime occurredAt;
  final String? fromStatus;
  final String? toStatus;
  final String? reasonCode;
  final String metadataJson;
  const ProgramEventRow({
    required this.id,
    required this.createdAt,
    required this.syncStatus,
    required this.revision,
    required this.userProgramId,
    required this.eventType,
    required this.occurredAt,
    this.fromStatus,
    this.toStatus,
    this.reasonCode,
    required this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['revision'] = Variable<int>(revision);
    map['user_program_id'] = Variable<String>(userProgramId);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(fromStatus);
    }
    if (!nullToAbsent || toStatus != null) {
      map['to_status'] = Variable<String>(toStatus);
    }
    if (!nullToAbsent || reasonCode != null) {
      map['reason_code'] = Variable<String>(reasonCode);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  ProgramEventsCompanion toCompanion(bool nullToAbsent) {
    return ProgramEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      revision: Value(revision),
      userProgramId: Value(userProgramId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: toStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(toStatus),
      reasonCode: reasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonCode),
      metadataJson: Value(metadataJson),
    );
  }

  factory ProgramEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramEventRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      revision: serializer.fromJson<int>(json['revision']),
      userProgramId: serializer.fromJson<String>(json['userProgramId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      fromStatus: serializer.fromJson<String?>(json['fromStatus']),
      toStatus: serializer.fromJson<String?>(json['toStatus']),
      reasonCode: serializer.fromJson<String?>(json['reasonCode']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'revision': serializer.toJson<int>(revision),
      'userProgramId': serializer.toJson<String>(userProgramId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'fromStatus': serializer.toJson<String?>(fromStatus),
      'toStatus': serializer.toJson<String?>(toStatus),
      'reasonCode': serializer.toJson<String?>(reasonCode),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  ProgramEventRow copyWith({
    String? id,
    DateTime? createdAt,
    String? syncStatus,
    int? revision,
    String? userProgramId,
    String? eventType,
    DateTime? occurredAt,
    Value<String?> fromStatus = const Value.absent(),
    Value<String?> toStatus = const Value.absent(),
    Value<String?> reasonCode = const Value.absent(),
    String? metadataJson,
  }) => ProgramEventRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
    revision: revision ?? this.revision,
    userProgramId: userProgramId ?? this.userProgramId,
    eventType: eventType ?? this.eventType,
    occurredAt: occurredAt ?? this.occurredAt,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus.present ? toStatus.value : this.toStatus,
    reasonCode: reasonCode.present ? reasonCode.value : this.reasonCode,
    metadataJson: metadataJson ?? this.metadataJson,
  );
  ProgramEventRow copyWithCompanion(ProgramEventsCompanion data) {
    return ProgramEventRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      revision: data.revision.present ? data.revision.value : this.revision,
      userProgramId: data.userProgramId.present
          ? data.userProgramId.value
          : this.userProgramId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      reasonCode: data.reasonCode.present
          ? data.reasonCode.value
          : this.reasonCode,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramEventRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('userProgramId: $userProgramId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    syncStatus,
    revision,
    userProgramId,
    eventType,
    occurredAt,
    fromStatus,
    toStatus,
    reasonCode,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramEventRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.revision == this.revision &&
          other.userProgramId == this.userProgramId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.reasonCode == this.reasonCode &&
          other.metadataJson == this.metadataJson);
}

class ProgramEventsCompanion extends UpdateCompanion<ProgramEventRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> revision;
  final Value<String> userProgramId;
  final Value<String> eventType;
  final Value<DateTime> occurredAt;
  final Value<String?> fromStatus;
  final Value<String?> toStatus;
  final Value<String?> reasonCode;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const ProgramEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    this.userProgramId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramEventsCompanion.insert({
    required String id,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.revision = const Value.absent(),
    required String userProgramId,
    required String eventType,
    required DateTime occurredAt,
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       userProgramId = Value(userProgramId),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt);
  static Insertable<ProgramEventRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? revision,
    Expression<String>? userProgramId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<String>? reasonCode,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (revision != null) 'revision': revision,
      if (userProgramId != null) 'user_program_id': userProgramId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? revision,
    Value<String>? userProgramId,
    Value<String>? eventType,
    Value<DateTime>? occurredAt,
    Value<String?>? fromStatus,
    Value<String?>? toStatus,
    Value<String?>? reasonCode,
    Value<String>? metadataJson,
    Value<int>? rowid,
  }) {
    return ProgramEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      userProgramId: userProgramId ?? this.userProgramId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      reasonCode: reasonCode ?? this.reasonCode,
      metadataJson: metadataJson ?? this.metadataJson,
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
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (userProgramId.present) {
      map['user_program_id'] = Variable<String>(userProgramId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(fromStatus.value);
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(toStatus.value);
    }
    if (reasonCode.present) {
      map['reason_code'] = Variable<String>(reasonCode.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('revision: $revision, ')
          ..write('userProgramId: $userProgramId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('metadataJson: $metadataJson, ')
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
  late final $ProgramsTable programs = $ProgramsTable(this);
  late final $UserProgramsTable userPrograms = $UserProgramsTable(this);
  late final $ProgramProgressTable programProgress = $ProgramProgressTable(
    this,
  );
  late final $ProgramEventsTable programEvents = $ProgramEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    harnessRecords,
    harnessRecordNotes,
    uiPreferences,
    programs,
    userPrograms,
    programProgress,
    programEvents,
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
typedef $$ProgramsTableCreateCompanionBuilder =
    ProgramsCompanion Function({
      required String id,
      required String code,
      required String name,
      required String description,
      required bool requiresWeightTarget,
      Value<bool> isAvailable,
      required int sortOrder,
      required int definitionVersion,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProgramsTableUpdateCompanionBuilder =
    ProgramsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String> description,
      Value<bool> requiresWeightTarget,
      Value<bool> isAvailable,
      Value<int> sortOrder,
      Value<int> definitionVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramsTable, Program> {
  $$ProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgramsTable, List<UserProgramRow>>
  _userProgramsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userPrograms,
    aliasName: 'programs__id__user_programs__program_id',
  );

  $$UserProgramsTableProcessedTableManager get userProgramsRefs {
    final manager = $$UserProgramsTableTableManager(
      $_db,
      $_db.userPrograms,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgramsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresWeightTarget => $composableBuilder(
    column: $table.requiresWeightTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
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

  Expression<bool> userProgramsRefs(
    Expression<bool> Function($$UserProgramsTableFilterComposer f) f,
  ) {
    final $$UserProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableFilterComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresWeightTarget => $composableBuilder(
    column: $table.requiresWeightTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
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
}

class $$ProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiresWeightTarget => $composableBuilder(
    column: $table.requiresWeightTarget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get definitionVersion => $composableBuilder(
    column: $table.definitionVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userProgramsRefs<T extends Object>(
    Expression<T> Function($$UserProgramsTableAnnotationComposer a) f,
  ) {
    final $$UserProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramsTable,
          Program,
          $$ProgramsTableFilterComposer,
          $$ProgramsTableOrderingComposer,
          $$ProgramsTableAnnotationComposer,
          $$ProgramsTableCreateCompanionBuilder,
          $$ProgramsTableUpdateCompanionBuilder,
          (Program, $$ProgramsTableReferences),
          Program,
          PrefetchHooks Function({bool userProgramsRefs})
        > {
  $$ProgramsTableTableManager(_$AppDatabase db, $ProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> requiresWeightTarget = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> definitionVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramsCompanion(
                id: id,
                code: code,
                name: name,
                description: description,
                requiresWeightTarget: requiresWeightTarget,
                isAvailable: isAvailable,
                sortOrder: sortOrder,
                definitionVersion: definitionVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required String description,
                required bool requiresWeightTarget,
                Value<bool> isAvailable = const Value.absent(),
                required int sortOrder,
                required int definitionVersion,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProgramsCompanion.insert(
                id: id,
                code: code,
                name: name,
                description: description,
                requiresWeightTarget: requiresWeightTarget,
                isAvailable: isAvailable,
                sortOrder: sortOrder,
                definitionVersion: definitionVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProgramsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userProgramsRefs) db.userPrograms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userProgramsRefs)
                    await $_getPrefetchedData<
                      Program,
                      $ProgramsTable,
                      UserProgramRow
                    >(
                      currentTable: table,
                      referencedTable: $$ProgramsTableReferences
                          ._userProgramsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProgramsTableReferences(
                        db,
                        table,
                        p0,
                      ).userProgramsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.programId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramsTable,
      Program,
      $$ProgramsTableFilterComposer,
      $$ProgramsTableOrderingComposer,
      $$ProgramsTableAnnotationComposer,
      $$ProgramsTableCreateCompanionBuilder,
      $$ProgramsTableUpdateCompanionBuilder,
      (Program, $$ProgramsTableReferences),
      Program,
      PrefetchHooks Function({bool userProgramsRefs})
    >;
typedef $$UserProgramsTableCreateCompanionBuilder =
    UserProgramsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      required String profileId,
      required String programId,
      required String status,
      Value<DateTime?> startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> endedAt,
      Value<double?> baselineWeightKg,
      Value<double?> targetWeightKg,
      Value<String?> targetDate,
      Value<double?> dailyEnergyTargetKcal,
      Value<double?> proteinTargetG,
      Value<double?> carbohydrateTargetG,
      Value<double?> fatTargetG,
      Value<double?> fiberTargetG,
      required String inputSnapshotJson,
      required String calculatorVersion,
      required String policyVersion,
      Value<String?> pauseReason,
      Value<String?> completionReason,
      Value<String?> supersedesUserProgramId,
      Value<String?> supersededByUserProgramId,
      Value<int> rowid,
    });
typedef $$UserProgramsTableUpdateCompanionBuilder =
    UserProgramsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      Value<String> profileId,
      Value<String> programId,
      Value<String> status,
      Value<DateTime?> startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> endedAt,
      Value<double?> baselineWeightKg,
      Value<double?> targetWeightKg,
      Value<String?> targetDate,
      Value<double?> dailyEnergyTargetKcal,
      Value<double?> proteinTargetG,
      Value<double?> carbohydrateTargetG,
      Value<double?> fatTargetG,
      Value<double?> fiberTargetG,
      Value<String> inputSnapshotJson,
      Value<String> calculatorVersion,
      Value<String> policyVersion,
      Value<String?> pauseReason,
      Value<String?> completionReason,
      Value<String?> supersedesUserProgramId,
      Value<String?> supersededByUserProgramId,
      Value<int> rowid,
    });

final class $$UserProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $UserProgramsTable, UserProgramRow> {
  $$UserProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias('user_programs__program_id__programs__id');

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<String>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProgramProgressTable, List<ProgramProgressRow>>
  _programProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.programProgress,
    aliasName: 'user_programs__id__program_progress__user_program_id',
  );

  $$ProgramProgressTableProcessedTableManager get programProgressRefs {
    final manager = $$ProgramProgressTableTableManager(
      $_db,
      $_db.programProgress,
    ).filter((f) => f.userProgramId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProgramEventsTable, List<ProgramEventRow>>
  _programEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.programEvents,
    aliasName: 'user_programs__id__program_events__user_program_id',
  );

  $$ProgramEventsTableProcessedTableManager get programEventsRefs {
    final manager = $$ProgramEventsTableTableManager(
      $_db,
      $_db.programEvents,
    ).filter((f) => f.userProgramId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_programEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgramsTable> {
  $$UserProgramsTableFilterComposer({
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

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineWeightKg => $composableBuilder(
    column: $table.baselineWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyEnergyTargetKcal => $composableBuilder(
    column: $table.dailyEnergyTargetKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinTargetG => $composableBuilder(
    column: $table.proteinTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateTargetG => $composableBuilder(
    column: $table.carbohydrateTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatTargetG => $composableBuilder(
    column: $table.fatTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberTargetG => $composableBuilder(
    column: $table.fiberTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputSnapshotJson => $composableBuilder(
    column: $table.inputSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculatorVersion => $composableBuilder(
    column: $table.calculatorVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionReason => $composableBuilder(
    column: $table.completionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersedesUserProgramId => $composableBuilder(
    column: $table.supersedesUserProgramId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersededByUserProgramId => $composableBuilder(
    column: $table.supersededByUserProgramId,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> programProgressRefs(
    Expression<bool> Function($$ProgramProgressTableFilterComposer f) f,
  ) {
    final $$ProgramProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programProgress,
      getReferencedColumn: (t) => t.userProgramId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramProgressTableFilterComposer(
            $db: $db,
            $table: $db.programProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programEventsRefs(
    Expression<bool> Function($$ProgramEventsTableFilterComposer f) f,
  ) {
    final $$ProgramEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programEvents,
      getReferencedColumn: (t) => t.userProgramId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramEventsTableFilterComposer(
            $db: $db,
            $table: $db.programEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgramsTable> {
  $$UserProgramsTableOrderingComposer({
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

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineWeightKg => $composableBuilder(
    column: $table.baselineWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyEnergyTargetKcal => $composableBuilder(
    column: $table.dailyEnergyTargetKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinTargetG => $composableBuilder(
    column: $table.proteinTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateTargetG => $composableBuilder(
    column: $table.carbohydrateTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatTargetG => $composableBuilder(
    column: $table.fatTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberTargetG => $composableBuilder(
    column: $table.fiberTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputSnapshotJson => $composableBuilder(
    column: $table.inputSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculatorVersion => $composableBuilder(
    column: $table.calculatorVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionReason => $composableBuilder(
    column: $table.completionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersedesUserProgramId => $composableBuilder(
    column: $table.supersedesUserProgramId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersededByUserProgramId => $composableBuilder(
    column: $table.supersededByUserProgramId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgramsTable> {
  $$UserProgramsTableAnnotationComposer({
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

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get baselineWeightKg => $composableBuilder(
    column: $table.baselineWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dailyEnergyTargetKcal => $composableBuilder(
    column: $table.dailyEnergyTargetKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinTargetG => $composableBuilder(
    column: $table.proteinTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateTargetG => $composableBuilder(
    column: $table.carbohydrateTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatTargetG => $composableBuilder(
    column: $table.fatTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberTargetG => $composableBuilder(
    column: $table.fiberTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputSnapshotJson => $composableBuilder(
    column: $table.inputSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculatorVersion => $composableBuilder(
    column: $table.calculatorVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionReason => $composableBuilder(
    column: $table.completionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supersedesUserProgramId => $composableBuilder(
    column: $table.supersedesUserProgramId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supersededByUserProgramId => $composableBuilder(
    column: $table.supersededByUserProgramId,
    builder: (column) => column,
  );

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> programProgressRefs<T extends Object>(
    Expression<T> Function($$ProgramProgressTableAnnotationComposer a) f,
  ) {
    final $$ProgramProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programProgress,
      getReferencedColumn: (t) => t.userProgramId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.programProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programEventsRefs<T extends Object>(
    Expression<T> Function($$ProgramEventsTableAnnotationComposer a) f,
  ) {
    final $$ProgramEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programEvents,
      getReferencedColumn: (t) => t.userProgramId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.programEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgramsTable,
          UserProgramRow,
          $$UserProgramsTableFilterComposer,
          $$UserProgramsTableOrderingComposer,
          $$UserProgramsTableAnnotationComposer,
          $$UserProgramsTableCreateCompanionBuilder,
          $$UserProgramsTableUpdateCompanionBuilder,
          (UserProgramRow, $$UserProgramsTableReferences),
          UserProgramRow,
          PrefetchHooks Function({
            bool programId,
            bool programProgressRefs,
            bool programEventsRefs,
          })
        > {
  $$UserProgramsTableTableManager(_$AppDatabase db, $UserProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> baselineWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<double?> dailyEnergyTargetKcal = const Value.absent(),
                Value<double?> proteinTargetG = const Value.absent(),
                Value<double?> carbohydrateTargetG = const Value.absent(),
                Value<double?> fatTargetG = const Value.absent(),
                Value<double?> fiberTargetG = const Value.absent(),
                Value<String> inputSnapshotJson = const Value.absent(),
                Value<String> calculatorVersion = const Value.absent(),
                Value<String> policyVersion = const Value.absent(),
                Value<String?> pauseReason = const Value.absent(),
                Value<String?> completionReason = const Value.absent(),
                Value<String?> supersedesUserProgramId = const Value.absent(),
                Value<String?> supersededByUserProgramId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgramsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                profileId: profileId,
                programId: programId,
                status: status,
                startedAt: startedAt,
                pausedAt: pausedAt,
                endedAt: endedAt,
                baselineWeightKg: baselineWeightKg,
                targetWeightKg: targetWeightKg,
                targetDate: targetDate,
                dailyEnergyTargetKcal: dailyEnergyTargetKcal,
                proteinTargetG: proteinTargetG,
                carbohydrateTargetG: carbohydrateTargetG,
                fatTargetG: fatTargetG,
                fiberTargetG: fiberTargetG,
                inputSnapshotJson: inputSnapshotJson,
                calculatorVersion: calculatorVersion,
                policyVersion: policyVersion,
                pauseReason: pauseReason,
                completionReason: completionReason,
                supersedesUserProgramId: supersedesUserProgramId,
                supersededByUserProgramId: supersededByUserProgramId,
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
                required String profileId,
                required String programId,
                required String status,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> baselineWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<double?> dailyEnergyTargetKcal = const Value.absent(),
                Value<double?> proteinTargetG = const Value.absent(),
                Value<double?> carbohydrateTargetG = const Value.absent(),
                Value<double?> fatTargetG = const Value.absent(),
                Value<double?> fiberTargetG = const Value.absent(),
                required String inputSnapshotJson,
                required String calculatorVersion,
                required String policyVersion,
                Value<String?> pauseReason = const Value.absent(),
                Value<String?> completionReason = const Value.absent(),
                Value<String?> supersedesUserProgramId = const Value.absent(),
                Value<String?> supersededByUserProgramId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgramsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                profileId: profileId,
                programId: programId,
                status: status,
                startedAt: startedAt,
                pausedAt: pausedAt,
                endedAt: endedAt,
                baselineWeightKg: baselineWeightKg,
                targetWeightKg: targetWeightKg,
                targetDate: targetDate,
                dailyEnergyTargetKcal: dailyEnergyTargetKcal,
                proteinTargetG: proteinTargetG,
                carbohydrateTargetG: carbohydrateTargetG,
                fatTargetG: fatTargetG,
                fiberTargetG: fiberTargetG,
                inputSnapshotJson: inputSnapshotJson,
                calculatorVersion: calculatorVersion,
                policyVersion: policyVersion,
                pauseReason: pauseReason,
                completionReason: completionReason,
                supersedesUserProgramId: supersedesUserProgramId,
                supersededByUserProgramId: supersededByUserProgramId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                programId = false,
                programProgressRefs = false,
                programEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (programProgressRefs) db.programProgress,
                    if (programEventsRefs) db.programEvents,
                  ],
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
                        if (programId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.programId,
                                    referencedTable:
                                        $$UserProgramsTableReferences
                                            ._programIdTable(db),
                                    referencedColumn:
                                        $$UserProgramsTableReferences
                                            ._programIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (programProgressRefs)
                        await $_getPrefetchedData<
                          UserProgramRow,
                          $UserProgramsTable,
                          ProgramProgressRow
                        >(
                          currentTable: table,
                          referencedTable: $$UserProgramsTableReferences
                              ._programProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).programProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userProgramId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programEventsRefs)
                        await $_getPrefetchedData<
                          UserProgramRow,
                          $UserProgramsTable,
                          ProgramEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$UserProgramsTableReferences
                              ._programEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).programEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userProgramId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgramsTable,
      UserProgramRow,
      $$UserProgramsTableFilterComposer,
      $$UserProgramsTableOrderingComposer,
      $$UserProgramsTableAnnotationComposer,
      $$UserProgramsTableCreateCompanionBuilder,
      $$UserProgramsTableUpdateCompanionBuilder,
      (UserProgramRow, $$UserProgramsTableReferences),
      UserProgramRow,
      PrefetchHooks Function({
        bool programId,
        bool programProgressRefs,
        bool programEventsRefs,
      })
    >;
typedef $$ProgramProgressTableCreateCompanionBuilder =
    ProgramProgressCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      required String userProgramId,
      required String recordedLocalDate,
      required DateTime recordedAt,
      Value<double?> weightKg,
      Value<double?> weightChangeKg,
      Value<double?> targetProgressRatio,
      Value<double?> consumedEnergyKcal,
      Value<double?> energyAdherenceRatio,
      Value<double?> proteinG,
      Value<double?> carbohydrateG,
      Value<double?> fatG,
      Value<int> loggedMealsCount,
      Value<bool> diaryComplete,
      required int activeDayNumber,
      Value<String> metricsJson,
      required String calculationVersion,
      Value<int> rowid,
    });
typedef $$ProgramProgressTableUpdateCompanionBuilder =
    ProgramProgressCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> revision,
      Value<String> userProgramId,
      Value<String> recordedLocalDate,
      Value<DateTime> recordedAt,
      Value<double?> weightKg,
      Value<double?> weightChangeKg,
      Value<double?> targetProgressRatio,
      Value<double?> consumedEnergyKcal,
      Value<double?> energyAdherenceRatio,
      Value<double?> proteinG,
      Value<double?> carbohydrateG,
      Value<double?> fatG,
      Value<int> loggedMealsCount,
      Value<bool> diaryComplete,
      Value<int> activeDayNumber,
      Value<String> metricsJson,
      Value<String> calculationVersion,
      Value<int> rowid,
    });

final class $$ProgramProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProgramProgressTable,
          ProgramProgressRow
        > {
  $$ProgramProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProgramsTable _userProgramIdTable(_$AppDatabase db) => db
      .userPrograms
      .createAlias('program_progress__user_program_id__user_programs__id');

  $$UserProgramsTableProcessedTableManager get userProgramId {
    final $_column = $_itemColumn<String>('user_program_id')!;

    final manager = $$UserProgramsTableTableManager(
      $_db,
      $_db.userPrograms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProgramIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramProgressTable> {
  $$ProgramProgressTableFilterComposer({
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

  ColumnFilters<String> get recordedLocalDate => $composableBuilder(
    column: $table.recordedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightChangeKg => $composableBuilder(
    column: $table.weightChangeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetProgressRatio => $composableBuilder(
    column: $table.targetProgressRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumedEnergyKcal => $composableBuilder(
    column: $table.consumedEnergyKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyAdherenceRatio => $composableBuilder(
    column: $table.energyAdherenceRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateG => $composableBuilder(
    column: $table.carbohydrateG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedMealsCount => $composableBuilder(
    column: $table.loggedMealsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diaryComplete => $composableBuilder(
    column: $table.diaryComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeDayNumber => $composableBuilder(
    column: $table.activeDayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProgramsTableFilterComposer get userProgramId {
    final $$UserProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableFilterComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramProgressTable> {
  $$ProgramProgressTableOrderingComposer({
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

  ColumnOrderings<String> get recordedLocalDate => $composableBuilder(
    column: $table.recordedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightChangeKg => $composableBuilder(
    column: $table.weightChangeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetProgressRatio => $composableBuilder(
    column: $table.targetProgressRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumedEnergyKcal => $composableBuilder(
    column: $table.consumedEnergyKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyAdherenceRatio => $composableBuilder(
    column: $table.energyAdherenceRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateG => $composableBuilder(
    column: $table.carbohydrateG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedMealsCount => $composableBuilder(
    column: $table.loggedMealsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diaryComplete => $composableBuilder(
    column: $table.diaryComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDayNumber => $composableBuilder(
    column: $table.activeDayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProgramsTableOrderingComposer get userProgramId {
    final $$UserProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramProgressTable> {
  $$ProgramProgressTableAnnotationComposer({
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

  GeneratedColumn<String> get recordedLocalDate => $composableBuilder(
    column: $table.recordedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get weightChangeKg => $composableBuilder(
    column: $table.weightChangeKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetProgressRatio => $composableBuilder(
    column: $table.targetProgressRatio,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consumedEnergyKcal => $composableBuilder(
    column: $table.consumedEnergyKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energyAdherenceRatio => $composableBuilder(
    column: $table.energyAdherenceRatio,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbohydrateG => $composableBuilder(
    column: $table.carbohydrateG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<int> get loggedMealsCount => $composableBuilder(
    column: $table.loggedMealsCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get diaryComplete => $composableBuilder(
    column: $table.diaryComplete,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeDayNumber => $composableBuilder(
    column: $table.activeDayNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => column,
  );

  $$UserProgramsTableAnnotationComposer get userProgramId {
    final $$UserProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramProgressTable,
          ProgramProgressRow,
          $$ProgramProgressTableFilterComposer,
          $$ProgramProgressTableOrderingComposer,
          $$ProgramProgressTableAnnotationComposer,
          $$ProgramProgressTableCreateCompanionBuilder,
          $$ProgramProgressTableUpdateCompanionBuilder,
          (ProgramProgressRow, $$ProgramProgressTableReferences),
          ProgramProgressRow,
          PrefetchHooks Function({bool userProgramId})
        > {
  $$ProgramProgressTableTableManager(
    _$AppDatabase db,
    $ProgramProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> userProgramId = const Value.absent(),
                Value<String> recordedLocalDate = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> weightChangeKg = const Value.absent(),
                Value<double?> targetProgressRatio = const Value.absent(),
                Value<double?> consumedEnergyKcal = const Value.absent(),
                Value<double?> energyAdherenceRatio = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbohydrateG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> loggedMealsCount = const Value.absent(),
                Value<bool> diaryComplete = const Value.absent(),
                Value<int> activeDayNumber = const Value.absent(),
                Value<String> metricsJson = const Value.absent(),
                Value<String> calculationVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramProgressCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                userProgramId: userProgramId,
                recordedLocalDate: recordedLocalDate,
                recordedAt: recordedAt,
                weightKg: weightKg,
                weightChangeKg: weightChangeKg,
                targetProgressRatio: targetProgressRatio,
                consumedEnergyKcal: consumedEnergyKcal,
                energyAdherenceRatio: energyAdherenceRatio,
                proteinG: proteinG,
                carbohydrateG: carbohydrateG,
                fatG: fatG,
                loggedMealsCount: loggedMealsCount,
                diaryComplete: diaryComplete,
                activeDayNumber: activeDayNumber,
                metricsJson: metricsJson,
                calculationVersion: calculationVersion,
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
                required String userProgramId,
                required String recordedLocalDate,
                required DateTime recordedAt,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> weightChangeKg = const Value.absent(),
                Value<double?> targetProgressRatio = const Value.absent(),
                Value<double?> consumedEnergyKcal = const Value.absent(),
                Value<double?> energyAdherenceRatio = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbohydrateG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> loggedMealsCount = const Value.absent(),
                Value<bool> diaryComplete = const Value.absent(),
                required int activeDayNumber,
                Value<String> metricsJson = const Value.absent(),
                required String calculationVersion,
                Value<int> rowid = const Value.absent(),
              }) => ProgramProgressCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                revision: revision,
                userProgramId: userProgramId,
                recordedLocalDate: recordedLocalDate,
                recordedAt: recordedAt,
                weightKg: weightKg,
                weightChangeKg: weightChangeKg,
                targetProgressRatio: targetProgressRatio,
                consumedEnergyKcal: consumedEnergyKcal,
                energyAdherenceRatio: energyAdherenceRatio,
                proteinG: proteinG,
                carbohydrateG: carbohydrateG,
                fatG: fatG,
                loggedMealsCount: loggedMealsCount,
                diaryComplete: diaryComplete,
                activeDayNumber: activeDayNumber,
                metricsJson: metricsJson,
                calculationVersion: calculationVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProgramId = false}) {
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
                    if (userProgramId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userProgramId,
                                referencedTable:
                                    $$ProgramProgressTableReferences
                                        ._userProgramIdTable(db),
                                referencedColumn:
                                    $$ProgramProgressTableReferences
                                        ._userProgramIdTable(db)
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

typedef $$ProgramProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramProgressTable,
      ProgramProgressRow,
      $$ProgramProgressTableFilterComposer,
      $$ProgramProgressTableOrderingComposer,
      $$ProgramProgressTableAnnotationComposer,
      $$ProgramProgressTableCreateCompanionBuilder,
      $$ProgramProgressTableUpdateCompanionBuilder,
      (ProgramProgressRow, $$ProgramProgressTableReferences),
      ProgramProgressRow,
      PrefetchHooks Function({bool userProgramId})
    >;
typedef $$ProgramEventsTableCreateCompanionBuilder =
    ProgramEventsCompanion Function({
      required String id,
      required DateTime createdAt,
      Value<String> syncStatus,
      Value<int> revision,
      required String userProgramId,
      required String eventType,
      required DateTime occurredAt,
      Value<String?> fromStatus,
      Value<String?> toStatus,
      Value<String?> reasonCode,
      Value<String> metadataJson,
      Value<int> rowid,
    });
typedef $$ProgramEventsTableUpdateCompanionBuilder =
    ProgramEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<int> revision,
      Value<String> userProgramId,
      Value<String> eventType,
      Value<DateTime> occurredAt,
      Value<String?> fromStatus,
      Value<String?> toStatus,
      Value<String?> reasonCode,
      Value<String> metadataJson,
      Value<int> rowid,
    });

final class $$ProgramEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProgramEventsTable, ProgramEventRow> {
  $$ProgramEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProgramsTable _userProgramIdTable(_$AppDatabase db) => db
      .userPrograms
      .createAlias('program_events__user_program_id__user_programs__id');

  $$UserProgramsTableProcessedTableManager get userProgramId {
    final $_column = $_itemColumn<String>('user_program_id')!;

    final manager = $$UserProgramsTableTableManager(
      $_db,
      $_db.userPrograms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProgramIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramEventsTable> {
  $$ProgramEventsTableFilterComposer({
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

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProgramsTableFilterComposer get userProgramId {
    final $$UserProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableFilterComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramEventsTable> {
  $$ProgramEventsTableOrderingComposer({
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProgramsTableOrderingComposer get userProgramId {
    final $$UserProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramEventsTable> {
  $$ProgramEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  $$UserProgramsTableAnnotationComposer get userProgramId {
    final $$UserProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProgramId,
      referencedTable: $db.userPrograms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPrograms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramEventsTable,
          ProgramEventRow,
          $$ProgramEventsTableFilterComposer,
          $$ProgramEventsTableOrderingComposer,
          $$ProgramEventsTableAnnotationComposer,
          $$ProgramEventsTableCreateCompanionBuilder,
          $$ProgramEventsTableUpdateCompanionBuilder,
          (ProgramEventRow, $$ProgramEventsTableReferences),
          ProgramEventRow,
          PrefetchHooks Function({bool userProgramId})
        > {
  $$ProgramEventsTableTableManager(_$AppDatabase db, $ProgramEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> userProgramId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String?> toStatus = const Value.absent(),
                Value<String?> reasonCode = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramEventsCompanion(
                id: id,
                createdAt: createdAt,
                syncStatus: syncStatus,
                revision: revision,
                userProgramId: userProgramId,
                eventType: eventType,
                occurredAt: occurredAt,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reasonCode: reasonCode,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> revision = const Value.absent(),
                required String userProgramId,
                required String eventType,
                required DateTime occurredAt,
                Value<String?> fromStatus = const Value.absent(),
                Value<String?> toStatus = const Value.absent(),
                Value<String?> reasonCode = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                syncStatus: syncStatus,
                revision: revision,
                userProgramId: userProgramId,
                eventType: eventType,
                occurredAt: occurredAt,
                fromStatus: fromStatus,
                toStatus: toStatus,
                reasonCode: reasonCode,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProgramId = false}) {
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
                    if (userProgramId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userProgramId,
                                referencedTable: $$ProgramEventsTableReferences
                                    ._userProgramIdTable(db),
                                referencedColumn: $$ProgramEventsTableReferences
                                    ._userProgramIdTable(db)
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

typedef $$ProgramEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramEventsTable,
      ProgramEventRow,
      $$ProgramEventsTableFilterComposer,
      $$ProgramEventsTableOrderingComposer,
      $$ProgramEventsTableAnnotationComposer,
      $$ProgramEventsTableCreateCompanionBuilder,
      $$ProgramEventsTableUpdateCompanionBuilder,
      (ProgramEventRow, $$ProgramEventsTableReferences),
      ProgramEventRow,
      PrefetchHooks Function({bool userProgramId})
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
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db, _db.programs);
  $$UserProgramsTableTableManager get userPrograms =>
      $$UserProgramsTableTableManager(_db, _db.userPrograms);
  $$ProgramProgressTableTableManager get programProgress =>
      $$ProgramProgressTableTableManager(_db, _db.programProgress);
  $$ProgramEventsTableTableManager get programEvents =>
      $$ProgramEventsTableTableManager(_db, _db.programEvents);
}
