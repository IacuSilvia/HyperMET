import 'package:floor/floor.dart';

@entity
class Pressure {
  //id will be the primary key of the table. Moreover, it will be autogenerated.
  //id is nullable since it is autogenerated.
  @PrimaryKey(autoGenerate: true)
  final int? id;

  //The systolic pressure
  final int systolic;

  //The diastolic pressure
  final int diastolic;

  //When the pressure was registered
  final DateTime dateTime;

  //Default constructor
  Pressure(this.id, this.systolic,this.diastolic, this.dateTime);

} //Pressure