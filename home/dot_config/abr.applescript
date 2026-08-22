-- Opens the Admin By Request elevation dialog, types the reason, and presses OK.
-- Invoked by the `abr` fish function, which validates the reason.
-- Note: the reason is typed via keystrokes (setting the field value directly
-- doesn't trigger ABR's validation, leaving OK disabled) — don't switch windows while it runs.
property formWindow : "Request Administrator Access"

on run argv
	set theReason to item 1 of argv
	open location "adminbyrequest://request-admin"
	tell application "System Events"
		tell process "Admin By Request"
			-- a confirmation dialog ("start an administrator session?") precedes the form — click Yes until the form appears
			repeat 40 times
				if (exists window formWindow) then exit repeat
				try
					click button "Yes" of window 1
				end try
				delay 0.25
			end repeat
			if not (exists window formWindow) then error "Timed out waiting for the " & formWindow & " dialog."
			set frontmost to true
			tell window formWindow
				set focused of text field 1 to true
				delay 0.3
				keystroke theReason
				delay 0.25
				-- keystrokes go to the frontmost app; make sure they landed in the reason field
				if value of text field 1 is not theReason then error "Typed reason did not land in the reason field — submit manually."
				repeat 20 times
					if enabled of button "OK" then
						click button "OK"
						return "Request submitted: " & theReason
					end if
					delay 0.25
				end repeat
			end tell
			error "Reason typed but OK never enabled — submit manually."
		end tell
	end tell
end run
