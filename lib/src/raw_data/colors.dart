/// A map of CSS color names to their corresponding ARGB values.
/// Usage could be like with Color class: Color(cssColorNamesToArgb['red'])
const cssColorNamesToArgb = <String, int>{
  'black': 0xFF000000,
  'white': 0xFFFFFFFF,
  'red': 0xFFFF0000,
  'lime': 0xFF00FF00,
  'green': 0xFF008000,
  'blue': 0xFF0000FF,
  'yellow': 0xFFFFFF00,
  'cyan': 0xFF00FFFF,
  'magenta': 0xFFFF00FF,
  'silver': 0xFFC0C0C0,
  'gray': 0xFF808080,
  'maroon': 0xFF800000,
  'olive': 0xFF808000,
  'purple': 0xFF800080,
  'teal': 0xFF008080,
  'navy': 0xFF000080,
  'orange': 0xFFFFA500,
  'pink': 0xFFFFC0CB,
  'brown': 0xFFA52A2A,
  'violet': 0xFFEE82EE,
  'gold': 0xFFFFD700,
  'indigo': 0xFF4B0082,
  'khaki': 0xFFF0E68C,
  'coral': 0xFFFF7F50,
  'aquamarine': 0xFF7FFFD4,
  'turquoise': 0xFF40E0D0,
  'lavender': 0xFFE6E6FA,
  'tan': 0xFFD2B48C,
  'salmon': 0xFFFA8072,
  'plum': 0xFFDDA0DD,
  'orchid': 0xFFDA70D6,
  'chocolate': 0xFFD2691E,
  'tomato': 0xFFFF6347,
  'crimson': 0xFFDC143C,
  'transparent': 0x00000000,
  'aliceblue': 0xFFF0F8FF,
  // (Additional named colors could be added here in the feature.)
};

/// Validates hex color strings in various formats (CSS-style or `0x` prefixed).
///
/// Supported formats (with optional `#` or `0x` prefix):
/// * 3 digits: RGB  → #RGB / 0xRGB (e.g., #123 → #112233)
/// * 4 digits: RGBA → #RGBA / 0xRGBA (e.g., 0x1234 → #11223344)
/// * 6 digits: RRGGBB → #FF00FF / 0xFF00FF
/// * 8 digits: RRGGBBAA → #FF00FF80 / 0xFF00FF80
///
/// Examples:
/// - Valid: "#123", "0xabc", "#FF00FF", "0x80808080", "a1b"
/// - Invalid: "12", "0x12345", "#ghijk", "0xXYZ"
///
/// NOTE: This regex is case-sensitive by default (only `0x` prefix and
/// lowercase hex digits match without flags). For case-insensitive matching:
/// ```dart
/// RegExp(
///   regexValidHexColor,
///   caseSensitive: false,
/// ).hasMatch('0XFF00ff'); // true (uppercase prefix + mixed case)
/// ```
const String regexValidHexColor =
    r'^(?:0x|#)?(?:[0-9a-f]{3}|[0-9a-f]{4}|[0-9a-f]{6}|[0-9a-f]{8})$';

const _intPattern = r'(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)';
const _percentPattern = r'(?:100|[1-9]?\d)%';

/// A regular expression pattern that matches whitespace-flexible comma separators.
/// This pattern is designed to handle the standard format of CSS color functions
/// like rgb(), rgba(), hsl(), etc.
///
/// Pattern breakdown:
/// - `\s*` : Zero or more whitespace characters before the comma
/// - `,`   : Required comma separator
/// - `\s*` : Zero or more whitespace characters after the comma
///
/// Examples of matching patterns:
/// - `,`      => matches
/// - ` , `    => matches
/// - `  ,  `  => matches
/// - `\t,\n`  => matches
/// - `;`      => doesn't match
/// - `  `     => doesn't match
///
/// Usage in color functions:
/// ```dart
/// // In rgb() function
/// "rgb(255, 128, 0)"      // matches
/// "rgb(255,128,0)"        // matches
/// "rgb(255  ,  128,  0)"  // matches
/// ```
const regexComponentSeparator = r'\s*,\s*';

/// Legacy rgb()/rgba() regex. (Note that if the function name is exactly "rgb("
/// then an alpha value is not allowed.)
const regexValidRgbColor = r'^rgba?\(\s*'
    '((?:$_intPattern|$_percentPattern))$regexComponentSeparator'
    '((?:$_intPattern|$_percentPattern))$regexComponentSeparator'
    '((?:$_intPattern|$_percentPattern))'
    '(?:$regexComponentSeparator'
    r'((?:1(?:\.0+)?|0?\.\d+|0|'
    '$_percentPattern)))?'
    r'\s*\)$';

/// Legacy hsl()/hsla() regex - updated to handle all valid space combinations
/// and Allow zero or more spaces before and after the comma.
const regexValidHslColor = r'^hsla?\s*\(\s*'
    r'([0-9]+(?:\.[0-9]+)?(?:deg|rad|turn|grad)?)'
    '$regexComponentSeparator'
    '((?:100|[0-9]{1,2})%)'
    '$regexComponentSeparator'
    '((?:100|[0-9]{1,2})%)'
    r'(?:,\s*((?:0?\.\d+|1|0)))?'
    r'\s*\)$';

/// Modern color function regex – it now outright disallows any commas inside the parentheses.
const regexValidModernColorFunc =
    r'^(?:(?:rgb|hsl|hwb|lab|lch)a?|color)\(\s*([^,]+)\s*\)$';
