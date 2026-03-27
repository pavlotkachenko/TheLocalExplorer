from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import Optional
import uuid
import math
from datetime import datetime, timedelta, timezone

app = FastAPI(title="The Local Explorer API")

# Disable CORS. Do not remove this for full-stack development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Dish(BaseModel):
    id: str
    name: str
    description: str
    price: float


class Spot(BaseModel):
    id: str
    name: str
    cuisine: str
    price_level: int
    latitude: float
    longitude: float
    address: str
    walking_time_minutes: int
    distance_miles: float
    vibes: list[str]
    description: str
    editorial_quote: str
    editor_name: str
    editor_avatar_url: str
    photo_urls: list[str]
    top_dishes: list[Dish]


class Drop(BaseModel):
    id: str
    title: str
    subtitle: str
    category: str
    image_url: str
    spot_ids: list[str]


class DailyDropResponse(BaseModel):
    hero: Drop
    drops: list[Drop]
    nearby_spots: list[Spot]


class Voter(BaseModel):
    id: str
    name: str
    avatar_url: str


class PollOption(BaseModel):
    id: str
    spot_id: str
    spot_name: str
    spot_image_url: str
    walking_time_minutes: int
    vote_count: int
    vote_percentage: float


class Poll(BaseModel):
    id: str
    title: str
    options: list[PollOption]
    total_votes: int
    closes_at: str
    created_at: str
    voters: list[Voter]


class CreatePollRequest(BaseModel):
    title: str
    spot_ids: list[str]
    duration_minutes: int = 45


class VoteRequest(BaseModel):
    option_id: str
    voter_name: str = "Anonymous"


class SpotCollection(BaseModel):
    id: str
    name: str
    spots: list[Spot]


class SaveSpotRequest(BaseModel):
    spot_id: str


EDITOR_AVATAR = "https://lh3.googleusercontent.com/aida-public/AB6AXuCQovXBn1bFDZD_yDkoLFfSJPwCxqFsGj99csZMP5_2tEihZVJ8PHX6374GMi-a8z8IfIEqCSXTMGZFf46ovXIFpGv6lHFPygqQQgINIL5nEeTVv-ecJSR-EJX_fVB1z4DJhmBbr0HC2IaIYTkyHS40Z_4lh5KQTlXubISSDM-tpnwGjIb4c_dtm54x-6F6g4Zo7erNF6gLbhLK8_1wqkktLiwo3-J2QQJQBlcWin4TFAGlffnkPp03tTiK0GsLULV7ww4nvBce"

VOTER_AVATARS = [
    "https://lh3.googleusercontent.com/aida-public/AB6AXuDeRptvmgFeSLIoecUgiXFH3HyYaaEFUUw-OzIPkaoK_5CFEkEUhkPazPfIY6C9Fq28WroxUPTi7Q3NQZvsAV1okeM9vt_IAlfRfMG6FwIoBNlSldrHN2b2myY-1kE3_s5H-b2781by4z-WAAXKPyL028kiwZcLckkRgGVRkt9xRd7lnZh8p8PhRv1SQjAMqxBpdkE4FvL1PGBivcFh5wZOBX3rBQ2D9PFV72JQdLcsZce4WnYnjoCu7lXgp49Cn3FLCXMoz1II",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuDJyXm1REyQfLJU00iOMH20kU8gcGpoSjWjB0EhgjOgVbEy_nvpE4vFXfnDBgCoNGo6SoaukEmJY6VGFRiH59SZP-tnrKsj2uK5mczSSzk3Rv8ybaBhvXVN0WpamEA3ZS8GpEWp2DgSAn6NKoaSig4AclxXX5ZLGugLgYdvKJuZOCceIzMQEbujgmTWf2LHlsGDzMokA4-RR6YPV5IEZFj7UdDHZck-20YbHowYVbFMJ-3hggVi6auvyoRW565sDAKHfIfl1GT3",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuBbzHr8nn4qzh1uUDvL6sdhYBjn2KKKFAVBRZWhsTYX3Mf61ZgTjJw3z8SrxEI0wl5T2wVPZINOE6GhnLldYX8nQIn3vmWfbU2zG3G1qhlsLLxOjFBR9zIdOjXW6HWyijISLU2U62VXabPXtyoIqhj-KFFzYgoxw7U1RT84cUjuyNBxAiSVO0dSOOO_gZm43sXUC455ZYDHgKhPEpM8O_4OhHA1kVJGjO9DLvU6griQAQJXrflJHBdqZ6sKSBYhUZJHwfvizDpy",
    "https://lh3.googleusercontent.com/aida-public/AB6AXuCQovXBn1bFDZD_yDkoLFfSJPwCxqFsGj99csZMP5_2tEihZVJ8PHX6374GMi-a8z8IfIEqCSXTMGZFf46ovXIFpGv6lHFPygqQQgINIL5nEeTVv-ecJSR-EJX_fVB1z4DJhmBbr0HC2IaIYTkyHS40Z_4lh5KQTlXubISSDM-tpnwGjIb4c_dtm54x-6F6g4Zo7erNF6gLbhLK8_1wqkktLiwo3-J2QQJQBlcWin4TFAGlffnkPp03tTiK0GsLULV7ww4nvBce",
]

SPOTS: list[Spot] = [
    Spot(id="spot-1", name="Rubirosa Ristorante", cuisine="Italian", price_level=3, latitude=40.7228, longitude=-73.9954, address="235 Mulberry St, New York, NY 10012", walking_time_minutes=5, distance_miles=0.3, vibes=["Loud", "Good for Groups", "Aesthetic", "Classic"], description="A bustling neighborhood favorite specializing in thin-crust pizzas and classic Italian-American comfort food.", editorial_quote="Don\'t leave without trying the tie-dye pizza. It\'s an absolute non-negotiable for team lunches.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://lh3.googleusercontent.com/aida-public/AB6AXuDF43Tie2lnC-jRFlMbOTbIkCsNzI9kc4c-ISXbn2NXnQl3TkWqzQD_FNFnS_-BwtUmRyghqxldjIUjsBoeUo6MrUhLM_1DdIXqZkGzqH8fjdDPe_HiFeF1NFA4tICvQBgB8D-zhlOVp-EiV0nDA0NAEg-_dhqKJ60vxU_KP7UcJyi5ASwZUSsXdR6As3EhYQl4NvddUompxNDYCRjBa0ZFOosnD8p8-FHkfOE2_RMxZdUGDdDECjFckaM3X5_yidbdFQ9rTUXx","https://lh3.googleusercontent.com/aida-public/AB6AXuBqhBXjBY3O_qO5ie2WFMNx1fSp5EDujOsvoOyQ-EWtSyh7eehVEoNuA8xSdPmmOt9MCkzebhk1R4gX9lzY2TOvx-g-vQ5pjvzuWRGFLqIRCwxdNj4NQNTElmTwn55gNkrXYcf5MTZvoFVE99yaBf6hhPff9un3dDhqiU-BzUsJeDLyZ_JbU43ZYWTDaoGDzkzlFQVR3hCoWPeXZ-X8lcDYPokQfbtP2pS8g7xeMz5AAA-isfPxqYtprX3Fn-jhdz5fmtUp5m77","https://lh3.googleusercontent.com/aida-public/AB6AXuCV4ykKFKd7k88lE89KWlhnZu33E9TXZoBRRo7CRLMsGBJEaE1LI7zGm8pFQkxEKXN7zY_bTZ--5fjnLfBzYJXahLcfjN0u95EKxZP9gwF476nn_oNMxK6MRBci0yku8bArelByAGo2l1LGXhk-3iEgTT_8puT4cCag4JjYURKzUAdZ0H_x-rVC6Q0HsRADfbsr51eatjT7zTknEd-qIk_PP_Rp5yBfwho9UXEKrKKMzpbiiC6fTTmY__FZPdd1bxpfv14WYlib"], top_dishes=[Dish(id="d1", name="Tie-Dye Pizza", description="Vodka, tomato, pesto", price=28), Dish(id="d2", name="Spicy Rigatoni", description="Housemade pasta, fresh ricotta", price=24), Dish(id="d3", name="Classic Caesar", description="Parmesan crisp, anchovy", price=16)]),
    Spot(id="spot-2", name="Sweetgreen", cuisine="Salads", price_level=2, latitude=40.7455, longitude=-73.9885, address="1164 Broadway, New York, NY 10001", walking_time_minutes=5, distance_miles=0.2, vibes=["Quick Bites", "Healthy", "Cheap Eats"], description="The reliable go-to for a healthy, customizable lunch.", editorial_quote="The harvest bowl with the hot honey chicken is genuinely great.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800","https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800","https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800"], top_dishes=[Dish(id="d4", name="Harvest Bowl", description="Warm quinoa, sweet potato, hot honey chicken", price=15), Dish(id="d5", name="Guacamole Greens", description="Avocado, tortilla chips, lime cilantro", price=14), Dish(id="d6", name="Crispy Rice Bowl", description="Blackened chicken, miso sesame ginger", price=15)]),
    Spot(id="spot-3", name="Carbone", cuisine="Italian", price_level=4, latitude=40.7263, longitude=-74.0005, address="181 Thompson St, New York, NY 10012", walking_time_minutes=8, distance_miles=0.5, vibes=["Power Lunch", "Client Meetings", "Loud", "Classic"], description="The ultimate power lunch destination. Old-school Italian-American grandeur.", editorial_quote="The spicy rigatoni is worth the line.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800","https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800","https://images.unsplash.com/photo-1481931098730-318b6f776db0?w=800"], top_dishes=[Dish(id="d7", name="Spicy Rigatoni Vodka", description="Vodka sauce, calabrian chili", price=36), Dish(id="d8", name="Meatball", description="Grandma\'s recipe, red sauce, ricotta", price=28), Dish(id="d9", name="Veal Parm", description="Pan-fried, mozzarella, San Marzano", price=58)]),
    Spot(id="spot-4", name="KazuNori", cuisine="Japanese", price_level=2, latitude=40.7287, longitude=-73.9944, address="15 W Houston St, New York, NY 10012", walking_time_minutes=12, distance_miles=0.7, vibes=["Aesthetic", "Quick Bites", "Date Spot"], description="The hand roll bar from Sugarfish\'s team. Clean, elegant, and surprisingly fast.", editorial_quote="Three hand rolls and a beer. In and out in 30 minutes. The blue crab is unreal.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800","https://images.unsplash.com/photo-1553621042-f6e147245754?w=800","https://images.unsplash.com/photo-1617196034183-421b4917c92d?w=800"], top_dishes=[Dish(id="d10", name="Blue Crab Hand Roll", description="Fresh crab, warm rice, crispy nori", price=12), Dish(id="d11", name="Salmon Hand Roll", description="Wild salmon, scallion, sesame", price=9), Dish(id="d12", name="Toro Hand Roll", description="Fatty tuna belly, shiso", price=16)]),
    Spot(id="spot-5", name="Joe\'s Pizza", cuisine="Pizza", price_level=1, latitude=40.7306, longitude=-74.0022, address="7 Carmine St, New York, NY 10014", walking_time_minutes=8, distance_miles=0.4, vibes=["Cheap Eats", "Quick Bites", "Classic", "Late Night"], description="The quintessential New York slice. No frills, just perfectly charred, foldable pizza.", editorial_quote="Two slices and a can of soda for under $10. The best deal in Manhattan.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800","https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800","https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800"], top_dishes=[Dish(id="d13", name="Plain Cheese Slice", description="Mozzarella, San Marzano sauce", price=4), Dish(id="d14", name="Fresh Mozz Slice", description="Hand-pulled mozzarella, basil", price=6), Dish(id="d15", name="Pepperoni Slice", description="Cup-and-char pepperoni", price=5)]),
    Spot(id="spot-6", name="La Pecora Bianca", cuisine="Italian", price_level=3, latitude=40.7420, longitude=-73.9890, address="1133 Broadway, New York, NY 10010", walking_time_minutes=8, distance_miles=0.4, vibes=["Power Lunch", "Outdoor Seating", "Good for Groups"], description="Light-filled, modern Italian with a focus on seasonal ingredients.", editorial_quote="The cacio e pepe is the best in the neighborhood.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://lh3.googleusercontent.com/aida-public/AB6AXuDF43Tie2lnC-jRFlMbOTbIkCsNzI9kc4c-ISXbn2NXnQl3TkWqzQD_FNFnS_-BwtUmRyghqxldjIUjsBoeUo6MrUhLM_1DdIXqZkGzqH8fjdDPe_HiFeF1NFA4tICvQBgB8D-zhlOVp-EiV0nDA0NAEg-_dhqKJ60vxU_KP7UcJyi5ASwZUSsXdR6As3EhYQl4NvddUompxNDYCRjBa0ZFOosnD8p8-FHkfOE2_RMxZdUGDdDECjFckaM3X5_yidbdFQ9rTUXx","https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800","https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800"], top_dishes=[Dish(id="d16", name="Cacio e Pepe", description="House-made tonnarelli, pecorino, black pepper", price=24), Dish(id="d17", name="Grilled Branzino", description="Lemon, capers, olive oil", price=34), Dish(id="d18", name="Burrata", description="Heirloom tomatoes, basil, aged balsamic", price=18)]),
    Spot(id="spot-7", name="Maman", cuisine="Cafe", price_level=2, latitude=40.7468, longitude=-73.9870, address="22 W 25th St, New York, NY 10010", walking_time_minutes=4, distance_miles=0.2, vibes=["Aesthetic", "Quiet", "Coffee", "Work Friendly"], description="French-inspired pastries and excellent coffee in a charming space.", editorial_quote="The nutella chocolate chunk cookie is one of the best things in this city.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://lh3.googleusercontent.com/aida-public/AB6AXuBqhBXjBY3O_qO5ie2WFMNx1fSp5EDujOsvoOyQ-EWtSyh7eehVEoNuA8xSdPmmOt9MCkzebhk1R4gX9lzY2TOvx-g-vQ5pjvzuWRGFLqIRCwxdNj4NQNTElmTwn55gNkrXYcf5MTZvoFVE99yaBf6hhPff9un3dDhqiU-BzUsJeDLyZ_JbU43ZYWTDaoGDzkzlFQVR3hCoWPeXZ-X8lcDYPokQfbtP2pS8g7xeMz5AAA-isfPxqYtprX3Fn-jhdz5fmtUp5m77","https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800","https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800"], top_dishes=[Dish(id="d19", name="Nutella Cookie", description="Chocolate chunk, sea salt, hazelnut", price=5), Dish(id="d20", name="Avocado Toast", description="Sourdough, poached egg, chili flakes", price=16), Dish(id="d21", name="Croque Monsieur", description="Gruyere, ham, bechamel, brioche", price=18)]),
    Spot(id="spot-8", name="Lilia", cuisine="Italian", price_level=3, latitude=40.7175, longitude=-73.9574, address="567 Union Ave, Brooklyn, NY 11211", walking_time_minutes=5, distance_miles=0.3, vibes=["Aesthetic", "Date Spot", "Power Lunch"], description="Missy Robbins\' celebrated pasta haven in a converted auto body shop.", editorial_quote="The mafaldini with pink peppercorn and Parm is a religious experience.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=800","https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800","https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800"], top_dishes=[Dish(id="d22", name="Mafaldini", description="Pink peppercorn, Parm, fennel", price=28), Dish(id="d23", name="Sheep\'s Milk Agnolotti", description="Saffron, honey, black pepper", price=26), Dish(id="d24", name="Clam Pizza", description="Oregano, chili, garlic", price=22)]),
    Spot(id="spot-9", name="Devocion", cuisine="Coffee", price_level=2, latitude=40.7468, longitude=-73.9860, address="25 E 20th St, New York, NY 10003", walking_time_minutes=8, distance_miles=0.4, vibes=["Aesthetic", "Quiet", "Work Friendly", "Coffee"], description="Colombian specialty coffee in a stunning greenhouse-style space.", editorial_quote="The best cortado in Manhattan, full stop.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800","https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800","https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800"], top_dishes=[Dish(id="d25", name="Cortado", description="Double shot, steamed milk, 4oz", price=5), Dish(id="d26", name="Cold Brew", description="Single origin Colombian, 16oz", price=6), Dish(id="d27", name="Avocado Toast", description="Everything seasoning, lemon, microgreens", price=14)]),
    Spot(id="spot-10", name="Sugarfish", cuisine="Japanese", price_level=3, latitude=40.7410, longitude=-73.9920, address="33 E 20th St, New York, NY 10003", walking_time_minutes=12, distance_miles=0.6, vibes=["Quick Bites", "Aesthetic", "Date Spot"], description="Nozawa Bar-quality omakase at a fraction of the price.", editorial_quote="Get the Trust Me and actually trust them. Best sushi lunch deal in the city.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800","https://images.unsplash.com/photo-1553621042-f6e147245754?w=800","https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=800"], top_dishes=[Dish(id="d28", name="Trust Me Lunch", description="Chef\'s selection nigiri, sashimi, hand roll", price=32), Dish(id="d29", name="Trust Me Nozawa", description="Extended omakase, premium cuts", price=55), Dish(id="d30", name="Edamame", description="Sea salt, togarashi", price=6)]),
    Spot(id="spot-11", name="L\'Industrie Pizzeria", cuisine="Pizza", price_level=1, latitude=40.7119, longitude=-73.9577, address="254 S 2nd St, Brooklyn, NY 11211", walking_time_minutes=20, distance_miles=1.1, vibes=["Cheap Eats", "Quick Bites", "Outdoor Seating"], description="The best slice in Brooklyn. Perfectly charred crust and quality toppings.", editorial_quote="The burrata slice will ruin all other pizza for you.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://lh3.googleusercontent.com/aida-public/AB6AXuCV4ykKFKd7k88lE89KWlhnZu33E9TXZoBRRo7CRLMsGBJEaE1LI7zGm8pFQkxEKXN7zY_bTZ--5fjnLfBzYJXahLcfjN0u95EKxZP9gwF476nn_oNMxK6MRBci0yku8bArelByAGo2l1LGXhk-3iEgTT_8puT4cCag4JjYURKzUAdZ0H_x-rVC6Q0HsRADfbsr51eatjT7zTknEd-qIk_PP_Rp5yBfwho9UXEKrKKMzpbiiC6fTTmY__FZPdd1bxpfv14WYlib","https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800","https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800"], top_dishes=[Dish(id="d31", name="Burrata Slice", description="Fresh burrata, arugula, cherry tomato", price=7), Dish(id="d32", name="Margherita Slice", description="Fresh mozz, basil, San Marzano", price=5), Dish(id="d33", name="Funghi Slice", description="Mixed mushrooms, truffle oil, fontina", price=7)]),
    Spot(id="spot-12", name="Tacombi", cuisine="Mexican", price_level=2, latitude=40.7450, longitude=-73.9880, address="30 W 24th St, New York, NY 10010", walking_time_minutes=5, distance_miles=0.2, vibes=["Quick Bites", "Good for Groups", "Outdoor Seating"], description="Bright, fun, and festive. Yucatan beach vibes in Flatiron with handmade tortillas.", editorial_quote="Order one of everything and share. The fish tacos and elote are mandatory.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800","https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800","https://images.unsplash.com/photo-1564767610261-3cea33f1c0ac?w=800"], top_dishes=[Dish(id="d34", name="Fish Tacos", description="Beer-battered mahi, chipotle crema", price=14), Dish(id="d35", name="Elote", description="Grilled corn, cotija, chili, lime", price=8), Dish(id="d36", name="Chicken Burrito Bowl", description="Rice, beans, guac, pico", price=15)]),
    Spot(id="spot-13", name="Daily Provisions", cuisine="American", price_level=2, latitude=40.7383, longitude=-73.9890, address="103 E 19th St, New York, NY 10003", walking_time_minutes=6, distance_miles=0.3, vibes=["Quick Bites", "Healthy", "Coffee"], description="Danny Meyer\'s casual all-day cafe. The cruller is iconic.", editorial_quote="The maple cruller is the best pastry in the neighborhood.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800","https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800","https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=800"], top_dishes=[Dish(id="d37", name="Maple Cruller", description="Glazed, flaky, perfection", price=5), Dish(id="d38", name="Turkey Club", description="Roasted turkey, bacon, avocado, sourdough", price=16), Dish(id="d39", name="Grain Bowl", description="Farro, roasted veg, tahini, soft egg", price=17)]),
    Spot(id="spot-14", name="Eataly Flatiron", cuisine="Italian", price_level=3, latitude=40.7422, longitude=-73.9897, address="200 5th Ave, New York, NY 10010", walking_time_minutes=7, distance_miles=0.3, vibes=["Good for Groups", "Outdoor Seating", "Power Lunch"], description="An Italian food hall experience with multiple restaurants under one roof.", editorial_quote="Take a client to the rooftop restaurant. Order a Negroni and the crudo.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800","https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800","https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=800"], top_dishes=[Dish(id="d40", name="Margherita Pizza", description="Wood-fired, fresh mozz, basil", price=18), Dish(id="d41", name="Crudo Misto", description="Chef\'s selection raw fish, citrus", price=22), Dish(id="d42", name="Tiramisu", description="Classic, mascarpone, espresso-soaked ladyfingers", price=14)]),
    Spot(id="spot-15", name="Blank Street Coffee", cuisine="Coffee", price_level=1, latitude=40.7445, longitude=-73.9870, address="28 E 23rd St, New York, NY 10010", walking_time_minutes=3, distance_miles=0.1, vibes=["Quick Bites", "Cheap Eats", "Coffee"], description="The NYC micro-coffee chain that\'s actually good.", editorial_quote="Best $4 latte in Manhattan. In, caffeinated, out in 2 minutes.", editor_name="The Local Explorer Editor", editor_avatar_url=EDITOR_AVATAR, photo_urls=["https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800","https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800","https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800"], top_dishes=[Dish(id="d43", name="Oat Milk Latte", description="Double shot, oat milk, hot or iced", price=4), Dish(id="d44", name="Matcha Latte", description="Ceremonial grade, oat milk", price=5), Dish(id="d45", name="Cold Brew", description="Slow-steeped, smooth, strong", price=4)]),
]

SPOTS_BY_ID = {s.id: s for s in SPOTS}

POLLS: dict[str, dict] = {}
COLLECTIONS: dict[str, list[str]] = {
    "favorites": ["spot-6", "spot-7", "spot-11"],
    "want_to_go": ["spot-3", "spot-8", "spot-10"],
    "client_lunch": ["spot-3", "spot-6", "spot-14"],
}

DROPS: list[Drop] = [
    Drop(id="drop-hero", title="5 Spots in Nomad to Impress Your Boss", subtitle="Curated for the perfect balance of aesthetic ambiance and incredible food.", category="Today\'s Drop", image_url="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200", spot_ids=["spot-1", "spot-3", "spot-6", "spot-14", "spot-8"]),
    Drop(id="drop-1", title="Best Grab & Go Salads Under $15", subtitle="Healthy lunches that won\'t break the bank.", category="Quick Bites", image_url="https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200", spot_ids=["spot-2", "spot-13"]),
    Drop(id="drop-2", title="Where to Talk Strategy Over Coffee", subtitle="Quiet cafes perfect for sensitive conversations.", category="Client Meetings", image_url="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200", spot_ids=["spot-7", "spot-9", "spot-15"]),
]


def haversine_miles(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 3959
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def walking_time(miles: float) -> int:
    return max(1, round(miles / 0.05))


def enrich_spot_with_distance(spot: Spot, lat: float, lng: float) -> Spot:
    dist = haversine_miles(lat, lng, spot.latitude, spot.longitude)
    wt = walking_time(dist)
    return spot.model_copy(update={"distance_miles": round(dist, 1), "walking_time_minutes": wt})


@app.get("/healthz")
async def healthz():
    return {"status": "ok"}


@app.get("/api/v1/drops/today", response_model=DailyDropResponse)
async def get_today_drops(lat: float = 40.7484, lng: float = -73.9857):
    nearby = [enrich_spot_with_distance(s, lat, lng) for s in SPOTS]
    nearby.sort(key=lambda s: s.distance_miles)
    return DailyDropResponse(hero=DROPS[0], drops=DROPS[1:], nearby_spots=nearby[:6])


@app.get("/api/v1/spots/nearby", response_model=list[Spot])
async def get_nearby_spots(lat: float = 40.7484, lng: float = -73.9857, radius: float = 1.0):
    results = []
    for spot in SPOTS:
        enriched = enrich_spot_with_distance(spot, lat, lng)
        if enriched.distance_miles <= radius:
            results.append(enriched)
    results.sort(key=lambda s: s.distance_miles)
    return results


@app.get("/api/v1/spots/search", response_model=list[Spot])
async def search_spots(
    q: Optional[str] = None,
    cuisine: Optional[str] = None,
    price: Optional[int] = None,
    vibe: Optional[str] = None,
    lat: float = 40.7484,
    lng: float = -73.9857,
):
    results = SPOTS[:]
    if q:
        results = [s for s in results if q.lower() in s.name.lower() or q.lower() in s.cuisine.lower()]
    if cuisine:
        results = [s for s in results if cuisine.lower() in s.cuisine.lower()]
    if price:
        results = [s for s in results if s.price_level <= price]
    if vibe:
        results = [s for s in results if any(vibe.lower() in v.lower() for v in s.vibes)]
    return [enrich_spot_with_distance(s, lat, lng) for s in results]


@app.get("/api/v1/spots/{spot_id}", response_model=Spot)
async def get_spot(spot_id: str, lat: float = 40.7484, lng: float = -73.9857):
    spot = SPOTS_BY_ID.get(spot_id)
    if not spot:
        raise HTTPException(status_code=404, detail="Spot not found")
    return enrich_spot_with_distance(spot, lat, lng)


@app.post("/api/v1/polls", response_model=Poll)
async def create_poll(req: CreatePollRequest):
    poll_id = str(uuid.uuid4())[:8]
    now = datetime.now(timezone.utc)
    options = []
    for sid in req.spot_ids:
        spot = SPOTS_BY_ID.get(sid)
        if not spot:
            raise HTTPException(status_code=404, detail=f"Spot {sid} not found")
        options.append(
            {
                "id": f"opt-{uuid.uuid4().hex[:6]}",
                "spot_id": sid,
                "spot_name": spot.name,
                "spot_image_url": spot.photo_urls[0] if spot.photo_urls else "",
                "walking_time_minutes": spot.walking_time_minutes,
                "vote_count": 0,
                "vote_percentage": 0.0,
            }
        )
    poll_data = {
        "id": poll_id,
        "title": req.title,
        "options": options,
        "total_votes": 0,
        "closes_at": (now + timedelta(minutes=req.duration_minutes)).isoformat(),
        "created_at": now.isoformat(),
        "voters": [],
    }
    POLLS[poll_id] = poll_data
    return Poll(**poll_data)


@app.get("/api/v1/polls", response_model=list[Poll])
async def list_polls():
    now = datetime.now(timezone.utc)
    active = []
    for p in POLLS.values():
        closes = datetime.fromisoformat(p["closes_at"])
        if closes.tzinfo is None:
            closes = closes.replace(tzinfo=timezone.utc)
        if closes > now:
            active.append(Poll(**p))
    return active


@app.get("/api/v1/polls/{poll_id}", response_model=Poll)
async def get_poll(poll_id: str):
    poll_data = POLLS.get(poll_id)
    if not poll_data:
        raise HTTPException(status_code=404, detail="Poll not found")
    return Poll(**poll_data)


@app.post("/api/v1/polls/{poll_id}/vote", response_model=Poll)
async def vote_poll(poll_id: str, req: VoteRequest):
    poll_data = POLLS.get(poll_id)
    if not poll_data:
        raise HTTPException(status_code=404, detail="Poll not found")
    found = False
    for opt in poll_data["options"]:
        if opt["id"] == req.option_id:
            opt["vote_count"] += 1
            found = True
            break
    if not found:
        raise HTTPException(status_code=404, detail="Option not found")
    total = sum(o["vote_count"] for o in poll_data["options"])
    poll_data["total_votes"] = total
    for opt in poll_data["options"]:
        opt["vote_percentage"] = round((opt["vote_count"] / total * 100) if total > 0 else 0, 1)
    voter_idx = len(poll_data["voters"]) % len(VOTER_AVATARS)
    poll_data["voters"].append(
        {
            "id": f"voter-{uuid.uuid4().hex[:6]}",
            "name": req.voter_name,
            "avatar_url": VOTER_AVATARS[voter_idx],
        }
    )
    return Poll(**poll_data)


@app.get("/api/v1/collections", response_model=list[SpotCollection])
async def get_collections():
    result = []
    for name, spot_ids in COLLECTIONS.items():
        spots = [SPOTS_BY_ID[sid] for sid in spot_ids if sid in SPOTS_BY_ID]
        result.append(SpotCollection(id=f"col-{name}", name=name, spots=spots))
    return result


@app.post("/api/v1/collections/{collection_name}/spots")
async def save_to_collection(collection_name: str, req: SaveSpotRequest):
    if req.spot_id not in SPOTS_BY_ID:
        raise HTTPException(status_code=404, detail="Spot not found")
    if collection_name not in COLLECTIONS:
        COLLECTIONS[collection_name] = []
    if req.spot_id not in COLLECTIONS[collection_name]:
        COLLECTIONS[collection_name].append(req.spot_id)
    return {"status": "saved"}


@app.delete("/api/v1/collections/{collection_name}/spots/{spot_id}")
async def remove_from_collection(collection_name: str, spot_id: str):
    if collection_name not in COLLECTIONS:
        raise HTTPException(status_code=404, detail="Collection not found")
    if spot_id in COLLECTIONS[collection_name]:
        COLLECTIONS[collection_name].remove(spot_id)
    return {"status": "removed"}


@app.get("/polls/{poll_id}", response_class=HTMLResponse)
async def poll_web_view(poll_id: str):
    poll_data = POLLS.get(poll_id)
    if not poll_data:
        return HTMLResponse(
            content=(
                "<html><body style='font-family:system-ui;display:flex;align-items:center;"
                "justify-content:center;height:100vh;background:#F4F1EA'>"
                "<div style='text-align:center'><h1 style='color:#2C2A26'>Poll not found</h1>"
                "<p style='color:#8A857D'>This poll may have expired.</p></div></body></html>"
            ),
            status_code=404,
        )
    poll = Poll(**poll_data)
    options_html = ""
    for opt in poll.options:
        is_winning = opt.vote_count == max(o.vote_count for o in poll.options) and opt.vote_count > 0
        border = "2px solid #556B2F" if is_winning else "1px solid #eee"
        bar_color = "#556B2F" if is_winning else "#8A857D"
        options_html += (
            f'<div style="background:white;border-radius:12px;padding:16px;'
            f'margin-bottom:12px;border:{border};display:flex;align-items:center;gap:16px">'
            f'<img src="{opt.spot_image_url}" style="width:64px;height:64px;'
            f'border-radius:8px;object-fit:cover"/>'
            f'<div style="flex:1"><div style="font-family:Georgia,serif;font-size:18px;'
            f'font-weight:bold;color:#2C2A26">{opt.spot_name}</div>'
            f'<div style="font-size:13px;color:#8A857D;margin-top:4px">'
            f'{int(opt.vote_percentage)}% &middot; {opt.walking_time_minutes} min walk</div>'
            f'<div style="background:#EAE6DD;border-radius:3px;height:6px;margin-top:8px;'
            f'overflow:hidden"><div style="background:{bar_color};height:100%;'
            f'width:{opt.vote_percentage}%;border-radius:3px"></div></div></div></div>'
        )
    html_content = (
        f'<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/>'
        f'<meta name="viewport" content="width=device-width,initial-scale=1.0"/>'
        f'<title>The Local Explorer - {poll.title}</title>'
        f'<style>*{{margin:0;padding:0;box-sizing:border-box}}'
        f'body{{font-family:-apple-system,system-ui,sans-serif;background:#F4F1EA;'
        f'min-height:100vh;padding:20px}}</style></head>'
        f'<body><div style="max-width:480px;margin:0 auto;padding-top:40px">'
        f'<h1 style="font-family:Georgia,serif;font-size:32px;text-align:center;'
        f'color:#2C2A26;margin-bottom:8px">{poll.title}</h1>'
        f'<p style="text-align:center;font-size:13px;font-weight:bold;'
        f'letter-spacing:2px;color:#8A857D;margin-bottom:32px">'
        f'{poll.total_votes} VOTED</p>{options_html}'
        f'<p style="text-align:center;margin-top:24px;font-size:14px;color:#8A857D">'
        f'Open in The Local Explorer app to vote</p></div></body></html>'
    )
    return HTMLResponse(content=html_content)
