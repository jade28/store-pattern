import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:admin_app/Controllers/image.controller.dart';
import 'package:admin_app/utils/log.dart';

import './../Constants/dialog.dart';
import './../Constants/theme.dart' as theme;
import './../Controllers/account.controller.dart';
import './../Controllers/accountType.controller.dart' as accTypeController;
import './../Models/accountType.model.dart' as accType;

class AddAccountScreen extends StatefulWidget {
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _idCardController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _birthDayController = TextEditingController();

  Future<List<accType.AccountType>> accTypes =
      accTypeController.Controller.instance.accTypes;
  accType.AccountType _accType;
  String _sex;
  File _image;
  bool _isUsernameExists = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _itemStyle = TextStyle(
        color: theme.fontColor,
        fontFamily: 'Dosis',
        fontSize: 16.0,
        fontWeight: FontWeight.w500);

    TextStyle _itemStyle2 = TextStyle(
        color: theme.accentColor,
        fontFamily: 'Dosis',
        fontSize: 18.0,
        fontWeight: FontWeight.w500);

    TextStyle _itemStyle3 = TextStyle(
        color: Colors.redAccent,
        fontFamily: 'Dosis',
        fontSize: 18.0,
        fontWeight: FontWeight.w500);

    Widget avatar = Column(
      children: <Widget>[
        _image == null
            ? Image.asset(
                'assets/images/account.png',
                width: 122.0,
                height: 122.0,
                fit: BoxFit.fill,
              )
            : Image.file(
                _image,
                width: 122.0,
                height: 122.0,
                fit: BoxFit.fill,
              ),
        Container(
          height: 15.0,
        ),
        RaisedButton(
          color: Colors.lightBlueAccent,
          child: Text(
            'Select Image',
            style: _itemStyle,
          ),
          onPressed: () async {
            var image = await ImageController.getImageFromGallery();
            setState(() {
              _image = image;
            });
          },
        )
      ],
    );

    Widget username = TextField(
      controller: _usernameController,
      style: _itemStyle,
      decoration: InputDecoration(
          labelText:
              _isUsernameExists ? 'Username already exists. Try again.' : 'Username:*',
          labelStyle: _isUsernameExists ? _itemStyle3 : _itemStyle2),
      onChanged: (value) async {
        bool result = await Controller.instance.isUsernameExists(value);
        setState(() {
          _isUsernameExists = result;
        });
      },
    );

    Widget displayName = TextField(
      controller: _displayNameController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Display name:', labelStyle: _itemStyle2),
    );

    Widget idCard = TextField(
      controller: _idCardController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Id card:', labelStyle: _itemStyle2),
    );

    Widget address = TextField(
      controller: _addressController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Address:', labelStyle: _itemStyle2),
    );

    Widget phone = TextField(
      controller: _phoneController,
      style: _itemStyle,
      decoration: InputDecoration(labelText: 'Phone:', labelStyle: _itemStyle2),
    );

    Widget accountType = Row(
      children: <Widget>[
        Text(
          'Account Type:  ',
          style: TextStyle(
              color: theme.accentColor,
              fontFamily: 'Dosis',
              fontSize: 13.0,
              fontWeight: FontWeight.w500),
        ),
        FutureBuilder<List<accType.AccountType>>(
          future: accTypes,
          builder: (context, snapshot) {
            if (snapshot.hasError) Log.error(snapshot.error);
            if (snapshot.hasData) {
              return _buildAccTypes(_itemStyle, snapshot.data);
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );

    Widget sex = Row(
      children: <Widget>[
        Text(
          'Sex:  ',
          style: TextStyle(
              color: theme.accentColor,
              fontFamily: 'Dosis',
              fontSize: 13.0,
              fontWeight: FontWeight.w500),
        ),
        _buildSex(_itemStyle),
      ],
    );

    Widget birthDay = Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            controller: _birthDayController,
            style: _itemStyle,
            decoration: InputDecoration(labelText: 'Birthday:', labelStyle: _itemStyle2),
          ),
        ),
        RaisedButton(
          child: Text(
            'Select birthday',
            style: _itemStyle,
          ),
          onPressed: () {
            _selectDate();
          },
        )
      ],
    );

    Widget create = Container(
      margin: const EdgeInsets.only(top: 15.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: Colors.redAccent,
          child: Text(
            'Create Account',
            style: _itemStyle,
          ),
          onPressed: () {
            _createAcc();
          },
        ),
      ),
    );

    return Container(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              avatar,
              username,
              displayName,
              sex,
              birthDay,
              idCard,
              address,
              phone,
              accountType,
              create
            ],
          )),
    );
  }

  Widget _buildAccTypes(TextStyle _itemStyle, List<accType.AccountType> accTypes) {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < accTypes.length; i++) {
      DropdownMenuItem item = DropdownMenuItem(
        value: accTypes[i],
        child: Text(
          accTypes[i].name,
          style: _itemStyle,
        ),
      );
      items.add(item);
    }

    return DropdownButton(
        value: _accType,
        items: items,
        onChanged: (value) {
          setState(() {
            _accType = value;
          });
        });
  }

  void _createAcc() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm', style: theme.titleStyle),
            content: Text('Do you want to create  account?', style: theme.contentStyle),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok', style: theme.okButtonStyle),
                onPressed: () async {
                  /* Pop screens */
                  Navigator.of(context).pop();
                  if (_usernameController.text.trim() != '' &&
                      _accType != null &&
                      !_isUsernameExists) {
                    if (await Controller.instance.insertAcc(
                      _usernameController.text.trim(),
                      _usernameController.text.trim(),
                      _displayNameController.text.trim(),
                      _sex == 'Male' ? 1 : (_sex == 'Female' ? 0 : -1),
                      _idCardController.text.trim(),
                      _addressController.text.trim(),
                      _phoneController.text.trim(),
                      _birthDayController.text != ''
                          ? DateTime.parse(_birthDayController.text)
                          : null,
                      _accType.id,
                      _image != null ? base64Encode(_image.readAsBytesSync()) : '',
                    )) {
                      // reload accounts
                      Controller.instance.insertAccountToLocal(
                        _usernameController.text.trim(),
                        _displayNameController.text.trim(),
                        _sex == 'Male' ? 1 : (_sex == 'Female' ? 0 : -1),
                        _idCardController.text.trim(),
                        _addressController.text.trim(),
                        _phoneController.text.trim(),
                        _birthDayController.text != ''
                            ? DateTime.parse(_birthDayController.text)
                            : null,
                        _accType.id,
                        _image != null ? base64Encode(_image.readAsBytesSync()) : '',
                      );

                      successDialog(this.context, 'Create  account success!');
                      clearDataWidget();
                    } else
                      errorDialog(this.context,
                          'Create  account failed.' + '\nPlease try again!');
                    return;
                  }
                  errorDialog(
                      this.context, 'Invalid infomations.' + '\nPlease try again!');
                },
              ),
              FlatButton(
                child: Text('Cancel', style: theme.cancelButtonStyle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void clearDataWidget() {
    setState(() {
      _image = null;
    });
    _usernameController.clear();
    _displayNameController.clear();
    _idCardController.clear();
    _addressController.clear();
    _phoneController.clear();
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
        firstDate: DateTime(1975),
        lastDate: DateTime(2019));
    if (picked != null)
      setState(() => _birthDayController.text = picked.toString().split(' ')[0]);
  }

  Widget _buildSex(TextStyle _itemStyle) {
    List<DropdownMenuItem> items = [];
    List<String> listSex = ['Male', 'Female', 'Other'];
    for (int i = 0; i < listSex.length; i++) {
      DropdownMenuItem item = DropdownMenuItem(
        value: listSex[i],
        child: Text(
          listSex[i],
          style: _itemStyle,
        ),
      );

      items.add(item);
    }

    return DropdownButton(
        value: _sex,
        items: items,
        onChanged: (value) {
          setState(() {
            _sex = value;
          });
        });
  }
}
