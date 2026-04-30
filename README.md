# 💰 Fin Tracker — The Ultimate Personal Finance Ecosystem

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Firebase-Cloud_Sync-FFCA28?style=for-the-badge&logo=firebase&logoColor=black">
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
**Fin Tracker** is a premium, high-performance financial ecosystem engineered to bridge the gap between complex financial data and intuitive user experience. 

Built with **Flutter**, the application leverages high-end design principles like **Glassmorphism**, **Staggered Animations**, and **Custom Painting** to deliver a "Best-in-Class" mobile experience. It is designed for users who value both their money and the software they use to track it.

---

## ✨ Advanced Professional Features

### 🏛️ Architecture & Security
*   **Firebase Cloud Sync**: Real-time synchronization and data persistence across device resets, powered by Firestore.
*   **Privacy-First Biometrics**: Integrated `local_auth` for military-grade protection (Fingerprint/FaceID). Includes **App Lock on Resume** with a blurred privacy overlay.
*   **Offline Sovereignty**: Powered by `Hive`, ensuring 100% data availability even in zero-connectivity environments.

### 📈 Wealth Management
*   **Investment Sub-Tracker**: Dedicated tracking for SIPs, Stocks, Gold, Mutual Funds, and Crypto—separated from daily expense logging.
*   **Budget Breakdown Alerts**: Intelligent monitoring of spending limits with home-screen alerts when approaching category thresholds.
*   **Smart OCR Scanning**: Advanced receipt parsing using `google_mlkit_text_recognition` to automatically extract financial data from images.

### 📝 Reports & Planning
*   **Professional PDF Reports**: Generate comprehensive monthly financial summaries with clean layouts, available for export and sharing.
*   **Rough Plans (Smart Budgeting)**: A dedicated planning ecosystem for trips and major purchases. Features "Smart Notes" technology that automatically sums expenses from free-form text.
*   **Motion-Driven Experience**: Fluid, staggered animations using `flutter_animate` for a high-end feel.

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
      <p align="center"><b>Investment Tracker</b></p>
      <img src="screenshots/goals.png?v=1.1" width="100%" style="border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
    </td>
  </tr>
</table>

---

## 🛠️ Technical Stack & Implementation

### Core Dependencies
- **UI Engine**: Flutter 3.x
- **Backend/Sync**: Firebase (Firestore & Auth)
- **Local Storage**: Hive (Lightweight & blazing fast)
- **State**: Provider (Scalable & decoupled)
- **Charts**: fl_chart (Fully interactive)
- **OCR Engine**: Google ML Kit (High-accuracy recognition)
- **Security**: local_auth (Biometric hardware integration)
- **Reporting**: pdf & printing

### Clean Code Principles
- **Decoupled Logic**: Strict separation between Models, Providers, and UI layers.
- **Atomic Components**: Highly reusable, theme-aware widget library.
- **Optimization**: 60FPS scrolling via efficient widget rebuilding and lazy loading.

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

3. **Cloud Configuration**
   - Add your `google-services.json` to `android/app/`.
   - Add your `GoogleService-Info.plist` to `ios/Runner/`.

4. **Build & Deploy**
   ```bash
   flutter run
   ```

---

## 🏗️ Roadmap
- [x] Smart OCR Receipt Scanning
- [x] Rough Plans with Smart Notes
- [x] Firebase Cloud Sync & Backup
- [x] Investment Sub-Tracker (SIP, Stocks, Gold)
- [x] Biometric App Lock on Resume
- [x] Professional PDF Report Generation
- [x] Budget Category Limit Alerts
- [ ] Multi-currency support (localization)
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
