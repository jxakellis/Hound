const { apnLogger } = require('../../logging/loggers');

const { logServerError } = require('../../logging/logServerError');
const { formatArray, formatString } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const { apn, apnProvider } = require('./apnProvider');
const { getUserToken, getAllFamilyMemberTokens, getOtherFamilyMemberTokens } = require('./apnTokens');

/**
 * Creates a notification that is immediately sent to Apple Push Services and informs users
 * Takes an array of notificationTokens that identifies all the recipients of the notification
 * Takes a string that will be the title of the notification
 * Takes a string that will be the body of the notification
 */
// (token, category, sound, alertTitle, alertBody)
async function sendAPN(token, category, sound, alertTitle, alertBody, customPayload) {
  let castedAlertTitle = formatString(alertTitle);
  let castedAlertBody = formatString(alertBody);

  apnLogger.debug(`sendAPN ${token}, ${category}, ${sound}, ${castedAlertTitle}, ${castedAlertBody}`);

  // sound doesn't have to be defined, its optional
  if (areAllDefined(token, category, castedAlertTitle, castedAlertBody, customPayload) === false) {
    return;
  }

  castedAlertTitle = castedAlertTitle.substring(0, global.constant.apn.length.ALERT_TITLE);
  castedAlertBody = castedAlertBody.substring(0, global.constant.apn.length.ALERT_BODY);

  // the tokens array is defined and has at least one element

  const notification = new apn.Notification();

  // Properties are sent along side the payload and are defined by node-apn

  // App Bundle Id
  notification.topic = 'com.example.Pupotty';

  // A UNIX timestamp when the notification should expire. If the notification cannot be delivered to the device, APNS will retry until it expires
  // An expiry of 0 indicates that the notification expires immediately, therefore no retries will be attempted.
  notification.expiry = Math.floor(Date.now() / 1000) + 300;

  // The type of the notification. The value of this header is alert or background. Specify alert when the delivery of your notification displays an alert, plays a sound, or badges your app's icon. Specify background for silent notifications that do not interact with the user.
  // The value of this header must accurately reflect the contents of your notification's payload. If there is a mismatch, or if the header is missing on required systems, APNs may delay the delivery of the notification or drop it altogether.
  notification.pushType = 'alert';

  // Multiple notifications with same collapse identifier are displayed to the user as a single notification. The value should not exceed 64 bytes.
  // notification.collapseId = 1;

  /// Raw Payload takes after apple's definition of the APS body
  notification.rawPayload = {
    aps: {
      // The notification’s type
      // This string must correspond to the identifier of one of the UNNotificationCategory objects you register at launch time.
      category,
      // The background notification flag.
      // To perform a silent background update, specify the value 1 and don’t include the alert, badge, or sound keys in your payload.
      'content-available': 1,
      // The notification service app extension flag
      // If the value is 1, the system passes the notification to your notification service app extension before delivery.
      // Use your extension to modify the notification’s content.
      'mutable-content': 1,
      // A string that indicates the importance and delivery timing of a notification
      // The string values “passive”, “active”, “time-sensitive”, or “critical” correspond to the
      'interruption-level': 'active',
      // alert Dictionary
      alert: {
        // The title of the notification. Apple Watch displays this string in the short look notification interface. Specify a string that’s quickly understood by the user.
        title: castedAlertTitle,
        // The content of the alert message.
        body: castedAlertBody,
      },
    },
  };

  // if there is a sound for the reminder alarm alert, then we add it to the rawPayload
  if (category === global.constant.apn.category.REMINDER && areAllDefined(sound, notification, notification.rawPayload, notification.rawPayload.aps)) {
    notification.rawPayload.aps.sound = `${sound}30.wav`;
  }

  // add customPayload into rawPayload
  notification.rawPayload = {
    ...customPayload,
    ...notification.rawPayload,
  };

  // aps Dictionary Keys
  // https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification#2943363

  // alert Dictionary Keys
  // https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification#2943365

  // sound Dictionary Keys
  // https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification#2990112

  apnProvider.send(notification, token)
    .then((response) => {
      // response.sent: Array of device tokens to which the notification was sent succesfully
      if (response.sent.length !== 0) {
        apnLogger.info(`sendAPN Response Successful: ${JSON.stringify(response.sent)}`);
      }
      // response.failed: Array of objects containing the device token (`device`) and either an `error`, or a `status` and `response` from the API
      if (response.failed.length !== 0) {
        apnLogger.info(`sendAPN Response Rejected: ${JSON.stringify(response.failed)}`);
      }
    })
    .catch((error) => {
      logServerError('sendAPN Response', error);
    });
}

/**
* Takes a userId and retrieves the userNotificationToken for the user
* Invokes sendAPN with the tokens, alertTitle, and alertBody
*/
async function sendAPNForUser(userId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendAPNForUser ${userId}, ${category}, ${alertTitle}, ${alertBody}, ${customPayload}`);

  if (areAllDefined(userId) === false) {
    return;
  }

  try {
    // get tokens of all qualifying family members that aren't the user
    const tokenAndSounds = formatArray(await getUserToken(userId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendAPNForUser', error);
  }
}

/**
 * Takes a familyId and retrieves the userNotificationToken for all familyMembers
 * Invokes sendAPN with the tokens, alertTitle, and alertBody
 */
async function sendAPNForFamily(familyId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendAPNForFamily ${familyId}, ${category}, ${alertTitle}, ${alertBody}, ${customPayload}`);

  try {
    // get notification tokens of all qualifying family members
    const tokenAndSounds = formatArray(await getAllFamilyMemberTokens(familyId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendAPNForFamily', error);
  }
}

/**
 * Takes a familyId and retrieves the userNotificationToken for all familyMembers (excluding the userId provided)
 * Invokes sendAPN with the tokens, alertTitle, and alertBody
 */
async function sendAPNForFamilyExcludingUser(userId, familyId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendAPNForFamilyExcludingUser ${userId}, ${familyId}, ${category}, ${alertTitle}, ${alertBody}, ${customPayload}`);

  try {
    // get tokens of all qualifying family members that aren't the user
    const tokenAndSounds = formatArray(await getOtherFamilyMemberTokens(userId, familyId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendAPNForFamilyExcludingUser', error);
  }
}

module.exports = {
  sendAPNForUser, sendAPNForFamily, sendAPNForFamilyExcludingUser,
};
