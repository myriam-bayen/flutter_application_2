import sys

# Suppress FutureWarnings

source = sys.argv[1]
#print(source)

import requests
from bs4 import BeautifulSoup
import json
import re

def fetch_page_source(url):
    response = requests.get(url)
    #sends https request
    if response.status_code == 200:
        #200 = success :)
        #404 = not found
        #500 = internal error 
        return response.text  # Return the raw "view source code stuff"
    return None

def extract_information(html):
    soup = BeautifulSoup(html, 'html.parser')
    #this just makes like a really long string with everything and let you sort for different tags and stuff easily

    content_link = soup.find('meta', property='og:url')
    link = content_link['content'] if content_link else None

    title_meta = soup.find('meta', property='og:title')
    description_meta = soup.find('meta', property='og:description')

    title = title_meta['content'] if title_meta else None
    short_description = description_meta['content'] if description_meta else None


    tags = []
    video_link = None
    script_tags = soup.find_all('script')
    
    for script in script_tags:
        if 'window.BFADS =' in script.text:
            match = re.search(r'"cms_tags":\s*\[(.*?)\]', script.text)
            if match:
                tag_string = match.group(1)
                tags = [tag.strip().strip('"') for tag in tag_string.split(',')]
        
        if 'video_id' in script.text:
            video_match = re.search(r'"url":\s*"([^"]+)"', script.text)
            if video_match:
                video_id = video_match.group(1)
                video_link = video_id
                break  # Exit after finding the first match
    

    important_tags = [
        # Ingredients
        'Chicken', 'Beef', 'Pork', 'Lamb', 'Turkey', 'Fish', 'Shrimp', 'Salmon', 'Tuna', 
        'Tofu', 'Lentils', 'Beans', 'Chickpeas', 'Tomatoes', 'Potatoes', 'Mushrooms', 
        'Garlic', 'Onion', 'Carrots', 'Bell Peppers', 'Spinach', 'Kale', 'Broccoli', 
        'Cauliflower', 'Pumpkin', 'Zucchini', 'Sweet Potatoes', 'Cheese', 'Eggs', 'Butter',
        
        # Dish Types
        'Soup', 'soups', 'Stew', 'Salad', 'Pasta', 'Sandwich', 'Burger', 'Pizza', 'Casserole', 
        'Stir-fry', 'Curry', 'Roast', 'Grilled', 'Baked', 'Fried', 'Braised', 'Sautéed', 
        'Slow-cooked', 'Barbecue', 'Sushi', 'Tacos', 'Wraps', 'Quiche', 'Pie', 'Pastry', 
        'Bread', 'Pancakes', 'Waffles', 'Muffins', 'Cake', 'Cookies', 'Vegetables'
        
        # Cuisines
        'Italian', 'Mexican', 'Chinese', 'Indian', 'French', 'Japanese', 'Thai', 'Greek', 
        'Mediterranean', 'Middle Eastern', 'Korean', 'American', 'Southern (U.S.)', 
        'Vietnamese', 
        
        # Cooking Methods
        'Oven-baked', 'Pan-fried', 'Deep-fried', 'Grilled', 'Smoked', 'Sous-vide', 
        'Air-fried', 'Roasted', 'Pressure-cooked', 'Boiled', 'Poached', 'Steamed', 'Quick'
        
        # Dietary Preferences
        'Vegetarian', 'Vegan', 'Gluten-free', 'Dairy-free', 'Low-carb', 'Keto', 'Paleo', 
        'Whole30', 'Pescatarian',
        
        # Themes & Occasions
        'Halloween', 'Christmas', 'Thanksgiving', 'Easter', 'Summer', 'Winter', 
        'Comfort Food', 'Game Day', 'Potluck', 'Kid-friendly', 'Fall', 'Spring', 'Winter', 'Snack', 'Breakfast', 'Lunch', 'dinner', 'Snack', 'Jewish', 'comfort_food',
        
        # Other Relevant Tags
        'Spicy', 'Sweet', 'Savory', 'Tangy', 'Crunchy', 'Warm', 'Cozy', 'Cold', 'Refreshing', 'Drink'
        ]


    selected_tags = list(set(item.lower() for item in important_tags).intersection(item.lower() for item in tags))
    #print(selected_tags)

    formatted_selected_tags = ""
    for i in range(len(selected_tags)):
        if i == len(selected_tags)-1:
            formatted_selected_tags = formatted_selected_tags + selected_tags[i]
        else:
            formatted_selected_tags = formatted_selected_tags + selected_tags[i] + "+"
    
    #print(formatted_selected_tags)


    search_results = fetch_page_source("https://tasty.co/search?q=" + formatted_selected_tags +  "&sort=popular")
    soup2 = BeautifulSoup(search_results, 'html.parser')

    element = soup2.select_one("#search-results-feed > div:nth-child(2) > section > ul > li:nth-child(1) > a")

    # Print the text content of the found element
    if element:
        href_value = element['href']
        next_link = "https://tasty.co" + href_value
        #print("HERE" + next_link)
    #else:
        #print("Element not found")


    # to do 1) check video before returning, 2) implement non rabbit hole 


    import random
    option1 = random.randint(1, len(important_tags))
    option2 = random.randint(1, len(important_tags))
    option3 = random.randint(1, len(important_tags))
    rand_search_results = fetch_page_source("https://tasty.co/search?q=" + important_tags[option1] + "+"  + important_tags[option2] + "+" + important_tags[option3] +  "&sort=popular")
    soup3 = BeautifulSoup(rand_search_results, 'html.parser')

    element2 = soup3.select_one("#search-results-feed > div:nth-child(2) > section > ul > li:nth-child(1) > a")

    # Print the text content of the found element
    href_value2 = element2['href']
    rand_link = "https://tasty.co" + href_value2
        #print("HERE" + next_link)
    #else:
        #print("Element not found")

    return {
        "link": link,
        "title": title,
        "short_description": short_description,
        "tags": tags,
        "video": video_link,
        "next_link": next_link,
        "rand_link": rand_link,
    }

    


""" 
if __name__ == "__main__":
    target_url = "https://tasty.co/recipe/beauty-and-the-beast-inspired-french-bread-pizza"
    page_source = fetch_page_source(target_url)
    
    if page_source:
        extracted_info = extract_information(page_source)
        
        print("Extracted Information:")
        print(f"Link: {extracted_info['link']}")
        print(f"Title: {extracted_info['title']}")
        print(f"Short Description: {extracted_info['short_description']}")
        print(f"Tags: {extracted_info['tags']}")
        print(f"Video: {extracted_info['video']}")
    else:
        print("Failed to fetch the page")

    target_url = "https://tasty.co/recipe/the-little-mermaid-inspired-under-the-sea-pizza"
    page_source = fetch_page_source(target_url)
    
    if page_source:
        extracted_info = extract_information(page_source)
        
        print("Extracted Information:")
        print(f"Link: {extracted_info['link']}")
        print(f"Title: {extracted_info['title']}")
        print(f"Short Description: {extracted_info['short_description']}")
        print(f"Tags: {extracted_info['tags']}")
        print(f"Video: {extracted_info['video']}")
    else:
        print("Failed to fetch the page")
"""

page_source = fetch_page_source(source)

if page_source:
    extracted_info = extract_information(page_source)
    print(json.dumps(extracted_info))  # Always print as valid JSONNNNN
else:
    print(json.dumps({"error": "Failed to fetch the page"}))

