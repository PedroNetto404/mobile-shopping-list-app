import 'package:flutter/material.dart';
import 'package:mobile_shopping_list_app/extensions/string-extensions.dart';
import 'package:mobile_shopping_list_app/providers/shopping-list-provider.dart';
import 'package:mobile_shopping_list_app/widgets/delete-confirmation-dialog.dart';
import 'package:mobile_shopping_list_app/widgets/shopping-list-card.dart';
import 'package:mobile_shopping_list_app/widgets/layout.dart';
import 'package:provider/provider.dart';
import '../constants/app-route.dart';
import '../models/shopping-list.dart';
import '../widgets/shopping-list-dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String _searchText = '';
  bool _dateAscending = true;
  Future<void>? _fetchFuture;

  @override
  void initState() {
    super.initState();

    _initFetch();
  }

  void _initFetch() => _fetchFuture = Future.delayed(
      const Duration(seconds: 2),
      () => context.read<ShoppingListProvider>().fetchLists().catchError(
          (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao buscar listas: $error'),
              backgroundColor: Colors.red))));

  List<ShoppingList> _getFilteredLists(List<ShoppingList> lists) {
    final filteredLists = _searchText.isEmpty
        ? lists
        : lists
            .where((element) =>
                element.name.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();

    filteredLists.sort((a, b) => a.name.compareTo(b.name));

    filteredLists.sort((a, b) => _dateAscending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));

    filteredLists.sort((a, b) => a.completed || b.items.isEmpty ? 1 : -1);

    return filteredLists;
  }

  @override
  Widget build(BuildContext context) => Layout(
      body: FutureBuilder(
          future: _fetchFuture,
          builder: (context, snapshot) => Consumer<ShoppingListProvider>(
                  builder: (context, provider, child) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const Text('Erro ao buscar listas...'),
                      const SizedBox(width: 8),
                      IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => setState(() => _initFetch())),
                    ],
                  ));
                }

                final lists = provider.lists;

                if (lists.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, size: 100),
                        SizedBox(height: 16),
                        Text('Nenhuma lista adicionada ainda...'),
                      ],
                    ),
                  );
                }

                final filteredLists = _getFilteredLists(lists);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _filterSection(),
                      _infoSection(lists),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredLists.length,
                          itemBuilder: (context, index) {
                            final list = filteredLists[index];
                            return ShoppingListCard(
                                list: filteredLists[index],
                                onDeletePressed: () =>
                                    _onDeletePressed(context, list),
                                onCheckPressed: () =>
                                    _onCheckboxTap(context, list),
                                onEditPressed: () =>
                                    _onEditPressed(context, list),
                                onTap: () => _onTap(context, list.id));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _onAddPressed(context),
          child: const Icon(Icons.playlist_add)));

  Widget _filterSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('📝 Minhas Listas',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchText = value),
                        decoration: const InputDecoration(
                            hintText: 'Digite o nome da lista',
                            labelText: 'Buscar lista',
                            prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                        onPressed: () =>
                            setState(() => _dateAscending = !_dateAscending),
                        icon: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            Icon(_dateAscending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward),
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _infoSection(List<ShoppingList> lists) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Total de listas pendentes: ${lists.where((list) => !list.completed || list.items.isEmpty).length}'),
                  Text('Total de listas: ${lists.length}')
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      );

  void _onAddPressed(BuildContext context) => showDialog(
      context: context,
      builder: (context) => ShoppingListDialog.createList(
          onSaveAsync: (String name) => context
              .read<ShoppingListProvider>()
              .addShoppingList(name)
              .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Erro ao adicionar lista: $error'),
                      backgroundColor: Colors.red)))));

  void _onCheckboxTap(BuildContext context, ShoppingList list) {
    var provider = context.read<ShoppingListProvider>();

    final future = list.completed
        ? provider.resetShoppingList(list.id)
        : provider.completeShoppingList(list.id);

    future.catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao atualizar lista: $error'),
            backgroundColor: Colors.red)));
  }

  void _onEditPressed(BuildContext context, ShoppingList list) => showDialog(
      context: context,
      builder: (context) => ShoppingListDialog.updateList(
          list: list,
          onSaveAsync: (String name) => context
              .read<ShoppingListProvider>()
              .updateShoppingListName(list.id, name)
              .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Erro ao atualizar lista: $error'),
                      backgroundColor: Colors.red)))));

  void _onDeletePressed(BuildContext context, ShoppingList list) => showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
          title: const Row(children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Remover Lista')
          ]),
          content: Row(children: [
            const Text('Tem certeza que deseja remover a lista '),
            Text(list.name.capitalize(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const Text('?')
          ]),
          onConfirm: () => _onConfirmDelete(context, list.id)));

  void _onConfirmDelete(BuildContext context, String listId) => context
      .read<ShoppingListProvider>()
      .removeShoppingList(listId)
      .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao remover lista: $error'),
              backgroundColor: Colors.red)));

  void _onTap(BuildContext context, String listId) =>
      AppRoute.navigateTo(context, AppRoute.shoppingListDetails,
          arguments: listId);
}
