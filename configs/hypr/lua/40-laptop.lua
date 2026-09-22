-- ThinkPad hardware: the F-row, the lid, the power button.
--
-- Every bind here carries { locked = true } so it keeps working while
-- hyprlock is up -- you should be able to mute the machine or turn the
-- backlight down without unlocking it first.

local p = require("lib.programs")

--------------------------------------------------------------------------
-- VOLUME AND MIC
--------------------------------------------------------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

--------------------------------------------------------------------------
-- BACKLIGHT
--------------------------------------------------------------------------

-- -e4 gives a perceptually even curve rather than a linear one, and -n2
-- stops the panel from going fully black at the bottom of the range.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%-"),
    { locked = true, repeating = true })

-- The ThinkPad keyboard backlight is a two-level ThinkLight successor;
-- step it rather than scaling it by percent.
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set +1"),
    { locked = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set 1-"),
    { locked = true })

--------------------------------------------------------------------------
-- MEDIA
--------------------------------------------------------------------------

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------------------------------------------------
-- THE F-ROW EXTRAS
--------------------------------------------------------------------------

-- F5/F6 on a T420 send these. Wiring them to the launcher and the network
-- TUI is more useful than letting them do nothing.
hl.bind("XF86Favorites", hl.dsp.exec_cmd(p.menu),       { locked = true })
hl.bind("XF86Search",    hl.dsp.exec_cmd(p.menu),       { locked = true })
hl.bind("XF86WLAN",      hl.dsp.exec_cmd(p.tuiNetwork), { locked = true })
hl.bind("XF86Display",   hl.dsp.exec_cmd(p.displays),   { locked = true })

--------------------------------------------------------------------------
-- LID
--------------------------------------------------------------------------

-- Closing the lid turns the internal panel off. If an external monitor is
-- attached the session simply carries on there; if not, Hyprland is left
-- with no enabled output and logind's own lid handling suspends the
-- machine -- which is what you want in a bag.
--
-- The panel name is substituted by the Home Manager module.
hl.bind("switch:on:Lid Switch",
    hl.dsp.exec_cmd("hyprctl keyword monitor '" .. p.laptopMonitor .. ", disable'"),
    { locked = true })
hl.bind("switch:off:Lid Switch",
    hl.dsp.exec_cmd("hyprctl keyword monitor '" .. p.laptopMonitor .. ", preferred, auto, 1'"),
    { locked = true })

--------------------------------------------------------------------------
-- POWER BUTTON
--------------------------------------------------------------------------

-- Locks rather than powering off, so a stray press in a bag is
-- recoverable. logind is told to ignore the button in the NixOS module,
-- otherwise it would act first and this bind would never fire.
hl.bind("XF86PowerOff", hl.dsp.exec_cmd(p.lock), { locked = true })
