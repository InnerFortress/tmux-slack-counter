#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir/shared.sh"

delay_string="@slack_update_delay"
default_delay="1 minute"

age="$(get_tmux_option "$delay_string" "$default_delay")"

counter="$1"

api='https://slack.com/api/users.counts'
mentions='. -map(select(.is_archived)) | .[].mention_count_display]'
messages='. -map(select(.is_archived or .is_muted)) | .[].unread_count_display]'
join='.groups + .channels'

tmp_out="$dir/../tmp"
err_out="$dir/../err"
token_file="$dir/../token.json"

append=''

err() {
    echo "$1"
    exit 1
}

main() {
    if [[ -f $err_out ]]; then
        err 'ERR'
    fi

    if ! jq --version >/dev/null 2>&1; then
        err 'NO_JQ'
    fi

    if [[ ! -s $token_file ]]; then
        err 'TOK'
    fi

    slack_token=$(jq -r '.slack_token' "$token_file")
    slack_xoxd_token=$(jq -r '.slack_xoxd_token' "$token_file")

    if ! test "$(find "$tmp_out" -newermt "$age ago")"; then
        if js="$(curl -s -H "Authorization: Bearer $slack_token" -H "Cookie: d=$slack_xoxd_token" $api)"; then
            case "$(echo "$js" | jq -r '.error')" in
                null)
                    echo "$js" > "$tmp_out"
                    ;;
                not_authed)
                    err 'AUTH'
                    ;;
                invalid_auth)
                    err 'AUTH'
                    ;;
                account_inactive)
                    err 'AUTH'
                    ;;
                *)
                    echo "$js" > "$err_out"
                    err 'ERR'
                    ;;
            esac
        else
            if [[ ! -s $tmp_out ]]; then
                err '?'
            else
                append='?'
            fi
        fi
    fi

    case "$counter" in
        slack_dms)
            echo "$(jq '[.ims[].dm_count] | add' "$tmp_out")$append"
            ;;
        slack_mentions)
            echo "$(jq "[$join | $mentions | add" "$tmp_out")$append"
            ;;
        slack_messages)
            echo "$(jq "[$join | $messages | add" "$tmp_out")$append"
            ;;
    esac
}

main
