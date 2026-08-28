# RentRig

RentRig is a high-tech Flutter web and mobile platform for lending, borrowing, and sharing technology equipment, tools, and hardware inside a trusted community network. Users can list equipment they own, browse available tools, submit borrow requests for specific date ranges, manage pending requests, communicate via real-time in-app chat, and build community trust with member rating badges.

## Features & Highlights

- **Email & Password Authentication**: Secure user login and signup flow backed by Firebase Auth.
- **Equipment & Tools Marketplace**: Cloud Firestore-backed real-time marketplace with instant category filtering and live keyword search.
- **Tool Listing Management**: Add tool listings with name, category, condition, description, and high-res image uploads powered by Cloudinary.
- **Owner Dashboard & My Tools**: Dedicated dashboard ("My tools") to manage listed tools, toggle availability, or remove listings.
- **Borrowing & Rental Requests**: Integrated request flow with start/end dates, pending approval screens for owners, and active rental tracking.
- **Real-Time In-App Chat**: Direct messaging system (`ChatScreen`) between tool owners and borrowers to coordinate pickup, usage details, and returns.
- **Community Trust & User Rating System**: Member rating system (`RatingService` & `TrustBadgeWidget`) featuring star ratings, review comments, and trust indicators on member profiles and drawer headers.
- **High-Tech Branding & Responsive UI**: Futuristic dark theme (Obsidian background `#181818` with Electric Cyan accents `#00FFFF`), custom vector 'R' monogram brandmark (`TechMonogramLogo`), responsive navigation drawer, and updated browser tab branding (`rentrig`).
- **Optimized Database Indexing**: Pre-configured Firestore composite indexes (`firestore.indexes.json`) for multi-field filtering and sorted rental transaction queries.

## Tech Stack

- **Framework**: Flutter (Dart ^3.9.2)
- **Backend Services**: Firebase Core, Firebase Auth, Cloud Firestore
- **Storage & Media**: Cloudinary Public SDK (`cloudinary_public`), Image Picker (`image_picker`)
- **UI & Typography**: Google Fonts (Space Grotesk & Poppins), Custom Paint Vector Monogram

## Project Structure

```text
lib/
  main.dart                    App entry point, MaterialApp config, theme, and routes
  firebase_options.dart        Generated Firebase project options
  models/                      Firestore data models (tools, transactions, chat, ratings)
    chat_message_model.dart    Chat message entity
    tool_transaction_model.dart Borrow request / rental transaction entity
    tools_model.dart           Tool listing entity
    user_rating_model.dart     Community review & rating entity
  screens/                     App screens and navigation flows
    add_tools_screen.dart      Create new equipment listings
    borrowed_tools_screen.dart Track active borrowed hardware
    chat_screen.dart           Real-time messaging between lender & borrower
    edit_profile_screen.dart   Update profile details & profile image
    home_screen.dart           Marketplace browse & filter interface
    log_in_screen.dart         Sign in screen
    my_tools_screen.dart       Owner tools inventory management
    pending_requests_screen.dart Review & approve/reject incoming borrow requests
    profile_screen.dart        Member profile view with trust badge & reviews
    sign_up_screen.dart        New user registration
    splash_screen.dart         App launch screen & auth routing
    tool_details_screen.dart   Tool overview & borrow request trigger
  services/                    Backend API and service layers
    chat_service.dart          Firestore real-time chat operations
    firestore_service.dart     Core Firestore CRUD for tools & transactions
    image_service.dart         Cloudinary image upload handler
    rating_service.dart        User rating & review collection handler
  utils/                       UI constants, app colors, and helpers
    app_colors.dart            Brand identity colors & app bar decorations
    forms_util.dart            Form field validators
    responsive_util.dart       Responsive screen breakpoints
  widgets/                     Reusable UI components
    category_bar_widget.dart   Horizontal category filter bar
    custom_action_button.dart  Primary styled action buttons
    drawer_widget.dart         Navigation sidebar with user profile header
    tech_monogram_logo.dart    Official RentRig cybernetic 'R' monogram painter
    trust_badge_widget.dart    Community trust badge & star rating indicator
assets/
  fonts/                       Poppins font files
  logo/                        Official RentRig app icon, favicon, & SVG logos
web/                           Web entry point, manifest, & favicons
firestore.indexes.json         Firestore composite index definitions
```

## Setup & Installation

1. **Install Dependencies**:

   ```sh
   flutter pub get
   ```

2. **Firebase Configuration**:

   Firebase options are configured in `lib/firebase_options.dart` and `android/app/google-services.json`. To link your own Firebase project:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. **Cloudinary Configuration**:

   Image uploads are managed via `lib/services/image_service.dart`. Set your Cloudinary cloud name and unsigned upload preset.

## Running the Application

- **Web (Chrome)**:

  ```sh
  flutter run -d chrome
  ```

- **Android / iOS**:

  ```sh
  flutter run -d android
  ```

## Main App Routes

| Route | Screen | Purpose |
| --- | --- | --- |
| `/` | `SplashScreen` | Launch splash screen & auth state verification |
| `/log_in` | `LogInScreen` | Account sign in |
| `/sign_up` | `SignUpScreen` | Account registration |
| `/home` | `HomeScreen` | Equipment marketplace & search |
| `/add_tool` | `AddToolScreen` | List new equipment |
| `/tool_detail` | `ToolDetailScreen` | Equipment details & borrow request form |
| `/profile` | `ProfileScreen` | Member profile, trust badge, & user reviews |
| `/edit_profile` | `EditProfileScreen` | Edit profile info & avatar |
| `/my_tools` | `MyToolsScreen` | Manage personal equipment inventory ("My tools") |
| `/borrowed_tools` | `BorrowedToolsScreen` | Track active hardware rentals |
| `/pending_requests` | `PendingRequestsScreen` | Approve or reject incoming rental requests |
| `/chat` | `ChatScreen` | Real-time chat between borrower & lender |

## Firestore Data Schemas

### `tools`
- `ownerId` (string): Owner's Firebase Auth UID
- `name` (string): Equipment name
- `category` (string): Equipment category
- `description` (string): Detailed description
- `condition` (string): `Excellent`, `Good`, `Fair`, or `Poor`
- `imageUrl` (string?): Cloudinary image URL
- `isAvailable` (boolean): Browse visibility flag
- `createdAt` (timestamp): Listing creation timestamp

### `transactions`
- `toolId` (string): Borrowed tool ID
- `toolName` (string): Tool name snapshot
- `borrowerId` (string): Borrower's Auth UID
- `lenderId` (string): Owner's Auth UID
- `startDate` (timestamp): Start date of rental
- `endDate` (timestamp?): End date of rental
- `status` (string): `pending`, `approved`, `rejected`, `active`, or `completed`
- `createdAt` (timestamp): Request timestamp

### `chat_messages`
- `rentalId` (string): Transaction / rental ID context
- `senderId` (string): Sender Auth UID
- `senderEmail` (string): Sender email
- `text` (string): Chat message body
- `timestamp` (timestamp): Message timestamp

### `ratings`
- `targetUserId` (string): User UID receiving the rating
- `reviewerId` (string): User UID submitting the review
- `rating` (double): Rating score (1.0 to 5.0)
- `comment` (string): Review commentary
- `timestamp` (timestamp): Review timestamp

## Quality & Build Commands

- **Code Analysis**:
  ```sh
  flutter analyze
  ```

- **Run Unit & Widget Tests**:
  ```sh
  flutter test
  ```

- **Regenerate App Launcher Icons**:
  ```sh
  dart run flutter_launcher_icons
  ```
