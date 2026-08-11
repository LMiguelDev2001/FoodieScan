# FoodieScan ![Logo](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADwElEQVR4nO1av2vbQBT+UroUshSKqbc2IAQWpEOHDMnuEMjodvUfEWpPQXSKQ/8Ir63HQIgzZJIHDxkSsMERpIUODaaliyFjO9hPOcuS7p1k6aTEHxikk05+3/fevfu5Nhq2/uEJ45luA3RjJUCaHzcrDZiVhrb6HKQmgFlp4ODqEOv2TiwSSetzkYoAZPz5zQU2rOzrq2DpAnz/8RcA8OXdZy31VfFctULccEwaxtz6o2FL6btsAciAg6tDAMD5zUXoux1rf8Hg0bCF2uCE9V9x6t8O5u3kCsESgNokIYq8LmxYUxHW7R1gZjNHBKkAInlV4uSVuFCtTwmThOCIwE6CefR6GFR6jrWouUAS74vtWKX9L6s+Rc/EdiKjgJUD4ni/Njjx/ljV+GXUp5wgg3I3qII4hi+zPgfSHFCkth8Hj3Y2yO1BWE0gaXeWZ0gFuB1MM2kRQYOiKEgFkHUjeQZn/iDNAUUlD6btjzYJcrESQLcBuvHkBUg8FH7/bTpcvfywH3nvL0v63F8WF08+AlYC6DZAN1YC6DZAN1YCyF5Ie3NSN0IFMCsNbHZ2sNlJd3NSNwIHQkSeFkJEEYo8OwxCYASMhi1c1xxsWA+rq1HRMLGdwkZJZA64rk1XgkgEEkIkO7EdHFdNHFfNQooQKgCF+nXNWYgGCKc3jqsmAODy5x98rLwq3PKZdDJEQgR5VyT/dfgbYK7D5QnscYCY/MRrIk9lE9spVBQonQ/4tb0NACgHRINZaaBtGHP3RegxWBEgkgcwd01oGwaqpZL3axtGIZIiayToJ1zu9Rbeq7vuQnnbMHLfHKQCBHmbyj51R17yaxvGXBOolkpeeZ5FCM0BQZ4XIZKFQNhf1h2P0TYM1G0HSLh8lQbYSfD11hYA4K7fB0II31vToxkvBg+biSRCXhHYBPzeJ/L+63vL8khjRlwkLyKvSTHwiExQ+IvEIUQCF93xGHXXzbxrlHXH7IHQXb+vTLoIUN4XWIYIWe0L0LHbKKR6RigMotFBBFSeJ0Uma4I6egGO9xG1IFLu9ZZqeJYJkMjv7h3h7LQZ+a40ApKKkLX3uZ4nhOaAs9MmdveOFkZ8KiDyddfF2WlT2bgk4HgfsiToiTC7Dxr9hcFPPivs7h0BM9sB4O2bl5HvR54VFtsSTXfD0B2Pveci+awhii0jD5kACBCBIJKtu+5CU8na835wyIMjAHwiwDcTJC9TGd3rIs8lTmAJAF92JSEgEPW3vTjG6ABbAAI3kxeBPOIMhYtCjIvV9rhuA3TjP0Y++OFKoBZYAAAAAElFTkSuQmCC) 

> *FoodieScan aims at reducing food waste in household environments. It allows users to scan product barcodes, manage a digital food inventory using **AI-driven text recognition**, and receive expiration date notifications to prevent food waste.*

### 📱 Development and Databases
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

### 🧠 APIs and Machine Learning
![Google ML Kit](https://img.shields.io/badge/Google_ML_Kit-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Open Food Facts](https://img.shields.io/badge/Open_Food_Facts_API-303E47?style=for-the-badge)

### 🛠️ Tools and Development Environments
![Visual Studio Code](https://img.shields.io/badge/VSCode-0078D4?style=for-the-badge&logo=visualstudiocode&logoColor=white)
![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)

### 🎨 Design
![Aseprite](https://img.shields.io/badge/Aseprite-7D929E?style=for-the-badge&logo=aseprite&logoColor=white)

---

## ℹ️ About the Project

The current socioeconomic context highlights food waste as a critical environmental and logistical issue within households, where more than half of food waste is generated. This project presents the development of **FoodieScan**, a cross-platform application designed for Android and Windows environments, aimed at minimizing household food waste through automated inventory management and proactive expiration alerts. Developed using Google’s Flutter framework and the Dart programming language, the system operates under a single codebase, optimizing development cycles. 

For data storage, a local SQLite architecture with three relational tables was implemented, prioritizing user privacy and ensuring offline functionality. The system automates data ingestion on mobile devices by integrating **Google's Machine Learning models (ML Kit SDK)** for barcode scanning and **AI-powered Optical Character Recognition (OCR)** to extract expiration dates via regular expressions, combined with the Open Food Facts API to retrieve commercial product details. 

Graphical user interfaces and iconography were handcrafted utilizing pixel-art techniques in Aseprite to ensure a unique, user-friendly, and lightweight visual identity. Black-box testing validated high system resilience and operational efficiency, although it revealed hardware permission dependencies on mobile platforms. 

## 🌟 Highlights

* **AI-Powered OCR & Barcode Scanner:** The app leverages on-device Machine Learning algorithms (Google ML Kit) to process camera feeds in real-time, instantly scanning barcodes and extracting expiration dates from product packaging.
* **Automated Data Extraction:** It connects to the Open Food Facts API via GET requests to instantly retrieve commercial product details.
* **Smart Alerts:** Users receive push notifications on their devices at configurable intervals (7 days, 3 days, 1 day, and on the exact day of expiration).
* **Simple Inventory Management:** Users can easily add and remove products from their digital pantry.
* **Retro Theme:** The UI features a custom 80s-inspired pixel-art aesthetic.

| Barcode Scan | Expiration date Scanning | Manage Inventory |
|:---:|:---:|:---:|
| <video src="https://github.com/user-attachments/assets/16d4104f-ad4a-4fcd-9b7b-4862791d2c2b" autoplay loop muted playsinline width="220"></video> | <video src="https://github.com/user-attachments/assets/f88dc762-0efa-4c15-9fa0-bc7ba13ce76c" autoplay loop muted playsinline width="220"></video> | <video src="https://github.com/user-attachments/assets/377b2310-e818-4d99-ba3b-6882f7c1f29b" autoplay loop muted playsinline width="220"></video> |

## ⚙️ Getting Started

### 💻 Developer Installation Guide
To compile, modify, or run the FoodieScan source code from a development environment, the following requirements and instructions must be met:

1. **Flutter Environment Setup:** Download and install the [Flutter SDK](https://docs.flutter.dev/get-started/install) from its official website, adding its path to the operating system's environment variables.
2. **IDE and Android SDK Installation:** It is mandatory to install [Android Studio](https://developer.android.com/studio) to obtain the Android compilation tools (Android SDK and Android SDK Command-line Tools). For the primary code editor, it is recommended to install [Visual Studio Code](https://code.visualstudio.com/) with the official Flutter and Dart extensions.
3. **Download the Project:** Extract the compressed file (`.zip`) containing the project's source code into an accessible path on your hard drive (or clone the repository using Git).
4. **Install Dependencies:** Open the project folder with Visual Studio Code, open a new integrated terminal, and run the command `flutter pub get`. This will automatically download all necessary libraries (such as `sqflite`, `camera`, `google_mlkit_barcode_scanning`, etc.).
5. **Execution:** With a physical Android device connected via USB (with USB debugging enabled) or by selecting the Windows environment in the IDE, run the command `flutter run` in the terminal to compile and launch the application in development mode.

---

### 📱 End-User Installation Guide
For the deployment of the final product, no technical knowledge or programming environment installations are required. Below are the steps for the two compatible operating systems:

#### Installation on Android Devices (Recommended)
1. Transfer the installable file `foodie_scan.apk` to the mobile phone's internal memory (you cand downloaded in your desktop and then send it to yourself via telegram, whatsapp, discord, etc).
2. If the device displays a security warning, you must enable the **"Install apps from unknown sources"** option in your phone's settings.
3. Finish the installation and open the application.
4. **Important:** Upon launching FoodieScan for the first time, the system will request Camera, Microphone, and Notification permissions. It is strictly necessary to grant all permissions so that the scanner and the expiration alert system function correctly.

#### Installation on Windows Systems
1. Download the compressed file corresponding to the PC version (`FoodieScan_Windows.zip`).
2. Extract the contents of the `.zip` file into a folder on your hard drive (for example, in Documents or on the Desktop).
3. Inside the extracted folder, locate and run the main `FoodieScan.exe` file by double-clicking it.
4. **Critical Warning:** The `.exe` file must never be moved or separated from its original folder. The application requires all files and libraries generated by the compiler to remain in the same directory to start. If you want to move the application, you must move the entire folder.
