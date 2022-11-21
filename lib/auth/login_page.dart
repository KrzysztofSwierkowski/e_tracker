import 'package:flutter/material.dart';
import 'package:phone_mqtt/auth/auth.dart';
import 'package:phone_mqtt/auth/loginuser.dart';

class LoginPage extends StatefulWidget {
  final Function? toggleView;
  LoginPage({this.toggleView});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: _email,
      autofocus: false,
      // validator: (value) {
      //   if (value != null) {
      //     if (value.contains('@')) {
      //       return null;
      //     }
      //     return 'Wpisz prawidłowy adres e-mail';
      //   }
      // },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final passwordField = TextFormField(
        obscureText: _obscureText,
        controller: _password,
        autofocus: false,
        // validator: (value) {
        //   if (value == null || value.trim().isEmpty) {
        //     return 'Pole obowiązkowe !';
        //   }
        //   if (value.trim().length < 4) {
        //     return 'Hasło musi mieć więcej niż 4 znaki';
        //   }
        //   return null;
        // },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Hasło",
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

    final txtbutton = TextButton(
        onPressed: () {
          widget.toggleView!();
        },
        child: const Text('Zarejestruj się'));

    // final anonymousLoginButton = Material(
    //   elevation: 5.0,
    //   borderRadius: BorderRadius.circular(30.0),
    //   //color: Theme.of(context).primaryColor,
    //   child: OutlinedButton(
    //     onPressed: () async {
    //       if (_formKey.currentState!.validate()) {
    //         dynamic result = await _auth.signInAnonymous();
    //         if (result.uid == null) {
    //           showDialog(
    //               context: context,
    //               builder: (context) {
    //                 return AlertDialog(
    //                   content: Text(result.code),
    //                 );
    //               });
    //         }
    //       }
    //     },
    //     child: Text(
    //       "Logowanie anonimowe",
    //       //style: TextStyle(color: Theme.of(context).primaryColorDark),
    //       textAlign: TextAlign.center,
    //     ),
    //   ),
    // );


    final loginEmailPasswordButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      //color: Theme.of(context).primaryColor,
      child: OutlinedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {

            dynamic result = await _auth.signInEmailPassword(LoginUser(email: _email.text,password: _password.text));
            if (result.uid == null) { //null means unsuccessfull authentication
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(result.code),
                    );
                  });
            }
          }
        },
        child: Text(
          "Zaloguj",
          //style: TextStyle(color: Theme.of(context).primaryColorLight),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Logowanie'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  const SizedBox(height: 45.0),
                  emailField,
                  const SizedBox(height:30.0),
                  passwordField,
                  const SizedBox(height:30),
                  txtbutton,
                  const SizedBox(height:30),
                  loginEmailPasswordButton,
                  const SizedBox(height:30),
                  //anonymousLoginButton,
                  const SizedBox(height: 15.0),
                ],
              ),
            ),
          )
        ],
      )
    );


  }
}
