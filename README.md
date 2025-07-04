# student_community_app


## Overview

student_community_app is a Flutter-based mobile application designed to foster a vibrant and interactive community for students. It provides features for communication, doubt clearing, and content sharing, aiming to enhance the learning and social experience within the community.

## Features

-   **User Authentication**: Secure login and registration processes.
-   **Chat Functionality**: Real-time messaging capabilities with support for various file formats (audio, video, documents, images).
-   **Doubt Clearing**: A dedicated section for students to post questions, receive answers, and engage in discussions.
-   **Profile Management**: Users can set and update their profile pictures.
-   **Firebase Integration**: Utilizes Firebase Firestore for data storage and management.
-   **Modular Design**: Organized into distinct modules for better maintainability and scalability.

## Project Structure

The project follows a standard Flutter application structure, with key modules organized under the `lib` directory:

-   `lib/chatpage`: Contains UI and logic for chat functionalities, including handling different media types.
-   `lib/doubt_clearing`: Manages the doubt clearing section, allowing users to add questions and view comments.
-   `lib/firestone_storage`: Handles interactions with Firebase Firestore for data persistence.
-   `lib/image_picker`: Functionality for setting user profile pictures.
-   `lib/sections`: Likely contains different content sections or categories within the app.
-   `lib/slidebar`: Implements the application's navigation sidebar.
-   `lib/main.dart`: The entry point of the Flutter application.
-   `lib/login.dart`, `lib/register.dart`, `lib/forget_pass/forget_password.dart`: User authentication flows.
-   `lib/homepage.dart`: The main dashboard or home screen of the application.

## Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
-   [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter and Dart plugins.
-   [Firebase Project](https://firebase.google.com/docs/flutter/setup) configured with Firestore.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/psprogrammer-07/student_community_app
    cd student_community_app

    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**:
    -   Follow the official Firebase documentation to connect your Flutter project to your Firebase project.
    -   Ensure `google-services.json` (for Android) is placed in `android/app/`.

4.  **Run the application**:
    ```bash
    flutter run
    ```



## License

This project is licensed under the MIT License - see the `LICENSE` file for details. (Note: A `LICENSE` file is not currently present in the provided directory structure. Please create one if you wish to specify a license.)

