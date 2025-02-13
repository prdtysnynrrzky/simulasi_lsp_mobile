// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/balance_provider.dart';
import '../widgets/sAppBar.dart';
import '../widgets/button.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDivice;
  bool isConnected = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initBluetooth() async {
    bool? isOn = await bluetooth.isOn;
    if (isOn == true) {
      try {
        devices = await bluetooth.getBondedDevices();
      } catch (e) {
        print('Error getting bonded devices: $e');
      }
      setState(() {});
    } else {
      print('Bluetooth is off');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected && selectedDivice?.address == device.address) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perangkat ${device.name} sudah terhubung'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    try {
      await bluetooth.connect(device);
      setState(() {
        selectedDivice = device;
        isConnected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil Terhubung ke perangkat ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('gagal terhubung ke perangkat $e');
      setState(() {
        isConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghubungkan ke perangkat ${device.name}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> disconnectDevice() async {
    String? deviceName = selectedDivice?.name;
    await bluetooth.disconnect();
    setState(() {
      selectedDivice = null;
      isConnected = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Koneksi ke perangkat ${deviceName ?? ''} terputus'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> refreshDevices() async {
    setState(() {
      isLoading = true;
      devices = [];
    });

    await initBluetooth();

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daftar perangkat berhasil diperbarui'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = ref.watch(balanceProvider);

    return Scaffold(
      appBar: sAppBar(
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
                'assets/images/rpl-logo.png',
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
                            onPressed: () => refreshDevices(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      isConnected
                          ? ListTile(
                              title:
                                  Text('Terhubung ke: ${selectedDivice?.name}'),
                              trailing: ElevatedButton(
                                onPressed: disconnectDevice,
                                child: Text(
                                  'Putuskan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'data',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : devices.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: devices.length,
                                  itemBuilder: (context, index) {
                                    final device = devices[index];
                                    return ListTile(
                                      title: Text(device.name ?? 'Unknown'),
                                      subtitle: Text(device.address.toString()),
                                      trailing: ElevatedButton(
                                        onPressed: () =>
                                            connectToDevice(device),
                                        child: Text(
                                          "Hubungkan",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Text(
                                  'Tidak ada perangkat Bluetooth ditemukan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
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
