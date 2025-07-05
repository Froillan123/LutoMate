import 'package:flutter/material.dart';

// 1. Dish Model Class
class Dish {
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> steps;

  const Dish({
    required this.name,
    required this.image,
    required this.ingredients,
    required this.steps,
  });
}

class PopularFoodsPage extends StatefulWidget {
  const PopularFoodsPage({super.key});

  @override
  State<PopularFoodsPage> createState() => _PopularFoodsPageState();
}

class _PopularFoodsPageState extends State<PopularFoodsPage> {
  // 2. Using the Dish Model for data
  final List<Dish> dishes = [
    Dish(
      name: 'Adobo',
      image: 'assets/adobo.png',
      ingredients: [
        '1 kg chicken or pork (or a mix)',
        '1/2 cup soy sauce',
        '1/2 cup vinegar',
        '6 cloves garlic, crushed',
        '3 bay leaves',
        '1 tsp black peppercorns',
        '2 tbsp oil',
        'Salt to taste',
      ],
      steps: [
        'Cut the meat into serving pieces and place in a bowl.',
        'Add soy sauce, vinegar, crushed garlic, bay leaves, and peppercorns. Mix well and marinate for at least 30 minutes (or overnight for best flavor).',
        'Heat oil in a pot over medium heat. Sauté extra garlic until fragrant.',
        'Add the marinated meat (reserve marinade) and brown on all sides.',
        'Pour in the marinade and add enough water to cover the meat.',
        'Bring to a boil, then lower heat and simmer, covered, until meat is tender (30-45 minutes).',
        'Remove the lid and continue simmering to reduce the sauce to your desired consistency.',
        'Season with salt if needed. Serve hot with steamed rice.'
      ],
    ),
    Dish(
      name: 'Sinigang',
      image: 'assets/sinigang.png',
      ingredients: [
        '1 kg pork (ribs or belly) or shrimp/fish',
        '1 pack tamarind mix or 200g fresh tamarind',
        '2 tomatoes, quartered',
        '1 onion, quartered',
        '1 bunch kangkong (water spinach)',
        '1 radish, sliced',
        '1 eggplant, sliced',
        '6-8 okra',
        '2 liters water',
        'Fish sauce and salt to taste',
      ],
      steps: [
        'In a large pot, combine pork, tomatoes, and onions. Add water and bring to a boil.',
        'Skim off any scum that rises to the surface.',
        'Lower heat and simmer until pork is tender (about 45 minutes).',
        'Add tamarind mix or fresh tamarind juice for sourness. Stir well.',
        'Add radish, eggplant, and okra. Simmer until vegetables are almost tender.',
        'Add kangkong and season with fish sauce and salt. Simmer for 2 more minutes.',
        'Taste and adjust seasoning as needed. Serve hot with steamed rice.'
      ],
    ),
    Dish(
      name: 'Kare-Kare',
      image: 'assets/kare-kare.png',
      ingredients: [
        '1 kg oxtail (or beef shank/tripe)',
        '1 banana flower (puso ng saging), sliced',
        '1 bundle string beans, cut',
        '2 eggplants, sliced',
        '1/2 cup peanut butter',
        '1/4 cup ground rice (or toasted rice flour)',
        '2 tbsp annatto seeds (atsuete)',
        '1 onion, chopped',
        '4 cloves garlic, minced',
        'Salt and pepper to taste',
        'Bagoong (shrimp paste) for serving',
      ],
      steps: [
        'Boil oxtail (and tripe, if using) in a large pot with enough water until tender. Set aside the meat and reserve the broth.',
        'In a small pan, soak annatto seeds in hot water, then strain to extract color. Set aside annatto water.',
        'In a large pan, heat oil and sauté garlic and onion until fragrant.',
        'Add the annatto water, peanut butter, and ground rice to the reserved broth. Stir until smooth and thickened.',
        'Add the vegetables (banana flower, string beans, eggplant) and simmer until just tender.',
        'Return the meat to the pot and simmer until sauce is thick and everything is heated through.',
        'Season with salt and pepper. Serve hot with bagoong (shrimp paste) on the side.'
      ],
    ),
    Dish(
      name: 'Lechon',
      image: 'assets/lechon.png',
      ingredients: [
        'Whole pig',
        'lemongrass',
        'garlic',
        'onions',
        'salt',
        'pepper',
      ],
      steps: [
        'Clean the pig thoroughly and pat dry.',
        'Stuff the cavity with lemongrass, garlic, and onions.',
        'Rub the skin with salt and pepper.',
        'Sew the cavity shut securely.',
        'Prepare a large charcoal pit or rotisserie.',
        'Roast the pig over hot coals, turning regularly, for several hours until the skin is crispy and golden brown.',
        'Let rest for a few minutes before chopping. Serve with liver sauce or vinegar dip.'
      ],
    ),
    Dish(
      name: 'Pancit Canton',
      image: 'assets/pancit-canton.png',
      ingredients: [
        'Egg noodles',
        'chicken',
        'pork',
        'shrimp',
        'cabbage',
        'carrots',
        'soy sauce',
        'garlic',
        'onions',
      ],
      steps: [
        'Prepare all ingredients: slice the meat and vegetables, peel shrimp if using.',
        'Boil the egg noodles for 2-3 minutes, then drain and set aside.',
        'Heat oil in a large pan or wok. Sauté garlic and onions until fragrant.',
        'Add chicken and pork, cook until lightly browned.',
        'Add shrimp and cook until pink.',
        'Add carrots and cabbage, stir-fry for 2 minutes.',
        'Pour in soy sauce and a little water or broth. Bring to a simmer.',
        'Add the noodles and toss everything together until well mixed and heated through.',
        'Season with more soy sauce or pepper to taste. Serve hot.'
      ],
    ),
    Dish(
      name: 'Pancit Bihon',
      image: 'assets/pancit-bihon.png',
      ingredients: [
        'Rice noodles',
        'chicken',
        'pork',
        'shrimp',
        'cabbage',
        'carrots',
        'soy sauce',
        'garlic',
      ],
      steps: [
        'Soak rice noodles in warm water until softened, then drain.',
        'Heat oil in a wok or large pan. Sauté garlic and onions until fragrant.',
        'Add chicken, pork, and shrimp. Cook until meat is done.',
        'Add carrots and cabbage, stir-fry for 2 minutes.',
        'Pour in soy sauce and a little water or broth. Bring to a simmer.',
        'Add the drained noodles and toss until well mixed and heated through.',
        'Season with more soy sauce or pepper to taste. Serve hot.'
      ],
    ),
    Dish(
      name: 'Lumpiang Shanghai',
      image: 'assets/lumpia.png',
      ingredients: [
        'Ground pork',
        'carrots',
        'garlic',
        'onions',
        'egg',
        'spring roll wrappers',
      ],
      steps: [
        'In a bowl, combine ground pork, minced carrots, garlic, onions, and egg. Mix well.',
        'Lay a lumpia wrapper flat and place a spoonful of filling near one edge.',
        'Roll tightly, folding in the sides, and seal the edge with a dab of water.',
        'Repeat until all filling is used.',
        'Heat oil in a deep pan. Fry lumpia in batches until golden brown and crispy.',
        'Drain on paper towels and serve with sweet chili sauce.'
      ],
    ),
    Dish(
      name: 'Tinola',
      image: 'assets/tinola.png',
      ingredients: [
        'Chicken',
        'green papaya or chayote',
        'ginger',
        'garlic',
        'onions',
        'malunggay leaves',
        'fish sauce',
      ],
      steps: [
        'Heat oil in a pot. Sauté garlic, onion, and ginger until fragrant.',
        'Add chicken pieces and cook until lightly browned.',
        'Add fish sauce and enough water to cover the chicken. Bring to a boil.',
        'Lower heat and simmer until chicken is almost cooked.',
        'Add green papaya or chayote and cook until tender.',
        'Add malunggay leaves and simmer for another 2 minutes.',
        'Serve hot with rice.'
      ],
    ),
    Dish(
      name: 'Laing',
      image: 'assets/laing.png',
      ingredients: [
        'Dried taro leaves',
        'coconut milk',
        'chili',
        'shrimp paste',
        'garlic',
        'pork or dried fish',
      ],
      steps: [
        'In a pot, combine coconut milk, garlic, chili, and shrimp paste. Bring to a simmer.',
        'Add pork or dried fish and cook for a few minutes.',
        'Add dried taro leaves on top. Do not stir.',
        'Simmer gently until taro leaves are fully softened and have absorbed the coconut milk.',
        'Stir gently, season to taste, and cook until oil starts to separate.',
        'Serve hot with rice.'
      ],
    ),
    Dish(
      name: 'Bicol Express',
      image: 'assets/bicol-express.png',
      ingredients: [
        'Pork',
        'coconut milk',
        'shrimp paste',
        'chili peppers',
        'garlic',
        'onions',
      ],
      steps: [
        'Heat oil in a pan. Sauté garlic and onions until fragrant.',
        'Add pork and cook until lightly browned.',
        'Add shrimp paste and chili peppers. Stir well.',
        'Pour in coconut milk and bring to a simmer.',
        'Cook until pork is tender and sauce is thickened.',
        'Serve hot with rice.'
      ],
    ),
    Dish(
      name: 'Halo-Halo',
      image: 'assets/halo-halo.png',
      ingredients: [
        'Shaved ice',
        'evaporated milk',
        'ube',
        'leche flan',
        'sweetened banana',
        'sweet beans',
        'nata de coco',
        'jackfruit',
        'ice cream',
      ],
      steps: [
        'Prepare all ingredients and chill them if possible.',
        'In a tall glass, layer sweetened banana, beans, nata de coco, jackfruit, and ube.',
        'Add a generous amount of shaved ice on top of the layers.',
        'Pour evaporated milk over the ice.',
        'Top with leche flan and a scoop of ice cream.',
        'Serve immediately and mix well before eating.'
      ],
    ),
    Dish(
      name: 'Turon',
      image: 'assets/turon.png',
      ingredients: [
        'Saba bananas',
        'jackfruit',
        'sugar',
        'spring roll wrapper',
      ],
      steps: [
        'Peel saba bananas and slice lengthwise.',
        'Place a slice of banana and a strip of jackfruit on a lumpia wrapper.',
        'Sprinkle with sugar.',
        'Roll tightly, folding in the sides, and seal the edge with water.',
        'Heat oil in a pan. Fry turon until golden brown and crispy.',
        'Drain on paper towels and serve warm.'
      ],
    ),
    Dish(
      name: 'Arroz Caldo',
      image: 'assets/arroz-caldo.png',
      ingredients: [
        'Glutinous rice',
        'chicken',
        'garlic',
        'ginger',
        'fish sauce',
        'hard-boiled eggs',
        'scallions',
      ],
      steps: [
        'Heat oil in a pot. Sauté garlic and ginger until fragrant.',
        'Add chicken pieces and cook until lightly browned.',
        'Add glutinous rice and stir to coat with oil.',
        'Pour in water and bring to a boil.',
        'Lower heat and simmer, stirring occasionally, until rice is soft and porridge-like.',
        'Season with fish sauce to taste.',
        'Serve hot, topped with hard-boiled eggs and chopped scallions.'
      ],
    ),
    Dish(
      name: 'Menudo',
      image: 'assets/menudo.png',
      ingredients: [
        'Pork',
        'liver',
        'potatoes',
        'carrots',
        'tomato sauce',
        'garlic',
        'onions',
        'bell peppers',
        'raisins',
      ],
      steps: [
        'Heat oil in a pan. Sauté garlic and onions until fragrant.',
        'Add pork and cook until lightly browned.',
        'Add liver and cook for 2 minutes.',
        'Add potatoes and carrots, stir well.',
        'Pour in tomato sauce and a little water. Simmer until meat and vegetables are tender.',
        'Add bell peppers and raisins. Simmer for 5 more minutes.',
        'Season to taste and serve hot with rice.'
      ],
    ),
    Dish(
      name: 'Caldereta',
      image: 'assets/caldereta.png',
      ingredients: [
        'Beef',
        'liver spread',
        'tomato sauce',
        'bell peppers',
        'carrots',
        'potatoes',
        'olives',
      ],
      steps: [
        'Heat oil in a pot. Sauté garlic and onions until fragrant.',
        'Add beef and cook until browned.',
        'Pour in tomato sauce and a little water. Simmer until beef is tender.',
        'Add liver spread and mix well.',
        'Add potatoes, carrots, and bell peppers. Simmer until vegetables are cooked.',
        'Add olives and simmer for 2 more minutes.',
        'Season to taste and serve hot.'
      ],
    ),
    Dish(
      name: 'Sisig',
      image: 'assets/sisig.png',
      ingredients: [
        'Pork face and ears',
        'liver',
        'onions',
        'chilies',
        'calamansi',
        'mayonnaise or egg',
      ],
      steps: [
        'Boil pork face and ears until tender, then drain and cool.',
        'Grill or broil the pork parts until crispy, then chop finely.',
        'Sauté chopped pork with onions and chilies in a hot pan.',
        'Add chopped liver and cook for 2 minutes.',
        'Season with calamansi juice, salt, and pepper.',
        'Top with mayonnaise or a raw egg before serving on a sizzling plate.'
      ],
    ),
    Dish(
      name: 'Ginataang Gulay',
      image: 'assets/ginataang-gulay.png',
      ingredients: [
        'Squash',
        'string beans',
        'coconut milk',
        'shrimp or pork',
        'garlic',
        'onions',
        'fish sauce',
      ],
      steps: [
        'Heat oil in a pan. Sauté garlic and onions until fragrant.',
        'Add shrimp or pork and cook until done.',
        'Pour in coconut milk and bring to a simmer.',
        'Add squash and string beans. Cook until vegetables are tender.',
        'Season with fish sauce to taste.',
        'Serve hot with rice.'
      ],
    ),
    Dish(
      name: 'Pinakbet',
      image: 'assets/pinakbet.png',
      ingredients: [
        'Eggplant',
        'bitter melon',
        'squash',
        'okra',
        'string beans',
        'tomatoes',
        'bagoong (shrimp paste)',
      ],
      steps: [
        'Heat oil in a pan. Sauté garlic, onions, and tomatoes until soft.',
        'Add bagoong (shrimp paste) and mix well.',
        'Add all vegetables and stir to coat with sauce.',
        'Pour in a little water, cover, and simmer until vegetables are tender.',
        'Season to taste and serve hot.'
      ],
    ),
    Dish(
      name: 'Tocino',
      image: 'assets/tocino.png',
      ingredients: [
        'Pork',
        'sugar',
        'salt',
        'pineapple juice',
        'garlic',
        'food coloring (optional)',
      ],
      steps: [
        'In a bowl, combine pork, sugar, salt, pineapple juice, garlic, and food coloring if using. Mix well.',
        'Marinate pork in the mixture overnight in the refrigerator.',
        'Place marinated pork in a pan with a little water. Cook over medium heat until water evaporates.',
        'Add oil and fry pork until caramelized and slightly crispy.',
        'Serve hot with garlic rice and egg.'
      ],
    ),
    Dish(
      name: 'Bibingka',
      image: 'assets/bibingka.png',
      ingredients: [
        'Rice flour',
        'coconut milk',
        'eggs',
        'sugar',
        'butter',
        'salted egg',
        'cheese',
      ],
      steps: [
        'Preheat oven to 180°C (350°F).',
        'In a bowl, mix rice flour, coconut milk, eggs, and sugar until smooth.',
        'Grease a baking pan or line with banana leaves.',
        'Pour batter into the pan. Top with slices of salted egg and cheese.',
        'Bake for 25-30 minutes or until set and golden brown.',
        'Brush with butter before serving.'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFD7BFA6).withOpacity(0.2), // Subtle gradient background
            ],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16, // Increased spacing
            mainAxisSpacing: 16, // Increased spacing
            childAspectRatio: 0.8, // Slightly adjusted for better image fit
          ),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PopularFoodDetailsPage(dish: dish),
                  ),
                );
              },
              child: Hero( // Hero Animation
                tag: dish.name, // Unique tag for hero animation
                child: Card(
                  elevation: 8, // More pronounced shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // More rounded corners
                  ),
                  clipBehavior: Clip.antiAlias, // Ensures content respects border radius
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.asset(
                          dish.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 50), // Larger icon
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFD7BFA6), // Main color
                          // No bottom radius here as it's part of the card
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), // More padding
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Slightly larger font
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PopularFoodDetailsPage extends StatelessWidget {
  final Dish dish; // Now expects a Dish object
  const PopularFoodDetailsPage({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFD7BFA6);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dish.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                mainColor,
                mainColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero( // Hero Animation
                tag: dish.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25), // More rounded corners
                  child: Image.asset(
                    dish.image,
                    width: double.infinity,
                    height: 250, // Slightly taller image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      height: 250,
                      child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 80), // Larger icon
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Increased spacing
              Text(
                'Ingredients:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87, // Darker text
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1, height: 20), // Added divider
              const SizedBox(height: 12),
              ...dish.ingredients.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 8), // More padding between ingredients
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: mainColor, size: 20), // Checkmark icon
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ing,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 35), // Increased spacing
              Text(
                'How to Cook:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1, height: 20), // Added divider
              const SizedBox(height: 12),
              ...dish.steps.asMap().entries.map((e) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 15), // More spacing between steps
                    padding: const EdgeInsets.all(15), // More padding
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.15), // Slightly stronger accent background
                      borderRadius: BorderRadius.circular(15), // More rounded corners
                      boxShadow: [ // Subtle shadow for steps
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 35, // Larger step number circle
                          height: 35,
                          decoration: BoxDecoration(
                            color: mainColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Larger font
                            ),
                          ),
                        ),
                        const SizedBox(width: 15), // More space between number and text
                        Expanded(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6, // Increased line height
                              color: Colors.grey[850],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}