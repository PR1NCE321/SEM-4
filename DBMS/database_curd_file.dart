import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


const String NAME = "Name";
const String CITY = "City";
const String COLUMN_ID = "id";
const String TABLE_NAME = "crud";


class DatabaseDemo{

  Future<Database> initDatabase() async{


    String databasePath = await getDatabasesPath();
    print(databasePath);
    String path = join(databasePath , "crud.db");
    return await openDatabase(
      path,
      onCreate: (db , version){
        return db.execute(
            "CREATE TABLE $TABLE_NAME("
                "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT , "
                "$NAME TEXT , "
                "$CITY TEXT)"
        );
      },
      version: 1,
    );
  }

  Future<int> addUser(Map<String , dynamic> user) async{
    Database db = await initDatabase();

    return db.insert(TABLE_NAME, {
      NAME : user[NAME],
      CITY : user[CITY]
    });
  }

  Future<int> deleteUser(int id) async{
    Database db = await initDatabase();

    return await db.delete(TABLE_NAME ,
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<List<Map<String , dynamic>>> getUserList() async{
    Database db = await initDatabase();

    List<Map<String , dynamic>> userList = await db.query(TABLE_NAME);

    return userList;
  }

  Future<int> updateUser(int id , Map<String , dynamic> user) async{
    Database db = await initDatabase();

    return await db.update(
        TABLE_NAME,
        user,
        where: 'id = ?',
        whereArgs: [id]
    );
  }

}
