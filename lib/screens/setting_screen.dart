// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../providers/balance_provider.dart';
import '../widgets/appBar.dart';
import '../widgets/button.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool connected = false;
  List<BluetoothInfo> items = [];
  String? macConnected;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getBluetooth();
  }

  Future<void> initPlatformState() async {
    try {
      await PrintBluetoothThermal.platformVersion;
      await PrintBluetoothThermal.batteryLevel;
      await checkBluetoothStatus();
    } on PlatformException {
      debugPrint("Failed to get platform version");
    }
  }

  Future<void> checkBluetoothStatus() async {
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      debugPrint("Bluetooth is disabled");
    }
  }

  Future<void> getBluetooth() async {
    setState(() => items = []);

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() => items = listResult);
    }
  }

  Future<void> connect(String macAddress) async {
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
    if (result) {
      setState(() {
        connected = true;
        macConnected = macAddress;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer connected: $macAddress'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    if (status) {
      setState(() {
        connected = false;
        macConnected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldo = ref.watch(balanceProvider);

    return Scaffold(
      appBar: cAppBar(
        noRek: '123456789',
        name: 'Rekayasa Perangkat Lunak',
        saldo: saldo.toString(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/smkpgriwlingi.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Refresh ->',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                size: 30, color: Colors.black),
                            onPressed: getBluetooth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      items.isEmpty
                          ? Text(
                              'Tidak ada perangkat yang terhubung',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Column(
                              children: items.map((device) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade100,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device.name,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            device
                                                .macAdress, // Menggunakan 'macAdress'
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () => connect(device
                                            .macAdress), // Menggunakan 'macAdress'
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          "Hubungkan",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: cButton(
                          text: 'Kembali',
                          onPressed: () => Navigator.pop(context),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Text(
                  'Rekayasa Perangkat Lunak',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
