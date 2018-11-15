import 'dart:io';
import 'package:contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  List<Contact> listContact = List();

  @override
  void initState() {
    super.initState();

    atualizaRegistros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                  const PopupMenuItem<OrderOptions>(
                    child: Text("Ordenar de A-Z"),
                    value: OrderOptions.orderAZ,
                  ),
                  const PopupMenuItem<OrderOptions>(
                    child: Text("Ordenar de Z-A"),
                    value: OrderOptions.orderZA,
                  )
                ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: listContact.length,
          itemBuilder: (context, index) {
            return contactCard(context, index);
          }),
    );
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: listContact[index].img != null
                          ? FileImage(File(listContact[index].img))
                          : AssetImage("images/persoa.png"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        listContact[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        listContact[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        listContact[index].phone ?? "",
                        style: TextStyle(fontSize: 18.0),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onTap: () {
          showOptions(context, index);
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }
      atualizaRegistros();
    }
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderAZ:
        listContact.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        listContact.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }

    setState(() {});
  }

  void atualizaRegistros() {
    contactHelper.getAllContact().then((list) {
      setState(() {
        listContact.clear();
        listContact = list;
      });
    });
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        launch("tel:${listContact[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: listContact[index]);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Excluir",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        contactHelper.deleteContact(listContact[index].id);
                        setState(() {
                          listContact.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
