# Modules Folder Structure:
    ├── code
    │   └── lambda.py
    ├── dependencies
    │   └── (Python dependencies)
    ├── main.tf
    └── requirements.txt

## Configure Terraform on Windows Linux Sub-System
- Upgrade WSL: ```sudo apt-get upgrade ```
- Install unzip package: ```sudo apt-get install unzip```
- Fetch terraform package and create zip: ```wget <terraform_url> -O terraform.zip```
- Perform unpacking: 
  ```
  unzip terraform.zip
  sudo mv terraform /usr/local/bin
  rm terraform.zip
  ```
- Verify installation: ```terraform -v```