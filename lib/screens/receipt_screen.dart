// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/currency_format.dart';
import '../providers/balance_provider.dart';
import '../widgets/costumAppBar.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final String tanggal;
  final String jenis;
  final String pengirim;
  final String penerima;
  final String noRekening;
  final int nominal;
  final String berita;

  const ReceiptScreen({
    super.key,
    required this.tanggal,
    required this.jenis,
    required this.pengirim,
    required this.penerima,
    required this.noRekening,
    required this.nominal,
    required this.berita,
  });

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    var bluetoothStatus = await Permission.bluetooth.request();

    if (bluetoothStatus.isGranted) {
      bool? isConnected = await bluetooth.isConnected;
      bool? isOn = await bluetooth.isOn;

      if (isOn == null || !isOn) {
        print('Bluetooth tidak aktif, mohon aktifkan Bluetooth');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth tidak aktif, mohon aktifkan Bluetooth'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (isConnected == null || !isConnected) {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

        if (devices.isNotEmpty) {
          try {
            await bluetooth
                .connect(devices[0])
                .timeout(const Duration(seconds: 10), onTimeout: () {
              throw Exception('Timeout: Gagal menghubungkan ke perangkat');
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Berhasil terhubung ke perangkat: ${devices[0].name}'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal terhubung ke perangkat: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada perangkat terpasang yang ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin untuk Bluetooth tidak diberikan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _printReceipt() async {
    int totalKolom = 46;
    int baris1 =
        totalKolom - ('Tanggal Transaksi'.length + widget.tanggal.length);
    int baris2 = totalKolom - ('Jenis Transaksi'.length + widget.jenis.length);
    int baris3 = totalKolom - ('Nama Pengirim'.length + widget.pengirim.length);
    int baris4 = totalKolom - ('Nama Penerima'.length + widget.penerima.length);
    int baris5 =
        totalKolom - ('No. Rek Tujuan'.length + widget.noRekening.length);
    int baris6 = totalKolom -
        ('Nominal Transfer'.length + widget.nominal.toString().length);
    int baris7 = totalKolom - ('Berita'.length + widget.berita.length);

    String format1 = 'Tanggal Transaksi${' ' * baris1}${widget.tanggal}';
    String format2 = 'Jenis Transaksi${' ' * baris2}${widget.jenis}';
    String format3 = 'Nama Pengirim${' ' * baris3}${widget.pengirim}';
    String format4 = 'Nama Penerima${' ' * baris4}${widget.penerima}';
    String format5 = 'No. Rek Tujuan${' ' * baris5}${widget.noRekening}';
    String format6 = 'Nominal Transfer${' ' * baris6}Rp${widget.nominal}';
    String format7 = 'Berita${' ' * baris7}${widget.berita}';

    if (await bluetooth.isConnected ?? false) {
      bluetooth.printCustom('DIGIHAM BANK', 1, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom(format1, 1, 0);
      bluetooth.printCustom(format2, 2, 0);
      bluetooth.printCustom(format3, 3, 0);
      bluetooth.printCustom(format4, 4, 0);
      bluetooth.printCustom(format5, 5, 0);
      bluetooth.printCustom(format6, 6, 0);
      bluetooth.printCustom(format7, 7, 0);
      bluetooth.printNewLine();
      bluetooth.printCustom('LSP - PRADITYA SONY NURRIZKY', 1, 1);
      bluetooth.printNewLine();
      bluetooth.paperCut();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Gagal menghubungkan ke printer, pastikan Bluetooth aktif dan printer terhubung.'),
          backgroundColor: Colors.red,
        ),
      );
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Transfer Berhasil',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 25),
                ).animate().fadeIn(
                      delay: 100.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 20),
                Container(
                  width: 55,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ).animate().fadeIn(
                      delay: 200.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 20),
                infoRow("Tanggal Transaksi", widget.tanggal).animate().fadeIn(
                      delay: 300.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow("Jenis Transaksi", widget.jenis).animate().fadeIn(
                      delay: 400.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow("Nama Pengirim", widget.pengirim).animate().fadeIn(
                      delay: 500.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow("Nama Penerima", widget.penerima).animate().fadeIn(
                      delay: 600.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow("No Rek. Tujuan", widget.noRekening).animate().fadeIn(
                      delay: 700.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow(
                        "Nominal Transfer",
                        CurrencyFormat.toRupiah(
                            int.tryParse(widget.nominal.toString()) ?? 0))
                    .animate()
                    .fadeIn(
                      delay: 800.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                infoRow("Berita", widget.berita).animate().fadeIn(
                      delay: 900.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () async {
                      print('Tombol Cetak & Kembali ditekan');
                      _printReceipt();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      'Cetak & Kembali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                      delay: 1000.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    )
              ],
            ),
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

  Widget infoRow(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
