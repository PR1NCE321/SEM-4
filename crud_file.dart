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
  List<Map<String, dynamic>> userList = [];

  bool isEditing = false;
  int? editingUserId;

  DatabaseDemo database = DatabaseDemo();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> users = await database.getUserList();
    setState(() {
      userList = users;
    });
  }

  void startEditing(Map<String, dynamic> user) {
    setState(() {
      isEditing = true;
      editingUserId = user["id"];
      nameController.text = user["Name"];
      cityController.text = user["City"];
    });
  }

  void resetForm() {
    setState(() {
      isEditing = false;
      editingUserId = null;
      nameController.clear();
      cityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("DATABASE CRUD"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Name",
                    labelText: "Enter Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    hintText: "Enter Your City",
                    labelText: "Enter City",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> user = {
                        "Name": nameController.text,
                        "City": cityController.text
                      };

                      if (isEditing) {
                        await database.updateUser(editingUserId!, user);
                      } else {
                        await database.addUser(user);
                      }

                      resetForm();
                      fetchUsers();
                    }
                  },
                  child: Text(isEditing ? "Update" : "Add"),
                ),
                SizedBox(height: 20),
                Text(
                  "User List",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                userList.isEmpty
                    ? Text("No Users Found")
                    : ListView.builder(
                  itemCount: userList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
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
                              onPressed: () {
                                startEditing(userList[index]);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Are you sure you want to delete the user?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await database.deleteUser(
                                                userList[index]["id"]);
                                            Navigator.pop(context);
                                            fetchUsers();
                                          },
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
