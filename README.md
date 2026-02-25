# AI Advanced Language Learning & Assessment Platform made with flutter 

## 🌐 Overview
This repository contains the codebase for a comprehensive language learning and testing platform built with Flutter. The application provides users with structured assessment simulations, interactive practice environments, and real-time AI-driven feedback to accelerate their language acquisition journey.

## ✨ Key Features
* **AI-Powered Evaluation Engine:** Integrates with backend AI models to evaluate user-recorded speaking audio and written essays. It provides immediate, detailed feedback including estimated proficiency scores, constructive comments, and actionable suggestions.
* **Comprehensive Testing Modules:** * **Speaking:** Audio recording interface with real-time AI processing.
  * **Listening:** Custom audio player UI featuring synchronized, collapsible audio scripts.
  * **Reading:** Interactive text passages with toggleable highlighting, inline blank filling, and multiple-choice questions.
  * **Writing:** Dedicated text editor with live word-counting and structural validation.
* **Interactive AI Chat Assistant:** A floating, always-accessible AI tutor overlay that allows users to ask questions and receive conversational guidance from anywhere in the app.
* **Smart Progress Tracking:** A visual analytics dashboard (built using `fl_chart`) that tracks user accuracy, total correct answers, and proficiency levels across different skill categories via bar charts and progress rings.
* **Gamified "Learn & Play" Hub:** A dedicated section for interactive mini-games and challenges designed to reinforce vocabulary and grammar.
* **Robust Network Architecture:** Features a custom API client equipped with interceptors for automatic JWT token refreshing, request queuing, and network retry logic to ensure a seamless user experience.

## 💻 Tech Stack
* **Framework:** Flutter / Dart
* **Architecture Highlights:** Custom API Client (Interceptors, Token Refresh), Audio Recording & Processing, State Management, Responsive UI Adapting (Mobile/Tablet/Web).
* **Key Packages:** `http`, `flutter_tts` (Text-to-Speech), `record` (Audio Recording), `fl_chart` (Data Visualization).
