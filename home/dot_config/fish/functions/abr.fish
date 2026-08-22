function abr --description 'Request an Admin By Request session with the reason pre-filled and submitted'
    set -l reason (string join ' ' $argv)
    # ABR's form requires a reason of at least 5 characters
    if test (string length "$reason") -lt 5
        echo "Usage: abr <reason> (minimum 5 characters)" >&2
        return 1
    end
    osascript ~/.config/abr.applescript "$reason"
end
