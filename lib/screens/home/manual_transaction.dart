import 'package:flutter/material.dart';
import 'package:kasir/components/input_validation.dart';
import 'package:kasir/helpers/colors_theme.dart';

class ManualTransaction extends StatefulWidget {
  const ManualTransaction({
    super.key,
  });

  @override
  State<ManualTransaction> createState() => _ManualTransactionState();
}

class _ManualTransactionState extends State<ManualTransaction> {
  String numberOutput = '';
  String _output = '';

  buttonPress(String textVal) {
    print(textVal);
    switch (textVal) {
      case "c":
        setState(() {
          _output = '';
          numberOutput = '';
        });
        break;
      case "DEL":
        setState(() {
          numberOutput = (double.parse(numberOutput) ~/ 10).toString();
          _output = (double.parse(_output) ~/ 10).toString() == ''
              ? ''
              : (double.parse(_output) ~/ 10).toString();
        });
        break;
      case "ADD":
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Tambah Data',
              style: TextStyle(fontSize: 12),
            ),
            content: Container(
              height: 180,
              child: Column(
                children: [],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
      default:
        _output += textVal;
        setState(() {
          numberOutput = _output;
        });
    }
  }

  buildButton(String contentText, [bool primary = false]) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => buttonPress(contentText),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
              side: BorderSide(color: Colors.black12, width: 0.3)),
          elevation: 0,
          backgroundColor: primary ? AppColor.primary : Colors.white,
        ),
        child: Text(
          contentText.isEmpty ? "0" : contentText,
          style: TextStyle(
            fontSize: 23,
            color: primary ? Colors.white : AppColor.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            numberOutput,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('1'),
                  buildButton('2'),
                  buildButton('3'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('4'),
                  buildButton('5'),
                  buildButton('6'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('7'),
                  buildButton('8'),
                  buildButton('9'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('0'),
                  buildButton('000'),
                  buildButton('c'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('DEL'),
                  buildButton('ADD', true),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
