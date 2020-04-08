import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import "dart:ui";

void main() {
  runZoned(() {
    runApp(MyApp());
  }, onError: (dynamic error, dynamic stack) {
    print(error);
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    // return <String, dynamic>{
    //   'version.securityPatch': build.version.securityPatch,
    //   'version.sdkInt': build.version.sdkInt,
    //   'version.release': build.version.release,
    //   'version.previewSdkInt': build.version.previewSdkInt,
    //   'version.incremental': build.version.incremental,
    //   'version.codename': build.version.codename,
    //   'version.baseOS': build.version.baseOS,
    //   'board': build.board,
    //   'bootloader': build.bootloader,
    //   'brand': build.brand,
    //   'device': build.device,
    //   'display': build.display,
    //   'fingerprint': build.fingerprint,
    //   'hardware': build.hardware,
    //   'host': build.host,
    //   'id': build.id,
    //   'manufacturer': build.manufacturer,
    //   'model': build.model,
    //   'product': build.product,
    //   'supported32BitAbis': build.supported32BitAbis,
    //   'supported64BitAbis': build.supported64BitAbis,
    //   'supportedAbis': build.supportedAbis,
    //   'tags': build.tags,
    //   'type': build.type,
    //   'isPhysicalDevice': build.isPhysicalDevice,
    //   'androidId': build.androidId,
    //   'systemFeatures': build.systemFeatures,
    // };
    String boardName;
    if (build.board.startsWith("sdm")) {
      boardName = build.board.replaceAll("sdm", "晓龙");
    }
    String deviceName;
    if (build.device.startsWith("star2")) {
      deviceName = "三星s9+";
    }
    String hardName;
    if (build.hardware.startsWith("qcom")) {
      hardName = "高通";
    }

    return <String, dynamic>{
      '安卓版本': build.version.release,
      '基带版本': build.version.incremental,
      '芯片': boardName == null ? build.board : boardName,
      '品牌': build.brand,
      '手机型号': deviceName == null ? build.device : deviceName,
      // 'display': build.display,
      '硬件': hardName == null ? build.hardware : hardName,
      '生产厂商': build.manufacturer,
      '手机版本': build.model,
      // 'window.devicePixelRatio':window.devicePixelRatio,
      '屏幕分辨率': window.physicalSize.height.toString() +
          " x " +
          window.physicalSize.width.toString()
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width.truncateToDouble();
    final height = size.height;

    setState(() {
      this._deviceData.putIfAbsent(
          "物理宽高", () => width.toStringAsFixed(2) + " x " + height.toStringAsFixed(2));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
            Platform.isAndroid ? 'Android Device Info' : 'iOS Device Info'),
      ),
      body: ListView(
        children: _deviceData.keys.map((String property) {
          return Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  property,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(
                  '${_deviceData[property]}',
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
