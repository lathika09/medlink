import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrescribeReport extends StatefulWidget {
  const PrescribeReport({Key? key,required this.docid, required this.medicines}) : super(key: key);
  final DocumentSnapshot docid;
  final Map<String, dynamic> medicines;

  @override
  State<PrescribeReport> createState() => _PrescribeReportState();
}

class _PrescribeReportState extends State<PrescribeReport> {

  final pdf = pw.Document();
  var pname;
  var docName;
  var did;
  var pid;
  var diag;
  var pemail;
  var medName;
  var dose;



  @override
  void initState() {
    super.initState();
    setState(() {
        pname = widget.docid.get('patientName');
        docName = widget.docid.get('doctorName');
        did = widget.docid.get('doctorId');
        pid = widget.docid.get('patientId');
        diag=widget.docid.get("diagnosis");
        pemail=widget.docid.get("patientEmail");

      });
  }

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      // maxPageWidth: 1000,
      // useActions: false,
      // canChangePageFormat: true,
      canChangeOrientation: false,
      // pageFormats:pageformat,
      canDebug: false,

      build: (format) => generateDocument(
        format,
      ),
    );
  }

  Future<Uint8List> generateDocument(PdfPageFormat format) async {

    int index = 0;
    List<String> keys = [];
    List<String> values = [];
    widget.medicines.forEach((medicineName, dosage) {
      print('Medicine Name $index: $medicineName');
      print('Dosage $index: $dosage');
      String key=medicineName?? '';
      String value=dosage?? '';
      keys.add(key);
      values.add(value);
      index++;
    });
    Map<String, String> medicines_New = {};
    for (int i = 0; i < keys.length; i++) {
      String medName = keys[i];
      String dose= values[i];

      medicines_New[medName] = dose;
    }


    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    // final image = await imageFromAssetBundle('assets/r2.svg');

    String? _logo = await rootBundle.loadString('assets/splash.svg');

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: format.copyWith(
            marginBottom: 1,
            marginLeft: 0,
            marginRight: 0,
            marginTop: 50,
          ),
          orientation: pw.PageOrientation.portrait,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),

        build: (context) {
          return pw.Center(
              child:pw.Padding(
                padding: pw.EdgeInsets.all(10),
                child:  pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    // pw.Flexible(
                    //   child: pw.SvgImage(
                    //     svg: _logo,
                    //     height: 100,
                    //   ),
                    // ),
                    // pw.SizedBox(
                    //   height: 20,
                    // ),
                    pw.Center(
                      child: pw.Text(
                        'PRESCRIPTION',
                        style: pw.TextStyle(
                            fontSize: 48,
                            fontWeight: pw.FontWeight.bold
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      height: 20,
                    ),
                    pw.Divider(),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                      child: pw.Flexible(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Patient Name : ',
                              style: pw.TextStyle(
                                fontSize:35,
                                  fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.Text(
                              pname,
                              style: pw.TextStyle(
                                fontSize: 35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                      child: pw.Flexible(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Doctor Name : ',
                              style: pw.TextStyle(
                                fontSize:35,
                                  fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.Text(
                              docName,
                              style: pw.TextStyle(
                                fontSize: 35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                      child: pw.Flexible(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Email : ',
                              style: pw.TextStyle(
                                  fontSize:35,
                                  fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.Text(
                              pemail,

                              maxLines: null,
                              style: pw.TextStyle(
                                  fontSize:30,

                              ),),
                          ],
                        ),
                      ),
                    ),
                    pw.Divider(),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                      child: pw.Flexible(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Diagnosis : ',
                              style: pw.TextStyle(
                                  fontSize:33,
                                  fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.Text(
                              diag,
                              style: pw.TextStyle(
                                fontSize: 34,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ),


                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children:List.generate(keys.length, (index)
                      {return pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12,vertical: 15),
                        child: pw.Column(
                          children: [
                            pw.Row(
                                children: [
                                  pw.Text(
                                    "Medicine${index+1} : ",
                                    style: pw.TextStyle(
                                        fontSize: 34,
                                        fontWeight: pw.FontWeight.bold
                                    ),
                                  ),
                                  pw.Text(
                                    keys[index],
                                    style: pw.TextStyle(
                                      fontSize: 34,
                                    ),
                                  ),

                                ]
                            ),
                            pw.Row(
                              children: [
                                pw.Text(
                                  " Dosage${index+1} : ",
                                  style: pw.TextStyle(
                                      fontSize: 34,
                                      fontWeight: pw.FontWeight.bold
                                  ),
                                ),
                                pw.Text(
                                  values[index],
                                  style: pw.TextStyle(
                                    fontSize: 34,
                                  ),
                                ),
                              ]
                            )
                          ]
                        )
                      );}).toList(),

                    ),
                  ],
                ),
              )
          );
        },
      ),
    );

    return doc.save();

  }
}
