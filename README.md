# LutoMate – Your AI-Powered Recipe Assistant 🍳🤖

LutoMate is a modern, mobile-first app that makes home cooking smarter, easier, and more fun. Powered by advanced AI, LutoMate helps you discover, personalize, and cook delicious recipes—just by chatting with the app!

---

## 🌟 What is LutoMate?
LutoMate is your personal kitchen companion. Whether you're a beginner or a seasoned cook, simply type what you want to eat or your available ingredients, and LutoMate's AI will suggest tailored recipes with:
- Dish name & description
- Main ingredients
- Cooking steps
- Estimated time & difficulty
- Reference links for full recipes

No more endless searching—just chat and cook!

---

## 🚀 Key Features
- **AI Chat for Recipes:** Type your cravings or available ingredients and get instant, smart recipe suggestions.
- **Personalized Experience:** Register, set your food preferences, and get recommendations that match your taste.
- **Clean, Intuitive UI:** Simple navigation with Home, AI Chat, and (optional) History tabs.
- **Recipe Details:** See all the info you need—ingredients, steps, time, difficulty, and links—on one page.
- **No Voice Required:** The app is fully chat-based for maximum reliability and privacy.
- **Mobile-First:** Built with Flutter for a smooth experience on Android and iOS.

---

## 🧑‍🍳 User Flow
1. **Register & Set Preferences:** Choose your favorite ingredients or cuisines.
2. **Home:** Browse popular categories and your personalized picks.
3. **AI Chat:** Type what you want ("I want something spicy with chicken"), and get instant recipe ideas.
4. **Recipe Details:** View all the info you need to cook, including a reference link.
5. **(Optional) History:** See your past queries (can be disabled for privacy).

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** FastAPI (Python 3.11)
- **Database:** PostgreSQL
- **AI Integration:** Google Gemini API
- **ORM:** SQLAlchemy
- **Deployment:** Docker, Render

---

## 🗂️ Project Structure
```
LutoMate/
  ├── Client/           # Flutter app
  │   └── lutomate/
  │       └── lib/
  │           ├── overview_page.dart
  │           ├── voice_page.dart
  │           └── ...
  └── Server/           # FastAPI backend
      └── User/app/
          ├── main.py
          ├── models.py
          ├── routers/
          │   ├── users.py
          │   └── recipes.py
          └── ...
```

---

## 💡 Example AI Chat
> **You:** I want a quick vegetarian dinner
>
> **LutoMate AI:**
> - Dish: Black Bean Burgers
>   - Description: Hearty and flavorful vegetarian burgers made with black beans and spices.
>   - Ingredients: Black beans, breadcrumbs, onion, spices, burger buns
>   - Time: 25 minutes
>   - Difficulty: Easy
>   

---

## 📈 Roadmap
- [x] AI-powered chat for recipes
- [x] Personalized recommendations
- [x] Clean, mobile-first UI
- [ ] User-uploaded recipes
- [ ] Favorites & grocery list
- [ ] Dietary filters (vegan, gluten-free, etc.)

---

## 🤝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 📲 Get Cooking with LutoMate!
Start chatting, get inspired, and make every meal smarter and easier. 🍲✨