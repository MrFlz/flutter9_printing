//import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ACHIEVED ATTEMPTS:
// OK <== imprimir página completa 1 click desde app (sin necesidad de dar varios "Feed") 
// OK <== imprimir imagen qr 1 página, 1 click desde app 

// OTHER ATEMPTS:
// MOSTRAR una img (qr) guardada creada a partir de string (_data) en la pantalla

  //PREVIOUS ATTEMPT: 
//CURRENT ATTEMPT: ACTUALIZAR EL QR del pdf cada vez que se cambia el contenido (texttField) SIN AGREGAR páginas (siempre 1, la misma)
  //NEXT ATTEMPT: 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR to IMG Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'QR to IMG Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String _data="asi hablaba sali baba";

  final _tectrl_roleidqr = TextEditingController();
  final ButtonStyle _style = ElevatedButton.styleFrom( //estilo del botón (pueden usarlo varios botones y crearse varios styles)
    textStyle: const TextStyle(
      fontSize: 20
    )
  );
  final pdf = pw.Document();
  
  bool bl_pdf=false;
  /*var profile;
  var generator;
  var img;   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _cuerpo(context),
       
    );
  }

  Widget _cuerpo(BuildContext context){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _tf_roleidqr(),
          //_qrimg(),
          _bt_createqr(context),
          _bt_printqr()      
          //_img_container()
          /* Visibility(
            visible: true,
            child: viewPdf()
          ) */          
        ]
      ),
    );
  }

  /* Widget _qrimg(){ //pinta y recrea un qr a partir de un string
    return QrImage(
      data: _data,
      version: QrVersions.auto,
      size: 150.0
    );
  } */

  Widget _tf_roleidqr(){
    String charPattern=r'(^[0-9]*$)'; //expresion regular para una CADENA de digitos, sin admitir espacios

    return TextField(  //limita el tamaño de expansión del textfield (oséase: ancho)      
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(charPattern)), //solo permite el contenido de una expresion regular
        LengthLimitingTextInputFormatter(15) //limita el tamaño de la cadena
      ],
      keyboardType: const TextInputType.numberWithOptions(),
      controller: _tectrl_roleidqr, //asociamos el TextEditingController como propiedad del TextField
      decoration: const InputDecoration( //preferible const por los datos que maneja
        hintText: "Input new Roleid...",
        fillColor: Colors.grey,
        filled: true
      )      
    );
  }

  Widget _bt_createqr(BuildContext context){
    return ElevatedButton(
      style: _style,
      onPressed: (){ // investigar sobre el ()=>{} es necesario?        
        if(_tectrl_roleidqr.text.isEmpty){
          showDialog( //alerta del roleid no aceptado por null, espacios o falta digitos?
            context: context,          
            builder: ( _ ) => AlertDialog(
              title: const Text("Roleid no aceptado :("),
              content: const Text("¡Ingrese al menos 1 digito sin espacios!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Aceptar",
                    style: TextStyle(
                      color: Colors.blue
                    )
                  )
                )
              ]
            )
          );
        } else if(_tectrl_roleidqr.text.isNotEmpty){
          setState(() {
            print("presionado generate..."); 
            _data = _tectrl_roleidqr.text;
            print("data gen: "+_data+" "+bl_pdf.toString());
            _tst_data();
          });
        } else {
          print("algún error en los AlertDialog :c");
        }
      },
      child: const Text("Generate QR")
    );
  }

  Widget _bt_printqr(){
    return ElevatedButton(
      style: _style,
      onPressed: (){
        print("presionado print...");
        print("data print: "+_data +" "+bl_pdf.toString());
        _tst_data();
        //bl_pdf ? updatePdf(PdfPageFormat.letter) : createPdf();
        printPdf(PdfPageFormat.letter);
      },
      child: const Text("Print QR")
    );
  }

  _tst_data(){ //metodo para mostrar un toast
    Fluttertoast.showToast(
      msg: _data,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700]
    );
  }
  
  /* void testReceipt(NetworkPrinter printer, ){
    /* List<int> bytes = [];
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.qrcode('wawawa');

    bytes += generator.feed(2);
    bytes += generator.cut(); */
    generator = Generator(PaperSize.mm80, profile);
    printer.text('Maaaaaaa si se pudo nene ;) ');  
    generator.image(img);
    //printer.qrcode(_data);
    //printer.feed(500);
    //printer.cut();
    //printer.beep();
  }

  printNow() async {
    const PaperSize paper = PaperSize.mm80;
    profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect('192.168.100.69', port: 9100);
    if (res == PosPrintResult.success) {
      testReceipt(printer);
      printer.disconnect();
    }
    print('Print result: ${res.msg}');
  }  

  toImg() async {
    try {
      final uiImg = await QrPainter(
        data: _data,
        version: QrVersions.auto,
        gapless: false,
      ).toImageData(200);
      final dir = await getTemporaryDirectory();
      final pathName = '${dir.path}/qr_tmp.png';
      final qrFile = File(pathName);
      final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List()); //use to convert to pdf!
      img = decodeImage(imgFile.readAsBytesSync());
      
      //print("Warabi says: " + img);

      //final image = pw.MemoryImage(_image.readAsBytesSync());
           
    } catch (e) {
      print(e);
    }
  }
 */
  
  Future<Uint8List> createPdf() async{
    print("estas en Create <===========");
    //
    setState(() {
      pdf.addPage(
        pw.Page(          
          pageFormat: PdfPageFormat.letter,
          build: (pw.Context context){
            return pw.BarcodeWidget(
              data: _data,
              width: 150,
              height: 150,
              barcode: pw.Barcode.qrCode()
            );
          }
        ),
        //index:
      );
    });
    return pdf.save();
    //bl_pdf=true;
  }

  Future<Uint8List> updatePdf(PdfPageFormat format) async {
    setState(() {
      print("estas en Update <===========");
      pdf.editPage(
        0,
        pw.Page(
          pageFormat: format,
          build: (pw.Context context){
            return pw.BarcodeWidget(
              color: const PdfColor.fromInt(750),
              data: "cochinotaaaaaaa",
              width: 150,
              height: 190,
              barcode: pw.Barcode.qrCode()
            );
          }
        )
      );
    });
    return pdf.save();
  }
  
  printPdf(PdfPageFormat format) async { //ERROR CHECAR: no RESPETA EL VALOR CAMBIADO _data para actualizar el PDF e imprimir un qr diferente
    print("Intentando imprimir...");
    print("ACTUAL: "+_data);
    await Printing.layoutPdf( //se manda a imprimir usando el pdf como documento base
      onLayout: (format) => bl_pdf ? updatePdf(format) : createPdf()
      //onLayout: (PdfPageFormat format) async => pdf.save()
      );
    bl_pdf=true;
  }

  /* viewPdf(){
    PdfPreview(
      build: (format) => pdf.save()    
    );
  } */

}
