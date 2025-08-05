// import 'package:blue_thermal_printer/blue_thermal_printer.dart'; // Temporarily disabled
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrintSettingScreen extends StatefulWidget {
  const PrintSettingScreen({super.key});

  @override
  State<PrintSettingScreen> createState() => _PrintSettingScreenState();
}

class _PrintSettingScreenState extends State<PrintSettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  String _status = "";

  // TestPrint testPrint = TestPrint();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
      // ignore: empty_catches
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _status = "bluetooth device state: connected";
            debugPrint("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: disconnected";
            debugPrint("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: disconnect requested";
            debugPrint("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: bluetooth turning off";
            debugPrint("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: bluetooth off";
            debugPrint("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            // _connected = true;
            _status = "bluetooth device state: bluetooth on";
            debugPrint("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: bluetooth turning on";
            debugPrint("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            _status = "bluetooth device state: error";
            debugPrint("bluetooth device state: error");
          });
          break;
        default:
          debugPrint(state.toString());
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan Printer",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: _connected ? Colors.green.shade800 : Colors.red.shade500,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Row(
              children: [
                _status.isNotEmpty
                    ? Text(
                        _status,
                        style: const TextStyle(color: Colors.white),
                      )
                    : const Text(
                        "Status tidak diketahui",
                        style: TextStyle(color: Colors.white),
                      ), // Text("$_status?")
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20),
                  child: DropdownButton(
                    items: _getDeviceItems(),
                    hint: const Text("Printer Devices"),
                    iconDisabledColor: Colors.white,
                    iconEnabledColor: Colors.white,
                    onChanged: (BluetoothDevice? value) =>
                        setState(() => _device = value),
                    value: _device,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      initPlatformState();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _connected ? Colors.red : Colors.green),
                    onPressed: _connected ? _disconnect : _connect,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _connected ? 'Disconnect' : 'Connect',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () async {
                bluetooth.printNewLine();
                bluetooth.printImage(
                    "https://www.svgrepo.com/show/69341/apple-logo.svg");
                bluetooth.printCustom("Bluetooth connected", 0, 1);
                bluetooth.printCustom("Hope You enjoy, Radja Kasir :)", 0, 1);
                bluetooth.printNewLine();
                bluetooth.printNewLine();
                bluetooth.printNewLine();
                bluetooth.printNewLine();
              },
              child: const Text('PRINT TEST',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name ?? ""),
        ));
      }
    }
    return items;
  }

  void _connect() {
    debugPrint(_device.toString());
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        debugPrint(isConnected.toString());
        if (isConnected == true) {
          // bluetooth.connect(_device!).catchError((error) {
          //   setState(() => _connected = false);
          // });
          setState(() => _connected = true);
        } else {
          bluetooth
              .connect(_device!)
              .then((value) => {setState(() => _connected = true)});
        }
      });
    } else {
      show('No device selected.');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
