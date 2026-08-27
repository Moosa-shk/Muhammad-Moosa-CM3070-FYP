RescueAid - Disaster Assistance Mobile Application

Muhammad Moosa Sheikh
CM3070 Final Year Project (FYP) – 10.1

About the Project

RescueAid is a mobile application developed as a Final Year Project (FYP) using Flutter. The application is designed to assist users during emergencies and disasters by providing disaster alerts, emergency communication resources, nearby emergency services, safety information, and other disaster-management features.

The project aims to use mobile technology to improve disaster awareness, emergency response, and user safety during critical situations.

Main Features

SOS Emergency System

* Send SOS via SMS
* Send SOS via WhatsApp
* Direct SMS support on Android
* Call emergency contacts
* Automatically share the user’s current location

Disaster Alerts

* View recent disaster alerts
* Receive earthquake and weather-related warnings
* Access relevant disaster information

Disaster Map

* View disaster-related locations on the map
* Identify emergency services within the surrounding area
* Access location-based emergency information

AI Disaster Assistant

* Chatbot providing disaster-related guidance and assistance

Disaster Safety Quiz

* Disaster education quizzes
* Improve disaster preparedness and awareness
* Learn important safety procedures

Nearby Emergency Services

Users can locate nearby:

* Hospitals
* Police stations
* Shelters

Technologies Used

* Flutter (Dart)
* GetX State Management
* Google Maps
* Location Services
* Open-Meteo Weather API
* USGS Earthquake API

Project Structure

lib/
|
+-- config/
+-- models/
+-- services/
+-- screens/
+-- widgets/
+-- main.dart

Services

The application uses different services to handle its core functionality, including:

* Location services
* Disaster alert services
* Weather services
* Earthquake information services
* SOS and emergency communication services
* Map and nearby emergency service functionality

How to Run the App

Clone the Repository

git clone

Open the Project

cd RescueAid

Install Dependencies

flutter pub get

Run the Application

flutter run

Running on Emulator

1. Open Android Studio or Xcode.
2. Start an emulator or simulator.
3. Run:

flutter run

Running on Physical Device

1. Enable USB Debugging on the device.
2. Connect the phone to the computer.
3. Run:

flutter run

Permissions Required

The application requires the following permissions:

* Location
* SMS
* Phone calls
* Internet

These permissions are required for SOS messaging, emergency calling, location sharing, disaster alerts, and location-based services.

Project Type

CM3070 Final Year Project (FYP) – 10.1

Flutter Mobile Application