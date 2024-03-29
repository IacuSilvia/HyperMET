import 'package:floor/floor.dart';
import 'package:progetto/models/entities/exercise.dart';

//Here, we are saying that the following class defines a dao.

@dao
abstract class ExerciseDao {
  //Query #0: SELECT -> this allows to obtain all the entries of the EX table of a certain date
  @Query(
      'SELECT * FROM Ex WHERE dateTime between :startTime and :endTime ORDER BY dateTime ASC')
  Future<List<Ex>> findExercisebyDate(DateTime startTime, DateTime endTime);

  //Query #1: SELECT -> this allows to obtain all the entries of the exercise table
  @Query('SELECT * FROM Ex')
  Future<List<Ex>> findAllExercise();

  //Query #2: INSERT -> this allows to add a EX in the table
  @insert
  Future<void> insertExercise(Ex exercisesData);

  //Query #3: DELETE -> this allows to delete a EX from the table
  @delete
  Future<void> deleteExercise(Ex exercisesData);

  //Query #4: UPDATE -> this allows to update a EX entry
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateExercise(Ex exercisesData);

  @Query('SELECT * FROM Ex ORDER BY dateTime ASC LIMIT 1')
  Future<Ex?> findFirstDayInDb();

  @Query('SELECT * FROM Ex ORDER BY dateTime DESC LIMIT 1')
  Future<Ex?> findLastDayInDb();
}//ExerciseDao