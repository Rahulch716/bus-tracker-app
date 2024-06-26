import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'driver-home.dart';
import 'home.dart';

FirebaseAuth auth = FirebaseAuth.instance;

StreamSubscription<User?> user =
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User is currently signed out!');
  } else {
    print('User is signed in!');
  }
});

GoogleSignIn _googleSignIn = GoogleSignIn(signInOption: SignInOption.standard);
// scopes: [
//   'email',
//   'https://www.googleapis.com/auth/contacts.readonly',
// ],
// );

Future<void> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}

handleSignOut() async => _googleSignIn.disconnect();

class Login extends StatelessWidget {
  // const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Tabbar(),
    );
  }
}

class Tabbar extends StatelessWidget {
  const Tabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('ICFAI BUS TRACKER'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/background_1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                      'images/Track_Your_Bus_Now-removebg-preview.png',
                      fit: BoxFit.cover),
                ),
                SizedBox(
                  height: 300,
                  width: 400,
                  child: Card(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 60,
                            child: TabBar(
                              labelColor: Colors.indigo,
                              unselectedLabelColor: Colors.indigo,
                              indicatorColor: Colors.blueGrey,
                              indicatorWeight: 2,
                              tabs: <Widget>[
                                Tab(
                                    text: "STUDENT LOGIN",
                                    icon: Icon(Icons.person)),
                                Tab(
                                    text: "DRIVER LOGIN",
                                    icon: Icon(Icons.airport_shuttle_rounded)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(75.0),
                                  child: ElevatedButton(
                                    child: const Text('Sign in with Google'),
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                      // _handleSignIn();
                                      // if (await _googleSignIn.isSignedIn() ==
                                      //     true) {
                                      //   Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //           builder: (context) => Home()));
                                      // }
                                    },
                                  ),
                                ),
                                MyCustomForm(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormModel {
  String? email;
  String? password;

  FormModel({this.email, this.password});
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final model = FormModel();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: TextFormField(
              onSaved: (value) {
                model.email = value;
              },
              decoration: InputDecoration(
                labelText: "Username",
                fillColor: Colors.white,
                contentPadding: new EdgeInsets.fromLTRB(0, 8.0, 8.0, 0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: TextFormField(
              obscureText: true,
              onSaved: (value) {
                model.password = value;
              },
              decoration: InputDecoration(
                labelText: "Password",
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                // if (_formKey.currentState!.validate()) {
                //   // If the form is valid, display a snackbar. In the real world,
                //   // you'd often call a server or save the information in a database.
                //   _formKey.currentState?.save();
                //   ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Processing Data')));
                //   if (kDebugMode) {
                //     print('email: ${model.email} password: ${model.password}');
                //   }
                //   try {
                //     if (model.email != null && model.password != null) {
                //       UserCredential userCredential =
                //           await auth.signInWithEmailAndPassword(
                //         email: model.email!,
                //         password: model.password!,
                //       );
                //     }
                //   } on FirebaseAuthException catch (e) {
                //     if (e.code == 'user-not-found') {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(content: Text('User not found :(')));
                //     } else if (e.code == 'wrong-password') {
                //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //           content: Text('Wrong password fool!')));
                //     }
                //   }
                // }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DriverHome()));
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
