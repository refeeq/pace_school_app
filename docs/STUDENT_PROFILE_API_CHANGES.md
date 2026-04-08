# Student Profile API Changes – Implementation Summary

This document describes the changes made to the School App to support the new Student Profile and related APIs. All modifications were implemented to align the app with the updated backend response structures and new UI requirements.

---

## Table of Contents

1. [Overview](#overview)
2. [API Response Structures](#api-response-structures)
3. [Model Changes](#model-changes)
4. [UI Changes](#ui-changes)
5. [Utility Functions](#utility-functions)
6. [Component Modifications](#component-modifications)
7. [Backend Requirements](#backend-requirements)
8. [Files Modified](#files-modified)

---

## Overview

The following areas were updated:

- **Student Profile API** – Extended with status, re-registration, and configuration data
- **Students List API** – Extended with status for avatar indicators
- **Student Profile UI** – Status labels, re-registration, document expiry warnings, and avatar status dots

---

## API Response Structures

### 1. Student Profile API

**Endpoint:** `getStudentProfile` (student profile details)

**Response structure (relevant fields):**

```json
{
  "conf_status": [
    {
      "id": "1",
      "status": "Active",
      "shortcode": "Active",
      "colour": "0,255,0",
      "final_stat": "0"
    }
  ],
  "rereg_stat": 1,
  "conf_rereg_stat": {
    "1": "REGISTERED",
    "2": "NOT REQUIRED",
    "3": "BLOCKED",
    "4": "NOT REGISTERED",
    "5": "NOT APPLICABLE",
    "6": "NO IDEA",
    "7": "NOT CONTINUE"
  },
  "parent_data": { ... },
  "parent": { ... },
  "status": true,
  "message": "Student Profile",
  "data": {
    "studcode": "3333",
    "fullname": "...",
    "ENTDATE": "12/02/2018",
    "class": "06",
    "section": "Q",
    "stud_stat": "1",
    "acdyear": "2025-2026",
    "ac_year_id": "25",
    "status_label": "Active",
    "status_shortcode": "Active",
    "status_colour": "0,255,0",
    "status_final_stat": "0",
    "student_reregistered": 1,
    "student_rereg_stat": "1",
    "student_rereg_label": "REGISTERED",
    "emirates_id": "...",
    "emirates_id_exp": "17/11/2031",
    "passno": "...",
    "pp_exp_date": "11/02/2024",
    "photo": "..."
  }
}
```

### 2. Students List API

**Endpoint:** `studentDetails` (list of students for a parent)

**Expected structure per student (additional fields):**

```json
{
  "studcode": "3333",
  "fullname": "...",
  "photo": "...",
  "status_label": "Active",
  "status_colour": "0,255,0",
  ...
}
```

---

## Model Changes

### 1. `StudentDetailModel` – Data Class

**File:** `lib/core/models/student_detail_model.dart`

| Field               | Type    | API Key               | Description                               |
|---------------------|---------|------------------------|-------------------------------------------|
| `statusLabel`       | String  | `status_label`         | Display label (e.g. "Active", "Fee Defaulter") |
| `statusShortcode`   | String  | `status_shortcode`     | Short code (e.g. "Active", "FD")          |
| `statusColour`      | String  | `status_colour`        | RGB string (e.g. "0,255,0")               |
| `statusFinalStat`   | String  | `status_final_stat`    | Final status indicator                    |
| `studentReregistered` | dynamic | `student_reregistered` | Re-registration value (int or null)       |
| `studentReregStat`  | String  | `student_rereg_stat`   | Re-registration status code               |
| `studentReregLabel` | String  | `student_rereg_label`  | Display label (e.g. "REGISTERED")         |

### 2. `StudentModel` (Students List)

**File:** `lib/core/models/students_model.dart`

| Field         | Type   | API Key        | Description                    |
|---------------|--------|----------------|--------------------------------|
| `statusLabel` | String | `status_label` | Status label for the student   |
| `statusColour`| String | `status_colour`| RGB string for status colour   |

Also updated: `lib/core/models/students_model.g.dart` (Hive adapter) to handle the new fields.

---

## UI Changes

### 1. Primary Details Section

**File:** `lib/views/components/basic_details_widget.dart`

- **Student Status** – Row showing `status_label` using the colour from `status_colour`
- **Re-registered** – Row showing `student_rereg_label` (e.g. "REGISTERED", "NOT REGISTERED")

Both rows are shown only when the corresponding data is present.

### 2. Document Details Section

**File:** `lib/views/components/document_details_widget.dart`

- **Emirates ID** and **Emirates ID Expiry** – Orange when expiring within 1 month, red when expired
- **Passport Number** and **Passport Expiry Date** – Same colour logic

### 3. Student Avatar Status Dots

**File:** `lib/views/components/slect_student.dart`

- Small status dot at the bottom-right of each student’s circle avatar
- Uses `status_colour` from the students list data
- Dot shows for every student whose data includes `status_colour`
- Uses the same students list API as name and photo, so no extra fetch is needed

---

## Utility Functions

**File:** `lib/core/utils/utils.dart`

### `parseRgbColor(String rgbString)`

Converts API colour strings to Flutter `Color`:

- Input examples: `"0,255,0"`, `"231, 139, 0"`
- Returns a Flutter `Color`
- Returns `Colors.black` for invalid or empty input

### `getDocumentExpiryStatus(String dateStr)`

Evaluates document expiry from `dd/mm/yyyy` strings:

- **Input:** Date string in `dd/mm/yyyy` (e.g. `"17/11/2031"`)
- **Output:** `DocumentExpiryStatus` enum:
  - `expired` – Date in the past
  - `expiringSoon` – Within 1 month from today
  - `valid` – Otherwise

---

## Component Modifications

### `ProfileTile` – Custom Value Colour

**File:** `lib/views/components/profile_tile.dart`

- Added optional `valueColor` for custom value text colour
- When set, overrides the default value colour
- Used for status labels and document expiry warnings

---

## Backend Requirements

### Student Profile API

- Must return `status_label`, `status_shortcode`, `status_colour`, `status_final_stat` in `data`
- Must return `student_reregistered`, `student_rereg_stat`, `student_rereg_label` in `data`

### Students List API

- Must return `status_label` and `status_colour` for each student in `data`
- Without these, status dots will not appear on avatars

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/core/models/student_detail_model.dart` | Added status and re-registration fields to `Data` |
| `lib/core/models/students_model.dart` | Added `statusLabel`, `statusColour` to `StudentModel` |
| `lib/core/models/students_model.g.dart` | Updated Hive adapter for new `StudentModel` fields |
| `lib/core/utils/utils.dart` | Added `parseRgbColor`, `getDocumentExpiryStatus`, `DocumentExpiryStatus` |
| `lib/views/components/profile_tile.dart` | Added optional `valueColor` parameter |
| `lib/views/components/basic_details_widget.dart` | Added Student Status and Re-registered rows |
| `lib/views/components/document_details_widget.dart` | Added document expiry colour logic |
| `lib/views/components/slect_student.dart` | Added status dot on avatars using students list data |

---

## Status Colour Reference (from API)

| Status | Shortcode | RGB Colour |
|--------|-----------|------------|
| Active | Active | 0,255,0 (Green) |
| New - Provision | New - Prov | 231, 139, 0 |
| Confirmed Provision | Conf - Pro | 22,122,35 |
| Cancellation | Cancel | 238,130,23 |
| Fee Defaulter | FD | 255,192,20 |
| Not Reported | NR | 135,155,12 |
| Transfer Certificate | TC | 255,0,0 (Red) |
| New | New | 0,0,255 (Blue) |
| Special Case | SC | 128,0,0 |
| Withdrawn | WD | 238,10,23 |

---

## Re-registration Status Reference

| ID | Label |
|----|-------|
| 1 | REGISTERED |
| 2 | NOT REQUIRED |
| 3 | BLOCKED |
| 4 | NOT REGISTERED |
| 5 | NOT APPLICABLE |
| 6 | NO IDEA |
| 7 | NOT CONTINUE |

---

*Document generated based on implementation completed in this session.*
