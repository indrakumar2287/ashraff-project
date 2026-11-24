

// **Main Commands** 
flutter clean
Flutter pub get
Flutter –version
Flutter doctor

// **Shortcuts**
Alt + Enter - Import and suggestion
Ctrl + Space = suggestion keys
Ctrl+ Alt + L = Format

// Important
MediaQuery.of(context).size.width,


// **Widgets**
1. MaterialApp - routes, themes, home
2. Scaffold = appbar, body , backgroundColor, floatingActionButton, drawer
3. Appbar - title, leading , actions, centerTitle,
4. SizedBox - width , height
5. Container - padding, margin , height, width, decoration- color, border, borderRadius,  — IMP
6. Text - string,textAlign,  style - fontSize, fontFamily, color, fontWeight
7. ElevatedButton - onPressed, style (Button Style ) - foregrounfColor, backGroundColor, shape ,
- (Parse Value in WidgetStatePropertyAll() )
8. GestureDetector - onTap, OnLongPress
   9.Drawer - width , styling, elevation ,
10.  Icon- Icons…. , size, color
11. FloatingActionButton - child , onpress
 ===
12. Row 
13. SingleChildScrollView 
14. textField - controller, style, hint , hintText , label , suffix, preficIcon, fillCOlor, color
15. Stack & Positioned 
16. Expanded & Flexible (take Child size)

Navigator.push(
context,
MaterialPageRoute(builder: (context) => HomeScreen()),
);
// push , Pushrelacement , pop

// 
Arguments, required key , 

SingleChildScrollView - axis , physics 

TextEditing Contollers 


// ListView.builder - itemCount, itemBuilder, scrollDirection, physics, shrinkWrap
// Lists 
// Row - Spacebetween , spaceAround , spaceEvenly , mainAxisAlignment, crossAxisAlignment

/// Async and await 
// GridView.builder 
// showDialog 
// showBottomSheet 

// DropdownButton - items, value, onChanged, hint, icon, underline, isExpanded
// Selection - 

// Github 
**Local Database**
 - SharedPreferences, Hive, Sqflite, Moor, Drift, 

**State Management** 
- GetX, Provider, Bloc, Riverpod, Mobx, Redux, 
- GetX - Controller, Obx, Get.put(), Get.find(), Get.snackbar(), Get.defaultDialog(), Get.bottomSheet(), Get.to(), Get.off(), Get.offAll()
- FormKey 
- Validators 

GetX Utilities 
GetX Routing - Get.to(), Get.off(), Get.offAll(), Get.back()
Responsive ui 
Assets and images 


Firebase Setup 
Firebase Auth - email/password


## Simple Firebase Chat

The chat example is in `lib/screens/chat/`. It uses the Firebase users already
created by signup in the `Users` collection.

1. Sign in with Firebase Authentication.
2. Open **Chats**, then tap **+** to choose another registered user.
3. The app creates or reuses a document in `chats`. Each document stores
   `members`, `memberNames`, `lastMessage`, `createdAt`, and `updatedAt`.
4. Messages are stored in that chat's `messages` subcollection with
   `senderId`, `senderName`, `text`, and `createdAt`.
5. Firestore snapshots update the chat list and message screen in real time.

`ChatController` contains the Firebase calls. The screens display its streams,
load users, and send messages. This keeps the example to one controller and
three screens.

Before running it, enable Cloud Firestore and Email/Password sign-in in the
Firebase project. Configure Firestore security rules to require authentication
and restrict chat reads and writes to members of that chat. Do not use open
rules in a deployed app.

## Module Home

The app opens on `HomeScreen`, which uses `GridView.builder` to navigate to the
learning modules. Sign-in and sign-up return to this screen. The logout button
asks for confirmation before signing out with Firebase Authentication.



// Push-Notifications 


 
// APk Command 
flutter build apk --release 
flutter build appbundle --release 
=
flutter pub get 
flutter clean 
==
fcm token
fzI_BLJeSkmV0zLyKBXZi4:APA91bHgneFKxvtSD7E02Pk_0BWVHryVWiBjo8mOuUktqCSsUv4sI33qup6aGLKA_YPNJf6be3-Zama6YclrTvpcSlq8D8Pf08QRocMmZPGtNPMH735TQmk


https://console.firebase.google.com/
=
// Frr APk 
https://www.diawi.com/. 
https://www.installonair.com/
flutter_projects/ashraff-project/build/app/outputs/flutter-apk/
==
