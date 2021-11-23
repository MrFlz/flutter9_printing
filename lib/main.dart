import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Author: Alan Emilio Flores Novelo (MrFlz), Cancún - México
// ACHIEVED ATTEMPTS:
// OK <== imprimir página completa 1 click desde app (sin necesidad de dar varios "Feed") 
// OK <== imprimir imagen qr 1 página, 1 click desde app 
// OK <== ACTUALIZAR EL QR del pdf cada vez que se cambia el contenido (texttField) SIN AGREGAR páginas (siempre 1, la misma)
//        No se actualiza, se VUELVE a CREAR el pdf.Document cada vez, ergo, los cambios se reflejarán
// OTHER ATEMPTS:
// OK <== MOSTRAR una img (qr) guardada creada a partir de string (_data) en la pantalla
//        Se usó BarcodeWidget
      
  //PREVIOUS ATTEMPT: 
//CURRENT ATTEMPT: 
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
  String _data="asi hablaba sali baba";
  final _tectrl_roleidqr = TextEditingController();
  final ButtonStyle _style = ElevatedButton.styleFrom( //estilo del botón (pueden usarlo varios botones y crearse varios styles)
    textStyle: const TextStyle(
      fontSize: 20
    )
  );
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: 
        _cuerpo(context),       
    );
  }

  Widget _cuerpo(BuildContext context){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_data),
          tfRoleidQr(),
          btCreateQr(context),
          btPrintQr(),                 
        ]
      ),
    );
  }

  Widget tfRoleidQr(){
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

  Widget btCreateQr(BuildContext context){
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
            print("data gen: "+_data);
            tstData();
          });
        } else {
          print("algún error en los AlertDialog :c");
        }
      },
      child: const Text("Generate QR")
    );
  }

  Widget btPrintQr(){
    return ElevatedButton(
      style: _style,
      onPressed: (){
        var pdf = pw.Document();
        print("presionado print...");
        print("data print: "+_data);
        tstData();
        createPdf(pdf);
        setState(() {
          printPdf(PdfPageFormat.letter, pdf);
        });
      },
      child: const Text("Print QR")
    );
  }

  tstData(){ //metodo para mostrar un toast
    Fluttertoast.showToast(
      msg: _data,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700]
    );
  }
    
  Future<Uint8List> createPdf(pw.Document pdf) async{
    print("estas en Create <===========");
    setState(() {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          build: (pw.Context context){
            return pw.Center(
              child: pw.Column (
                children: [
                  pw.Text(_data),
                  pw.BarcodeWidget(
                    data: _data,
                    width: 150,
                    height: 150,
                    barcode: pw.Barcode.qrCode()
                  )
                ]
              )
            );
          }
        ),
        index: 0
      );
    });
    return pdf.save();
  }

  printPdf(PdfPageFormat format, pw.Document pdf) async {
    print("Intentando imprimir...");
    print("ACTUAL: "+_data);
    await Printing.layoutPdf( //se manda a imprimir usando el pdf como documento base
      onLayout: (PdfPageFormat format) async => pdf.save()
    );
  }
}
