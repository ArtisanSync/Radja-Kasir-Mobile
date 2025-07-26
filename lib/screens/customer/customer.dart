import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/customer/customer_create.dart';
import 'package:kasir/screens/customer/customer_detail.dart';
import 'package:kasir/screens/transaction/action_payment/action_dept.dart';
import 'package:kasir/services/customer_services.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _search = TextEditingController();
  CustomerServices customerServices = CustomerServices();
  bool loading = true;
  List<dynamic> customers = [];
  List<dynamic> filteredItem = [];

  Future<void> fetch() async {
    setState(() {
      loading = true;
    });
    var resp = await customerServices.list();
    setState(() {
      customers = resp.data['data'] as List<dynamic>;
      filteredItem = resp.data['data'] as List<dynamic>;
      loading = false;
    });
  }

  void filterProducts(String query) {
    if (query.isNotEmpty) {
      var res = customers
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      setState(() {
        filteredItem = res;
      });
    } else {
      setState(() {
        filteredItem = customers;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    var searchInput = Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: TextFormField(
        controller: _search,
        onChanged: (value) {
          filterProducts(value);
        },
        decoration: const InputDecoration(
          hintText: 'Cari Pelanggan',
          border: OutlineInputBorder(
            // borderSide: BorderSide(width: 0.3),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusColor: Colors.black12,
          hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          prefixIcon: Icon(
            Icons.search,
            color: AppColor.secondary,
          ),
        ),
      ),
    );

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pelanggan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => fetch(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    searchInput,
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItem.length,
                        itemBuilder: (BuildContext context, index) {
                          var item = filteredItem[index];
                          return InkWell(
                            onTap: () {
                              Route detail = MaterialPageRoute(
                                builder: (context) => CustomerDetailScreen(
                                    id: item['id'].toString()),
                              );

                              Navigator.push(context, detail).then(
                                (value) => fetch(),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: AppColor.textPrimary,
                                ),
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${item['whatsapp']}',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Route detail = MaterialPageRoute(
            builder: (context) => const CustomerCreate(),
          );

          Navigator.push(context, detail).then(
            (value) => fetch(),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
