# Parent Update Requests – Feature Documentation

This document describes all new changes, APIs, and features added to the school app for **Parent Update Requests**: a flow where parents submit change requests (passport, EID, photos, email, phone, address) from the mobile app, and changes are applied only after a registrar/admin approves them in the studPortal.

---

## Table of Contents

1. [Overview](#1-overview)
2. [New API Endpoints](#2-new-api-endpoints)
3. [Backend Integration Summary](#3-backend-integration-summary)
4. [New Files and Structure](#4-new-files-and-structure)
5. [Models](#5-models)
6. [Repository Layer](#6-repository-layer)
7. [State Management (Provider)](#7-state-management-provider)
8. [New Screens and Flows](#8-new-screens-and-flows)
9. [Navigation and Entry Points](#9-navigation-and-entry-points)
10. [Validation and UX](#10-validation-and-ux)
11. [Dependencies](#11-dependencies)
12. [Existing Flows Touched](#12-existing-flows-touched)

---

## 1. Overview

### What Was Added

- **Request-based updates**: Parents no longer update some profile/document fields directly. They submit **requests** that appear in the app and are approved/rejected in the studPortal.
- **Single hub**: A **Change Requests** hub lists all request types (student passport/EID/photo, parent photo/EID/email, phone, address) and opens the right form or existing OTP flow.
- **Request history**: A screen shows the family’s submitted requests with status (Pending / Approved / Rejected) and optional remark.
- **Consistent patterns**: All new flows use the same auth (token + famcode), error handling (toast + loader), and validation style as the rest of the app.

### Authentication

All new endpoints use the same parent auth as existing APIs:

- **Token** and **famcode** are read from Hive (`USERDB` / `AuthModel`) and sent in the request body (e.g. `FormData`).
- Invalid or missing auth returns `401` with `{"status":false,"message":"Authentication Error"}`.

---

## 2. New API Endpoints

Base URL for all: `https://<your-domain>/app-api/index.php?page=<page>`

| API Constant (in app)           | Backend `page` value              | Method | Purpose                          | File upload |
|--------------------------------|-----------------------------------|--------|----------------------------------|-------------|
| `requestPassportUpdate`        | `requestPassportUpdate`           | POST   | Student passport update request  | Yes (document) |
| `requestStudentEidUpdate`      | `requestEidUpdate`                | POST   | Student EID update request       | Yes (document) |
| `requestStudentPhotoUpdate`    | `requestPhotoUpdate`              | POST   | Student photo update request     | Yes (photo) |
| `requestFatherPhotoUpdate`     | `requestFatherPhotoUpdate`        | POST   | Father profile photo request     | Yes (photo) |
| `requestMotherPhotoUpdate`     | `requestMotherPhotoUpdate`        | POST   | Mother profile photo request     | Yes (photo) |
| `requestFatherEmailUpdate`     | `requestFatherEmailUpdate`        | POST   | Father email update request      | No |
| `requestFatherEidUpdate`      | `requestFatherEidUpdate`          | POST   | Father EID update request        | Yes (document) |
| `requestMotherEidUpdate`      | `requestMotherEidUpdate`          | POST   | Mother EID update request        | Yes (document) |
| `requestAddressUpdate`        | `requestAddressUpdate`            | POST   | Family address update request    | No |
| `getParentUpdateRequests`     | `getParentUpdateRequests`         | GET/POST | List family’s update requests  | No |

### Existing APIs (unchanged, now create requests on backend)

- **Phone**: `updateParentMobileOtp` → `updateParentPhoneOtp`, `updateParentMobile` → `updateParentPhone` (OTP flow; backend creates a request on verify).
- **Email OTP**: `updateParentEmailOtp` (send OTP), `updateParentEmail` (verify OTP). After verify, the app also calls `requestFatherEmailUpdate` so the new email is recorded as a request.

---

## 3. Backend Integration Summary

| Request type        | App action / screen                          | Backend page (POST)           |
|---------------------|----------------------------------------------|-------------------------------|
| Student passport    | `StudentPassportRequestScreen` → submit      | `requestPassportUpdate`       |
| Student EID         | `StudentEidRequestScreen` → submit           | `requestEidUpdate`            |
| Student photo       | `StudentPhotoRequestScreen` → submit         | `requestPhotoUpdate`          |
| Father photo        | `ParentPhotoRequestScreen(relation: Father)` | `requestFatherPhotoUpdate`    |
| Mother photo        | `ParentPhotoRequestScreen(relation: Mother)`  | `requestMotherPhotoUpdate`    |
| Father email        | After OTP verify in `VerifyEmail`            | `requestFatherEmailUpdate`    |
| Father EID          | `ParentEidRequestScreen(relation: Father)`    | `requestFatherEidUpdate`      |
| Mother EID          | `ParentEidRequestScreen(relation: Mother)`   | `requestMotherEidUpdate`      |
| Address             | `AddressUpdateScreen` → submit               | `requestAddressUpdate`        |
| Phone               | Existing `VerifyMobile` OTP flow             | Backend creates request on verify |
| List requests       | `ParentUpdateHistoryScreen` → fetch         | `getParentUpdateRequests`     |

---

## 4. New Files and Structure

### New files

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart                    # Added 10 new API constants (see above)
│   ├── models/
│   │   └── parent_update_request_model.dart      # NEW: ParentUpdateRequest, ParentUpdateRequestListModel
│   ├── repository/
│   │   └── parent_update/
│   │       ├── repository.dart                  # NEW: ParentUpdateRepository interface
│   │       └── repository_impl.dart             # NEW: ParentUpdateRepositoryImpl (Dio + FormData)
│   └── provider/
│       └── parent_update_provider.dart          # NEW: ParentUpdateProvider (submit + fetch history)
├── views/
│   ├── screens/
│   │   ├── parent/
│   │   │   ├── parent_profile/
│   │   │   │   └── parent_profile_screen_view.dart   # MODIFIED: "Change Requests" button
│   │   │   │   └── verify_email.dart                # MODIFIED: call requestFatherEmailUpdate after OTP success
│   │   │   └── parent_update/
│   │   │       ├── parent_update_hub_screen.dart     # NEW: Hub with all request options
│   │   │       ├── parent_update_history_screen.dart# NEW: List of requests + status
│   │   │       ├── parent_photo_request_screen.dart # NEW: Father/Mother photo (param by relation)
│   │   │       ├── parent_eid_request_screen.dart   # NEW: Father/Mother EID (param by relation)
│   │   │       └── address_update_screen.dart       # NEW: Family address form
│   │   └── student/
│   │       └── student_profile/
│   │           ├── student_eid_request_screen.dart  # NEW: Student EID + document
│   │           ├── student_passport_request_screen.dart # NEW: Student passport + document
│   │           └── student_photo_request_screen.dart   # NEW: Student photo picker
│   └── components/
│       └── document_details_widget.dart         # MODIFIED: EID/Passport tap → request screens
├── core/services/
│   └── dependecyInjection.dart                  # MODIFIED: register ParentUpdateRepository
└── main.dart                                    # MODIFIED: register ParentUpdateProvider
```

### Modified files (summary)

| File | Change |
|------|--------|
| `api_constants.dart` | Added 10 constants for parent update request APIs. |
| `parent_profile_screen_view.dart` | Added "Change Requests" button that navigates to `ParentUpdateHubScreen`. |
| `verify_email.dart` | After successful OTP verification, calls `ParentUpdateProvider.submitFatherEmailRequest(email)`. |
| `document_details_widget.dart` | Emirates ID and Emirates ID Expiry tap → `StudentEidRequestScreen`. Passport Number tap → `StudentPassportRequestScreen`. Removed unused `EditEmiratesIdScreen` import and `_isExpiredOrToday`. |
| `dependecyInjection.dart` | Registered `ParentUpdateRepository` → `ParentUpdateRepositoryImpl(locator())`. |
| `main.dart` | Added `ChangeNotifierProvider(create: (_) => ParentUpdateProvider())`. |

---

## 5. Models

### `lib/core/models/parent_update_request_model.dart`

- **ParentUpdateRequestListModel**
  - `status` (bool), `message` (String), `data` (List&lt;ParentUpdateRequest&gt;).
  - `fromJson(Map)` for `getParentUpdateRequests` response.

- **ParentUpdateRequest**
  - Fields: `id`, `requestType`, `requestTypeLabel`, `studcode`, `newValue`, `expiryDate`, `dateRequested`, `approvalStatus`, `approvalStatusLabel`, `approvedAt`, `remark`.
  - `fromJson(Map)` for each item in `data`.
  - Helpers: `isPending` (approvalStatus == 0), `isApproved` (1), `isRejected` (2).

---

## 6. Repository Layer

### Interface: `ParentUpdateRepository`

- `requestStudentPassportUpdate({ admissionNo, passportNumber?, expiryDate, documentPath })`
- `requestStudentEidUpdate({ admissionNo, emiratesId, expiryDate, documentPath })`
- `requestStudentPhotoUpdate({ admissionNo, photoPath })`
- `requestFatherPhotoUpdate({ photoPath })`
- `requestMotherPhotoUpdate({ photoPath })`
- `requestFatherEmailUpdate({ email })`
- `requestFatherEidUpdate({ emiratesId, expiryDate, documentPath })`
- `requestMotherEidUpdate({ emiratesId, expiryDate, documentPath })`
- `requestAddressUpdate({ homeAddress?, flatNo?, buildingName?, comNumber?, communityId? })`
- `getParentUpdateRequests()` → `Either<MyError, ParentUpdateRequestListModel>`

### Implementation: `ParentUpdateRepositoryImpl`

- Uses `DioAPIServices.postAPI` and Hive `AuthModel` (token, famcode).
- File-upload methods build `FormData` and attach files via `MultipartFile.fromFile(path)`.
- Parameter names match backend: e.g. `admission_no`, `expiry_date`, `document`, `photo`, `homeadd`, `flat_no`, `building_name`, `com_number`, `community_id`, `email`, `emirates_id`.
- Returns `Either<MyError, dynamic>` for submit endpoints; `Either<MyError, ParentUpdateRequestListModel>` for `getParentUpdateRequests`.

---

## 7. State Management (Provider)

### `ParentUpdateProvider` (ChangeNotifier)

- **State**
  - `_requestStates`: map of operation key → `AppStates` (e.g. `student_eid`, `student_passport`, `father_photo`, `address`).
  - `historyState`: `AppStates` for the history list.
  - `historyModel`: `ParentUpdateRequestListModel?` (result of `getParentUpdateRequests`).

- **Methods**
  - `stateFor(String key)` – used by screens to show loaders/disable buttons.
  - `submitStudentPassportRequest(...)`, `submitStudentEidRequest(...)`, `submitStudentPhotoRequest(...)`.
  - `submitFatherPhotoRequest(...)`, `submitMotherPhotoRequest(...)`.
  - `submitFatherEmailRequest(...)`.
  - `submitFatherEidRequest(...)`, `submitMotherEidRequest(...)`.
  - `submitAddressRequest(...)`.
  - `fetchParentUpdateRequests()`.

- **Behaviour**
  - Checks internet via `InternetConnectivity().hasInternetConnection`; on failure shows toast and sets appropriate `AppStates`.
  - On API success/failure shows `showToast` with backend `message` when available.
  - Submit methods return `Future<bool>` (true = success, false = error/no internet).

---

## 8. New Screens and Flows

### 8.1 Change Requests Hub – `ParentUpdateHubScreen`

- **Path**: `lib/views/screens/parent/parent_update/parent_update_hub_screen.dart`
- **App bar**: "Change Requests"
- **Sections**:
  - **Student updates**: Student Passport, Student Emirates ID, Student Photo → navigate to respective request screens.
  - **Parent updates**: Father Photo, Mother Photo, Father EID, Mother EID, Father Email, Phone Number → navigate to request screens or close (email/phone use existing profile flows).
  - **Family address**: Address → `AddressUpdateScreen`.
  - **History**: View all requests → `ParentUpdateHistoryScreen`.

### 8.2 Student request screens

- **StudentEidRequestScreen**  
  - Form: Emirates ID (15 digits), Expiry date (date picker, future only), document (PDF/JPG/JPEG/PNG).  
  - Uses `StudentProvider.studentDetailModel?.data.studcode` as `admission_no`.  
  - Submit → `ParentUpdateProvider.submitStudentEidRequest(...)`.

- **StudentPassportRequestScreen**  
  - Form: Passport number (optional), Expiry date (required, future only), document (PDF/JPG/JPEG/PNG).  
  - Same student source for `admission_no`.  
  - Submit → `ParentUpdateProvider.submitStudentPassportRequest(...)`.

- **StudentPhotoRequestScreen**  
  - Photo picker (JPG/JPEG/PNG), preview in CircleAvatar.  
  - Submit → `ParentUpdateProvider.submitStudentPhotoRequest(...)`.

### 8.3 Parent request screens

- **ParentPhotoRequestScreen**  
  - Parameter: `relation` ("Father" or "Mother").  
  - Photo picker (JPG/JPEG/PNG).  
  - Submit → `submitFatherPhotoRequest` or `submitMotherPhotoRequest`.

- **ParentEidRequestScreen**  
  - Parameter: `relation`.  
  - Form: Emirates ID (15 digits), Expiry date, document (PDF/image).  
  - Submit → `submitFatherEidRequest` or `submitMotherEidRequest`.

- **AddressUpdateScreen**  
  - Fields: Home address/Area, Flat number, Building name, Community/Contact number, Community ID (optional).  
  - All optional at UI level; validation requires at least one field.  
  - Submit → `submitAddressRequest(...)`.

### 8.4 Request history – `ParentUpdateHistoryScreen`

- **Path**: `lib/views/screens/parent/parent_update/parent_update_history_screen.dart`
- On init: `ParentUpdateProvider.fetchParentUpdateRequests()`.
- States: Loading, No internet (with retry), Error, Fetched empty, Fetched with list.
- List: each item shows `request_type_label`, `new_value`, `expiry_date`, `date_requested`, and a status chip (`approval_status_label` with Pending/Approved/Rejected colors).
- Tap on item: if `remark` is non-empty, show dialog with remark.

---

## 9. Navigation and Entry Points

| Entry point | Destination |
|-------------|-------------|
| Parent Profile tab → "Change Requests" button | `ParentUpdateHubScreen` |
| Hub → Student Passport / Student EID / Student Photo | `StudentPassportRequestScreen` / `StudentEidRequestScreen` / `StudentPhotoRequestScreen` |
| Hub → Father Photo / Mother Photo | `ParentPhotoRequestScreen(relation: 'Father'/'Mother')` |
| Hub → Father EID / Mother EID | `ParentEidRequestScreen(relation: 'Father'/'Mother')` |
| Hub → Address | `AddressUpdateScreen` |
| Hub → View all requests | `ParentUpdateHistoryScreen` |
| Student Profile → Document Details → Emirates ID or Emirates ID Expiry | `StudentEidRequestScreen` |
| Student Profile → Document Details → Passport Number | `StudentPassportRequestScreen` |
| Parent Profile → Mobile Number (tap) | Existing `VerifyMobile` (phone OTP) |
| Parent Profile → Email ID (tap, when empty) | Existing `VerifyEmail` (email OTP; then app calls `requestFatherEmailUpdate`) |

---

## 10. Validation and UX

- **Dates**: All expiry fields use future-only date pickers; display/API format `DD/MM/YYYY` (via `DateFormat('dd/MM/yyyy')`).
- **Emirates ID**: 15 digits, digits-only input.
- **Documents**: File picker restricted to PDF, JPG, JPEG, PNG for documents; JPG, JPEG, PNG for photos.
- **Address**: At least one field required; Community ID, if provided, must be numeric.
- **Feedback**: Success and error messages via `showToast`; submit buttons show a loading indicator and are disabled while `stateFor(key) == AppStates.Initial_Fetching`.
- **Success**: On successful submit, screen calls `Navigator.pop(context)` and user sees success toast.

---

## 11. Dependencies

- **file_picker** (e.g. `^8.1.2`) added in `pubspec.yaml` for document and image selection (student/parent EID and passport documents, student/parent photos).

---

## 12. Existing Flows Touched

- **Parent Profile screen**  
  - Added a single "Change Requests" button that opens the hub.

- **Verify Email screen**  
  - After successful OTP verification, in addition to refreshing parent list and showing toast, calls `ParentUpdateProvider.submitFatherEmailRequest(email)` so the new email is sent to `requestFatherEmailUpdate`.

- **Document Details widget (student profile)**  
  - Emirates ID and Emirates ID Expiry: tap now opens `StudentEidRequestScreen` instead of `EditEmiratesIdScreen`.  
  - Passport Number: tap now opens `StudentPassportRequestScreen` (with `canEdit: true`).  
  - Passport Issue Date and Passport Expiry Date remain read-only.

- **Phone update**  
  - No code change; still uses `updateParentPhoneOtp` and `updateParentPhone`. Backend is expected to create a request when the phone is updated via OTP.

- **Edit Emirates ID screen**  
  - Still present in the codebase but no longer linked from Document Details (replaced by request flow). Can be removed or kept for direct-update if backend supports it.

---

## Quick Reference: API Constant → Screen / Provider Method

| API constant | Provider method | Screen (or flow) |
|--------------|-----------------|-------------------|
| requestPassportUpdate | submitStudentPassportRequest | StudentPassportRequestScreen |
| requestStudentEidUpdate | submitStudentEidRequest | StudentEidRequestScreen |
| requestStudentPhotoUpdate | submitStudentPhotoRequest | StudentPhotoRequestScreen |
| requestFatherPhotoUpdate | submitFatherPhotoRequest | ParentPhotoRequestScreen(relation: Father) |
| requestMotherPhotoUpdate | submitMotherPhotoRequest | ParentPhotoRequestScreen(relation: Mother) |
| requestFatherEmailUpdate | submitFatherEmailRequest | Called after VerifyEmail OTP success |
| requestFatherEidUpdate | submitFatherEidRequest | ParentEidRequestScreen(relation: Father) |
| requestMotherEidUpdate | submitMotherEidRequest | ParentEidRequestScreen(relation: Mother) |
| requestAddressUpdate | submitAddressRequest | AddressUpdateScreen |
| getParentUpdateRequests | fetchParentUpdateRequests | ParentUpdateHistoryScreen |

This document reflects the implementation as of the Parent Update Requests feature completion. For backend request/response shapes and error messages, refer to the official API documentation for each `page` value.
