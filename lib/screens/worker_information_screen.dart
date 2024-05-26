import 'dart:io';

import 'package:allobrico_worker/model/worker_model.dart';
import 'package:allobrico_worker/provider/auth_provider.dart';
import 'package:allobrico_worker/screens/home_screen.dart';
import 'package:allobrico_worker/utils/utils.dart';
import 'package:allobrico_worker/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  String? selectedWorkerType;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  // for selecting image
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 53, 105, 1),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => selectImage(),
                        child: image == null
                            ? const CircleAvatar(
                                backgroundColor: Color.fromRGBO(251, 53, 105, 1),
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!),
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // name field
                            textField(
                              hintText: "John Smith",
                              icon: Icons.account_circle,
                              inputType: TextInputType.name,
                              maxLines: 1,
                              controller: nameController,
                            ),

                            // email
                            textField(
                              hintText: "abc@example.com",
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              maxLines: 1,
                              controller: emailController,
                            ),

                            // bio
                            textField(
                              hintText: "Enter your bio here",
                              icon: Icons.edit,
                              inputType: TextInputType.name,
                              maxLines: 2,
                              controller: bioController,
                            ),
                            // Worker type selection
                            DropdownButtonFormField<String>(
                              value: selectedWorkerType,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedWorkerType = newValue;
                                });
                              },
                              items: <String>['Plombier', 'Electricien', 'peintre']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Worker Type',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              ),
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () => storeData(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget textField({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Color.fromRGBO(251, 53, 105, 1),
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(251, 53, 105, 1),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Color.fromARGB(255, 255, 230, 236),
          filled: true,
        ),
      ),
    );
  }

  // store user data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (selectedWorkerType != null) {
      WorkerModel workerModel = WorkerModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        bio: bioController.text.trim(),
        profilePic: "",
        createdAt: "",
        phoneNumber: "",
        uid: "",
        workerType: getWorkerTypeFromString(selectedWorkerType!),
      );
      if (image != null) {
        ap.saveUserDataToFirebase(
          context: context,
          workerModel: workerModel,
          profilePic: image!,
          onSuccess: () {
            ap.saveUserDataToSP().then(
                  (value) => ap.setSignIn().then(
                        (value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                );
          },
        );
      } else {
        showSnackBar(context, "Please upload your profile photo");
      }
    } else {
      showSnackBar(context, "Please select worker type");
    }
  }

  WorkerType getWorkerTypeFromString(String typeString) {
    switch (typeString) {
      case 'Plombier':
        return WorkerType.plombier;
      case 'Electricien':
        return WorkerType.electricien;
      case 'Peintre':
        return WorkerType.peintre;
      default:
        throw Exception("Invalid worker type string: $typeString");
    }
  }
  
}

