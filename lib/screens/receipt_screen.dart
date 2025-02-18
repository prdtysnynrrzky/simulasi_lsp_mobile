// ignore_for_file: use_build_context_synchronously

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simulasi_lsp_praditya/services/text_to_speech_service.dart';
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    var bluetoothStatus = await Permission.bluetooth.request();

    if (bluetoothStatus.isGranted) {
      bool? isOn = await bluetooth.isOn;
      bool? isConnected = await bluetooth.isConnected;

      if (isOn == null || !isOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth tidak aktif. Silakan aktifkan Bluetooth.'),
            backgroundColor: Colors.red,
          ),
        );
        TextToSpeechService()
            .queue('Bluetooth tidak aktif, silakan aktifkan Bluetooth.');
      } else {
        if (isConnected == null || !isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Printer tidak terhubung. Pastikan printer terhubung via Bluetooth.'),
              backgroundColor: Colors.red,
            ),
          );
          TextToSpeechService().queue(
              'Printer tidak terhubung, pastikan printer terhubung via Bluetooth.');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Printer siap digunakan.'),
              backgroundColor: Colors.green,
            ),
          );
          TextToSpeechService().queue('Printer siap digunakan.');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Izin Bluetooth tidak diberikan. Mohon izinkan Bluetooth.'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService()
          .queue('Izin Bluetooth tidak diberikan. Mohon izinkan Bluetooth.');
    }
  }

  Future<void> _printReceipt() async {
    setState(() {
      isLoading = true;
    });

    int totalKolom = 46;

    String format1 =
        'Tanggal Transaksi${' ' * (totalKolom - ('Tanggal Transaksi'.length + widget.tanggal.length))}${widget.tanggal}';
    String format2 =
        'Jenis Transaksi${' ' * (totalKolom - ('Jenis Transaksi'.length + widget.jenis.length))}${widget.jenis}';
    String format3 =
        'Nama Pengirim${' ' * (totalKolom - ('Nama Pengirim'.length + widget.pengirim.length))}${widget.pengirim}';
    String format4 =
        'Nama Penerima${' ' * (totalKolom - ('Nama Penerima'.length + widget.penerima.length))}${widget.penerima}';
    String format5 =
        'No. Rek Tujuan${' ' * (totalKolom - ('No. Rek Tujuan'.length + widget.noRekening.length))}${widget.noRekening}';
    String format6 =
        'Nominal Transfer${' ' * (totalKolom - ('Nominal Transfer'.length + widget.nominal.toString().length))}Rp${widget.nominal}';
    String format7 =
        'Berita${' ' * (totalKolom - ('Berita'.length + widget.berita.length))}${widget.berita}';

    if (await bluetooth.isConnected ?? false) {
      try {
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencetakan berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        TextToSpeechService().queue('Pencetakan berhasil!');
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: $e'),
            backgroundColor: Colors.red,
          ),
        );
        TextToSpeechService().queue('Gagal mencetak: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Printer tidak terhubung. Pastikan Bluetooth aktif dan printer terhubung.'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService().queue(
          'Printer tidak terhubung. Pastikan Bluetooth aktif dan printer terhubung.');
    }

    setState(() {
      isLoading = false;
    });
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
                ),
                const SizedBox(height: 20),
                infoRow("Tanggal Transaksi", widget.tanggal),
                infoRow("Jenis Transaksi", widget.jenis),
                infoRow("Nama Pengirim", widget.pengirim),
                infoRow("Nama Penerima", widget.penerima),
                infoRow("No Rek. Tujuan", widget.noRekening),
                infoRow("Nominal Transfer",
                    CurrencyFormat.toRupiah(widget.nominal)),
                infoRow("Berita", widget.berita),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _printReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 24),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Cetak & Kembali',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
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
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
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
            Text(title, style: GoogleFonts.poppins(fontSize: 13)),
            SizedBox(
              width: 200,
              child: Text(
                value,
                maxLines: 1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
