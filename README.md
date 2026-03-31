# 🫀 Organ Transplantation Management System

A smart, efficient, and fully-featured system designed to streamline the organ transplantation process. This project provides a comprehensive dashboard and robust CRUD management to handle hospitals, donors, recipients, and transplants, as well as an intelligent Organ Matching Engine to find available donors for recipients.

---

## 🚀 Overview

Organ transplantation is a critical and time-sensitive medical process. This project aims to improve efficiency, transparency, and decision-making in organ allocation and management. 

The system helps medical professionals and administrators in:
- Seamlessly matching available donors with urgent recipients
- Managing critical medical data (Blood Groups, Organ Types, Urgency Levels)
- Automating workflow with intuitive dashboards and status tracking
- Streamlining administrative tasks across multiple hospitals

---

## 🧠 Key Features

- 📊 **Main Dashboard**: View real-time statistics including available donors, critical recipients, and recent transplants.
- 🩸 **Donors Management**: Add, modify, delete, and search organ donors. Track donation dates, organ types, and donor status.
- 🏥 **Recipients Management**: Keep track of patients requiring organs. Prioritize them using a 1-5 Urgency Level scale.
- 🏢 **Hospitals Directory**: Manage participating hospitals and transplant centers.
- 🔄 **Transplants Record**: View, record, and delete successful or historical transplant surgeries.
- 🔍 **Smart Organ Matching**: Specifically match available donors with critical recipients using automated database procedures and advanced algorithms.

---

## 🛠️ Tech Stack

- **Backend:** Python + Flask
- **Database:** MySQL
- **Frontend:** HTML5, CSS3, JavaScript (with Jinja2 templating)
- **Data Engineering:** MySQL Procedures/Algorithms (`Match_Organ` protocol)

---

## 📂 Project Structure

```text
.
├── app.py                            # Main Flask application and server routes
├── db_init.py                        # Python script to automatically initialize the database
├── organ_transplant_db-org (1).sql   # Initial SQL dump schema and sample data
├── requirements.txt                  # Python dependencies
├── static/                           # Static assets (CSS, JS, Fonts, Images)
└── templates/                        # Jinja2 HTML templates
```

---

## ⚙️ How to Setup and Run

### 1. Prerequisites
- Python 3.8+ installed
- MySQL Server running locally (Default port 3306, user `root`, no password by default)
- `pip` package manager

### 2. Install Dependencies
Open your terminal and run:
```bash
pip install -r requirements.txt
```

### 3. Initialize the Database
Before running the application, set up the MySQL database schemas and initial data by running:
```bash
python db_init.py
```
*(This will automatically create `organ_transplant_db` and populate it with tables and procedures).*

### 4. Run the Application
Start the Flask server:
```bash
python app.py
```

### 5. Access the Platform
Open your web browser and navigate to:
```text
http://127.0.0.1:5000
```

---
*Built to bring transparency, efficiency, and speed to the critical domain of Organ Transplantation.*
