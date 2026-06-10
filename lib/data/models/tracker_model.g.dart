// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerModelAdapter extends TypeAdapter<TrackerModel> {
  @override
  final int typeId = 0;

  @override
  TrackerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackerModel(
      id: fields[0] as String,
      type: fields[1] as TrackerType,
      title: fields[2] as String,
      startDate: fields[3] as DateTime,
      description: fields[4] as String?,
      color: fields[5] as String,
      person1Name: fields[6] as String?,
      person2Name: fields[7] as String?,
      person1AvatarPath: fields[8] as String?,
      person2AvatarPath: fields[9] as String?,
      singleTrackerName: fields[10] as String?,
      singleTrackerIconPath: fields[11] as String?,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackerModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.person1Name)
      ..writeByte(7)
      ..write(obj.person2Name)
      ..writeByte(8)
      ..write(obj.person1AvatarPath)
      ..writeByte(9)
      ..write(obj.person2AvatarPath)
      ..writeByte(10)
      ..write(obj.singleTrackerName)
      ..writeByte(11)
      ..write(obj.singleTrackerIconPath)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerModel _$TrackerModelFromJson(Map<String, dynamic> json) => TrackerModel(
      id: json['id'] as String,
      type: $enumDecode(_$TrackerTypeEnumMap, json['type']),
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      description: json['description'] as String?,
      color: json['color'] as String,
      person1Name: json['person1Name'] as String?,
      person2Name: json['person2Name'] as String?,
      person1AvatarPath: json['person1AvatarPath'] as String?,
      person2AvatarPath: json['person2AvatarPath'] as String?,
      singleTrackerName: json['singleTrackerName'] as String?,
      singleTrackerIconPath: json['singleTrackerIconPath'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrackerModelToJson(TrackerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TrackerTypeEnumMap[instance.type]!,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'description': instance.description,
      'color': instance.color,
      'person1Name': instance.person1Name,
      'person2Name': instance.person2Name,
      'person1AvatarPath': instance.person1AvatarPath,
      'person2AvatarPath': instance.person2AvatarPath,
      'singleTrackerName': instance.singleTrackerName,
      'singleTrackerIconPath': instance.singleTrackerIconPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TrackerTypeEnumMap = {
  TrackerType.pairBond: 'pairBond',
  TrackerType.single: 'single',
};
