import subprocess
import json

result = subprocess.run(
    ['python', 'getinfo.py', 'https://tasty.co/recipe/blueberry-cream-muffins'],
    capture_output=True,  # Capture the output
    text=True 
)


if result.returncode == 0:
    try:
        extracted_info = json.loads(result.stdout)

        # Create variables from the JSON data
        link = extracted_info.get("link")
        title = extracted_info.get("title")
        short_description = extracted_info.get("short_description")
        tags = extracted_info.get("tags")
        video = extracted_info.get("video")
        next_link = extracted_info.get("next_link")
        rand_link = extracted_info.get("rand_link")

        # Now you can use these variables
        print("Link:", link)
        print("Title:", title)
        print("Short Description:", short_description)
        print("Tags:", tags)
        print("Video:", video)
        print("Next Link:", next_link)
        print("Rand Link:", rand_link )

    except json.JSONDecodeError:
        print("Failed to parse JSON response")
else:
    print("Failed to run getinfo.py")
    print(result.stderr)  



