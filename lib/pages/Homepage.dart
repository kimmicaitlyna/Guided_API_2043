import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gd_api_2043/client/BarangClient.dart';
import 'package:gd_api_2043/entity/Barang.dart';
import 'package:gd_api_2043/pages/EditBarang.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  //provider untuk mengambil list data barang dari API
  final listBarangProvider = FutureProvider<List<Barang>>((ref) async {
    return await BarangClient.fetchAll();
  });

  // aksi ketika floating button ditekan
  void onAdd(context, ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          const EditBarang())).then((value) => ref.refresh( 
      listBarangProvider)); 
  }

  void onDelete(id, context, ref) async {
    try {
      await BarangClient.destroy(id); //menghapus data barang berdasarkan id
      ref.refresh(listBarangProvider); //refresh list data barang
      showSnackBar(context, "Delete Success", Colors.green);
    } catch (e) {
      showSnackBar(context, e.toString(), Colors.red);
    }
  }

  ListTile scrollViewItem(Barang b, context, ref) => ListTile(
    title: Text(b.nama),
    subtitle: Text(b.deskripsi),
    onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => EditBarang(id: b.id)))
          .then((value) => ref.refresh(listBarangProvider)),
    trailing: IconButton(
          onPressed: () => onDelete(b.id, context, ref),
          icon: const Icon(Icons.delete))); // IconButton // ListTile

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listener = ref.watch(listBarangProvider); //

    return Scaffold(
      appBar: AppBar(
        title: const Text("GD API 2043"),
      ), // AppBar
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => onAdd(context, ref),
      ), // FloatingActionButton
      body: listener.when(
        data: (barangs) => SingleChildScrollView(
          child: Column(
            children: barangs
                .map((barang) => scrollViewItem(barang, context, ref))
                .toList()), // Column
        ), //muncul ketika data berhasil diambil // SingleChildScrollView
        error: (err, s) =>
            Center(child: Text(err.toString())), //muncul ketika error
        loading: () => const Center(
            child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// untuk menampilkan snackbar
void showSnackBar(BuildContext context, String msg, Color bg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: bg,
      action: SnackBarAction(
          label: 'hide', onPressed: scaffold.hideCurrentSnackBar), 
    ),
  );
}