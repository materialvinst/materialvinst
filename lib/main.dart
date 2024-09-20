import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Material till salu'),
    );
  }
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

class MaterialCard extends Container {
  final String name;
  final String date;
  final String place;
  final String seller;

  @override
  Widget get child {
    return getTextRows();
  }

  MaterialCard({
    required this.name,
    required this.date,
    required this.place,
    required this.seller,
    double height = 150,
    width = double.infinity,
    margin = const EdgeInsets.all(8),
    padding = const EdgeInsets.all(12),
    color = Colors.lightBlue,
  }) : super(
          height: height,
          width: width,
          margin: margin,
          padding: padding,
          color: color,
        );

  Text getTitle([double size = 25]) {
    return Text(name, style: TextStyle(fontSize: size));
  }

  Row getInfoRow(IconData icon, String info, [double size = 18]) {
    return Row(children: [
      Icon(icon, size: size),
      Text(" $info", style: TextStyle(fontSize: size)),
    ]);
  }

  Column getTextRows() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          getTitle(),
          getInfoRow(Icons.schedule, date),
          getInfoRow(Icons.location_on, place),
          getInfoRow(Icons.domain, seller),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState gtells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialList(children: [
              MaterialCard(
                  name: "Material",
                  date: "5 dagar sen",
                  place: "Knislinge",
                  seller: "PEAB"),
              MaterialCard(
                  name: "Material",
                  date: "5 dagar sen",
                  place: "Knislinge",
                  seller: "PEAB"),
              MaterialCard(
                  name: "Material",
                  date: "5 dagar sen",
                  place: "Knislinge",
                  seller: "PEAB"),
              MaterialCard(
                  name: "Material",
                  date: "5 dagar sen",
                  place: "Knislinge",
                  seller: "PEAB"),
            ]),
            Padding(
                padding: EdgeInsets.all(20),
                child: SearchBar(
                  hintText: "Sök på material...",
                )),
            NavigationBar(
              destinations: [
                const Icon(Icons.home),
                const Icon(Icons.volunteer_activism),
                const Icon(Icons.settings),
              ],
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.info),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
