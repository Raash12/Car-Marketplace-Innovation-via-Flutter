# carmarketplace



## Description

This Flutter project provides a fully functional page to add new car listings into a Firebase Firestore database. It supports uploading a car image from the device gallery and hosting it on ImgBB, a free image hosting service, then saving the car data along with the hosted image URL into Firestore.

The app collects detailed car information such as the car name, buying price, rent price, description, quantity, mileage (selected from a dropdown), and fuel type (also selected from a dropdown). Each field is validated to ensure data integrity before submission.

This project demonstrates practical use of Flutter forms, validation, image picking, asynchronous HTTP requests, and Firestore CRUD operations, making it an excellent example for developers building Flutter apps with cloud data and media upload.

---

## Features

- **User-friendly form** with validation for all input fields
- **Dropdown menus** for mileage and fuel type, ensuring consistent data entry
- **Image selection** from device gallery via `image_picker`
- **Image upload** to ImgBB with automatic base64 encoding and HTTP POST
- **Firestore integration** to store car data with timestamps
- Clear success and error feedback using Snackbars
- Responsive UI with Material Design components

---



## Getting Started

### Prerequisites

- Flutter SDK (version 2.0.0 or above recommended)
- Firebase project with Firestore enabled
- ImgBB account with API key for image hosting

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
Install dependencies:

bash
Copy
Edit
flutter pub get
Configure Firebase:

Follow FlutterFire setup instructions to connect your Flutter app with Firebase.

Add google-services.json (Android) and GoogleService-Info.plist (iOS) files to your project.

Get ImgBB API Key:

Sign up for free at ImgBB

Obtain your API key from your ImgBB dashboard.

Update the API Key:
Open add_car_page.dart and replace the placeholder with your ImgBB API key:

dart
Copy
Edit
final String imgbbApiKey = 'YOUR_IMGBB_API_KEY_HERE';
Run the app:

bash
Copy
Edit
flutter run
