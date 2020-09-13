import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db= Firestore.instance;
  List _listaViagens = [
    'Cristo Redentor',
    'Grande muralha',
  ];

  _abrirMapa(String idViagem){
    Navigator.push(context, MaterialPageRoute(builder:(_)=> Mapa(idViagem: idViagem,) ));
  }

  _excluirViagem(String idViagem){
    _db.collection('viagens').document(idViagem).delete();
  }

  _adcionarLocal(){
    Navigator.push(context, MaterialPageRoute(builder:(_)=> Mapa() ));
  }

  _adcionarListenViagens()async{
    final stream = _db.collection('viagens').snapshots();

    stream.listen((event) {
      _controller.add(event);
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adcionarListenViagens();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas viagens'),),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _adcionarLocal();
          },
          child: Icon(Icons.add),
         backgroundColor: Color(0xff0066cc),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
            case ConnectionState.done:

              QuerySnapshot querySnapshot = snapshot.data;
              List<DocumentSnapshot> viagens = querySnapshot.documents.toList();

              return Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: viagens.length,
                          itemBuilder: (context, index){

                            DocumentSnapshot item = viagens[index];
                            String titulo = item['titulo'];
                            String idViagem = item.documentID;

                            return GestureDetector(
                              onTap: (){
                                _abrirMapa(idViagem);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(titulo),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          _excluirViagem(idViagem);
                                        },
                                        child: Padding(padding: EdgeInsets.all(8),
                                          child: Icon(Icons.remove_circle, color: Colors.red,),

                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      )
                  )
                ],
              );
              break;
          }
          return Container();
        },
      )
    );
  }
}
