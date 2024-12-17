# AEMS Mobile Application 📊

An efficient **iOS-based Appliances Enquiry Management System (AEMS)** designed to streamline the management of product inquiries and improve collaboration between Salespersons and Dealers within the appliance industry.

---

## 🚀 Features

### **1. User Registration & Authentication**
- **Sign-Up**: Allows both **Salespersons** and **Dealers** to create their accounts securely.
- **Sign-In**: Log in to access features based on user roles.

### **2. Enquiry Management**
- **Create Enquiries**: Salespersons can create enquiries with customer details, product lists, and quantities.
- **Update Enquiries**: Modify enquiry details, including status changes like:
   - "In Progress," "Closed," or "Retailed."
- **Dashboard**: View enquiry metrics:
   - **Total Enquiries**
   - **Retailed Enquiries**
   - **Closed Enquiries**

### **3. Role-Based Views**
- **Salespersons**:
   - Manage and track individual enquiries.
   - Update enquiry statuses in real-time.
- **Dealers**:
   - View and oversee enquiries created by Salespersons under them.

### **4. Sign-Out Functionality**
- Securely log out from the application.

---

## 🛠️ Tech Stack

### **Languages & Tools**
- **Swift**, **Objective-C**: iOS app development.
- **UIKit**: User Interface components.
- **Xcode**: Development environment.
- **PODS**: Dependency management for third-party libraries.

### **Database**
- **SQLite**: Local database for storing enquiries and user details.

---

## 🎯 Use Cases

1. **User Authentication**
   - UC-001: Sign-Up.
   - UC-002: Sign-In.

2. **Enquiry Features**
   - UC-003: Home Screen (Role-Based View).
   - UC-004: Dashboard with Metrics.
   - UC-005: Create New Enquiries.
   - UC-006: Update Existing Enquiries.

3. **Account Management**
   - UC-007: Sign Out.

---

## 🎨 UI/UX Design Highlights

- **Clean Interface**: Designed with UIKit and Interface Builder for a smooth experience.
- **Role-Based Navigation**: Tailored features for Salespersons and Dealers.
- **Responsive Layout**: Optimized for all iOS devices.

![image](https://github.com/user-attachments/assets/eaf2bc48-790c-40c7-a3ef-e26451ae60cc)


## 📂 Folder Structure

```plaintext
AEMS/
│-- README.md
│-- AEMS/
    │-- Models/           # Data Models
    │-- Views/            # UI Components
    │-- Controllers/      # View Controllers
    │-- Utils/            # Utility Functions
    │-- Database/         # SQLite Setup
    │-- Services/         # Core Logic and API Integrations
    │-- Tests/            # XCTest Cases
