#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

MENU_DIR="$TARGET_HOME/GNUstep/Defaults"
mkdir -p "$MENU_DIR"

printf "Creating default dock configuration...\n"

# Create WMDock configuration with default applications (skip if already exists)
if [ ! -f "$TARGET_HOME/GNUstep/Defaults/WMState.default" ]; then
cat > "$TARGET_HOME/GNUstep/Defaults/WMState.default" << 'EOF'
{
  Dock = {
    AutoRaiseLower = No;
    Applications = (
      {
        Forced = No;
        Name = Logo.WMDock;
        BuggyApplication = No;
        AutoLaunch = No;
        Position = "0,0";
        Lock = No;
        Command = "WPrefs";
      },
      {
        Forced = No;
        Name = wmclock.WMClock;
        DropCommand = "wmclock %d";
        BuggyApplication = No;
        AutoLaunch = Yes;
        Position = "0,1";
        Lock = No;
        PasteCommand = "wmclock %s";
        Command = "wmclock -12";
      },
      {
        Forced = No;
        Name = wmcpuload.DockApp;
        DropCommand = "wmcpuload %d";
        BuggyApplication = No;
        AutoLaunch = Yes;
        Position = "0,2";
        Lock = No;
        PasteCommand = "wmcpuload %s";
        Command = wmcpuload;
      },
      {
        Forced = No;
        Name = wmsystemtray0.wmsystemtray;
        DropCommand = "wmsystemtray %d";
        BuggyApplication = No;
        AutoLaunch = Yes;
        Position = "0,3";
        Lock = No;
        PasteCommand = "wmsystemtray %s";
        Command = wmsystemtray;
      }
    );
    Lowered = Yes;
    Position = "1216,0";
  };
  Clip = {
    Forced = No;
    Name = Logo.WMClip;
    BuggyApplication = No;
    AutoLaunch = No;
    Position = "0,0";
    Lock = No;
    Command = "-";
  };
  Applications = ();
  Drawers = ();
  Workspaces = (
    {
      Clip = {
        AutoRaiseLower = No;
        AutoCollapse = No;
        Applications = ();
        Collapsed = No;
        AutoAttractIcons = No;
        Lowered = Yes;
      };
      Name = Main;
    },
    {
      Clip = {
        AutoRaiseLower = No;
        AutoCollapse = No;
        Applications = ();
        Collapsed = No;
        AutoAttractIcons = No;
        Lowered = Yes;
      };
      Name = Programming;
    },
    {
      Clip = {
        AutoRaiseLower = No;
        AutoCollapse = No;
        Applications = ();
        Collapsed = No;
        AutoAttractIcons = No;
        Lowered = Yes;
      };
      Name = Productivity;
    },
    {
      Clip = {
        AutoRaiseLower = No;
        AutoCollapse = No;
        Applications = ();
        Collapsed = No;
        AutoAttractIcons = No;
        Lowered = Yes;
      };
      Name = Media;
    }
  );
  Workspace = Main;
}
EOF
fi


if [ ! -f "$TARGET_HOME/GNUstep/Defaults/WMState" ]; then
  cp "$TARGET_HOME/GNUstep/Defaults/WMState.default" "$TARGET_HOME/GNUstep/Defaults/WMState"
fi

if [ ! -f "$TARGET_HOME/GNUstep/Defaults/WMWindowAttributes" ]; then
  cat > "$TARGET_HOME/GNUstep/Defaults/WMWindowAttributes" << "EOF"
{
    "*" = {
        NoAppIcon = NO;
    };
    "XTerm" = {
        Icon = "/usr/local/share/pixmaps/xterm_48x48.xpm";
        MiniaturizePixmap = "/usr/local/share/pixmaps/xterm_48x48.xpm";
        NoAppIcon = NO;
    };
}
EOF
fi

printf "Dock configuration created\n"


# Create Window Maker preferences
printf "Creating Window Maker preferences...\n"

if [ ! -f "$TARGET_HOME/GNUstep/Defaults/WindowMaker" ]; then

cat > "$TARGET_HOME/GNUstep/Defaults/WindowMaker" << 'EOF'
{
  FrameBorderColor = "#000000";
  FTitleColor = "#ffffff";
  KeepDockOnPrimaryHead = YES;
  CenterKey = None;
  IconTitleColor = "#ffffff";
  MoveTo6to12Head = None;
  DbClickFullScreen = NO;
  DoubleClickTitlebar = Shade;
  WindowSnapping = No;
  FrameFocusedBorderColor = "#ffffff";
  OpenTransientOnOwnerWorkspace = YES;
  CloseRootMenuByLeftOrRightMouseClick = YES;
  FrameSelectedBorderColor = "#ffffff";
  HotCornerDelay = 250;
  AntialiasedText = YES;
  MouseWheelAction = SwitchWorkspaces;
  HighlightColor = "#ffffff";
  CClipTitleColor = "#616161";
  IconPath = (
    "~/GNUstep/Library/WindowMaker/CachedPixmaps",
    "~/GNUstep/Library/Icons",
    "/usr/local/share/WindowMaker/Icons",
    "/usr/local/share/WindowMaker/Pixmaps",
    "/usr/local/share/pixmaps"
  );
  CirculateRaise = YES;
  DontLinkWorkspaces = NO;
  MenuDisabledColor = "#7f7f7f";
  IconTitleBack = "#000000";
  MenuTitleColor = "#ffffff";
  HotCorners = NO;
  EnableWorkspacePager = YES;
  NoWindowOverDock = YES;
  HighlightTextColor = "#000000";
  EnforceIconMargin = NO;
  AutoArrangeIcons = YES;
  ClipTitleColor = "#000000";
  MoveTo12to6Head = None;
  WindowTitleFont = "CaskaydiaMono Nerd Font:slant=0:weight=80:width=100:pixelsize=13";
  KbdModeLock = NO;
  Workspace1Key = "Mod4+1";
  Workspace2Key = "Mod4+2";
  Workspace3Key = "Mod4+3";
  Workspace4Key = "Mod4+4";
  MoveToWorkspace1Key = "Control+Mod4+1";
  MoveToWorkspace2Key = "Control+Mod4+2";
  MoveToWorkspace3Key = "Control+Mod4+3";
  MoveToWorkspace4Key = "Control+Mod4+4";
  ToggleKbdModeKey = None;
  RaiseAppIconsWhenBouncing = YES;
  WindowPlacement = smart;
  CycleWorkspaces = YES;
  OpaqueMoveResizeKeyboard = YES;
  MenuTextColor = "#000000";
  WrapMenus = YES;
  UTitleColor = "#000000";
  ViKeyMenus = YES;
  PTitleColor = "#ffffff";
  LHMaximizeKey = "Mod4+Left";
  RHMaximizeKey = "Mod4+Right";
  MaximizeKey = "Mod4+Up";
}
EOF
fi

printf "Window Maker preferences created\n"

# Stash the existing default before overwriting so we can detect changes
_menu_prev="$MENU_DIR/WMRootMenu.default.prev"
[ -f "$MENU_DIR/WMRootMenu.default" ] && cp "$MENU_DIR/WMRootMenu.default" "$_menu_prev"

# Create basic Window Maker menu configuration
cat > "$MENU_DIR/WMRootMenu.default" << 'EOF'
(
  "TRITON",
  ("Run...", EXEC, "%a(Run,Type command to run:)"),
  (Terminals, ("Triton Terminal", EXEC, "triton-terminal"), (xterm, EXEC, xterm), (urxvt, EXEC, "sh -c 'exec urxvt'")),
  (Browsers, (Chromium, EXEC, "triton-chromium"), (Waterfox, EXEC, waterfox), (Falkon, EXEC, "triton-falkon")),
  ("File Managers", (Thunar, EXEC, "thunar"), (Ranger, EXEC, "triton-terminal -e ranger")),
  (Development,
    (Leafpad, EXEC, leafpad),
    (Geany, EXEC, geany),
    (Neovim, EXEC, "triton-terminal -e nvim"),
    (Emacs, EXEC, "emacs"),
    (Zed, EXEC, "zedit"),
    (xev, EXEC, "triton-terminal -e xev")
  ),
  (
    Productivity,
    (GNUMail, EXEC, "openapp GNUMail"),
    (Graphics,
        (GIMP, EXEC, gimp),
        (Imageviewer, EXEC, "openapp ImageViewer"),
        (Pinta, EXEC, "pinta")),
    (Office,
      ("LibreOffice Writer", EXEC, lowriter),
      ("LibreOffice Calc", EXEC, localc),
      ("LibreOffice Draw", EXEC, lodraw),
      ("LibreOffice Impress", EXEC, loimpress),
      ("LibreOffice Math", EXEC, lomath),
      ("LibreOffice Base", EXEC, lobase),
      ("LibreOffice Web", EXEC, loweb),
      (LibreOffice, EXEC, libreoffice)),
    ("PDF Viewers", (Evince, EXEC, evince), (Xpdf, EXEC, xpdf)),
    (Logseq, EXEC, "triton-logseq"),
    (Nextcloud, EXEC, nextcloud)
  ),
  (Multimedia, (VLC, EXEC, vlc), (mpv, EXEC, "triton-terminal -e 'mpv --player-operation-mode=pseudo-gui --force-window=yes --idle=yes --keep-open=always; exec bash'")),
  (
    Utils,
    (System, ("CPU Load", EXEC, wmcpuload), (btop, EXEC, "triton-terminal -e btop")),
    (Network,
      ("Network Manager", EXEC, networkmgr),
      ("Network Monitor", EXEC, wmnetload)),
    ("Time & Date", EXEC, wmclock),
    (Magnify, EXEC, wmagnify),
    (Calculator, EXEC, xcalc),
    ("Volume Control", EXEC, "/usr/local/bin/Mixer.app"),
    ("Screenshot", EXEC, "triton-terminal -e flameshot gui"),
    ("XScreensaver", EXEC, "xscreensaver-settings"),
    ("Kill X Application", EXEC, xkill)
  ),
  (Workspaces, WORKSPACE_MENU),
  (Appearance, OPEN_MENU, appearance.menu),
  (
    Info,
    ("Info Panel", INFO_PANEL),
    (Legal, LEGAL_PANEL),
    ("Manual Browser", EXEC, xman),
    ("About", EXEC, "xterm -class About -T About -e bash -c 'fastfetch; read -n 1 -s'")
  ),
  (
    Session,
    ("Save Session", SAVE_SESSION),
    ("Clear Session", CLEAR_SESSION),
    ("Restart Window Maker", RESTART),
    (Lock, EXEC, "xlock -allowroot -usefirst"),
    ("Reboot", EXEC, "shutdown -r now"),
    ("Shutdown", EXEC, "shutdown -h now"),
    (Exit, EXIT)
  )
)
EOF

# If the default changed from the previous version, save a dated copy for review
if [ -f "$_menu_prev" ]; then
  if ! diff -q "$_menu_prev" "$MENU_DIR/WMRootMenu.default" >/dev/null 2>&1; then
    _dated="$MENU_DIR/WMRootMenu.default.$(date '+%Y%m%d')"
    cp "$MENU_DIR/WMRootMenu.default" "$_dated"
    printf "Menu default updated — review %s\n" "$_dated"
  fi
  rm -f "$_menu_prev"
fi

if [ ! -f "$MENU_DIR/WMRootMenu" ]; then
  cp "$MENU_DIR/WMRootMenu.default" "$MENU_DIR/WMRootMenu"
fi

printf "Window Maker menu created\n"

chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/GNUstep"

printf "Setting up xbindkeys\n"
if ! pkg info -e xbindkeys >/dev/null 2>&1; then
    pkg install -y xbindkeys
fi

if [ ! -f "$TARGET_HOME/.xbindkeysrc" ]; then
cat > "$TARGET_HOME/.xbindkeysrc" << 'EOF'
# Triton terminal
"triton-terminal"
  Mod4 + Return

# Triton dmenu launcher
"triton-dmenu-run"
  Mod4 + grave

# Triton rofi launcher
"rofi -show run"
  Mod4 + space

# X terminal
"xterm"
  Shift + Mod4 + Return

# PrintScreen → region screenshot
"flameshot gui"
    Alt + F10

# Shift+PrintScreen → full screen
"flameshot full -p ~/Pictures/"
    Alt + F11

# Ctrl+PrintScreen → active window
"flameshot screen -p ~/Pictures/"
    Alt + F12
EOF
chown "${TARGET_USER}:${TARGET_USER}" "$TARGET_HOME/.xbindkeysrc"
fi

printf "xbindkeys done\n"
