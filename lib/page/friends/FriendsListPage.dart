import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FriendState();
  }

}
class _FriendState extends State<FriendsPage>{
  List _friendList=List();
  @override
  void initState() {
    // TODO: implement initState
    _friendList.add("15011381883");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: Text("我的好友"),),
      body: ListView.builder(itemBuilder: (context,index){
        return GestureDetector(
          child: ListTile(
            title: Text("${_friendList[index]}"),
          ),
          onTap: (){
            Navigator.pushNamed(context, "/MainPage",arguments: {"taggetid":_friendList[index]});

          },
        );
      },
       itemCount: _friendList.length,
       ),
    );
  }

}