import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_scanner/AddManger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String sdata = "No data found !";

  var height, width;
  bool hasData = false;
  File? file;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = const Color.fromARGB(255, 88, 125, 117);
  BannerAd? bannerAd;
  bool isloaded = false;
  void Load() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AddManger.BannerScan,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              isloaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: AdRequest())
      ..load();
  }

  @override
  void initState() {
    Load();
    super.initState();
  }

  @override
  void dispose() {
    if (isloaded) {
      bannerAd!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Hero(
        tag: 'Scan QR',
        child: Scaffold(
            body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                      child: Text(
                    'Barcode Scanner',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  )),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 88, 125, 117),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40)),
                    shape: BoxShape.rectangle,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          child: Linkify(
                              options: LinkifyOptions(humanize: false),
                              onOpen: (link) async {
                                if (!await launchUrl(Uri.parse(link.url),
                                    mode: LaunchMode.externalApplication)) {
                                  throw Exception(
                                      'Could not launch ${link.url}');
                                }
                              },
                              text: sdata,
                              style: TextStyle(
                                color: currentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: Color.fromARGB(255, 88, 125, 117),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: sdata,
                                ));
                              }),
                          IconButton(
                              onPressed: () => showPicker(),
                              icon: Icon(Icons.colorize_sharp,
                                  color: const Color.fromARGB(
                                    255,
                                    88,
                                    125,
                                    117,
                                  ))),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      var data = await FlutterBarcodeScanner.scanBarcode(
                        '#2A99CF',
                        'cancel',
                        true,
                        ScanMode.QR,
                      );

                      setState(() {
                        sdata = data.toString();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 88, 125, 117),
                        side: const BorderSide(color: Colors.orange, width: 1),
                        shape: const BeveledRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        textStyle: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    child: const Text(
                      ('Scanner'),
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: isloaded
                        ? SizedBox(
                            width: bannerAd!.size.width.toDouble(),
                            height: bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: bannerAd!),
                          )
                        : SizedBox(
                            height: 60,
                          ))
              ],
            ),
          ),
        )),
      ),
    );
  }

  Future<void> launch(String url) async {
    if (await launchUrlString(url)) {
      throw 'Could not launch $url';
    }
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future showPicker() {
    return showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              child: const Text('Change'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 125, 117),
                side: const BorderSide(color: Colors.orange, width: 1),
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              )),
        ],
      ),
      context: context,
    );
  }

  void launchh(String url) async {
    if (await launchUrlString(url)) {
      throw 'Could not launch $url';
    }
  }
}
