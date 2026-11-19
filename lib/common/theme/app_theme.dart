import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trusttunnel/common/assets/asset_icons.dart';
import 'package:trusttunnel/common/assets/font_families.dart';
import 'package:trusttunnel/common/extensions/theme_extensions.dart';
import 'package:trusttunnel/widgets/custom_icon.dart';

class AppTheme {
  AppTheme(this.brightness);

  final Brightness brightness;

  Color _color(int light, int dark) => Color(brightness == Brightness.dark ? dark : light);

  // Each pair is the same role in light and dark mode.

  late final _accent = _color(0xFF3972AA, 0xFF8CC9FF);
  late final _accentHover = _color(0xFF336699, 0xFFA9D7FF);
  late final _accentPressed = _color(0xFF2D5986, 0xFF6DB7F4);
  late final _accentDisabled = _color(0x664F8AC4, 0x668CC9FF);

  late final _accentAdditional = _color(0xFF4F8AC4, 0xFF194969);

  late final _blend = _color(0x334F8AC4, 0x348CC9FF);
  late final _blendHover = _color(0x4D4F8AC4, 0x508CC9FF);
  late final _blendPressed = _color(0x664F8AC4, 0x668CC9FF);
  late final _attention = _color(0xFFF08400, 0xFFFFC271);
  late final _attentionHover = _color(0xFFE07400, 0xFFFFD39A);
  late final _attentionPressed = _color(0xFFC76300, 0xFFF6B45C);
  late final _attentionDisabled = _color(0x80FFA424, 0x80FFC271);
  late final _error = _color(0xFFF44725, 0xFFFFA99B);
  late final _errorHover = _color(0xFFE7320D, 0xFFFFC0B4);
  late final _errorPressed = _color(0xFFD02C0B, 0xFFF99484);
  late final _errorDisabled = _color(0x80F56447, 0x80FFA99B);
  late final _background = _color(0xFFFFFFFF, 0xFF10161D);
  late final _backgroundHover = _color(0xFFF6F7F9, 0xFF23313E);
  late final _backgroundPressed = _color(0xFFE6EAEF, 0xFF2B3A49);

  late final _neutralBlend = _color(0x1A30353B, 0x33C1D2E1);

  late final _backgroundAdditional = _color(0xFFF6F7F9, 0xFF19232D);
  late final _backgroundElevated = _color(0xFFFFFFFF, 0xFF202D39);
  late final _backgroundSystem = _color(0xFFE6EAEF, 0xFF1B2733);
  late final _backgroundSystemHover = _color(0xFFD1D8E0, 0xFF2A3948);
  late final _backgroundSystemPressed = _color(0xFFBFC8D4, 0xFF334558);
  late final _neutralLight = _color(0xFF9AA8B8, 0xFFB0C1D2);
  late final _neutralLightHover = _color(0xFF8997A9, 0xFFC1CFDD);
  late final _neutralLightPressed = _color(0xFF74869C, 0xFFCDD9E5);
  late final _neutralLightDisabled = _color(0x3330353B, 0x47B0C1D2);
  late final _neutralDark = _color(0xFF74869C, 0xFFA9BDD0);
  late final _neutralDarkHover = _color(0xFF5C6E84, 0xFFBBCDDE);
  late final _neutralDarkPressed = _color(0xFF465567, 0xFFCFDDEA);
  late final _neutralDarkDisabled = _color(0x4D30353B, 0x61A9BDD0);
  late final _neutralBlack = _color(0xFF333E4C, 0xFFEAF1F7);
  late final _neutralBlackHover = _color(0xFF242D38, 0xFFF4F8FB);
  late final _neutralBlackPressed = _color(0xFF1A2028, 0xFFFFFFFF);
  late final _neutralBlackDisabled = _color(0x6630353B, 0x66EAF1F7);
  static const _specialStaticWhite = Color(0xFFFFFFFF);
  static const _specialStaticWhiteHover = Color(0xFFF6F7F9);
  static const _specialStaticWhitePressed = Color(0xFFE6EAEF);
  static const _specialStaticWhiteDisabled = Color(0x80FFFFFF);
  late final _dumInputDecorationIdleColor = _color(0xFF73859D, 0xFFB0C1D2);

  // System colors
  static const _transparent = Colors.transparent;

  static const _macOSSystemTitleBarBackground = Color(0xFFFFFFFF);
  static const _macOSSystemTitleBarTitle = Color(0xFF3D3D3D);

  static const _windowsSystemTitleBarBackground = Color(0xFFE6EAEF);
  static const _windowsSystemTitleBarTitle = Color(0xFF3D3D3D);
  static const _windowsSystemTitleBarCloseButtonBackgroundHover = Color(0xFFE81123);
  static const _windowsSystemTitleBarCloseButtonBackgroundPressed = Color(0xFFC50F1F);
  static const _windowsSystemTitleBarCloseButtonForeground = Color(0xFFFFFFFF);
  static const _windowsSystemTitleBarTitleInactive = Color(0x993D3D3D);
  static const _windowsSystemTitleBarButtonBackgroundHover = Color(0x14000000);
  static const _windowsSystemTitleBarButtonBackgroundPressed = Color(0x29000000);

  // Legacy colors
  late final _primary1 = _color(0xFF67B279, 0xFF8BD5A1);
  late final _primary2 = _color(0xFF5B9F6B, 0xFF9FDDB1);
  late final _primary3 = _color(0xFF4E8C5D, 0xFFB2E8C2);
  late final _primary4 = _color(0xFFA2D0AD, 0xFF69BA84);
  late final _blend1 = _color(0xFFD9ECDE, 0xFF183527);
  late final _blend2 = _color(0xFFBEDFC6, 0xFF224733);
  late final _blend3 = _color(0xFFA2D0AD, 0xFF2F5940);
  late final _orange1 = _color(0xFFD58500, 0xFFFFC271);
  late final _orange2 = _color(0xFFC77901, 0xFFFFD39A);
  late final _orange3 = _color(0xFFB76C01, 0xFFF6B45C);
  late final _orange4 = _color(0xFFE5B460, 0xFFDDA65D);
  late final _red1 = _color(0xFFE9653A, 0xFFFFA99B);
  late final _red2 = _color(0xFFE75727, 0xFFFFC0B4);
  late final _red3 = _color(0xFFDC4918, 0xFFF99484);
  late final _red4 = _color(0xFFEF9071, 0xFFE6A194);
  late final _background1 = _color(0xFFFFFFFF, 0xFF10161D);
  late final _background2 = _color(0xFFF6F6F6, 0xFF19232D);
  late final _background3 = _color(0xFFE4E4E4, 0xFF2B3A49);
  late final _gray1 = _color(0xFFA4A4A4, 0xFFB0C1D2);
  late final _gray2 = _color(0xFF7F7F7F, 0xFFA9BDD0);
  late final _gray3 = _color(0xFF5B5B5B, 0xFFCAD7E3);
  late final _gray4 = _color(0xFFE4E4E4, 0xFF334558);
  late final _contrast1 = _color(0xFF3D3D3D, 0xFFEAF1F7);
  late final _contrast2 = _color(0xFF5B5B5B, 0xFFD2DEE9);
  late final _contrast3 = _color(0xFF7F7F7F, 0xFFBACBDD);
  late final _contrast4 = _color(0xFFA4A4A4, 0xFFA9BDCF);
  static const _staticBlack1 = Color(0xFF0A0A0A);
  static const _staticBlack2 = Color(0xFF1F1F1F);
  static const _staticBlack3 = Color(0xFF3D3D3D);
  static const _staticWhite = Color(0xFFF6F6F6);
  late final _purple1 = _color(0xFFA870B2, 0xFFDFB0EB);
  late final _purple2 = _color(0xFF9F61AA, 0xFFE8C4F1);
  late final _purple3 = _color(0xFF92549C, 0xFFD49CE4);
  late final _purple4 = _color(0xFFC096C7, 0xFFC59FD6);

  // New colors (Colors and styles Library)
  late final _accentMainDefault = _color(0xFF3972AA, 0xFF8CC9FF);

  late final _onEmphasis = _color(0xFFFFFFFF, 0xFF102336);
  late final _barIcons = brightness == Brightness.dark ? Brightness.light : Brightness.dark;

  late final appSystemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: _background,
    statusBarIconBrightness: _barIcons,
    statusBarBrightness: brightness,
    systemNavigationBarColor: defaultTargetPlatform == TargetPlatform.android ? _backgroundSystem : null,
    systemNavigationBarIconBrightness: defaultTargetPlatform == TargetPlatform.android ? _barIcons : null,
    systemStatusBarContrastEnforced: false,
  );

  late final _scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all<bool>(true),
    thumbColor: WidgetStateProperty.all<Color>(
      _neutralLight.withValues(
        alpha: 0.5,
      ),
    ),
    mainAxisMargin: 12,
    crossAxisMargin: 4,
    thickness: const WidgetStatePropertyAll(4),
    radius: const Radius.circular(100),
  );

  late final _customColors = CustomColors(
    accent: _accent,
    accentHover: _accentHover,
    accentPressed: _accentPressed,
    accentDisabled: _accentDisabled,
    blend: _blend,
    blendHover: _blendHover,
    blendPressed: _blendPressed,
    attention: _attention,
    attentionHover: _attentionHover,
    attentionPressed: _attentionPressed,
    attentionDisabled: _attentionDisabled,
    error: _error,
    errorHover: _errorHover,
    errorPressed: _errorPressed,
    errorDisabled: _errorDisabled,
    background: _background,
    backgroundAdditional: _backgroundAdditional,
    backgroundElevated: _backgroundElevated,
    backgroundSystem: _backgroundSystem,
    backgroundSystemHover: _backgroundSystemHover,
    backgroundSystemPressed: _backgroundSystemPressed,
    neutralLight: _neutralLight,
    neutralLightHover: _neutralLightHover,
    neutralLightPressed: _neutralLightPressed,
    neutralLightDisabled: _neutralLightDisabled,
    neutralBlack: _neutralBlack,
    neutralBlackHover: _neutralBlackHover,
    neutralBlackPressed: _neutralBlackPressed,
    neutralBlackDisabled: _neutralBlackDisabled,
    neutralDark: _neutralDark,
    neutralDarkHover: _neutralDarkHover,
    neutralDarkPressed: _neutralDarkPressed,
    neutralDarkDisabled: _neutralDarkDisabled,
    specialStaticWhite: _specialStaticWhite,
    specialStaticWhiteHover: _specialStaticWhiteHover,
    specialStaticWhitePressed: _specialStaticWhitePressed,
    specialStaticWhiteDisabled: _specialStaticWhiteDisabled,
    transparent: _transparent,
    macOSSystemTitleBarBackground: _macOSSystemTitleBarBackground,
    macOSSystemTitleBarTitle: _macOSSystemTitleBarTitle,
    windowsSystemTitleBarBackground: _windowsSystemTitleBarBackground,
    windowsSystemTitleBarTitle: _windowsSystemTitleBarTitle,
    windowsSystemTitleBarTitleInactive: _windowsSystemTitleBarTitleInactive,
    windowsSystemTitleBarButtonBackgroundHover: _windowsSystemTitleBarButtonBackgroundHover,
    windowsSystemTitleBarButtonBackgroundPressed: _windowsSystemTitleBarButtonBackgroundPressed,
    windowsSystemTitleBarCloseButtonBackgroundHover: _windowsSystemTitleBarCloseButtonBackgroundHover,
    windowsSystemTitleBarCloseButtonBackgroundPressed: _windowsSystemTitleBarCloseButtonBackgroundPressed,
    windowsSystemTitleBarCloseButtonForeground: _windowsSystemTitleBarCloseButtonForeground,
    primary1: _primary1,
    primary2: _primary2,
    primary3: _primary3,
    primary4: _primary4,
    blend1: _blend1,
    blend2: _blend2,
    blend3: _blend3,
    orange1: _orange1,
    orange2: _orange2,
    orange3: _orange3,
    orange4: _orange4,
    red1: _red1,
    red2: _red2,
    red3: _red3,
    red4: _red4,
    background1: _background1,
    background2: _background2,
    background3: _background3,
    gray1: _gray1,
    gray2: _gray2,
    gray3: _gray3,
    gray4: _gray4,
    contrast1: _contrast1,
    contrast2: _contrast2,
    contrast3: _contrast3,
    contrast4: _contrast4,
    staticBlack1: _staticBlack1,
    staticBlack2: _staticBlack2,
    staticBlack3: _staticBlack3,
    staticWhite: _staticWhite,
    purple1: _purple1,
    purple2: _purple2,
    purple3: _purple3,
    purple4: _purple4,
    accentMainDefault: _accentMainDefault,
  );

  late final _colorScheme = ColorScheme.fromSeed(
    seedColor: _accent,
    brightness: brightness,
  );

  late final _checkboxThemeData = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) return _accent;
        if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) return _accentDisabled;

        return null;
      },
    ),
    checkColor: WidgetStateProperty.all(_onEmphasis),
    side: WidgetStateBorderSide.resolveWith(
      (states) {
        if (!states.contains(WidgetState.selected) && !states.contains(WidgetState.disabled)) {
          return BorderSide(width: 2, color: _neutralLight);
        }
        if (!states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
          return BorderSide(width: 2, color: _neutralLightDisabled);
        }

        return null;
      },
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed)) return _accentPressed.withValues(alpha: 0.2);

        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _backgroundSystem;

        return _transparent;
      },
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2.0),
    ),
  );

  late final _iconButtonThemeData = IconButtonThemeData(
    style: ButtonStyle(
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(
            Radius.circular(
              4.0,
            ),
          ),
        ),
      ),
      foregroundColor: WidgetStatePropertyAll(brightness == Brightness.dark ? _neutralBlack : _specialStaticWhite),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused)) return _backgroundHover;
          if (states.contains(WidgetState.hovered)) return _backgroundPressed;

          return null;
        },
      ),
      mouseCursor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) return SystemMouseCursors.basic;

          return null;
        },
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
      iconSize: const WidgetStatePropertyAll(24),
    ),
  );

  late final _radioThemeData = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) return _neutralBlack.withValues(alpha: 0.38);
        if (states.contains(WidgetState.selected)) return _accent;

        return _neutralBlack;
      },
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed))
          return _backgroundSystem;

        return _transparent;
      },
    ),
  );

  late final _floatingActionButtonThemeData = FloatingActionButtonThemeData(
    backgroundColor: _accent,
    extendedTextStyle: _textTheme.labelLarge?.copyWith(color: _onEmphasis),
    foregroundColor: _onEmphasis,
    iconSize: 24,
    extendedSizeConstraints: const BoxConstraints(minHeight: 56),
    smallSizeConstraints: const BoxConstraints(minHeight: 40, minWidth: 40),
    sizeConstraints: const BoxConstraints(minHeight: 56, minWidth: 56),
    largeSizeConstraints: const BoxConstraints(minHeight: 96, minWidth: 96),
    focusColor: _accentHover,
    hoverColor: _accentHover,
    splashColor: _accentPressed,
    hoverElevation: 4,
    elevation: 3,
    focusElevation: 3,
    disabledElevation: 3,
    highlightElevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  late final _switchThemeData = SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) return _accentMainDefault;

        return _background2;
      },
    ),
    thumbColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) return brightness == Brightness.dark ? _onEmphasis : _staticWhite;
        if (states.contains(WidgetState.disabled)) return _contrast4;

        return _contrast1;
      },
    ),
    overlayColor: const WidgetStatePropertyAll(_transparent),
    trackOutlineWidth: WidgetStateProperty.resolveWith(
      (states) {
        if (!states.contains(WidgetState.selected)) return 2;

        return 0;
      },
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) return null;

        if (states.contains(WidgetState.disabled)) return _gray1;

        return _contrast1;
      },
    ),
  );

  late final _snackBarThemeData = SnackBarThemeData(
    backgroundColor: _neutralBlack,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
    contentTextStyle: _textTheme.bodyMedium?.copyWith(color: _onEmphasis),
    actionTextColor: _accentAdditional,
    closeIconColor: _onEmphasis,
  );

  late final _badgeThemeData = BadgeThemeData(
    textColor: _onEmphasis,
    textStyle: _textTheme.labelSmall,
    backgroundColor: _error,
    smallSize: 6,
    largeSize: 16,
    padding: const EdgeInsets.symmetric(horizontal: 4),
  );

  late final _windowsCaptionButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return _windowsSystemTitleBarButtonBackgroundPressed;
      }
      if (states.contains(WidgetState.hovered)) {
        return _windowsSystemTitleBarButtonBackgroundHover;
      }

      return _transparent;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return _windowsSystemTitleBarTitleInactive;
      }

      return _windowsSystemTitleBarTitle;
    }),
  );

  late final _customWindowsCaptionButtonTheme = CustomWindowsCaptionButtonTheme(
    regular: _windowsCaptionButtonStyle,
    close: _windowsCaptionButtonStyle.copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return _windowsSystemTitleBarCloseButtonBackgroundPressed;
        }
        if (states.contains(WidgetState.hovered)) {
          return _windowsSystemTitleBarCloseButtonBackgroundHover;
        }

        return _transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
          return _windowsSystemTitleBarCloseButtonForeground;
        }

        return _windowsCaptionButtonStyle.foregroundColor?.resolve(states);
      }),
    ),
    focusBorderColor: _windowsSystemTitleBarTitle,
  );

  late final _customFilledButtonTheme = CustomFilledButtonTheme(
    danger: FilledButtonThemeData(
      style: _filledButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return _error.withValues(alpha: 0.5);

            return _error;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.pressed)) return _errorPressed;
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _errorHover;

            return null;
          },
        ),
      ),
    ),
    attention: FilledButtonThemeData(
      style: _filledButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return _attention.withValues(alpha: 0.5);

            return _attention;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.pressed)) return _attentionPressed;
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _attentionHover;

            return null;
          },
        ),
      ),
    ),
    iconButton: FilledButtonThemeData(
      style: _filledButtonTheme.style?.copyWith(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
        ),
      ),
    ),
  );

  late final _customElevatedButtonTheme = CustomElevatedButtonTheme(
    iconButton: ElevatedButtonThemeData(
      style: _filledButtonTheme.style?.copyWith(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
        ),
      ),
    ),
  );

  late final _customOutlinedButtonTheme = CustomOutlinedButtonTheme(
    iconButton: OutlinedButtonThemeData(
      style: _outlinedButtonThemeData.style?.copyWith(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 24),
        ),
      ),
    ),
  );

  late final _customTextButtonTheme = CustomTextButtonTheme(
    danger: TextButtonThemeData(
      style: _textButtonThemeData.style?.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return _errorDisabled.withValues(alpha: 0.5);

            return _error;
          },
        ),
      ),
    ),
    attention: TextButtonThemeData(
      style: _textButtonThemeData.style?.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return _attentionDisabled.withValues(alpha: 0.5);

            return _attention;
          },
        ),
      ),
    ),
    success: TextButtonThemeData(
      style: _textButtonThemeData.style?.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return _accentDisabled.withValues(alpha: 0.5);

            return _accent;
          },
        ),
      ),
    ),
    iconButton: _textButtonThemeData,
  );

  late final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: _filledButtonTheme.style,
  );

  late final _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) return _accentDisabled.withValues(alpha: 0.4);

          return _accent;
        },
      ),
      foregroundColor: WidgetStatePropertyAll(_onEmphasis),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.pressed)) return _accentPressed;
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _accentHover;

          return null;
        },
      ),
      textStyle: WidgetStatePropertyAll(_textTheme.labelLarge),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      ),
      iconSize: const WidgetStatePropertyAll(18),
      minimumSize: WidgetStatePropertyAll(
        Size(_buttonTheme.minWidth, _buttonTheme.height),
      ),
      visualDensity: VisualDensity.standard,
    ),
  );

  late final _outlinedButtonThemeData = OutlinedButtonThemeData(
    style: _filledButtonTheme.style?.copyWith(
      backgroundColor: const WidgetStatePropertyAll(_transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) return _neutralLight;

          return _neutralBlack;
        },
      ),
      shape: WidgetStateProperty.resolveWith(
        (states) {
          final Color borderColor;

          if (states.contains(WidgetState.disabled)) {
            borderColor = _neutralLight;
          } else {
            borderColor = _neutralBlack;
          }

          return StadiumBorder(
            side: BorderSide(
              color: borderColor,
            ),
          );
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.pressed)) return _backgroundPressed;
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _backgroundHover;

          return null;
        },
      ),
    ),
  );

  late final _textButtonThemeData = TextButtonThemeData(
    style: _filledButtonTheme.style?.copyWith(
      backgroundColor: const WidgetStatePropertyAll(_transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) return _neutralLight;

          return _neutralBlack;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.pressed)) return _backgroundPressed;
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return _backgroundHover;

          return _transparent;
        },
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      textStyle: WidgetStatePropertyAll(
        _textTheme.labelLarge,
      ),
    ),
  );

  late final _appBarTheme = AppBarTheme(
    backgroundColor: _transparent,
    surfaceTintColor: _transparent,
    shadowColor: _transparent,
    systemOverlayStyle: appSystemUiOverlayStyle,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: _textTheme.titleLarge,
    centerTitle: true,
    foregroundColor: _neutralBlack,
  );

  late final _navigationBarThemeData = NavigationBarThemeData(
    backgroundColor: _backgroundSystem,
    indicatorColor: _blendHover,
  );

  late final _popupMenuThemeData = PopupMenuThemeData(
    color: _background,
    position: PopupMenuPosition.under,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    surfaceTintColor: _background,

    elevation: 2,
    textStyle: _textTheme.bodyLarge?.copyWith(
      color: _neutralBlack,
    ),
  );

  late final _menuButtonThemeData = MenuButtonThemeData(
    style: _textButtonThemeData.style?.copyWith(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      textStyle: WidgetStatePropertyAll(_textTheme.bodyLarge),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) return _transparent;
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.selected))
            return _backgroundSystemHover;
          if (states.contains(WidgetState.pressed)) return _backgroundSystemPressed;

          return null;
        },
      ),
    ),
  );

  late final _menuBarThemeData = MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(_background),
      surfaceTintColor: WidgetStatePropertyAll(_transparent),
    ),
  );

  late final _dropdownMenuThemeData = DropdownMenuThemeData(
    textStyle: _textTheme.bodyLarge,
    inputDecorationTheme: _inputDecorationTheme,
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(_background),
      surfaceTintColor: WidgetStatePropertyAll(_transparent),
      visualDensity: VisualDensity.standard,
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 8),
      ),
    ),
  );

  late final _menuThemeData = MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(_background),
      surfaceTintColor: WidgetStatePropertyAll(_transparent),
    ),
  );

  late final _progressIndicatorThemeData = ProgressIndicatorThemeData(
    color: _accent,
    circularTrackColor: _blend.withValues(alpha: 0.2),
    linearTrackColor: _blend.withValues(alpha: 0.2),
    linearMinHeight: 4,
  );

  late final _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _neutralDarkDisabled.withValues(
          alpha: 0.3,
        ),
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _error),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _dumInputDecorationIdleColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _neutralDark,
        width: 3,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _error, width: 3),
    ),
    outlineBorder: BorderSide(
      color: _dumInputDecorationIdleColor,
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: _dumInputDecorationIdleColor,
      ),
    ),
    floatingLabelStyle: WidgetStateTextStyle.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return _textTheme.bodySmall!.copyWith(color: _neutralBlackDisabled.withValues(alpha: 0.4));
        }

        if (states.contains(WidgetState.error)) {
          return _textTheme.bodySmall!.copyWith(color: _error);
        }

        return _textTheme.bodySmall!;
      },
    ),
    labelStyle: WidgetStateTextStyle.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return _textTheme.bodySmall!.copyWith(color: _neutralBlackDisabled.withValues(alpha: 0.3));
        }

        if (states.contains(WidgetState.error)) {
          return _textTheme.bodySmall!.copyWith(color: _error);
        }

        return _textTheme.bodySmall!;
      },
    ),
    alignLabelWithHint: true,
    hoverColor: _backgroundSystem,
    fillColor: _transparent,
    iconColor: _neutralBlack,
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return _neutralBlackDisabled;
        }

        return _neutralBlack;
      },
    ),
    suffixIconColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return _neutralBlackDisabled;
        }

        if (states.contains(WidgetState.error)) {
          return _error;
        }

        return _neutralBlack;
      },
    ),
    errorStyle: _textTheme.bodySmall?.copyWith(color: _error),
    hintStyle: WidgetStateTextStyle.resolveWith(
      (states) {
        final Color textColor;
        if (states.contains(WidgetState.disabled)) {
          textColor = _neutralDarkDisabled.withValues(alpha: 0.4);
        } else {
          textColor = _dumInputDecorationIdleColor;
        }

        return _textTheme.bodyLarge!.copyWith(color: textColor);
      },
    ),
    helperStyle: WidgetStateTextStyle.resolveWith(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return _textTheme.bodySmall!.copyWith(color: _neutralBlackDisabled.withValues(alpha: 0.3));
        }

        if (states.contains(WidgetState.error)) {
          return _textTheme.bodySmall!.copyWith(color: _error);
        }

        return _textTheme.bodySmall!;
      },
    ),
    counterStyle: WidgetStateTextStyle.resolveWith((states) => _textTheme.bodySmall!),
    contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    focusColor: _transparent,
  );

  late final _textSelectionTheme = TextSelectionThemeData(
    cursorColor: WidgetStateColor.resolveWith(
      (states) {
        if (states.contains(WidgetState.error)) {
          return _error;
        }

        return _neutralBlack;
      },
    ),
    selectionColor: _blend,
    selectionHandleColor: _accent,
  );

  late final _dividerThemeData = DividerThemeData(
    color: _neutralBlend,
    space: 1,
  );

  late final _iconThemeData = IconThemeData(
    size: 24,
    color: _neutralBlack,
  );

  late final _navigationRailThemeData = NavigationRailThemeData(
    indicatorColor: _blend.withValues(alpha: 0.2),
    unselectedLabelTextStyle: _textTheme.labelMedium,
    selectedLabelTextStyle: _textTheme.labelMedium,
    backgroundColor: _backgroundSystem,
  );

  late final _actionIconThemeData = ActionIconThemeData(
    closeButtonIconBuilder: (context) => CustomIcon.medium(
      icon: AssetIcons.close,
      color: _neutralBlack,
    ),
    backButtonIconBuilder: (context) => CustomIcon.medium(
      icon: AssetIcons.arrowBack,
      color: _neutralBlack,
    ),
  );

  late final _listTileThemeData = ListTileThemeData(
    contentPadding: const EdgeInsets.all(16),
    titleTextStyle: _textTheme.titleSmall,
    subtitleTextStyle: _textTheme.bodyMedium?.copyWith(color: _neutralLight),
  );

  late final _customDropdownMenuTheme = CustomDropdownMenuTheme(
    enabled: _dropdownMenuThemeData,
    disabled: _dropdownMenuThemeData.copyWith(
      textStyle: _dropdownMenuThemeData.textStyle?.copyWith(
        color: _neutralBlackDisabled.withValues(alpha: 0.4),
      ),
    ),
  );

  late final _tabBarTheme = TabBarThemeData(
    labelColor: _accent,
    unselectedLabelColor: _neutralBlack,
    indicatorColor: _accent,
    labelPadding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ),
    labelStyle: _textTheme.titleSmall,
  );

  late final _dialogTheme = DialogThemeData(
    // TODO: investigate why this color is used and if it's correct
    barrierColor: Colors.black54,
    backgroundColor: _background,
    surfaceTintColor: _transparent,
    titleTextStyle: _textTheme.headlineSmall,
    contentTextStyle: _textTheme.bodyMedium,
    iconColor: _accent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(28.0),
      ),
    ),
  );

  late final _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 57,
      letterSpacing: -0.25,
      height: 1.12,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 45,
      height: 1.15,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 36,
      height: 1.22,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 32,
      height: 1.25,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 28,
      height: 1.28,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 24,
      height: 1.33,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 22,
      height: 1.27,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 16,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 14,
      letterSpacing: 0.1,
      height: 1.42,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 14,
      letterSpacing: 0.1,
      height: 1.42,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 12,
      letterSpacing: 0.5,
      height: 1.33,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 11,
      letterSpacing: 0.5,
      height: 1.45,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 16,
      letterSpacing: 0.5,
      height: 1.5,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 14,
      letterSpacing: 0.25,
      height: 1.42,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: _neutralBlack,
      fontSize: 12,
      letterSpacing: 0.4,
      height: 1.33,
      fontFamily: FontFamilies.roboto,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  final _buttonTheme = const ButtonThemeData(
    minWidth: 70,
    height: 40,
  );

  late final _customFilledIconButtonTheme = CustomFilledIconButtonTheme(
    iconButton: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(_onEmphasis),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _accent;
            }

            return _neutralDark;
          },
        ),
      ),
    ),
    iconButtonInProgress: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(_onEmphasis),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _accent;
            }

            return _neutralDark;
          },
        ),
      ),
    ),
  );

  late final _customMissSpelledTextTheme = CustomMissSpelledTextTheme(
    missSpelledStyle: TextStyle(
      decorationColor: _error,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
      decorationThickness: 2,
    ),
  );

  ThemeData get data => ThemeData(
    // GENERAL CONFIGURATION
    useMaterial3: true,
    extensions: [
      _customColors,
      _customWindowsCaptionButtonTheme,
      _customFilledButtonTheme,
      _customElevatedButtonTheme,
      _customOutlinedButtonTheme,
      _customTextButtonTheme,
      _customDropdownMenuTheme,
      _customFilledIconButtonTheme,
      _customMissSpelledTextTheme,
    ],

    // COLOR
    scaffoldBackgroundColor: _background,
    brightness: brightness,
    primaryColor: _accent,
    colorScheme: _colorScheme,
    hoverColor: _transparent,
    focusColor: _transparent,

    // TYPOGRAPHY & ICONOGRAPHY
    textTheme: _textTheme,
    fontFamily: FontFamilies.roboto,
    iconTheme: _iconThemeData,
    textSelectionTheme: _textSelectionTheme,

    // COMPONENT THEMES
    checkboxTheme: _checkboxThemeData,
    iconButtonTheme: _iconButtonThemeData,
    radioTheme: _radioThemeData,
    floatingActionButtonTheme: _floatingActionButtonThemeData,
    switchTheme: _switchThemeData,
    snackBarTheme: _snackBarThemeData,
    badgeTheme: _badgeThemeData,
    elevatedButtonTheme: _elevatedButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonThemeData,
    textButtonTheme: _textButtonThemeData,
    dialogTheme: _dialogTheme,
    menuButtonTheme: _menuButtonThemeData,
    menuBarTheme: _menuBarThemeData,
    dropdownMenuTheme: _dropdownMenuThemeData,
    menuTheme: _menuThemeData,
    popupMenuTheme: _popupMenuThemeData,
    navigationBarTheme: _navigationBarThemeData,
    appBarTheme: _appBarTheme,
    progressIndicatorTheme: _progressIndicatorThemeData,
    inputDecorationTheme: _inputDecorationTheme,
    dividerTheme: _dividerThemeData,
    navigationRailTheme: _navigationRailThemeData,
    actionIconTheme: _actionIconThemeData,
    listTileTheme: _listTileThemeData,
    buttonTheme: _buttonTheme,
    tabBarTheme: _tabBarTheme,

    scrollbarTheme: _scrollbarTheme,
  );
}
