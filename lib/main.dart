import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'models/sellobj.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

Future<List<SellObj>> fetchSellObjs() async {
  final response = await http.get(Uri.parse('http://localhost:8080/materials'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((dynamic item) => SellObj.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load sell objs');
  }
}

class SellObjsScreen extends StatefulWidget {
  @override
  _SellObjsScreenState createState() => _SellObjsScreenState();
}

class _SellObjsScreenState extends State<SellObjsScreen> {
  late Future<List<SellObj>> futureSellObjs;
  List<SellObj> filteredSellObjs = [];

  // Variable to hold search query
  String query = "";

  @override
  void initState() {
    super.initState();
    futureSellObjs = fetchSellObjs();
  }

  // This method will filter the list based on the search query
  void _filterItems(String enteredKeyword, List<SellObj> sellObjs) {
    List<SellObj> results = [];
    if (enteredKeyword.isEmpty) {
      // If search query is empty, display all items
      results = sellObjs;
    } else {
      // Filter the list based on the entered keyword
      results = sellObjs
          .where((sellObj) =>
              sellObj.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Update the filtered list
    setState(() {
      filteredSellObjs = results;
      query = enteredKeyword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(children: [
      (FutureBuilder<List<SellObj>>(
        future: futureSellObjs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No persons found'));
          } else {
            List<SellObj> sellobjs = snapshot.data!;
            // Initially, display all items
            if (query.isEmpty) {
              filteredSellObjs = sellobjs;
            }
            return ListView.builder(
              itemCount: filteredSellObjs.length,
              itemBuilder: (context, index) {
                return MaterialCard(sellObj: filteredSellObjs[index]);
              },
            );
          }
        },
      )),
      Positioned(
          bottom: 20,
          right: 40,
          left: 40,
          child: SearchBar(
            hintText: "Sök på material...",
            onChanged: (value) {
              futureSellObjs.then((items) {
                _filterItems(value, items);
              });
            },
            // backgroundColor: WidgetStateProperty.all<Color>(
            //     Theme.of(context).colorScheme.surfaceContainerHigh),
            // backgroundColor:
            // WidgetStateProperty.all<Color>(Colors.white),
            // shadowColor: WidgetStateProperty.all<Color>(Colors.white38),
          )),
    ]));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('sv'), // Spanish
      ],
      home: const MyHomePage(title: 'Material till salu'),
      routes: {
        '/hem': (context) => MyHomePage(title: "Material till salu"),
        '/sälj': (context) => SellRoute(),
      },
    );
  }
}

Row getInfoRow(IconData icon, String info, [double size = 18]) {
  return Row(children: [
    Icon(icon, size: size),
    Text(" $info", style: TextStyle(fontSize: size)),
  ]);
}

class MaterialList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final ListView view;
  MaterialList({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(8),
  }) : view = ListView(
          padding: padding,
          children: children,
        ); // <- initializer list

  @override
  Widget build(BuildContext context) {
    return Expanded(child: view);
  }
}

class MaterialCard extends StatelessWidget {
  final SellObj sellObj;
  final double height;
  final double width;
  dynamic margin;
  dynamic padding;

  MaterialCard({
    required this.sellObj,
    this.height = 310,
    this.width = double.infinity,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(12),
  });

  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Stack(children: [
        getTextRows(context),
        Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 40, color: Colors.amber)),
              child: const Text("Info"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondRoute(
                            sellObj: sellObj,
                          )),
                );
              },
            ))
      ]),
    ).build(context);
  }

  Text getTitle([double size = 25]) {
    return Text(sellObj.name,
        style: TextStyle(fontSize: size, decoration: TextDecoration.underline));
  }

  Column getTextRows(BuildContext context) {
    var url = "http://localhost:8080/materialpic/${sellObj.id}";
    print(url);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              child: Image.network(
                url,
                width: double.infinity,
                height: 150,
                fit: BoxFit.fitWidth,
              )),
          getTitle(),
          getInfoRow(Icons.schedule, sellObj.date),
          getInfoRow(Icons.location_on, sellObj.place),
          getInfoRow(Icons.domain, sellObj.seller),
        ]);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Define a function to handle navigation based on index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different routes based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/hem');
        break;
      case 1:
        Navigator.pushNamed(context, '/sälj');
        break;
      case 2:
        Navigator.pushNamed(context, '/screen3');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.surface,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SellObjsScreen(),
            BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped, // This handles taps on the nav bar
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Hem',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Sälj',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Inställningar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController to get input from the form fields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool isUploading = false;

  // Function to pick an image from the gallery
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to upload image to server via HTTP
  Future uploadImage(File imageFile) async {
    setState(() {
      isUploading = true;
    });

    var uri = Uri.parse("http://localhost:8080/upload");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        print('Response: $jsonData');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while uploading image: $e');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed.
    nameController.dispose();
    placeController.dispose();
    sellerController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Function to post form data to the API
  Future<int> submitForm() async {
    // Replace with your API endpoint
    const String apiUrl = "http://localhost:8080/material";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'place': placeController.text,
          'seller': sellerController.text
        }),
      );

      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Skapa annons'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Vad säljes?',
                    ),
                    // Validator to check if the name field is not empty.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Var god ange titel';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: placeController,
                    decoration: InputDecoration(
                      labelText: 'Plats:',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: sellerController,
                    decoration: InputDecoration(
                      labelText: 'Säljes av:',
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Beskrivning:'),
                      minLines: 5,
                      maxLines: 99),
                  SizedBox(height: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image == null
                          ? Text('Ingen bild vald')
                          : Image.file(_image!,
                              height: 150), // Display the selected image
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: pickImage,
                        child: Text('Välj bild'),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate the form by checking the validators in each field.
                      if (_formKey.currentState!.validate()) {
                        int result = await submitForm();
                        if (_image != null) {
                          await uploadImage(_image!);
                        }
                        if (!mounted) {
                          return;
                        } else if (result == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Form submitted successfully!')),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyHomePage(title: "Material till salu")),
                          );
                        } else {
                          // If the submission fails, execute this block
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit form')),
                          );
                        }
                      } else {
                        // If the submission fails, execute this block
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit form')),
                        );
                      }
                    },
                    child: Text('Skicka in annons',
                        style: TextStyle(fontSize: 25)),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class SellRoute extends StatelessWidget {
  const SellRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Theme.of(context).colorScheme.inversePrimary,
            child: MyForm()));
  }
}

class SecondRoute extends StatelessWidget {
  final SellObj sellObj;
  const SecondRoute({super.key, required this.sellObj});
  // Widget build(BuildContext context) {
  //   return Container(
  //     height: height,
  //     width: width,
  //     margin: margin,
  //     padding: padding,
  //     color: Theme.of(context).colorScheme.inversePrimary,
  //     child: Stack(children: [
  //       getTextRows(context),
  //       Align(
  //           alignment: Alignment.bottomRight,
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //                 textStyle: TextStyle(fontSize: 40, color: Colors.amber)),
  //             child: const Text("Info"),
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => SecondRoute(
  //                           sellObj: sellObj,
  //                         )),
  //               );
  //             },
  //           ))
  //     ]),
  //   ).build(context);
  // }

  @override
  Widget build(BuildContext context) {
    var url = "http://localhost:8080/materialpic/${sellObj.id}";
    return Scaffold(
        appBar: AppBar(
          title: const Text('Second Route'),
        ),
        body: SingleChildScrollView(
            child: Expanded(
                child: Container(
          color: Theme.of(context).colorScheme.inversePrimary,
          padding: EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.network(
              url,
              width: double.infinity,
              height: 500,
              fit: BoxFit.fitWidth,
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Text(sellObj.name, style: TextStyle(fontSize: 40)),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            getInfoRow(Icons.schedule, sellObj.date, 24),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            getInfoRow(Icons.place, sellObj.place, 24),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            getInfoRow(Icons.domain, sellObj.seller, 24),
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Text("Beskrivning:", style: TextStyle(fontSize: 25)),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec ante feugiat, porta enim ut, sagittis risus. Donec lobortis eleifend nunc eu finibus. In placerat massa sapien, a consectetur lectus tristique eu. Cras interdum dolor turpis, non condimentum metus faucibus nec. Donec ullamcorper porta sapien, a dignissim tortor molestie tristique. Curabitur porta in magna ac facilisis. Ut dictum urna vehicula purus egestas euismod. Donec a felis vel felis pulvinar aliquam. Vivamus nec rhoncus nunc. Nullam consectetur quam placerat ipsum tempus fermentum. Vestibulum vel mauris at ex commodo blandit. In vitae nisl id lacus viverra dictum eu et mauris. Phasellus quis est sit amet libero tincidunt egestas. Sed nec risus luctus magna vehicula ultricies et quis tellus. Fusce quis blandit neque, sed semper odio. Nullam id lacus porta, ultricies lectus sed, mollis enim.",
                style: TextStyle(fontSize: 20))
          ]),
        ))));
  }
}
        // child: ElevatedButton(
        //   onPressed: () {
        //     // Navigate back to first route when tapped.
        //   },
        //   child: Text(sellObj.name),
        // ),
//       ),
//     );
//   }
// }
