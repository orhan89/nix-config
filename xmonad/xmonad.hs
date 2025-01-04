import XMonad
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Actions.CycleWS
import XMonad.Layout.Maximize
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle.Instances
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
import XMonad.Hooks.SetWMName
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Hooks.FadeInactive
import XMonad.Layout.Minimize
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import Graphics.X11.ExtraTypes.XF86
import System.IO
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "urxvt"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse= True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

myWorkspaces = map show [1..8] ++ ["NSP"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "black"
myFocusedBorderColor = "#69DFFA"   --"#E39402"    #00F2FF

hiddenNotNSP :: X (WindowSpace -> Bool)
hiddenNotNSP = do
  hs <- gets $ map W.tag . W.hidden . windowset
  return (\w -> (W.tag w) /= "NSP" && (W.tag w) `elem` hs)

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask,  xK_Return), spawn $ XMonad.terminal conf)

    -- launch rofi
    , ((modm,               xK_p     ), spawn "rofi -show run")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- Grid Select
    --, ((modm,               xK_g     ), goToSelected defaultGSConfig)

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
    --, ((modm,               xK_m     ), windows W.focusMaster  )
    --, ((modm,               xK_m     ), withFocused minimizeWindow)
    --, ((modm .|. shiftMask, xK_m     ), sendMessage RestoreNextMinimizedWin)

    -- Maximize selected window
    --, ((modm, xK_f     ), (sendMessage $ Toggle FULL))

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

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Switch workspaces and screens
    , ((modm,               xK_Right),  moveTo Next (WSIs hiddenNotNSP))
    , ((modm,               xK_Left),   moveTo Prev (WSIs hiddenNotNSP))
    , ((modm .|. shiftMask, xK_Right),  shiftTo Next (WSIs hiddenNotNSP))
    , ((modm .|. shiftMask, xK_Left),   shiftTo Prev (WSIs hiddenNotNSP))
    , ((modm,               xK_Down),   nextScreen)
    , ((modm,               xK_Up),     prevScreen)
    , ((modm .|. shiftMask, xK_Down),   shiftNextScreen)
    , ((modm .|. shiftMask, xK_Up),     shiftPrevScreen)

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


myLayout = smartBorders $ avoidStruts $ minimize (mkToggle (NOBORDERS ?? FULL ?? EOT) (tiled ||| Mirror tiled ||| Full))
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = gaps [(U,10), (R,10), (L,10), (R,10)] $ spacing 10 $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myLogHook xmproc = dynamicLogWithPP xmobarPP
                     { ppOutput = hPutStrLn xmproc
                     , ppCurrent = xmobarColor "#69DFFA" "" . wrap "[" "]"   -- #9BC1B2
                     , ppTitle = xmobarColor "#69DFFA" "" . shorten 50       -- #9BC1B2
                     , ppSort = fmap (.namedScratchpadFilterOutWorkspace) getSortByTag
                     }
                     >> updatePointer (0.75, 0.75) (0.75, 0.75)
                     >> (fadeOutLogHook $ fadeIf ((className =? "URxvt")) 0.93)
                     
myConfig xmproc = def {
        -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        -- key bindings
        keys               = myKeys,
        -- mouseBindings      = myMouseBindings,

        -- hooks, layouts
        layoutHook         = myLayout,
        -- manageHook         = myManageHook,
        -- handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc
        -- startupHook        = myStartupHook
    }

main = do
    xmproc <- spawnPipe "/etc/profiles/per-user/rhariady/bin/xmobar"
    xmonad $ ewmh $ myConfig xmproc