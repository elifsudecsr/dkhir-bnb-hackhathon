import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BNB Zikirmatik',
      theme: ThemeData(
        primaryColor: Color(0xFFF0B90B), // BNB sarısı
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.black,
        ),
        scaffoldBackgroundColor: Color(0xFF1E1E1E), // BNB siyahı
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFF0B90B),
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFFF0B90B)),
            foregroundColor: MaterialStateProperty.all(Colors.black),
            textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ),
      ),
      home: ZikirmatikScreen(),
    );
  }
}

class ZikirmatikScreen extends StatelessWidget {
  final String rpcUrl = "https://bsc-dataseed.binance.org/";
  final String privateKey = "YOUR_PRIVATE_KEY";
  final String contractAddress = "YOUR_CONTRACT_ADDRESS";
  final String contractABI = '[YOUR_CONTRACT_ABI]';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BNB Zikirmatik'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Zikir Sayısı:',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Text(
                  '${counter.count}',
                  style: TextStyle(fontSize: 48, color: Colors.white),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<Counter>().increment();
                _addZikirToBlockchain();
              },
              child: Text('Zikir Çek'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<Counter>().reset();
              },
              child: Text('Sıfırla'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addZikirToBlockchain() async {
    final client = Web3Client(rpcUrl, http.Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final contract = DeployedContract(
      ContractAbi.fromJson(contractABI, "ZikirNFT"),
      EthereumAddress.fromHex(contractAddress),
    );

    final addZikirFunction = contract.function("addZikir");

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: addZikirFunction,
        parameters: [],
      ),
      chainId: 56,
    );
  }
}

class Counter extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}
