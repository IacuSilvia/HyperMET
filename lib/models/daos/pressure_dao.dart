import 'package:floor/floor.dart';
import 'package:progetto/models/entities/exercise.dart';
import 'package:progetto/models/entities/pressure.dart';
//Here, we are saying that the following class defines a dao.

@dao
abstract class PressureDao {
  //Query #0: SELECT -> this allows to obtain all the entries of the pressure table of a certain date
  @Query(
      'SELECT * FROM Pressure WHERE dateTime between :startTime and :endTime ORDER BY dateTime ASC')
  Future<List<Pressure>> findPressurebyDate(
      DateTime startTime, DateTime endTime);

  //Query #1: SELECT -> this allows to obtain all the entries of the pressure table
  @Query('SELECT * FROM Pressure')
  Future<List<Pressure>> findAllPressure();

  //Query #2: INSERT -> this allows to add a pressure in the table
  @insert
  Future<void> insertPressure(Pressure pressureData);

  //Query #3: DELETE -> this allows to delete a pressure from the table
  @delete
  Future<void> deletePressure(Pressure pressureData);

  //Query #4: UPDATE -> this allows to update a pressure entry
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePressure(Pressure pressureData);

  @Query('SELECT * FROM Pressure ORDER BY dateTime ASC LIMIT 1')
  Future<Pressure?> findFirstDayInDb();

  @Query('SELECT * FROM Pressure ORDER BY dateTime DESC LIMIT 1')
  Future<Pressure?> findLastDayInDb();
}//PressureDao