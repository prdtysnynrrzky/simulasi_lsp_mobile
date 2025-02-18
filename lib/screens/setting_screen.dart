// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/balance_provider.dart';
import '../widgets/costumAppBar.dart';

class SettingScreen extends ConsumerStatefulWidget {
  static const routeName = '/setting-screen';
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isConnected = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    bool? isOn = await bluetooth.isOn;
    if (isOn == true) {
      await refreshDevices();
    } else {
      print('Bluetooth is off');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected && selectedDevice?.address == device.address) {
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
        selectedDevice = device;
        isConnected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil Terhubung ke perangkat ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Gagal terhubung ke perangkat: $e');
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
    String? deviceName = selectedDevice?.name;
    await bluetooth.disconnect();
    setState(() {
      selectedDevice = null;
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

    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      print('Error getting bonded devices: $e');
    }

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
      appBar: customAppBar(
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
                'assets/logo/rpl.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                                title: Text(
                                    'Terhubung ke: ${selectedDevice?.name}'),
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
                                'Tidak ada perangkat yang terhubung',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: devices.length,
                                    itemBuilder: (context, index) {
                                      final device = devices[index];
                                      return ListTile(
                                        title: Text(device.name ?? 'Unknown'),
                                        subtitle:
                                            Text(device.address.toString()),
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
                                    textAlign: TextAlign.center,
                                    'Tidak ada perangkat Bluetooth ditemukan',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ).animate().fadeIn(
                delay: 300.ms,
                curve: Curves.easeIn,
                duration: 500.ms,
              ),
        ],
      ),
      bottomNavigationBar: Container(
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
    );
  }
}
