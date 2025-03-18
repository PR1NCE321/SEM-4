import 'package:flutter/material.dart';

import 'api_file.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: api_crud(),
  ));
}

class api_crud extends StatefulWidget {
  @override
  State<api_crud> createState() => _api_crudState();
}

class _api_crudState extends State<api_crud> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey();
  List<dynamic> userList = [];

  bool isEditing = false;
  String? editingUserId;
  Api_Service apiService = Api_Service();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    var users = await apiService.getUsers(context);
    if (users is List) {
      setState(() {
        userList = users;
      });
    } else {
      print("Error: Unexpected response format -> $users");
    }
  }


  void startEditing(Map<String, dynamic> user) {
    setState(() {
      isEditing = true;
      editingUserId = user["id"].toString();
      nameController.text = user["name"] ?? "";
      cityController.text = user["city"] ?? "";
      emailController.text =user["email"] ?? "";
    });
  }

  void resetForm() {
    setState(() {
      isEditing = false;
      editingUserId = null;
      nameController.clear();
      cityController.clear();
      emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("API CRUD"),
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
                    labelText: "Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    hintText: "Enter Your City",
                    labelText: "City",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Your email",
                    labelText: "email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> user = {
                        "name": nameController.text,
                        "city": cityController.text,
                        "email":emailController.text
                      };

                      if (isEditing) {
                        await apiService.updateUser(id: editingUserId!, map: user, context: context);
                      } else {
                        await apiService.addUser(map: user, context: context);
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
                        title: Text(userList[index]["name"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userList[index]["city"] ?? "No City"),
                            Text(userList[index]["email"] ?? "No Email"),
                          ],
                        ),
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
                                            await apiService.deleteUser(
                                                id: userList[index]["id"].toString(),
                                                context: context);
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
