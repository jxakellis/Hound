const { areAllDefined } = require('./validateDefined');

// Returned string with whitespaces and new lines removed. If parameter is not a string, returns undefined
function formatName(string) {
  if (typeof string !== 'string') {
    return undefined;
  }
  // removes whitespaces and newLines from beginning / end of string
  return string.trim();
}

function formatIntoFullName(userFirstName, userLastName) {
  // TO DO add int parameter for existing message length. APN have a limited length for their messages
  // If the name is too long, them important parts of the APN message could be cut off
  // Therefore, we pass through the existing message length, then we limit the size of the fullName returned
  // So, fullName.length + existingMessage.length <= maxiumumLengthOfAPNBody / maxiumumLengthOfAPNTitle
  const trimmedFirstName = formatName(userFirstName);
  const trimmedLastName = formatName(userLastName);

  if ((areAllDefined(trimmedFirstName) === false || trimmedFirstName === '') && (areAllDefined(trimmedLastName) === false || trimmedLastName === '')) {
    return 'No Name';
  }
  // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
  if (areAllDefined(trimmedFirstName) === false && trimmedFirstName === '') {
    // no first name but has last name
    return trimmedLastName;
  }
  if (areAllDefined(trimmedLastName) === false && trimmedLastName === '') {
    // no last name but has first name
    return trimmedFirstName;
  }

  return `${trimmedFirstName} ${trimmedLastName}`;
}

function formatIntoAbreviatedFullName(userFirstName, userLastName) {
  // TO DO add int parameter for existing message length. APN have a limited length for their messages
  // If the name is too long, them important parts of the APN message could be cut off
  // Therefore, we pass through the existing message length, then we limit the size of the abreviatedFullName returned
  // So, abreviatedFullName.length + existingMessage.length <= maxiumumLengthOfAPNBody / maxiumumLengthOfAPNTitle
  const trimmedFirstName = formatName(userFirstName);
  const trimmedLastName = formatName(userLastName);

  if ((areAllDefined(trimmedFirstName) === false || trimmedFirstName === '') && (areAllDefined(trimmedLastName) === false || trimmedLastName === '')) {
    return 'No Name';
  }
  // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
  if (areAllDefined(trimmedFirstName) === false && trimmedFirstName === '') {
    // no first name but has last name
    return trimmedLastName;
  }
  if (areAllDefined(trimmedLastName) === false && trimmedLastName === '') {
    // no last name but has first name
    return trimmedFirstName;
  }

  return `${trimmedFirstName} ${trimmedLastName.charAt(0)}`;
}

function formatLogAction(logAction, logCustomActionName) {
  if (areAllDefined(logAction) === false) {
    return undefined;
  }

  switch (logAction) {
    case 'Feed':
      return `${logAction} 🍗`;
    case 'Fresh Water':
      return `${logAction} 💧`;
    case 'Treat':
      return `${logAction} 🦴`;
    case 'Potty: Pee':
      return `${logAction} 💦`;
    case 'Potty: Poo':
      return `${logAction} 💩`;
    case 'Potty: Both':
      return `${logAction} 💦💩`;
    case "Potty: Didn't Go":
      return `${logAction} 💦`;
    case 'Accident':
      return `${logAction} ⚠️`;
    case 'Walk':
      return `${logAction} 🦮`;
    case 'Brush':
      return `${logAction} 💈`;
    case 'Bathe':
      return `${logAction} 🛁`;
    case 'Medicine':
      return `${logAction} 💊`;
    case 'Wake Up':
      return `${logAction} ☀️`;
    case 'Sleep':
      return `${logAction} 💤`;
    case 'Crate':
      return `${logAction} 🏡`;
    case 'Training Session':
      return `${logAction} 🐾`;
    case 'Doctor Visit':
      return `${logAction} 🩺`;
    case 'Custom':
      // check to make sure logCustomActionName is defined, is string, and isn't just a blank string (e.g. '      ')
      if (areAllDefined(logCustomActionName) === false || typeof logCustomActionName !== 'string' || logCustomActionName.trim() === '') {
        return `${logAction} 📝`;
      }
      return logCustomActionName;
    default:
      return undefined;
  }
}

function formatReminderAction(reminderAction, reminderCustomActionName) {
  if (areAllDefined(reminderAction) === false) {
    return undefined;
  }

  switch (reminderAction) {
    case 'Feed':
      return `${reminderAction} 🍗`;
    case 'Fresh Water':
      return `${reminderAction} 💧`;
    case 'Potty':
      return `${reminderAction} 💦💩`;
    case 'Walk':
      return `${reminderAction} 🦮`;
    case 'Brush':
      return `${reminderAction} 💈`;
    case 'Bathe':
      return `${reminderAction} 🛁`;
    case 'Medicine':
      return `${reminderAction} 💊`;
    case 'Sleep':
      return `${reminderAction} 💤`;
    case 'Training Session':
      return `${reminderAction} 🐾`;
    case 'Doctor Visit':
      return `${reminderAction} 🩺`;
    case 'Custom':
      // check to make sure reminderCustomActionName is defined, is string, and isn't just a blank string (e.g. '      ')
      if (areAllDefined(reminderCustomActionName) === false || typeof reminderCustomActionName !== 'string' || reminderCustomActionName.trim() === '') {
        return `${reminderAction} 📝`;
      }
      return reminderCustomActionName;
    default:
      return undefined;
  }
}

module.exports = {
  formatIntoFullName, formatIntoAbreviatedFullName, formatLogAction, formatReminderAction,
};
