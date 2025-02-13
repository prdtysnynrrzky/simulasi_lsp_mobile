// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/balance_provider.dart';
import '../widgets/sAppBar.dart';
import '../widgets/button.dart';
import 'home_screen.dart';

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
      bool? isConnectted = await bluetooth.isConnected;
      bool? isOn = await bluetooth.isOn;

      if (isOn != null && !isOn) {
        print('Bluetooth tidak aktif, mohon aktifkan bluettoh');
      } else if (isConnectted == null || !isConnectted) {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

        if (devices.isNotEmpty) {
          // await bluetooth.connect(devices.first);
          await bluetooth
              .connect(devices[0])
              .timeout(const Duration(seconds: 300), onTimeout: () {
            throw Exception('Timeout : Gagal menghubungkan ke perangkat');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil terhubung ke $devices'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('tidak ada perangkat terpasang yang ditemukan');
          const SnackBar(
            content: Text('Tidak ada perangkat terpasang yang ditemukan'),
            backgroundColor: Colors.red,
          );
        }
      }
    } else {
      print('izin untuk bluetooh tidak di berikan');
      const SnackBar(
        content: Text('Izin untuk bluetooh tidak di berikan'),
        backgroundColor: Colors.red,
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
    int baris6 =
        totalKolom - ('Nominal Transfer'.length + widget.nominal.bitLength);
    int baris7 = totalKolom - ('Berita'.length + widget.berita.length);

    String format1 = 'Tanggal Transaksi${' ' * baris1}${widget.tanggal}';
    String format2 = 'Jenis Transaksi${' ' * baris2}${widget.jenis}';
    String format3 =
        'Nama Pengirim${' ' * baris3}${widget.pengirim.split(' '[0])}';
    String format4 =
        'Nama Penerima${' ' * baris4}${widget.penerima.split(' '[0])}';
    String format5 = 'No. Rek Tujuan${' ' * baris5}${widget.noRekening}';
    String format6 = 'Nominal Transfer${' ' * baris6}${widget.nominal}';
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
      _printReceipt();
    }
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bukti Transaksi',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.checklist,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 20),
                infoRow("Tanggal Transaksi", widget.tanggal),
                infoRow("Jenis Transaksi", widget.jenis),
                infoRow("Nama Pengirim", widget.pengirim),
                infoRow("Nama Penerima", widget.penerima),
                infoRow("No Rek. Tujuan", widget.noRekening),
                infoRow("Nominal Transfer", 'Rp${widget.nominal}'),
                infoRow("Berita", widget.berita),
                const SizedBox(height: 20),
                cButton(
                  text: 'Cetak & Kembali',
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  color: Colors.lightBlue,
                ),
              ],
            ),
          ),
        ],
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
