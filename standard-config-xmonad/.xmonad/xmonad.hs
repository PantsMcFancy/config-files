import XMonad
import XMonad.Config.Desktop
import Data.Monoid
import System.Exit

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import XMonad.Util.SpawnOnce
import XMonad.Util.Run

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog

import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid

color00 = "#071222"
color01 = "#424d57"
color02 = "#e7edef"
color03 = "#6272a4"
color04 = "#8be9fd"
color05 = "#3a91ee"
color06 = "#3e607e"

--color06 = "#ffb86c"
--color07 = "#ff79c6"
--color08 = "#bd93f9"
--color09 = "#ff5555"
--color10 = "#f1fa8c"






myTerminal     = "alacritty"
--myBorderWidth  = 4
myBorderWidth  = 0
myModMask      = mod4Mask

-- Startup Commands
myStartupHook  = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom &"
    spawnOnce "xmobar"
    spawnOnce "greenclip daemon"
    spawnOnce "xinput set-prop 9 'Coordinate Transformation Matrix' 0.23 0 0 0 0.23 0 0 0 1"

-- Layouts
--myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
myLayout = avoidStruts (tiled ||| grid ||| Full)
    where
        tiled = spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True $ ResizableTall 1 (3/100) (1/2)[]
        grid = spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True $ Grid

-- Keybindings
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch rofi -show run
    , ((modm,               xK_p     ), spawn "rofi -show run")

    -- launch imagemagick clipboard mode
    , ((modm,               xK_Print     ), spawn "flameshot gui")

    --launch rofi greenclip
    , ((modm,               xK_v     ), spawn "rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    , ((0                     , 0x1008FF11), spawn "pactl set-sink-volume 0 -5%")
    , ((0                     , 0x1008FF13), spawn "pactl set-sink-volume 0 +5%")
    , ((0                     , 0x1008FF12), spawn "pactl set-sink-mute 0 toggle")
    , ((0                     , 0x1008FF02), spawn "brightnessctl set 50+")
    , ((0                     , 0x1008FF03), spawn "brightnessctl set 50-")
    

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)


    , ((modm .|. shiftMask, xK_h     ), sendMessage MirrorShrink    )
 

    , ((modm .|. shiftMask, xK_l     ), sendMessage MirrorExpand    )

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myNormalBorderColor  = "#333333"
--myFocusedBorderColor = "#bd93f9"
myFocusedBorderColor = color01
--myFocusedBorderColor = "#ff0000"





main = do
    xmproc0 <- spawnPipe ("xmobar")
    xmonad $ docks def {
          terminal    = myTerminal
        , modMask     = myModMask
        , borderWidth = myBorderWidth
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , keys        = myKeys

        , startupHook = myStartupHook
        , layoutHook  = myLayout
        , handleEventHook = fullscreenEventHook
         , logHook     = dynamicLogWithPP $ xmobarPP
            {
                ppOutput = hPutStrLn xmproc0
               ,ppCurrent = xmobarColor color02 "" . wrap ("<box type=Bottom width=2 mb=2 color=" ++ color05 ++ ">") "</box>" 
               ,ppHidden = xmobarColor color01 ""
               ,ppTitle  = xmobarColor color02 "" . shorten 120
               ,ppSep =  "<fc=" ++ color02 ++ "> <fn=1>|</fn> </fc>"               
               ,ppOrder  = \(ws:_:t:_) -> [ws,t]
            }
    }

