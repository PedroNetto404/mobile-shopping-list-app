import 'package:flutter/material.dart';

class ShoppingListDetailsNoteField extends StatelessWidget {
  final TextEditingController controller;

  const ShoppingListDetailsNoteField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Observação',
            hintText: 'Digite uma observação sobre o item',
            prefixIcon: Icon(Icons.edit_note_sharp),
          ),
          maxLines: 3,
        ),
      );
}
