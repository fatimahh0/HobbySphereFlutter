import 'package:flutter/material.dart'; // Flutter core widgets
import 'app.dart'; // Our root App widget

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Make sure bindings are ready
  runApp(const App()); // Run the app
}
