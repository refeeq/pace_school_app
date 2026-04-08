# FCM Topics Backend Integration Guide

## Overview

The mobile app now automatically subscribes to FCM topics provided in the `studentDetails` API response. This enables efficient broadcast notifications without sending individual messages to each device token.

## API Response Format

The `studentDetails` endpoint should include a `topics` array at the root level:

```json
{
  "status": true,
  "message": "Student List",
  "data": [...],
  "parent": {...},
  "topics": [
    "fam_2709",
    "stud_3333",
    "stud_5555"
  ]
}
```

### Topic Naming Convention

- **Family-level topics**: `fam_{famcode}` - e.g., `fam_2709`
  - Used to notify all devices associated with a family (all children)
  
- **Student-level topics**: `stud_{studcode}` - e.g., `stud_3333`, `stud_5555`
  - Used to notify devices for a specific student only

- **Future group topics** (can be added without app updates):
  - `grade_{class}` - e.g., `grade_06`, `grade_10`
  - `area_{area_name}` - e.g., `area_dubai`, `area_abu_dhabi`
  - `section_{section}` - e.g., `section_A`, `section_B`
  - Any combination that makes sense for your filtering needs

### Topic Name Rules

- Must be lowercase
- Can contain: letters, numbers, underscores, hyphens, dots, tildes, percent signs
- Max length: 140 characters
- Examples of valid names: `fam_2709`, `stud_3333`, `grade_06`, `area_dubai`

## Sending Notifications via FCM

### Prerequisites

- Use Firebase Admin SDK on your backend
- Have FCM server key or service account credentials configured

### Method 1: Send to Single Topic

**Notify entire family:**
```php
$message = [
    'topic' => 'fam_2709',
    'notification' => [
        'title' => 'Important Announcement',
        'body' => 'This is a message for your family',
    ],
    'data' => [
        'click_action' => 'NOTIFICATION',
        // ... other data fields
    ],
];
$firebase->send($message);
```

**Notify specific student:**
```php
$message = [
    'topic' => 'stud_3333',
    'notification' => [
        'title' => 'Student-Specific Update',
        'body' => 'This message is for student 3333 only',
    ],
    'data' => [
        'click_action' => 'COMMUNICATION',
        'studcode' => '3333',
    ],
];
$firebase->send($message);
```

### Method 2: Send to Multiple Topics (Conditional)

Use FCM conditions to target devices subscribed to multiple topics:

**Notify multiple students:**
```php
$message = [
    'condition' => "'stud_3333' in topics || 'stud_5555' in topics",
    'notification' => [
        'title' => 'Group Message',
        'body' => 'This message goes to students 3333 and 5555',
    ],
    'data' => [
        'click_action' => 'NOTIFICATION',
    ],
];
$firebase->send($message);
```

**Notify Grade 6 students in Dubai:**
```php
$message = [
    'condition' => "'grade_06' in topics && 'area_dubai' in topics",
    'notification' => [
        'title' => 'Grade 6 Dubai Students',
        'body' => 'Special announcement for Grade 6 students in Dubai',
    ],
    'data' => [
        'click_action' => 'NOTIFICATION',
    ],
];
$firebase->send($message);
```

### FCM Condition Limits

- Maximum **5 different topics** per condition
- Condition string must be **≤ 2000 characters**
- Supported operators: `&&` (AND), `||` (OR), `()` (parentheses)
- Syntax: `"'topic_name' in topics"`

**Valid condition examples:**
```
"'stud_3333' in topics || 'stud_5555' in topics"
"('grade_06' in topics || 'grade_07' in topics) && 'area_dubai' in topics"
"'fam_2709' in topics && 'grade_06' in topics"
```

### Method 3: Send Multiple Separate Messages

If you need to notify many individual topics, you can send separate messages:

```php
$topics = ['stud_3333', 'stud_5555', 'stud_7777'];
$messageTemplate = [
    'notification' => [
        'title' => 'Individual Message',
        'body' => 'Personalized content',
    ],
    'data' => [
        'click_action' => 'NOTIFICATION',
    ],
];

foreach ($topics as $topic) {
    $message = $messageTemplate;
    $message['topic'] = $topic;
    $firebase->send($message);
}
```

## Deep Linking: click_action and data Payload

When the user **taps** the notification, the app uses `data.click_action` to decide which screen to open. All `data` values must be **strings**.

### 1. Open Notifications tab

```json
"data": {
  "click_action": "NOTIFICATION"
}
```

Opens the app and switches to the **Notifications** tab.

### 2. Open Communication tab (and optionally a specific chat)

```json
"data": {
  "click_action": "COMMUNICATION",
  "comm_type_id": "1",
  "studcode": "3333"
}
```

- **studcode** (optional): Can be omitted if you send to a single student topic (e.g. `stud_3333`); the app derives it from the topic or stored topics.
- **comm_type_id** (optional): Id of the chat type (e.g. Principal). If provided with studcode, opens that specific chat screen.

### 3. Open a student menu screen (e.g. Circular, Fee Statement)

Use this for notifications about a specific feature (e.g. new circular, fee reminder). Opens the app, selects the student (if provided), and opens the screen for that menu.

```json
"data": {
  "click_action": "MENU",
  "menu_key": "Circular",
  "studcode": "3333"
}
```

- **menu_key** (required): Must match the `menu_key` from your **student menu API**. Supported values (same as in the app’s student menu response):
  - `StudentProfile` – Student Profile  
  - `FeeStatement` – Fee Statement  
  - `PayFee` – Pay Fee  
  - `Attendance` – Attendance  
  - `LeaveApplication` – Leave  
  - `Circular` – Circular  
  - `Progress Report` – Progress Report  
  - `OpenHouse` – Open House  
  - `studTrack` – Student Tracking  
  - `internalWeb` – Internal web (e.g. Activity Fee); requires **url** in data  
  - `Library` – Library  
  - `SchoolInfo` – School Info  
  - (Other menu keys from your API can be added to the app later.)  

- **studcode** (optional): Student to select and for whom the menu is shown. If omitted, the app can derive it from the FCM topic (e.g. `stud_3333`) or use the first student in stored topics. For **general** (non–student-specific) notifications, omit studcode and send only `click_action` and `menu_key` if you still want to open a menu, or use `click_action: "NOTIFICATION"` to just open the Notifications tab.

- **url** (optional): Only for `menu_key: "internalWeb"`. The in-app web URL to open (e.g. Activity Fee page).

**Example: New circular for a specific student**

Send to topic `stud_3333`:

```json
{
  "message": {
    "topic": "stud_3333",
    "notification": {
      "title": "New Circular",
      "body": "A new circular has been published."
    },
    "data": {
      "click_action": "MENU",
      "menu_key": "Circular"
    }
  }
}
```

No `studcode` needed in `data` when sending to `stud_3333`; the app derives the student from the topic.

**Example: General announcement (no specific student)**

```json
"data": {
  "click_action": "NOTIFICATION"
}
```

Opens the app on the Notifications tab. No student selection.

## Use Cases

### 1. Broadcast to All Parents

**Option A**: If all parents subscribe to a common topic like `all_parents`:
```php
$message = ['topic' => 'all_parents', ...];
```

**Option B**: Send to all family topics (requires querying database for all famcodes):
```php
// Query all active family codes
$famcodes = getActiveFamilyCodes();
foreach ($famcodes as $famcode) {
    $message = ['topic' => "fam_$famcode", ...];
    $firebase->send($message);
}
```

### 2. Notify Specific Grade

Add `grade_06` to topics array for all Grade 6 students, then:
```php
$message = ['topic' => 'grade_06', ...];
```

### 3. Notify Specific Area

Add `area_dubai` to topics array for all Dubai-area families, then:
```php
$message = ['topic' => 'area_dubai', ...];
```

### 4. Notify Multiple Criteria (Combined)

Use conditions:
```php
$message = [
    'condition' => "'grade_06' in topics && 'area_dubai' in topics",
    ...
];
```

## Benefits

1. **Efficiency**: One API call to FCM instead of thousands of individual token calls
2. **Performance**: Faster delivery, lower backend load
3. **Scalability**: Handles millions of users without performance degradation
4. **Flexibility**: Easy to add new filtering criteria without app updates
5. **Cost**: Reduces API calls and server resources

## Migration Strategy

1. **Phase 1**: Backend starts including `topics` array in API response (can be empty initially)
2. **Phase 2**: App automatically subscribes to topics (already implemented)
3. **Phase 3**: Backend gradually migrates notifications from token-based to topic-based
4. **Phase 4**: Once fully migrated, remove individual token sending logic

## Testing

1. **Verify topic subscription**: Check app logs for successful topic subscriptions
2. **Test single topic**: Send notification to `fam_2709` and verify delivery
3. **Test conditions**: Send notification with condition and verify correct devices receive it
4. **Test unsubscription**: Logout and verify topics are unsubscribed

## Notes

- Topics are automatically subscribed when user logs in and student data is fetched
- Topics are automatically unsubscribed when user logs out
- If topics change between sessions, new topics will be subscribed on next fetch
- Topic subscription failures are logged but don't block app functionality
- The app gracefully handles missing or empty `topics` array in API response
