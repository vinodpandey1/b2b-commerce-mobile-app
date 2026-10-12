import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/components/cart_action_button.dart';
import '../../core/models/userModel.dart';
import '../../core/routes/app_routes.dart';
import '../menu/menu_page.dart';
import 'components/home_product_card.dart';
import 'home_data.dart';
import 'new_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, this.onOpenCategories, this.onOpenAccount, this.loader});
  final VoidCallback? onOpenCategories;
  final VoidCallback? onOpenAccount;
  final Future<HomeData> Function()? loader;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeData? data;
  bool loading = true;
  int bannerIndex = 0;
  final bannerController = PageController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result = await (widget.loader ?? HomeRepository().load)();
      if (!mounted) return;
      setState(() {
        // Keep the visible catalog during a failed refresh.
        data = result.products.isEmpty && result.hasError && data != null
            ? HomeData(
                content: data!.content,
                products: data!.products,
                categories: data!.categories,
                hasError: true)
            : result;
        loading = false;
        bannerIndex = 0;
      });
      if (bannerController.hasClients) bannerController.jumpToPage(0);
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          data = HomeData(
              content: data?.content ?? {},
              products: data?.products ?? [],
              categories: data?.categories ?? [],
              hasError: true);
        });
      }
    }
  }

  void _catalog({bool latest = false}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              NewItemsPage(title: latest ? 'Latest Eats' : 'All products')));
  void _categories() {
    if (widget.onOpenCategories != null) {
      widget.onOpenCategories!();
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const MenuPage()));
    }
  }

  void _category(int? id, String title) {
    if (id == null || title.toLowerCase() == 'default') {
      _catalog();
      return;
    }
    Navigator.pushNamed(context, AppRoutes.categoryDetails,
        arguments: {'categoryId': id, 'categoryName': title});
  }

  String _text(Map<String, dynamic> section, String key, String fallback) =>
      section[key]?.toString().trim().isNotEmpty == true
          ? section[key].toString()
          : fallback;
  Widget _heading(String title, {VoidCallback? onTap, String? eyebrow}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (eyebrow != null) ...[
              Text(eyebrow.toUpperCase(),
                  style: const TextStyle(
                      color: homeLeaf,
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
            ],
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: homeForest,
                          fontSize: 25,
                          height: 1.15,
                          fontWeight: FontWeight.w700))),
              if (onTap != null)
                TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                        foregroundColor: homeLeaf,
                        padding: const EdgeInsets.all(8)),
                    child: const Text('View all')),
            ]),
          ]));
  Widget _image(String url, String asset, {BoxFit fit = BoxFit.cover}) {
    final fallback = Image.asset('assets/images/home/$asset', fit: fit);
    if (url.isEmpty) return fallback;
    return CachedNetworkImage(
        imageUrl: homeImageUrl(url),
        fit: fit,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback);
  }

  Widget _hero(List<HomeBanner> banners) => Column(children: [
        SizedBox(
            height: 210,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: PageView.builder(
                    controller: bannerController,
                    itemCount: banners.length,
                    onPageChanged: (index) =>
                        setState(() => bannerIndex = index),
                    itemBuilder: (_, index) {
                      final banner = banners[index];
                      return InkWell(
                          onTap: () =>
                              _category(banner.categoryId, banner.title),
                          child: Stack(fit: StackFit.expand, children: [
                            _image(banner.image, banner.asset),
                            const DecoratedBox(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                  Colors.transparent,
                                  Color(0xB3183C2B)
                                ]))),
                            Positioned(
                                left: 18,
                                right: 14,
                                bottom: 16,
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        const Text('FULL OF FLAVOUR',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.7)),
                                        const SizedBox(height: 5),
                                        Text(banner.title,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                height: 1.15,
                                                fontWeight: FontWeight.w700)),
                                      ])),
                                  const CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.arrow_forward,
                                          color: homeForest, size: 18)),
                                ])),
                          ]));
                    }))),
        if (banners.length > 1)
          SizedBox(
              height: 28,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < banners.length; i++)
                  Semantics(
                      label: 'Banner ${i + 1}',
                      button: true,
                      selected: i == bannerIndex,
                      child: InkWell(
                          onTap: () => bannerController.animateToPage(i,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              child: Container(
                                  width: i == bannerIndex ? 22 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: i == bannerIndex
                                          ? homeLeaf
                                          : const Color(0xFFCCD9C5),
                                      borderRadius:
                                          BorderRadius.circular(8))))))
              ])),
      ]);
  Widget _products(List<Product> products, {bool rail = false}) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final height = 430.0 + (scale - 1) * 250;
    if (products.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
              'Products are currently unavailable. Pull down to refresh.'));
    }
    if (rail) {
      return SizedBox(
          height: height,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                  width: 178,
                  child: HomeProductCard(product: products[index]))));
    }
    return LayoutBuilder(builder: (_, constraints) {
      final count = constraints.maxWidth >= 650 ? 4 : 2;
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              mainAxisExtent: height,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12),
          itemBuilder: (_, index) => HomeProductCard(product: products[index]));
    });
  }

  Widget _story(HomeData home) {
    final story = home.section('story');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
              height: 210,
              width: double.infinity,
              child: _image(_text(story, 'image', ''), 'story.jpg'))),
      const SizedBox(height: 22),
      _heading(_text(story, 'title', 'Why choose us'),
          eyebrow: _text(story, 'eyebrow', 'Earthling Consumer Products')),
      Text(
          _text(story, 'body',
              'At Earthling, we believe everyday meals should feel effortless, dependable and full of flavour. Our carefully selected range of canned fruits, vegetables, sauces, syrups, purees and ready-to-use ingredients helps homes and professional kitchens create memorable food with confidence.'),
          style: const TextStyle(
              color: Color(0xFF69746D), fontSize: 14, height: 1.65)),
      const SizedBox(height: 12),
      Text(
          _text(story, 'body_secondary',
              'Every product reflects our focus on integrity, quality and passion—from sourcing and packaging to the moment it reaches your kitchen.'),
          style: const TextStyle(
              color: Color(0xFF69746D), fontSize: 14, height: 1.65)),
      const SizedBox(height: 16),
      OutlinedButton.icon(
          onPressed: () => _catalog(),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(_text(story, 'button_text', 'Explore all products')),
          style: OutlinedButton.styleFrom(
              foregroundColor: homeForest,
              side: const BorderSide(color: Color(0xFFD5E3CD)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)))),
    ]);
  }

  Widget _stats(HomeData home) {
    final configured = homeList(home.earthling['stats']);
    final stats = configured.isEmpty
        ? [
            {'value': '100+', 'label': 'SKUs'},
            {'value': '25+', 'label': 'Lakh cans sold'},
            {'value': '40+', 'label': 'Cities'},
            {'value': '10k+', 'label': 'Happy customers'},
          ]
        : configured;
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: homeMint, borderRadius: BorderRadius.circular(22)),
        child: LayoutBuilder(
            builder: (_, size) => Wrap(spacing: 12, runSpacing: 24, children: [
                  for (final raw in stats)
                    SizedBox(
                        width:
                            (size.maxWidth - 12).clamp(0.0, double.infinity) /
                                2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${homeMap(raw)['value'] ?? ''}',
                                  style: const TextStyle(
                                      color: homeForest,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30)),
                              Text('${homeMap(raw)['label'] ?? ''}',
                                  style: const TextStyle(
                                      color: Color(0xFF69746D), fontSize: 12)),
                            ]))
                ])));
  }

  Widget _expert(HomeData home) {
    final expert = home.section('expert');
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: homeCream,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE9EAD8))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
              aspectRatio: 1280 / 966,
              child: _image(_text(expert, 'image', ''), 'expert.jpg',
                  fit: BoxFit.contain)),
          Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading(_text(expert, 'title', 'Expert corner')),
                    const Icon(Icons.format_quote_rounded,
                        color: homeLeaf, size: 32),
                    Text(
                        _text(expert, 'quote',
                            'Quality ingredients make good cooking simpler. Earthling brings dependable products and consistent flavour to every kitchen.'),
                        style: const TextStyle(
                            color: homeForest, fontSize: 16, height: 1.6)),
                    const SizedBox(height: 18),
                    Text(_text(expert, 'name', 'Chef Izzat Hussain'),
                        style: const TextStyle(
                            color: homeForest, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_text(expert, 'role', 'Culinary expert'),
                        style: const TextStyle(
                            color: Color(0xFF69746D), fontSize: 12)),
                  ])),
        ]));
  }

  IconData _categoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('syrup') || lower.contains('crush')) {
      return Icons.local_drink_outlined;
    }
    if (lower.contains('oil')) return Icons.water_drop_outlined;
    if (lower.contains('noodle') || lower.contains('pasta')) {
      return Icons.ramen_dining_outlined;
    }
    if (lower.contains('sauce') || lower.contains('lkk')) {
      return Icons.soup_kitchen_outlined;
    }
    if (lower.contains('fruit')) return Icons.eco_outlined;
    return Icons.kitchen_outlined;
  }

  Widget _categoryTiles(HomeData home) => LayoutBuilder(
      builder: (_, size) => Wrap(spacing: 12, runSpacing: 12, children: [
            for (final category in home.categories.take(6))
              SizedBox(
                  width: (size.maxWidth - 12).clamp(0.0, double.infinity) / 2,
                  child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Color(0xFFDFE9D8))),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _category(category.id, category.name),
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                        backgroundColor: homeMint,
                                        child: Icon(
                                            _categoryIcon(category.name),
                                            color: homeLeaf,
                                            size: 22)),
                                    const SizedBox(height: 14),
                                    Text(
                                        category.name.toLowerCase() == 'default'
                                            ? 'All categories'
                                            : category.name,
                                        style: const TextStyle(
                                            color: homeForest,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.arrow_forward,
                                        size: 17, color: homeLeaf),
                                  ]))))),
          ]));
  @override
  Widget build(BuildContext context) {
    final home = data;
    return Scaffold(
        backgroundColor: const Color(0xFFFBFDF8),
        body: LayoutBuilder(
            builder:
                (context, viewport) =>
                    viewport.maxWidth < 80 || viewport.maxHeight < 80
                        ? const SizedBox.shrink()
                        : SafeArea(
                            bottom: false,
                            child: RefreshIndicator(
                                onRefresh: _load,
                                color: homeLeaf,
                                child: CustomScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    slivers: [
                                      SliverAppBar(
                                          pinned: true,
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          elevation: 0,
                                          scrolledUnderElevation: 1,
                                          leading: IconButton(
                                              tooltip: 'Menu',
                                              icon: const Icon(
                                                  Icons.menu_rounded,
                                                  color: homeForest),
                                              onPressed: () =>
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.drawerPage)),
                                          titleSpacing: 0,
                                          title: Image.asset(
                                              'assets/images/home/earthling-logo.png',
                                              width: 120,
                                              height: 42,
                                              fit: BoxFit.contain),
                                          actions: [
                                            const CartActionButton(),
                                            IconButton(
                                                tooltip: 'Account',
                                                icon: const Icon(
                                                    Icons.person_outline,
                                                    color: homeForest),
                                                onPressed: widget
                                                        .onOpenAccount ??
                                                    () => Navigator.pushNamed(
                                                        context,
                                                        AppRoutes.profilePage))
                                          ]),
                                      SliverToBoxAdapter(
                                          child: Center(
                                              child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 1000),
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          16, 12, 16, 28),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Material(
                                                                color: Colors
                                                                    .white,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            14),
                                                                    side: const BorderSide(
                                                                        color: Color(
                                                                            0xFFDFE9D8))),
                                                                child: InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            14),
                                                                    onTap: () => Navigator.pushNamed(
                                                                        context,
                                                                        AppRoutes
                                                                            .search),
                                                                    child: const Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                                                        child: Row(children: [
                                                                          Icon(
                                                                              Icons.search,
                                                                              color: homeLeaf,
                                                                              size: 21),
                                                                          SizedBox(
                                                                              width: 12),
                                                                          Expanded(
                                                                              child: Text('Search products, brands & more', style: TextStyle(color: Color(0xFF69746D), fontSize: 13)))
                                                                        ])))),
                                                            const SizedBox(
                                                                height: 18),
                                                            _hero(
                                                                home?.banners ??
                                                                    const [
                                                                      HomeBanner(
                                                                          '',
                                                                          21,
                                                                          'Crushes and Bar Syrups',
                                                                          'hero-crushes.jpeg'),
                                                                      HomeBanner(
                                                                          '',
                                                                          32,
                                                                          'Sauces and Ketchups',
                                                                          'hero-sauces.jpg')
                                                                    ]),
                                                            if (loading)
                                                              const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              32),
                                                                  child: Center(
                                                                      child: CircularProgressIndicator(
                                                                          color:
                                                                              homeLeaf))),
                                                            if (home !=
                                                                null) ...[
                                                              if (home.hasError)
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            12),
                                                                    child: Row(
                                                                        children: [
                                                                          const Expanded(
                                                                              child: Text('Some content could not be refreshed.', style: TextStyle(fontSize: 12))),
                                                                          TextButton(
                                                                              onPressed: _load,
                                                                              child: const Text('Retry'))
                                                                        ])),
                                                              if (homeEnabled(homeMap(
                                                                      home.content[
                                                                          'products_list'])[
                                                                  'status'])) ...[
                                                                Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            16),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                24),
                                                                        gradient: const LinearGradient(
                                                                            colors: [
                                                                              homeMint,
                                                                              homeCream
                                                                            ],
                                                                            begin: Alignment
                                                                                .topLeft,
                                                                            end: Alignment
                                                                                .bottomRight),
                                                                        border: Border.all(
                                                                            color: const Color(
                                                                                0xFFDFE9D8))),
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          _heading(
                                                                              _text(homeMap(home.content['products_list']), 'title', 'Latest Eats'),
                                                                              eyebrow: _text(homeMap(home.content['products_list']), 'tag', 'Special offer'),
                                                                              onTap: () => _catalog(latest: true)),
                                                                          _products(
                                                                              home.latest,
                                                                              rail: true),
                                                                        ])),
                                                                const SizedBox(
                                                                    height: 32),
                                                              ],
                                                              _story(home),
                                                              const SizedBox(
                                                                  height: 28),
                                                              _stats(home),
                                                              const SizedBox(
                                                                  height: 32),
                                                              _expert(home),
                                                              const SizedBox(
                                                                  height: 32),
                                                              _heading(
                                                                  _text(
                                                                      home.section(
                                                                          'featured'),
                                                                      'title',
                                                                      'Popular products'),
                                                                  onTap: () =>
                                                                      _catalog()),
                                                              _products(
                                                                  home.popular),
                                                              const SizedBox(
                                                                  height: 32),
                                                              _heading(
                                                                  _text(
                                                                      home.section(
                                                                          'categories'),
                                                                      'title',
                                                                      'Shop by category'),
                                                                  onTap:
                                                                      _categories),
                                                              _categoryTiles(
                                                                  home),
                                                              const SizedBox(
                                                                  height: 36),
                                                              const Divider(
                                                                  color: Color(
                                                                      0xFFDFE9D8)),
                                                              const SizedBox(
                                                                  height: 20),
                                                              Center(
                                                                  child: Image.asset(
                                                                      'assets/images/home/earthling-logo.png',
                                                                      width:
                                                                          130,
                                                                      height:
                                                                          48)),
                                                              const SizedBox(
                                                                  height: 10),
                                                              const Center(
                                                                  child: Text(
                                                                      'Integrity · Quality · Passion',
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF69746D),
                                                                          fontSize:
                                                                              12))),
                                                            ],
                                                          ]))))),
                                    ])))));
  }
}
