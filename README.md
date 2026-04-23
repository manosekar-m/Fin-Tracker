# 💰 Fin Tracker — The Ultimate Personal Finance Ecosystem

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Provider-State_Management-6366F1?style=for-the-badge">
  <img src="https://img.shields.io/badge/Hive-NoSQL_DB-FFC107?style=for-the-badge&logo=hive&logoColor=black">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white">
  <img src="https://img.shields.io/badge/Platform-iOS-000000?style=flat-square&logo=apple&logoColor=white">
  <img src="https://img.shields.io/badge/Licence-MIT-blue.svg?style=flat-square">
  <img src="https://img.shields.io/github/stars/manosekar-m/Fin-Tracker?style=flat-square&color=yellow">
</p>

---

## 💎 The Vision
**Fin Tracker** is more than just an expense logger—it is a premium, high-performance financial ecosystem engineered to bridge the gap between complex financial data and intuitive user experience. 

Built with **Flutter**, this application leverages high-end design principles like **Glassmorphism**, **Staggered Animations**, and **Custom Painting** to deliver a "Best-in-Class" mobile experience. It is designed for users who value both their money and the software they use to track it.

---

## ✨ Professional Features

### 🏛️ Architecture-First Design
*   **Reactive State Management**: Orchestrated via `Provider` for ultra-fast, low-latency UI updates.
*   **Offline Sovereignty**: Powered by `Hive`, a high-performance NoSQL database, ensuring 100% data persistence even in zero-connectivity environments.
*   **Secure Enclave**: Integrated `local_auth` for biometric protection (Fingerprint/FaceID), keeping sensitive financial data strictly private.

### 📈 Advanced Analytics & UX
*   **Dynamic Staggered Branding**: A custom-engineered splash experience with character-by-character animations.
*   **Intelligent Insights**: Interactive data visualization using `fl_chart`, providing deep dives into spending patterns and trend analysis.
*   **Goal-Centric Logic**: A dedicated savings ecosystem that motivates users by visualizing progress through real-time calculation engines.
*   **Smart OCR Scanning**: Advanced receipt parsing using `google_mlkit_text_recognition` to automatically extract amounts, dates, categories, and merchant names from images.
*   **Rough Plans (Smart Budgeting)**: A dedicated planning ecosystem for trips and major purchases. Features "Smart Notes" technology that automatically detects and sums expenses from free-form text.
*   **Premium Customization**: Global font scaling and theme-matched UI components (Light/Dark mode) that adapt to user accessibility needs.

---

## 📸 Visual Walkthrough

<table border="0">
  <tr>
    <td width="50%">
      <p align="center"><b>Main Dashboard</b></p>
      <img src="screenshots/dashboard.png?v=1.1" width="100%" style="border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
    </td>
    <td width="50%">
      <p align="center"><b>Transaction Registry</b></p>
      <img src="screenshots/transactions.png?v=1.1" width="100%" style="border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
    </td>
  </tr>
  <tr>
    <td width="50%">
      <p align="center"><b>Deep Insights</b></p>
      <img src="screenshots/insights.png?v=1.1" width="100%" style="border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
    </td>
    <td width="50%">
      <p align="center"><b>Savings Targets</b></p>
      <img src="screenshots/goals.png?v=1.1" width="100%" style="border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
    </td>
  </tr>
</table>

---

## 🛠️ Technical Stack & Implementation

### Core Dependencies
- **UI Engine**: Flutter 3.x
- **Storage**: Hive (Lightweight & blazing fast)
- **State**: Provider (Scalable & decoupled)
- **Charts**: fl_chart (Fully interactive & customizable)
- **OCR Engine**: Google ML Kit (High-accuracy text recognition)
- **Security**: local_auth (Biometric hardware integration)
- **Typography**: Google Fonts (Outfit)

### Clean Code Principles
- **Decoupled Logic**: Separate layers for Models, Providers, and UI components.
- **Reusable Widgets**: Atomic design approach for UI components.
- **Optimization**: Efficient use of `ListView.builder` and `CustomScrollView` for 60FPS scrolling.

---

## ⚙️ Engineering Setup

1. **Clone & Navigate**
   ```bash
   git clone https://github.com/manosekar-m/Fin-Tracker.git
   cd Fin-Tracker
   ```

2. **Initialize Environment**
   ```bash
   flutter pub get
   ```

3. **Build & Deploy**
   ```bash
   # Run in debug mode
   flutter run
   ```

> **Pro-Tip**: Ensure **Developer Mode** is enabled on your Windows system for proper symlink support during the build process.

---

## 🏗️ Roadmap
- [ ] Multi-currency support (localization)
- [ ] PDF statement generation
- [ ] Budget category limit alerts
- [ ] Recurring transaction automation

---

## 👨‍💻 Engineering Lead

**Mano Sekar M**
*Mobile Application Architect | Flutter Specialist*

<p align="left">
  <a href="https://www.linkedin.com/in/manosekar-m/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
  <a href="https://github.com/manosekar-m"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"></a>
</p>

---

<p align="center">
  <b>Built with precision and purpose. ⭐ this repo if you find it valuable!</b>
</p>
