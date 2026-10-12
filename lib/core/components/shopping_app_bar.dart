import 'package:flutter/material.dart';
import 'app_back_button.dart';
import 'cart_action_button.dart';

class ShoppingAppBar extends AppBar {
  ShoppingAppBar(
      {super.key,
      super.title,
      Widget? leading,
      List<Widget>? actions,
      super.backgroundColor,
      super.elevation,
      super.titleTextStyle,
      super.centerTitle,
      super.automaticallyImplyLeading,
      bool showCart = true})
      : super(
            leading: leading ?? const AppBackButton(),
            actions: [...?actions, if (showCart) const CartActionButton()]);
}
