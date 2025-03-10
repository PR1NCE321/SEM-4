import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database_curd_file.dart';

void main(){
  runApp(MaterialApp(
    home: Crud(),
  ));
}

class Crud extends StatefulWidget {
  Crud({super.key});

  @override
  State<Crud> createState() => _CrudState();
}

class _CrudState extends State<Crud> {

  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey();
  List<Map<String , dynamic>> userList = [];

  void initState(){
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async{
    List<Map<String , dynamic>> users = await database.getUserList();

    setState(() {
      userList = users;
    });
  }

  DatabaseDemo database = DatabaseDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crud With Database"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        hintText: "Enter Your Name",
                        labelText: "Enter Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)
                        )
                    ),
                  ),
                ),

                SizedBox(height: 10,),

                Container(
                  child: TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                        hintText: "Enter Your City",
                        labelText: "Enter City",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        )
                    ),
                  ),
                ),

                ElevatedButton(onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    Map<String , dynamic> user = {
                      "Name" : nameController.text,
                      "City" : cityController.text
                    };

                    await database.addUser(user);

                    setState(() {
                      fetchUsers();
                    });

                    nameController.clear();
                    cityController.clear();
                  }
                }, child: Text("Add"),
                ),

                SizedBox(height: 20,),

                Text("UserList" ,
                  style: TextStyle(fontSize: 24 ,
                      fontWeight: FontWeight.bold
                  ),
                ),

                SizedBox(height: 10,),

                userList.isEmpty
                    ? Text("Not User Found")
                    : ListView.builder(
                    itemCount: userList.length,
                    shrinkWrap: true,
                    itemBuilder: (context , index){
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(userList[index]["Name"]),
                          subtitle: Text(userList[index]["City"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: (){
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context){
                                        TextEditingController editNameController = TextEditingController(text: userList[index]["Name"]);
                                        TextEditingController editCityController = TextEditingController(text: userList[index]["City"]);

                                        return Padding(padding: EdgeInsets.only(bottom: 10),
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Edit User" , style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),),

                                                SizedBox(height: 20,),

                                                TextFormField(
                                                  controller: editNameController,
                                                  decoration: InputDecoration(
                                                      labelText: "Edit Name",
                                                      border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(15)
                                                      )
                                                  ),
                                                ),

                                                SizedBox(height: 10,),

                                                TextFormField(
                                                  controller: editCityController,
                                                  decoration: InputDecoration(
                                                      labelText: "Edit City",
                                                      border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(15)
                                                      )
                                                  ),
                                                ),

                                                SizedBox(height: 20,),

                                                ElevatedButton(onPressed: () async{

                                                  Map<String , dynamic> updateUser = {
                                                    "Name" : editNameController.text,
                                                    "City" : editCityController.text
                                                  };

                                                  await database.updateUser(userList[index]["id"], updateUser);

                                                  setState(() {
                                                    fetchUsers();
                                                  });

                                                  Navigator.pop(context);
                                                }, child: Text("Update")),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),

                              IconButton(onPressed: () async{
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    title: Text("Are you sure you want to delete the user"),
                                    actions: [
                                      TextButton(onPressed: (){
                                        Navigator.pop(context);
                                      }, child: Text("Cancel")),

                                      TextButton(onPressed: () async{
                                        await database.deleteUser(index);
                                        Navigator.pop(context);
                                        fetchUsers();
                                      }, child: Text("Delete"))
                                    ],
                                  );
                                });
                              },
                                icon: Icon(Icons.delete),
                              )
                            ],
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
