# Carpenter App

The Carpenter App is a comprehensive solution designed to streamline the management of woodworking and carpentry projects. Whether you're a professional carpenter or a DIY enthusiast, this app simplifies the process of organizing tasks, managing inventory, and tracking project progress.

## Features

- **Project Management**: Create, update, and track your carpentry projects.

- **Inventory Tracking**: Keep a record of tools and materials with quantity management.

- **Task Assignment**: Assign tasks to team members and monitor their progress.

- **Estimation and Budgeting**: Generate cost estimates for materials and labor.

- **Reports and Analytics**: View project summaries, resource usage, and performance metrics.

- **Notifications**: Stay updated with reminders for deadlines and low inventory alerts.

- **User-friendly Interface**: Intuitive and visually appealing design for easy navigation.

## Technologies Used

- **Frontend**: Flutter (Dart)

- **Backend**: SQLite (using `sqflite` package for local database management)

- **State Management**: Provider / Riverpod

- **APIs**: Integration with external APIs for cost estimation

- **Design**: Material Design principles with a modern touch

## Installation

### Prerequisites
- Flutter SDK installed on your machine
- A Firebase account
- Android Studio or VS Code (with Flutter and Dart plugins)

### Steps

1. Clone this repository:

   ```bash
   git clone https://github.com/shreramkedlaya/carpenter-app.git
   cd carpenter-app
   ```

2. Install dependencies:

   ```dart
   flutter pub get
   ```

3. Configure Firebase:
   - Go to the Firebase console.
   - Create a new project.
   - Add an Android/iOS app and download the `google-services.json`/`GoogleService-Info.plist` file.
   - Place the file in the respective directory of your Flutter project.

4. Run the app:
   ```dart
   flutter run
   ```

## Screenshots
<!-- To add screenshots -->
![Dashboard](./screenshots/dashboard.png)
![Inventory](./screenshots/inventory.png)
![Project Details](./screenshots/project_details.png)

## Contribution

Contributions are welcome! Follow these steps to contribute:

1. Fork this repository.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes and push to the branch:
   ```bash
   git add .
   git commit -m "Add your message here"
   git push origin feature/your-feature-name
   ```
4. Open a pull request.

## Contact

For any queries or suggestions, feel free to reach out:

- **Email**: youremail@example.com
- **LinkedIn**: [Your Name](https://www.linkedin.com/in/yourprofile)
- **GitHub**: [@yourusername](https://github.com/yourusername)

---

Thank you for using the Carpenter App! We hope it makes your woodworking projects more efficient and enjoyable.
