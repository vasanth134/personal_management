# Personal Management App

This is a cross-platform application (Linux, Android, Web) for personal management, including Expense Tracker, Clock, Notes, and Task Reminder.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Node.js, Express, MongoDB

## Prerequisites

- Flutter SDK
- Node.js & npm
- MongoDB

## Setup & Run

### 1. Backend

Navigate to the `backend` directory and install dependencies:

```bash
cd backend
npm install
```

Start the backend server:

```bash
npm start
```

The server will run on `http://localhost:3000`.

### 2. Frontend (Flutter App)

Navigate to the root directory and install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

To run on a specific device (e.g., Linux):

```bash
flutter run -d linux
```

## Features

- **Dashboard**: Real-time clock and summary.
- **Expenses**: Add and view expenses.
- **Tasks**: Create and complete tasks.
- **Notes**: Take quick notes.
