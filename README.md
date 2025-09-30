# JBM 💸

A clean, minimalist, and powerful personal finance tracker built with Flutter. This app is designed to work completely offline, putting you in full control of your financial data.


## ✨ Features

*   **100% Offline First:** All your data is stored locally on your device, ensuring privacy and instant access.
*   **Modern Material 3 Design:** A beautiful and intuitive user interface with light and dark themes.
*   **Comprehensive Dashboard:** Get a complete overview of your finances with filterable date ranges (This Month, This Year, Custom).
    *   Key Performance Indicators (KPIs) for Total Balance, Net Flow, Income, and Expenses.
    *   Interactive Pie Charts showing a breakdown of income and expenses by category.
    *   Detailed lists of all account balances.
    *   Summary of total Debts and Credits.
*   **Multi-Account Management:** Register and track balances for various types of accounts (e.g., Cash, M-PESA, CRDB Bank).
*   **Categorization:** Create and manage custom categories for your income and expenses (e.g., Salary, Groceries, Transport).
*   **Transaction Logging:** Easily add, edit, and view all your deposits and withdrawals.
*   **Debtors & Creditors:** A full-featured system to track money you've lent and money you've borrowed.
*   **Money Transfers:** Seamlessly move money between accounts or reallocate funds between categories within the same account.
*   **Data Drilldowns:** Tap on any account or category to see a detailed breakdown of its composition and history.

## 🚀 Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
*   A configured IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
*   An Android Emulator or physical device

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://your-repository-url/budget_master.git
    cd budget_master
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Run the code generator:**
    The project uses ObjectBox, which requires code generation to build the database schema. This command must be run after any changes to the data models in `lib/domain/models/`.
    ```sh
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```


## 🛠️ Key Technologies Used

*   **Framework:** [Flutter](https://flutter.dev/)
*   **State Management:** [Riverpod](https://riverpod.dev/)
*   **Local Database:** [ObjectBox](https://objectbox.io/)
*   **UI Design:** [Material 3](https://m3.material.io/)
*   **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
*   **Fonts:** [google_fonts](https://pub.dev/packages/google_fonts) (Quicksand)
