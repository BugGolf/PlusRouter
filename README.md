Easy Router for web application. 
---
This package using Navigator 2.0 system for routing easy in web application

# Using
การนำไปใช้งาน ทำการกำหนดเส้นทาง routes ไปยังหน้าแต่ละหน้าภายในแอพพลิเคชัน ตามตัวอย่าง

```dart
List<PlusRoute> routes = [
  PlusRoute(
    path: "/",
    builder: (state, args) => HomePage(routerState: state)
  ),
  PlusRoute(
    path: "/home/list",
    builder: (state, args) => WelcomePage(routerState: state)
  ),
  PlusRoute(
    path: "/home/list/:id",
    builder: (state, args) => HomeDetailPage(routerState: state, args: args)
  )
];
```

สร้าง MyApp กำหนดการ router ในรูปแบบ ใหม่ด้วยค่าต่าง ๆ ดังนี้
- กำหนด routerDelegate: ด้วย PlusRouterDelegate(routes)
- กำหนด routeInformationParser: PlusRouteInformationParser(routes)

```dart
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Demo Route',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: PlusRouterDelegate(routes),
      routeInformationParser: PlusRouteInformationParser(routes),
    );
  }
}
```

ดูตัวอย่างแบบเต็มได้ [ที่นี่](example/main.dart)

# Navigation
การเปลี่ยนเส้นทางภายในแต่ละหน้า จะไม่สามารถใช้วิธีการ Navigator.push(), Navigator.pushNamed() หรือ อื่นๆ ได้อีกต่อไป ให้ใช้วิธีการเปลี่ยนเส้นทางด้วย routerState.navigate(["home"), routerState.navigateByUrl("/home") ตัวอย่างเช่นภายในหน้า Home Page

```dart
class HomePage extends StatelessWidget {
  final PlusRouterState routerState;
  HomePage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          Container(child: Text("Home Page")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigateByUrl("/home/list");
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}
```

# URL Parameter
ในแต่ละหน้าสามารถรับค่าพารามิเตอร์ที่กำหนดไว้ใน URL ได้ด้วย เช่น /home/:id เมื่อผู้ใช้เข้าด้วย /home/1 เราจะสามารถรับค่า id ผ่านตัวแปร args ดังเช่นในตัวอย่าง Detail Page

```dart
class WelcomePage extends StatelessWidget {
  final PlusRouterState routerState;
  const WelcomePage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(child: Column(
        children: [
          Container(child: Text("Welcome Page")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigateByUrl("/home/list/100");
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}

class HomeDetailPage extends StatelessWidget {
  final PlusRouterState routerState;
  final Map<String, dynamic> args;
  const HomeDetailPage({ Key? key, required this.routerState, required this.args }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String arg = args["id"] ?? "None";

    return Scaffold(
       body: Center(child: Column(
        children: [
          Container(child: Text("Detail Page $arg")),
          Container(
            child: ElevatedButton(
              onPressed: () {
                this.routerState.back();
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}
```

# Contributing
เราต้องการนักพัฒนาอื่น ๆ ที่สามารถมีส่วนช่วยในการปรับปรุงวิธีการ Navigation สำหรับ Flutter for web ในง่ายกว่าเดิม ในปัจจุบันวิธีการยังขาดส่วนที่จำเป็นอื่น ๆ เช่น การย้อนกลับ การตรวจสอบยืนยันตัวตนอื่น ๆ