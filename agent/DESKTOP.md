## `DTD` - Default Testing Desktop

Use labwc on Wayland.

Use a 40 px bottom Waybar with notifications on the left and the launcher and
open apps in the center. On the right, show the tray, screen, audio, power and
WAN, weather, and UTC clock in that order. Click an app icon to raise or
minimize it, middle-click to close it, and Shift-click for a new instance.

The desktop's patched Waybar supplies Shift-click and card positioning. Use
compact cards that follow the bar's light or dark appearance. Open one card at
a time above its control on the same display. Escape or an outside click closes it.

- **Notifications.** Put Do Not Disturb, dismiss, and restore controls above
  separate lists for current notifications and history.
- **Screen.** Show each display's brightness, one slider for all displays, and
  a light/dark toggle.
- **Audio.** Show speaker volume and mute, microphone status and mute, and a
  link to sound settings. Use a slider for speaker volume.
- **Power and WAN.** Run a test when the card opens. Show test status, download
  and upload speed, latency, and the Cloudflare datacenter. Keep Suspend,
  Reboot, and Shut Down in a collapsible group below the results.
- **Weather.** Show current conditions in the bar. In the card, identify the
  forecast location and group upcoming changes by day. Each row shows UTC
  start time, condition and feels-like Celsius, duration, and precipitation
  chance when applicable. Show rain, snow, and storm events above 50% chance.
- **Clock.**

  ```html
  <card theme="follow-desktop">
    <heading>UTC</heading>
    <row>
      <text id="timestamp">2026-11-18T14:32:00Z</text>
      <button copy="timestamp">Copy UTC timestamp</button>
    </row>
    <text>November, Q4 2026</text>
    <text>Wednesday, week 47</text>
    <divider />
    <footer>Coordinated Universal Time</footer>
  </card>
  ```
- **Clipboard history.** Put search above a scrollable, newest-first list of
  text copies. Selecting an entry copies it again. Include a clear action.

## `ISD` - Internet Service Defaults

Treat essential Internet services as part of the operating environment. Choose a
trusted default for each capability and reuse it across desktop and agent tools.

- **Time.** Prefer UTC throughout. Follow [LANG](LANG.md#timestamp) for timestamp
  formatting.
- **Weather.** Query Google Weather API for the requested location and report
  current conditions or a seven-day forecast. Report feels-like temperature in
  Celsius.
- **WAN quality.** Run `cloudflare-speedtest` on the host being diagnosed with
  configured Cloudflare TURN credentials. Report latency, upload and download
  speeds, packet loss, and the WAN health score from its JSON output.
