# LegalLink App

A Flutter-based marketplace application designed to connect clients with legal professionals. This app provides a seamless platform for users to find lawyers based on their specialty, manage cases, and communicate effectively.

## 🚀 Features

-   **User Authentication:** Secure sign-up and sign-in for clients and lawyers.
-   **Lawyer Profiles:** Detailed profiles for lawyers, showcasing their expertise, experience, and client reviews.
-   **Search and Filter:** Clients can easily search for lawyers by name or legal specialty.
-   **Gig Posting (for Clients):** Clients can post legal "gigs" or cases they need assistance with.
-   **Case Applications (for Lawyers):** Lawyers can browse and apply for gigs posted by clients.
-   **Real-time Chat:** Secure and real-time messaging between clients and lawyers.
-   **AI-Powered Chat:** An integrated AI assistant to answer legal questions.
-   **Payments and Earnings:** (Mocked) Functionality for managing payments and tracking earnings.
-   **Reviews and Ratings:** Clients can leave reviews and ratings for lawyers.

## 🛠️ Technologies Used

-   **Frontend:** Flutter
-   **Backend:** Firebase (Authentication, Firestore, Storage)
-   **State Management:** Provider
-   **Routing:** go_router
-   **AI:** Google Generative AI
-   **UI:** Material Design, Google Fonts, Lottie for animations.

## 🏁 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK: Make sure you have the Flutter SDK installed.
-   Firebase Account: You will need a Firebase account to set up the backend services.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/rianphlox/lawyer-app.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd lawyer-app
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Set up Firebase**
    -   Create a new project on [Firebase](https://firebase.google.com/).
    -   Add an Android and/or iOS app to your Firebase project.
    -   Follow the Firebase setup instructions and add the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to your project.
5.  **Run the app**
    ```sh
    flutter run
    ```

## 📂 Project Structure

The project is structured with a feature-first approach, with clear separation of concerns.

```
lib/
├── core/         # Core utilities, constants, routes, and theme.
├── models/       # Data models for the app.
├── providers/    # State management using Provider.
├── screens/      # UI for each screen of the app.
├── services/     # Services for interacting with APIs and backend.
└── widgets/      # Reusable UI widgets.
```