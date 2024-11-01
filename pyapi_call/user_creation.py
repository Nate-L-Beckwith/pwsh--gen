import json
import logging
import requests
import certifi

logging.basicConfig(
    filename='/home/$USER/jira_user_creation.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

certifi.where()
"~/CACert"

jira_url = ""
jira_email = ""
jira_pat = ""



# Headers for API requests
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": f'Bearer {jira_pat}'  # Bearer token for PAT
}

def load_and_format_json(file_path):
    try:
        with open(file_path, 'r') as file:
            json_data = file.read()

        # Convert CRLF to LF
        json_data = json_data.replace('\r\n', '\n')

        # Load JSON data
        users = json.loads(json_data)
        logging.info("JSON data loaded and formatted successfully.")
        return users

    except json.JSONDecodeError as e:
        logging.error(f"Failed to parse JSON file: {e}")
        return None
    except Exception as e:
        logging.error(f"An error occurred while loading JSON: {e}")
        return None

def create_jira_user(user):
    try:
        payload = {
            "name": user.get("username"),
            "emailAddress": user.get("email"),
            "displayName": user.get("displayName"),
#           "notification": user.get("notification", False)
        }

        response = requests.post(
            jira_url,
            headers=headers,
            json=payload,
            verify=certifi.where()  # Verifies SSL certificates
        )

        if response.status_code == 201:
            logging.info(f"User {user.get('username')} created successfully.")
        else:
            logging.error(f"Failed to create user {user.get('username')}. Response: {response.text}")

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed for user {user.get('username')}: {e}")

def main():
    # Path to the JSON file
    json_file_path = '$HOME/lab/jira-utils/jira_users/OUusers.json'

    # Load and format the JSON data
    users = load_and_format_json(json_file_path)

    if users is None:
        logging.error("No users were loaded. Exiting.")
        return

    # Create users in Jira
    for user in users:
        create_jira_user(user)

if __name__ == "__main__":
    main()

# headers = {
#     "Accept": "application/json",
#     "Content-Type": "application/json",
#     "Authorization": 'Bearer {}'.format(jira_api_token)
# }

# def load_and_format_json(file_path):
#     try:
#         with open(file_path, 'r') as file:
#             json_data = file.read()

#         json_data = json_data.replace('\r\n', '\n')


#         users = json.loads(json_data)
#         logging.info("JSON data loaded and formatted successfully.")
#         return users

#     except json.JSONDecodeError as e:
#         logging.error(f"Failed to parse JSON file: {e}")
#         return None
#     except Exception as e:
#         logging.error(f"An error occurred while loading JSON: {e}")
#         return None

# def create_jira_user(user):
#     try:
#         payload = {
#             "name": user.get("username"),
#             "emailAddress": user.get("email"),
#             "displayName": user.get("displayName"),
#             # "notification": user.get("notification", False)
#         }

#         response = requests.post(
#             jira_url,
#             headers=headers,
#             auth=None,
#             json=payload
#         )

#         if response.status_code == 201:
#             logging.info(f"User {user.get('username')} created successfully.")
#         else:
#             logging.error(f"Failed to create user {user.get('username')}. Response: {response.text}")

#     except requests.exceptions.RequestException as e:
#         logging.error(f"Request failed for user {user.get('username')}: {e}")

# def main():

#     json_file_path = '$HOME/lab/jira-utils/jira_users/OUusers.json'


#     users = load_and_format_json(json_file_path)

#     if users is None:
#         logging.error("No users were loaded. Exiting.")
#         return


#     for user in users:
#         create_jira_user(user)

# if __name__ == "__main__":
#     main()
