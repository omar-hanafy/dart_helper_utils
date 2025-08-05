/// A list of Greek number suffixes used for large numbers representation.
///
/// The suffixes are used to denote large values such as thousands, millions,
/// billions, and beyond.
const greekNumberSuffixes = <String>[
  'K', // Thousand represents 1000
  'M', // Million represents 1000000
  'B', // Billion represents 1000000000
  'T', // Trillion represents 1000000000000
  'Q', // Quadrillion represents 1000000000000000
  'P', // Quintillion represents 1000000000000000000
  'E', // Exa represents 1000000000000000000000
  'Z', // Zetta represents 1000000000000000000000000
  'Y', // Yotta represents 1000000000000000000000000000
];

/// A map of integers to Roman numeral representations.
///
/// This map is used to convert integers into their corresponding Roman numeral forms.
const romanNumerals = <int, String>{
  1: 'I', // One
  2: 'II', // Two
  3: 'III', // Three
  4: 'IV', // Four
  5: 'V', // Five
  6: 'VI', // Six
  7: 'VII', // Seven
  8: 'VIII', // Eight
  9: 'IX', // Nine
  10: 'X', // Ten
  11: 'XI', // Eleven
  12: 'XII', // Twelve
  13: 'XIII', // Thirteen
  14: 'XIV', // Fourteen
  15: 'XV', // Fifteen
  20: 'XX', // Twenty
  30: 'XXX', // Thirty
  40: 'XL', // Forty
  50: 'L', // Fifty
  60: 'LX', // Sixty
  70: 'LXX', // Seventy
  90: 'XC', // Ninety
  99: 'IC', // Ninety-Nine (rarely used; common alternative is XCIX)
  100: 'C', // One Hundred
  200: 'CC', // Two Hundred
  400: 'CD', // Four Hundred
  500: 'D', // Five Hundred
  600: 'DC', // Six Hundred
  900: 'CM', // Nine Hundred
  990: 'XM', // Nine Hundred Ninety (non-standard; commonly use CMXC)
  1000: 'M', // One Thousand
};

/// A map of integers to abbreviated weekday names.
const smallWeekdays = <int, String>{
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

/// A map of integers to full weekday names.
const fullWeekdays = <int, String>{
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
};

/// A map of integers to abbreviated month names.
const smallMonthsNames = <int, String>{
  1: 'Jan',
  2: 'Feb',
  3: 'Mar',
  4: 'Apr',
  5: 'May',
  6: 'Jun',
  7: 'Jul',
  8: 'Aug',
  9: 'Sep',
  10: 'Oct',
  11: 'Nov',
  12: 'Dec',
};

/// A map of integers to full month names.
const fullMonthsNames = <int, String>{
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

/// Common time-related durations defined as constants.
/// oneSecond
const Duration oneSecond = Duration(seconds: 1);

/// oneMinute
const Duration oneMinute = Duration(minutes: 1);

/// oneHour
const Duration oneHour = Duration(hours: 1);

/// oneDay
const Duration oneDay = Duration(days: 1);

/// Milliseconds constants for different time units.
/// millisecondsPerSecond
const millisecondsPerSecond = 1000;

/// millisecondsPerMinute
const int millisecondsPerMinute = 60 * millisecondsPerSecond;

/// millisecondsPerHour
const int millisecondsPerHour = 60 * millisecondsPerMinute;

/// millisecondsPerDay
const int millisecondsPerDay = 24 * millisecondsPerHour;

/// Common regex patterns used for validation and parsing.
/// regexAlphanumeric
const String regexAlphanumeric = r'^[a-zA-Z0-9]+$';

/// regexSpecialChars
const String regexSpecialChars = '[^a-zA-Z0-9 ]';

/// regexStartsWithNumber
const String regexStartsWithNumber = r'^\d';

/// regexContainsDigits
const String regexContainsDigits = r'\d';

/// regexValidUsername
const String regexValidUsername = r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$';

/// regexValidCurrency
const String regexValidCurrency =
    r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R\$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$';

/// regexValidPhoneNumber
const String regexValidPhoneNumber =
    r'(\+\d{1,3}\s?)?((\(\d{3}\)\s?)|(\d{3})(\s|-?))(\d{3}(\s|-?))(\d{4})(\s?(([E|e]xt[:|.|]?)|x|X)(\s?\d+))?';

/// regexValidEmail
const String regexValidEmail =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

/// regexValidIp4
const String regexValidIp4 =
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';

/// regexValidIp6
const String regexValidIp6 =
    r'/(?<protocol>(?:http|ftp|irc)s?:\/\/)?(?:(?<user>[^:\n\r]+):(?<pass>[^@\n\r]+)@)?(?<host>(?:www\.)?(?:[^:\/\n\r]+)(?::(?<port>\d+))?)\/?(?<request>[^?#\n\r]+)?\??(?<query>[^#\n\r]*)?\#?(?<anchor>[^\n\r]*)?/';

/// regexValidUrl
const String regexValidUrl =
    r'''^((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))+$''';

/// regexNumeric
const String regexNumeric = r'^\d+$';

/// regexAlphabet
const String regexAlphabet = r'^[a-zA-Z]+$';

/// regexHasCapitalLetter
const String regexHasCapitalLetter = '[A-Z]';

/// A map of HTTP status codes to their corresponding messages.
///
/// This map provides a quick reference for HTTP status codes and their standard
/// messages used in API responses.
Map<int, String> get httpStatusMessages => const {
      100: 'Continue',
      101: 'Switching Protocols',
      102: 'Processing',
      103: 'Early Hints',
      200: 'OK',
      201: 'Created',
      202: 'Accepted',
      203: 'Non-Authoritative Information',
      204: 'No Content',
      205: 'Reset Content',
      206: 'Partial Content',
      207: 'Multi-Status',
      208: 'Already Reported',
      226: 'IM Used',
      300: 'Multiple Choices',
      301: 'Moved Permanently',
      302: 'Found',
      303: 'See Other',
      304: 'Not Modified',
      305: 'Use Proxy',
      306: 'Switch Proxy',
      307: 'Temporary Redirect',
      308: 'Permanent Redirect',
      400: 'Bad Request',
      401: 'Unauthorized',
      402: 'Payment Required',
      403: 'Forbidden',
      404: 'Not Found',
      405: 'Method Not Allowed',
      406: 'Not Acceptable',
      407: 'Proxy Authentication Required',
      408: 'Request Timeout',
      409: 'Conflict',
      410: 'Gone',
      411: 'Length Required',
      412: 'Precondition Failed',
      413: 'Payload Too Large',
      414: 'URI Too Long',
      415: 'Unsupported Media Type',
      416: 'Range Not Satisfiable',
      417: 'Expectation Failed',
      418: "I'm a Teapot",
      421: 'Misdirected Request',
      422: 'Unprocessable Entity',
      423: 'Locked',
      424: 'Failed Dependency',
      425: 'Too Early',
      426: 'Upgrade Required',
      428: 'Precondition Required',
      429: 'Too Many Requests',
      431: 'Request Header Fields Too Large',
      451: 'Unavailable For Legal Reasons',
      499: 'Client Closed Request',
      500: 'Internal Server Error',
      501: 'Not Implemented',
      502: 'Bad Gateway',
      503: 'Service Unavailable',
      504: 'Gateway Timeout',
      505: 'HTTP Version Not Supported',
      506: 'Variant Also Negotiates',
      507: 'Insufficient Storage',
      508: 'Loop Detected',
      510: 'Not Extended',
      511: 'Network Authentication Required',
      599: 'Network Connect Timeout Error',
    };

/// A map of HTTP status codes to user-friendly messages.
///
/// This map provides easy-to-understand explanations of HTTP status codes
/// that can be shown to end users in error messages and notifications.
Map<int, String> get httpStatusUserMessage => const {
// 1xx - Informational
      100: 'Please wait while we process your request...',
      101: 'Switching to a different protocol...',
      102: 'Your request is being processed...',
      103: 'Getting things ready...',

// 2xx - Success
      200: 'Success! Everything worked as expected.',
      201:
          'Success! Your request has been completed and a new resource was created.',
      202: 'Your request has been accepted and is being processed.',
      203: 'Request successful, but some information might have been modified.',
      204: "The request was successful, but there's nothing to show.",
      205: 'Please refresh your page to see the changes.',
      206: 'Showing partial content as requested.',
      207: 'Multiple operations completed with different results.',
      208: 'This information was already reported earlier.',
      226:
          'Your request was successful and the response has been modified for efficiency.',

// 3xx - Redirection
      300: 'Multiple options are available. Please choose one.',
      301: 'This page has been permanently moved to a new location.',
      302: 'This page has been temporarily moved to a different location.',
      303: 'Please check another page for the response to your request.',
      304: 'Nothing has changed since your last visit.',
      305: 'You need to use a proxy to access this resource.',
      306: 'This code is no longer used but reserved for future use.',
      307: 'This page is temporarily at a different address. Please try again.',
      308:
          'This page has been permanently moved. Please update your bookmarks.',

// 4xx - Client Errors
      400: 'Oops! There seems to be a problem with your request.',
      401: 'Please log in to access this content.',
      402: 'Payment is required to access this content.',
      403: "Sorry, you don't have permission to access this.",
      404: "Sorry, we couldn't find what you're looking for.",
      405: 'This type of request is not allowed here.',
      406: 'The requested format is not available.',
      407: 'Please authenticate with the proxy server first.',
      408: 'The request took too long. Please try again.',
      409: 'There was a conflict with your request. Please try again.',
      410: 'Sorry, this content has been permanently removed.',
      411: 'Please specify the length of the content in your request.',
      412: 'Some conditions for this request were not met.',
      413: "Sorry, the file you're trying to upload is too large.",
      414: 'The web address is too long. Please use a shorter URL.',
      415: 'This type of file is not supported.',
      416: 'The requested range of data is not available.',
      417: "Sorry, we couldn't meet the requirements for your request.",
      418:
          'This server is actually a teapot! (Yes, this is a real error code!)',
      421: 'Your request was sent to the wrong server.',
      422: "We couldn't process your request due to invalid information.",
      423: 'The requested resource is currently locked.',
      424: 'This request failed because another related request failed.',
      425: 'Please try again later to prevent potential issues.',
      426: 'You need to upgrade your client to access this resource.',
      428: 'Some required conditions were not provided.',
      429: "Please slow down! You're making too many requests.",
      431: 'Your request headers are too large.',
      451: 'Sorry, this content is not available for legal reasons.',
      499: 'The request was cancelled before completion.',

// 5xx - Server Errors
      500: 'Oops! Something went wrong on our end. Please try again later.',
      501: 'Sorry, this feature is not available yet.',
      502:
          "We're having trouble connecting to our servers. Please try again later.",
      503: 'Our service is temporarily unavailable. Please try again later.',
      504: 'The server took too long to respond. Please try again.',
      505: "Your browser's HTTP version is not supported.",
      506: 'We encountered an issue while negotiating content types.',
      507: "We've run out of storage space to complete your request.",
      508: 'We detected an infinite loop while processing your request.',
      510: 'The server needs additional extensions to fulfill this request.',
      511: 'Please authenticate with the network first.',
      599:
          'Unable to connect to the server. Please check your internet connection.',
    };

/// A map of HTTP status codes to detailed technical messages.
///
/// This map provides in-depth technical explanations of HTTP status codes
/// intended for developers, including common causes and troubleshooting hints.
Map<int, String> get httpStatusDevMessage => const {
      // 1xx - Informational
      100:
          'Client should continue with request. Server received request headers and client should proceed with body.',
      101:
          'Server is switching protocols as requested by client Upgrade header.',
      102:
          'Server received and is processing request, but no response is available yet.',
      103:
          'Server is likely to send a final response with the headers included in this interim response.',

      // 2xx - Success
      200: 'Request successfully processed. Response includes payload.',
      201:
          'Resource successfully created. Response includes Location header or payload with resource URI.',
      202:
          'Request accepted for processing but not completed. Processing may occur asynchronously.',
      203:
          'Request processed via proxy that modified the underlying response data.',
      204:
          'Request processed successfully but response intentionally empty. Common for DELETE operations.',
      205:
          'Request processed. Client should reset document view. No response payload.',
      206: 'Partial content delivered as per Range header requirements.',
      207: 'Multi-Status response. Payload contains XML MultiStatus (WebDAV).',
      208:
          'DAV binding member already enumerated in previous part of (207) Multi-Status.',
      226: 'Server fulfilled GET request, response is delta encoding result.',

      // 3xx - Redirection
      300:
          'Multiple representations available. Respond to Accept header or provide choice.',
      301:
          'Resource permanently moved. Update all references to new Location header URI.',
      302:
          'Resource temporarily moved. Maintain original URI for future requests.',
      303:
          'Response found at different URI. Use GET for redirect regardless of original method.',
      304:
          'Resource not modified since timestamp or ETag in conditional request.',
      305:
          'Resource must be accessed through proxy in Location header (deprecated).',
      306:
          'Status code reserved for future use. Originally meant "Switch Proxy".',
      307:
          'Resource temporarily moved. Maintain method and payload for redirect.',
      308:
          'Resource permanently moved. Maintain method and payload for redirect.',

      // 4xx - Client Errors

      400:
          'Malformed request syntax, invalid request message framing, or deceptive request routing.',
      401:
          'Request lacks valid authentication credentials. Check Authorization header.',
      402:
          'Payment required. Reserved for future use. Check API documentation.',
      403:
          "Server understood request but refuses to authorize. Authentication won't help.",
      404: 'Resource not found at this location. Check URI path and method.',
      405:
          'HTTP method not allowed for resource. Check Allow header for valid methods.',
      406: 'Resource cannot generate response matching Accept headers.',
      407: 'Proxy authentication required. Check Proxy-Authenticate header.',
      408: 'Server timed out waiting for complete request from client.',
      409:
          'Request conflicts with current resource state. Common in PUT/POST/DELETE.',
      410: 'Resource permanently removed. Similar to 404 but more definitive.',
      411: 'Content-Length header required. Check request headers.',
      412:
          'Precondition in headers failed. Check If-Match/If-None-Match/If-Modified-Since.',
      413:
          'Request payload larger than server willing to process. Check Content-Length.',
      414: 'Request URI longer than server will interpret. Shorten URI.',
      415: 'Media type in Content-Type or Content-Encoding not supported.',
      416: 'Range header value invalid for resource. Check Content-Range.',
      417: 'Expectation in Expect header cannot be met by server.',
      418: 'Request refused - server is a teapot 🫖.',
      421:
          'Request directed to server unable to produce response. Check Host header.',
      422: 'Request well-formed but semantically invalid. Common in WebDAV.',
      423: 'Resource locked. Check WebDAV lock-token header.',
      424: 'Request failed due to failure of previous request (WebDAV).',
      425:
          'Server unwilling to risk processing request that might be replayed.',
      426: 'Client should upgrade to required protocol. Check Upgrade header.',
      428: 'Precondition Required. Request should be conditional.',
      429: 'Too Many Requests. Check Rate-Limit headers and implement backoff.',
      431: 'Request header fields too large. Reduce header size.',
      451: 'Resource unavailable for legal reasons. May include explanation.',
      499: 'Client closed connection before server finished response.',

      // 5xx - Server Errors
      500:
          'Server encountered unexpected condition preventing request fulfillment.',
      501: 'Server does not support functionality required to fulfill request.',
      502:
          'Invalid response received from upstream server while acting as gateway.',
      503:
          'Server temporarily unable to handle request due to overload or maintenance.',
      504: 'Gateway timeout waiting for response from upstream server.',
      505: 'HTTP version in request not supported by server.',
      506: 'Server has internal configuration error with content negotiation.',
      507: 'Server unable to store representation needed to complete request.',
      508: 'Server detected infinite loop while processing WebDAV request.',
      510: 'Further extensions to request required for server to fulfill it.',
      511: 'Client needs to authenticate to gain network access.',
      599:
          'Network connection timeout error occurred while server processing request.',
    };
