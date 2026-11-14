# DataCore Pay — High-Concurrency Financial Mobile App

[![Build DataCore Android APK](https://github.com/sarveshsuyal/datacore-mobile-app/actions/workflows/build-apk.yml/badge.svg)](https://github.com/sarveshsuyal/datacore-mobile-app/actions/workflows/build-apk.yml)

A high-concurrency mobile banking and transaction customer application built with **Flutter**, connected to the **DataCore Real-Time Transaction Engine** backend.

## 🚀 Key Features

- **PhonePe-Inspired Modern UI:**
  - Dynamic user header with cloud ledger connectivity indicator (`● Protected Ledger • Render Cloud`).
  - Gradient Available Balance card with `Strict Locks` badge and `INR • PERSISTENT` tag.
  - 4 Quick Actions: **Send**, **Scan QR**, **Receive**, and **Services**.
  - **Bharat BillPay (BBPS)** promotional hero banner for instant utility & bill payments.
  - **Cashback Hub** scratch cards & reward claiming.
  - **5-tab bottom navigation** featuring an elevated center circular **Scan QR** button.
- **Enterprise Financial Concurrency:**
  - Multi-strategy row-level locking (Pessimistic `SELECT ... FOR UPDATE`, Optimistic Versioning, Atomic Conditional).
  - Double-entry ledger accounting principles preserving strict financial invariants.
- **Production Cloud Architecture:**
  - **Backend API:** Hosted on Render (`https://datacore-backend-wktd.onrender.com`)
  - **Database:** Supabase PostgreSQL (`https://kphdytcnwanrmudtcojz.supabase.co`)
  - **Extended Sessions:** 7-day JWT access tokens with 30-day refresh rotation and transparent 401 recovery.
  - **Biometrics:** Hardware-backed biometric authentication with `local_auth`.

## 📦 Download Release APK

Download the latest signed release APK directly from GitHub Actions or Releases:
- [Download Latest APK](https://github.com/sarveshsuyal/datacore-mobile-app/releases/latest/download/app-release.apk)
