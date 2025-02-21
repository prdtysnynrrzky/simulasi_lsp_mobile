// ignore_for_file: use_build_context_synchronously
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simulasi_lsp_praditya/services/text_to_speech_service.dart';
import '../providers/balance_provider.dart';
import '../widgets/costumAppBar.dart';

class SettingScreen extends ConsumerStatefulWidget {
  static const routeName = '/setting-screen';
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Bluetooth tidak aktif. Mohon nyalakan Bluetooth Anda.'),
            backgroundColor: Colors.red,
          ),
        );
        TextToSpeechService()
            .queue('Bluetooth tidak aktif. Mohon nyalakan Bluetooth Anda.');
      }
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected && selectedDevice?.address == device.address) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perangkat ${device.name} sudah terhubung.'),
          backgroundColor: Colors.green,
        ),
      );
      TextToSpeechService().queue('Perangkat ${device.name} sudah terhubung.');
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      await bluetooth.connect(device);

      if (mounted) {
        setState(() {
          selectedDevice = device;
          isConnected = true;
          isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil Terhubung ke perangkat ${device.name}.'),
          backgroundColor: Colors.green,
        ),
      );
      TextToSpeechService()
          .queue('Berhasil Terhubung ke perangkat ${device.name}.');
    } catch (e) {
      if (mounted) {
        setState(() {
          isConnected = false;
          isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghubungkan ke perangkat ${device.name}'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService()
          .queue('Gagal menghubungkan ke perangkat ${device.name}.');
    }
  }

  Future<void> disconnectDevice() async {
    if (selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perangkat yang terhubung untuk diputuskan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? deviceName = selectedDevice?.name;
    try {
      await bluetooth.disconnect();
      if (mounted) {
        setState(() {
          selectedDevice = null;
          isConnected = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koneksi ke perangkat ${deviceName ?? ''} terputus.'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService()
          .queue('Koneksi ke perangkat ${deviceName ?? ''} terputus.');
    } catch (e) {
      if (mounted) {
        setState(() {
          isConnected = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memutuskan koneksi'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService().queue('Gagal memutuskan koneksi.');
    }
  }

  Future<void> refreshDevices() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool? isOn = await bluetooth.isOn;
      if (isOn != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth tidak aktif. Mohon nyalakan Bluetooth.'),
            backgroundColor: Colors.red,
          ),
        );
        TextToSpeechService()
            .queue('Bluetooth tidak aktif. Mohon nyalakan Bluetooth.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      if (mounted) {
        setState(() {
          devices = bondedDevices;
          isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftar perangkat berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
      TextToSpeechService().queue('Daftar perangkat berhasil diperbarui.');
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error mendapatkan perangkat yang terhubung'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService()
          .queue('Error mendapatkan perangkat yang terhubung.');
    }
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
                              onPressed: refreshDevices,
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
                        const Divider(color: Colors.grey),
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
                          vertical: 20, horizontal: 24),
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
                const SizedBox(height: 20),
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
