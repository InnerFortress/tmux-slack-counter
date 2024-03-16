# Tmux slack counter
This project is a fork of [Tmux slack counter](https://github.com/x4121/tmux-slack-counter) by [x4121](https://github.com/x4121).

Plugin that displays counters for mentions and messages in
[slack](https://slack.com/) so you can keep TMUX in fullscreen.


## Usage
Find your Slack [cookie and token](https://papermtn.co.uk/retrieving-and-using-slack-cookies-for-authentication/) for the slack
API and store them in: `$TMUX_PLUGIN_MANAGER_PATH/tmux-slack-counter/token.json`:
```
{
  "slack_token": "your_slack_api_token_here",
  "slack_xoxd_token": "your_slack_xoxd_token_here"
}
```

Add `#{slack_dms}`, `#{slack_mentions}` and `#{slack_messages}` to your `status-right`.
```tmux.conf
set -g status-right 'Slack: #{slack_dms}/#{slack_mentions}/#{slack_messages} | %a %Y-%m-%d %H:%M'
```
![screenshot](/screenshot.png)


### Variables
- `#{slack_dms}`: All direct messages for you (without group chats)
- `#{slack_mentions}`: All mentions in group chats, groups and channels that
  are not archived
- `#{slack_messages}`: All messages in group chats, groups and channels
  that are not archived or muted

### Delay
The default minimum delay between API requests is 1 minute.
This doesn't affect the `status-interval` of tmux, just how often the API can be queried.
You can change this value by setting `@slack_update_delay` in your `.tmux.conf`.
```tmux.conf
set -g @slack_update_delay '5 minutes'
```

## Installation
### Requirements
- [jq](https://stedolan.github.io/jq/)

### Installation with Tmux Plugin Manager (recommended)
Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux.conf
set -g @plugin 'InnerFortress/tmux-slack-counter'
```

Hit `prefix + I` to install it.

### Manual Installation
Clone the repo:

```bash
$ git clone https://github.com/InnerFortress/tmux-slack-counter.git ~/clone/path
```

Add this line to the bottom of your `.tmux.conf`:

```tmux.conf
run-shell ~/clone/path/tmux-slack-counter.tmux
```

Reload TMUX environment with:

```bash
$ tmux source-file ~/.tmux.conf
```

## Errors
`#{slack_dms}`, `#{slack_mentions}` and `#{slack_messages}` either
return numbers or error codes. These are:

- `TOK`: There is no `token` file or it is empty (see [Usage](#usage))
- `AUTH`: The token seems to be invalid. You may test it against the [slack
  API web interface](https://api.slack.com/methods/auth.test/test).
- `?` or `X?` where `X` is a number: The request failed, you might be offline.
- `NO_JQ`: You don't have [jq](https://stedolan.github.io/jq/) installed.
- `ERR`: Something else failed. The plugin will stop sending API requests
  until you remove the file `err` in the plugin directory. This is to
  prevent the plugin from spamming the API with invalid requests. The file
  `err` contains the last result from the failed request.

### License
[MIT](LICENSE)
