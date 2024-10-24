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
const Duration oneSecond = Duration(seconds: 1);
const Duration oneMinute = Duration(minutes: 1);
const Duration oneHour = Duration(hours: 1);
const Duration oneDay = Duration(days: 1);

/// Milliseconds constants for different time units.
const millisecondsPerSecond = 1000;
const millisecondsPerMinute = 60 * millisecondsPerSecond;
const millisecondsPerHour = 60 * millisecondsPerMinute;
const millisecondsPerDay = 24 * millisecondsPerHour;

/// Common regex patterns used for validation and parsing.
const String regexAlphanumeric = r'^[a-zA-Z0-9]+$';
const String regexSpecialChars = '[^a-zA-Z0-9 ]';
const String regexStartsWithNumber = r'^\d';
const String regexContainsDigits = r'\d';
const String regexValidUsername = r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$';
const String regexValidCurrency =
    r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R\$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$';
const String regexValidPhoneNumber =
    r'(\+\d{1,3}\s?)?((\(\d{3}\)\s?)|(\d{3})(\s|-?))(\d{3}(\s|-?))(\d{4})(\s?(([E|e]xt[:|.|]?)|x|X)(\s?\d+))?';
const String regexValidEmail =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
const String regexValidIp4 =
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';
const String regexValidIp6 =
    r'/(?<protocol>(?:http|ftp|irc)s?:\/\/)?(?:(?<user>[^:\n\r]+):(?<pass>[^@\n\r]+)@)?(?<host>(?:www\.)?(?:[^:\/\n\r]+)(?::(?<port>\d+))?)\/?(?<request>[^?#\n\r]+)?\??(?<query>[^#\n\r]*)?\#?(?<anchor>[^\n\r]*)?/';
const String regexValidUrl =
    r'''^((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))+$''';
const String regexNumeric = r'^\d+$';
const String regexAlphabet = r'^[a-zA-Z]+$';
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
