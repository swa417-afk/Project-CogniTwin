# Game Time - Roku Sports Streaming Channel

A full-featured Roku channel for live sports streaming, inspired by **FuboTV** and **NBA League Pass**. Features a modern dark UI with live TV guide, real-time scores, team-following, and adaptive video playback.

## Features

### Home Screen (FuboTV-style)
- Hero banner showcasing featured live events
- Horizontally scrolling content rows by sport category
- Live Now, Trending, NFL, NBA, Soccer, MLB, NHL, UFC, Motorsports, Continue Watching
- Sport-specific color theming on cards and badges
- Smooth scroll animations between rows

### Live TV Guide (EPG)
- Full electronic program guide with time-based grid
- Channel sidebar with logos and numbers
- Real-time "now" indicator line
- Mini preview panel on program focus
- Sport category filter chips
- 6-hour lookahead with 30-minute time slots

### Game Center (League Pass-style)
- Date selector bar (3 days past through 3 days future)
- Live score ticker (horizontal scroll)
- Detailed game cards with team logos, records, and scores
- Slide-in game detail panel with box score
- Watch Live / Condensed Game action buttons
- Sport filter tabs (All, NFL, NBA, MLB, NHL, Soccer, NCAAF)

### Video Player
- Full-screen adaptive bitrate playback (HLS/DASH)
- Sports HUD overlay (toggle with UP): live score, period, league badge
- Playback controls overlay (toggle with DOWN): progress bar, time, play/pause
- 10-second skip forward/back with FF/RW buttons
- Auto-quality indicator (4K/HD/SD/LOW)
- Buffering overlay with spinner
- Auto-hide controls after 5 seconds
- Live score polling every 30 seconds during live games

### Search
- Keyboard search with debounced API calls
- Browse by sport category badges
- Trending searches with viewer counts
- Grid results display

### My Teams (Favorites)
- Follow favorite teams with persistent storage
- Personalized upcoming games feed
- Team logo card carousel
- Registry-backed persistence across sessions

### Settings
- Video Quality (Auto/1080p/720p/480p)
- Score Spoiler Protection
- Live Notifications
- Auto-Play Next
- Closed Captions
- Configurable stream source API
- Clear history / Reset favorites

## Project Structure

```
roku-sports-channel/
├── manifest                    # Roku channel manifest
├── source/
│   ├── main.brs               # Entry point, event loop, deep linking
│   ├── utils.brs              # Time formatting, colors, registry helpers
│   └── networkManager.brs     # HTTP GET/POST with SSL and error handling
├── components/
│   ├── MainScene.xml/brs      # Root scene - screen navigation, key handling
│   ├── NavBar.xml/brs         # Top navigation bar with tabs
│   ├── NavTab.xml/brs         # Individual nav tab button
│   ├── HomeScreen.xml/brs     # FuboTV-style home with hero + rows
│   ├── ContentRow.xml/brs     # Horizontal scrolling content row
│   ├── ContentCard.xml/brs    # Game/event thumbnail card
│   ├── LiveGuide.xml/brs      # EPG program guide grid
│   ├── ChannelLogo.xml/brs    # EPG channel sidebar item
│   ├── ProgramCell.xml/brs    # EPG program grid cell
│   ├── GameCenter.xml/brs     # Scores, schedules, game detail
│   ├── ScoreCard.xml/brs      # Compact score ticker card
│   ├── GameCard.xml/brs       # Detailed game matchup card
│   ├── VideoPlayerScreen.xml/brs  # Full player with sports HUD
│   ├── SearchScreen.xml/brs   # Search with keyboard + categories
│   ├── FavoritesScreen.xml/brs    # My Teams + upcoming games
│   ├── SettingsScreen.xml/brs # App preferences
│   ├── SettingsItem.xml/brs   # Settings row item
│   ├── ContentFeedTask.xml/brs    # Async API data fetcher + demo data
│   ├── FilterChip.xml/brs     # Selectable filter pill
│   ├── SportBadge.xml/brs     # Sport category icon badge
│   ├── TeamCard.xml/brs       # Team logo card for favorites
│   ├── ToastNotification.xml/brs  # Popup notification banner
│   └── BusySpinner.xml/brs    # Loading indicator
├── images/                     # Channel icons and splash screens
└── .gitignore
```

## Setup & Development

### Prerequisites
- Roku device with Developer Mode enabled
- Roku Developer account (free at developer.roku.com)

### Enable Developer Mode on Roku
1. On your Roku remote, press: Home 3x, Up 2x, Right, Left, Right, Left, Right
2. Note the IP address shown
3. Set a developer password

### Sideload the Channel
1. Zip the project: `cd roku-sports-channel && zip -r ../gametime.zip . -x ".*"`
2. Open `http://<roku-ip>` in your browser
3. Log in with username `rokudev` and your developer password
4. Upload `gametime.zip` via the installer page
5. The channel will launch automatically

### Configure Content API
Edit the API base URL in `components/ContentFeedTask.brs`:
```brightscript
function GetApiBaseUrl() as String
    return "https://your-api-server.com/api/v1"
end function
```

Or set it at runtime via Settings > Stream Source, which writes to the device registry.

### Expected API Endpoints
Your backend should serve these endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/featured` | GET | Featured/hero events |
| `/category?sport=nba` | GET | Events filtered by sport |
| `/epg` | GET | EPG data: `{ channels: [], programs: [] }` |
| `/scores` | GET | Live scores and game data |
| `/search?q=term` | GET | Search results |
| `/trending` | GET | Trending search queries |
| `/upcoming?teamIds=id1,id2` | GET | Games for followed teams |

### Demo Mode
When no API is configured, the channel automatically falls back to built-in demo data showing sample games across NFL, NBA, NHL, MLB, Soccer, and UFC.

## Navigation

| Button | Action |
|--------|--------|
| OK | Select / Play-Pause |
| Back | Go back / Close player |
| Up/Down | Navigate rows / Toggle player HUD |
| Left/Right | Navigate items / Seek 10s in player |
| Options (*) | Open settings / Toggle stats HUD |
| Play/Pause | Play-Pause in player |
| FF/RW | Skip 10s forward/back |

## Deep Linking
Supports Roku Search deep linking:
- `contentId` + `mediaType=live` → tunes to live channel
- `contentId` + `mediaType=game` → opens game in GameCenter
- Other → opens content from home screen

## Color Theme
- Background: `#0D0D1A`
- Accent: `#E10600` (red)
- Card: `#1C1C3A`
- Text Primary: `#FFFFFF`
- Text Secondary: `#888899`
- Sport-specific colors for NFL, NBA, MLB, NHL, Soccer, UFC, etc.
