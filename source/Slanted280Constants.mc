using Toybox.Graphics;

// Watch face specific Constants

const TIME_Y_POS = 50;
const SEC_Y_POS = 42;
const AMPM_Y_POS = 58;
const PROGBAR_UPPER_Y_POS = 32;
const PROGBAR_LOWER_Y_POS = 65;
const PROGBAR_THICKNESS = 2;
const GRID_LINE_WIDTH = 2;

const TOP_X = 50;
const TOP_Y = 6;

const UPPER_LEFT_X = 29;
const UPPER_LEFT_Y = 28;

const UPPER_RIGHT_X = 79;
const UPPER_RIGHT_Y = 31;

const LOWER_LEFT_X = 22;
const LOWER_LEFT_Y = 69;

const LOWER_RIGHT_X = 70;
const LOWER_RIGHT_Y = 72;

const BOTTOM_X = 50;
const BOTTOM_Y = 92;

const UPPER_BAR_Y = 16;
const LOWER_BAR_Y = 83;

const IS_ICONS = true; // watchface specific
const P_ISCOLON = true;

// Theme colors
/*
<listEntry value="0">@Strings.ColorBabyPoo</listEntry>
<listEntry value="1">@Strings.ColorWhite</listEntry>
<listEntry value="2">@Strings.ColorLightGray</listEntry>
<listEntry value="3">@Strings.ColorYellow</listEntry>
<listEntry value="4">@Strings.ColorRed</listEntry>
<listEntry value="5">@Strings.ColorBlue</listEntry>
<listEntry value="6">@Strings.ColorGreen</listEntry>
<listEntry value="7">@Strings.ColorOrange</listEntry>
<listEntry value="8">@Strings.ColorPink</listEntry>
<listEntry value="9">@Strings.ColorPurple</listEntry>
<listEntry value="10">@Strings.ColorDarkGray</listEntry>
<listEntry value="11">@Strings.ColorLightGreen</listEntry>
<listEntry value="12">@Strings.ColorDarkGreen</listEntry>
<listEntry value="13">@Strings.ColorLightBlue</listEntry>
<listEntry value="14">@Strings.ColorDarkBlue</listEntry>
<listEntry value="15">@Strings.ColorLightRed</listEntry>
<listEntry value="16">@Strings.ColorDarkRed</listEntry>
<listEntry value="30">@Strings.ColorBlack</listEntry>
<listEntry value="99">@Strings.ColorTheme</listEntry>
*/
// [MinutesCoor, SecondsColor, MainColor, SecondaryColor, GridColor, IconsColor, TopBarColor, BottomBarColor, BackColor]
const T_ENDURO2 = [0,0,1,2,2,10,4,6,30];
const T_NATURE = [1,11,11,11,12,6,3,4,30];
const T_ICE = [1,13,1,13,2,13,13,13,30];
const T_ENDURO = [5,5,1,1,10,2,5,5,30];
const T_WHITE = [30,30,30,30,10,10,16,12,1];


const FONT_HOUR_MINUTES = Graphics.FONT_SYSTEM_NUMBER_THAI_HOT;
const FONT_SECONDS = Graphics.FONT_SYSTEM_SMALL;
const FONT_AMPM = Graphics.FONT_SYSTEM_XTINY;
const FONT_FIELD = Graphics.FONT_SYSTEM_TINY;

const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;
const SECONDS_FONT = Graphics.FONT_SYSTEM_SMALL;
const FIELD_FONT = Graphics.FONT_SYSTEM_TINY;


