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



    return {
        "link": link,
        "title": title,
        "short_description": short_description,
        "tags": tags,
        "video": video_link,
    }

# Example usage
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

    target_url = "https://tasty.co/recipe/spooky-beef-stew"
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
