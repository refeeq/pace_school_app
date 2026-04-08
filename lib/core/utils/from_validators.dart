String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? messageValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Message is required';
  } else if (value.length < 10) {
    return 'Message must be at least 10 characters long';
  }
  return null;
}

String? nameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  } else if (value.length < 2) {
    return 'Name must be at least 2 characters long';
  } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Name can only contain letters and spaces';
  }
  return null;
}

String? phoneNumberValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  } else if (!RegExp(r"^\+?[0-9]{10,15}$").hasMatch(value)) {
    return 'Enter a valid phone number';
  }
  return null;
}
