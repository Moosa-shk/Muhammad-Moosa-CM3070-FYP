// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_aid_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirstAidModelAdapter extends TypeAdapter<FirstAidModel> {
  @override
  final int typeId = 1;

  @override
  FirstAidModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FirstAidModel(
      title: fields[0] as String,
      description: fields[1] as String,
      steps: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FirstAidModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirstAidModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
