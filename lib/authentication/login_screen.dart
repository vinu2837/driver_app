import 'package:driver_app/authentication/signup_screen.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/splashScreen/splash_screen.dart';
import 'package:driver_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {
     if(!emailTextEditingController.text.contains("@"))
    {
      Fluttertoast.showToast(msg: "Email address is not valid");
    }

    else if(passwordTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Password is mandatory");
    }
    else
    {
       loginDriverNow();
    }
  }

  loginDriverNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return ProgressDialog(message: "Processing, Please Wait...",);
        }
    );
    final User? firebaseUser = (
        await fAuth.signInWithEmailAndPassword(
          email:  emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());
        })
    ).user;
    if(firebaseUser!= null)
    {
      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
      driversRef.child(firebaseUser.uid).once().then((driverKey)
      {
        final snap = driverKey.snapshot;
        if(snap.value != null)
          {
            currentFirebaseUser = firebaseUser;
            Fluttertoast.showToast(msg: "Login Successful");
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
        else
          {
            Fluttertoast.showToast(msg: "No record exist record found");
            fAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
      });



    }
    else
    {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occurred during login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),

          const SizedBox(height: 10,),
          const Text(
            "Login as a Driver",
            style:  TextStyle(
              fontSize: 26,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",

                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),

                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",

                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),

                ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                 validateForm();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
               child: const Text(
                 "Do not have an Account? SignUp Here",
                 style: TextStyle(color: Colors.grey),

               ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}
