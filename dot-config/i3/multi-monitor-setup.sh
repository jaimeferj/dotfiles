#!/usr/bin/env bash
# Detect if two monitors are connected; if yes, assign workspaces accordingly.

# 1) Count connected monitors
#    (grep for " connected" but exclude "disconnected")
LOG_FILE="$HOME/.cache/i3/init-script.log"
setup_workspaces() {
    MAX_TRIES=50
    SLEEP_INTERVAL=0.1

    # Helper: wait until i3 reports that $1 exists as a workspace name
    wait_for_workspace() {
        local WS_NAME="$1"
        local attempt=0
        while true; do
            # Query i3 for its current list of workspaces (JSON array)
            ws_json=$(i3-msg -t get_workspaces)

            # Check if our target workspace appears in that JSON
            if echo "$ws_json" | grep -q "\"name\":\"$WS_NAME\""; then
                return 0
            fi

            # Not found yet: increment counter, sleep, and retry
            attempt=$((attempt + 1))
            if [ "$attempt" -ge "$MAX_TRIES" ]; then
                echo "ERROR: Timed out waiting for workspace \"$WS_NAME\" to exist." >&2
                return 1
            fi
            sleep "$SLEEP_INTERVAL"
        done
    }

    num_monitors=$(xrandr --query | grep " connected" | grep -v "disconnected" | wc -l)

    # Only proceed if at least 2 monitors are up
    if [ "$num_monitors" -ge 2 ]; then
        PRIMARY_OUTPUT=$(xrandr --query |
            grep " connected primary" |
            awk '{ print $1 }')

        CONNECTED=($(xrandr --query | grep " connected" | grep -v "disconnected" | awk '{ print $1 }'))

        SECONDARY_OUTPUT=""
        for mon in "${CONNECTED[@]}"; do
            if [ "$mon" != "$PRIMARY_OUTPUT" ]; then
                SECONDARY_OUTPUT="$mon"
                break
            fi
        done

        # Sanity check: if somehow PRIMARY or SECONDARY is empty, bail out
        if [ -z "$PRIMARY_OUTPUT" ] || [ -z "$SECONDARY_OUTPUT" ]; then
            echo "Error: Could not detect primary or secondary output."
            exit 1
        else
            echo "Primary monitor: $PRIMARY_OUTPUT, secondary: $SECONDARY_OUTPUT"
        fi

        # List of workspace→output mappings
        declare -A ws_to_output=(
            ["1:main"]="$PRIMARY_OUTPUT"
            ["2:qsearch"]="$PRIMARY_OUTPUT"
            ["3:docs"]="$PRIMARY_OUTPUT"
            ["5:tasks"]="$SECONDARY_OUTPUT"
            ["6:chat"]="$SECONDARY_OUTPUT"
        )

        # For each workspace name, wait until it exists, then move it
        for ws in "${!ws_to_output[@]}"; do
            output="${ws_to_output[$ws]}"

            if wait_for_workspace "$ws"; then
                i3-msg "workspace \"$ws\"; move workspace to output $output" >/dev/null
            else
                # If the workspace never appeared, skip moving it
                echo "Skipping move for \"$ws\" since it did not appear." >&2
            fi
        done

        # After moving, switch to your preferred workspace
        preferred_ws="1:main"
        if wait_for_workspace "$preferred_ws"; then
            i3-msg "workspace \"$preferred_ws\""
        fi
    fi
    exit 0
}

setup_workspaces 2>&1 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0 }' \
    >>"$LOG_FILE"
