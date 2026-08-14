// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'disaster_alert_model.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class DisasterAlertAdapter extends TypeAdapter<DisasterAlert> {
//   @override
//   final int typeId = 10;

//   @override
//   DisasterAlert read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return DisasterAlert(
//       id: fields[0] as String,
//       title: fields[1] as String,
//       summary: fields[2] as String,
//       source: fields[3] as String,
//       publishedAt: fields[4] as DateTime,
//       url: fields[5] as String,
//       severity: fields[6] as String?,
//       region: fields[7] as String?,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, DisasterAlert obj) {
//     writer
//       ..writeByte(8)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.title)
//       ..writeByte(2)
//       ..write(obj.summary)
//       ..writeByte(3)
//       ..write(obj.source)
//       ..writeByte(4)
//       ..write(obj.publishedAt)
//       ..writeByte(5)
//       ..write(obj.url)
//       ..writeByte(6)
//       ..write(obj.severity)
//       ..writeByte(7)
//       ..write(obj.region);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is DisasterAlertAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
