---
title: Notification System
summary: Centralized notification management and delivery system for AlienFall
tags:
  - gui
  - notifications
  - ux
  - love2d
---

# Notification System

## Overview

The AlienFall notification system provides a centralized mechanism for managing and delivering various types of user notifications across all game screens. It ensures consistent presentation, proper prioritization, and appropriate delivery channels for different types of information.

## Architecture

### Central Dispatcher
- **Module**: `gui.notifications`
- **Purpose**: Single point of control for all notification creation, queuing, and delivery
- **Features**: Priority management, channel routing, persistence handling

### Notification Types
- **Critical**: Game-stopping events requiring immediate attention (base under attack, critical resource depletion)
- **Warning**: Important alerts that need user awareness (UFO interception opportunities, facility malfunctions)
- **Info**: General information updates (research completion, mission reports)
- **Log**: Background events and historical records (geoscape events, battlescape action logs)

### Delivery Channels

#### Toast Notifications
- **Purpose**: Immediate, non-intrusive alerts that auto-dismiss
- **Positioning**: Scene-specific placement (top-right for geoscape, bottom-left for battlescape)
- **Duration**: Configurable based on type (critical: persistent until dismissed, info: 3-5 seconds)
- **Interaction**: Click to dismiss, hover to pause auto-hide

#### Status Badges
- **Purpose**: Persistent counters on UI elements (tabs, panels, buttons)
- **Display**: Small circular badges with numbers or icons
- **Examples**: Unread message counts, pending research projects, available missions
- **Updates**: Real-time synchronization with underlying data

#### Log Feeds
- **Purpose**: Chronological records of events and actions
- **Locations**: Geoscape event log, battlescape action history, base activity logs
- **Features**: Filtering, search, export capabilities
- **Persistence**: Saved across game sessions

## Configuration

### Notification Settings
Stored in `data/gui/notifications.toml`:

```toml
[types.critical]
icon = "alert_triangle"
color = "#FF4444"
persistence = "manual"  # until dismissed
sound = "alert_critical"

[types.warning]
icon = "alert_circle"
color = "#FFAA44"
persistence = "timed"   # 10 seconds
sound = "alert_warning"

[types.info]
icon = "info"
color = "#44AAFF"
persistence = "timed"   # 5 seconds
sound = "notification"

[types.log]
icon = "clock"
color = "#888888"
persistence = "permanent"
sound = "none"
```

### Channel Configuration
- **Toast Lane**: Position, size, animation settings
- **Badge Display**: Size limits, positioning offsets
- **Log Feeds**: Maximum entries, auto-cleanup rules

## Usage Examples

### Creating Notifications

```lua
-- Critical alert for base under attack
gui.notifications:create({
    type = "critical",
    title = "Base Under Attack",
    message = "Alien forces detected at " .. base.name,
    actions = {
        {text = "View Base", callback = function() showBaseView(base) end},
        {text = "Dispatch Craft", callback = function() showCraftDispatch() end}
    }
})

-- Research completion notification
gui.notifications:create({
    type = "info",
    title = "Research Complete",
    message = tech.name .. " research has been completed",
    icon = tech.icon,
    channels = {"toast", "badge"}  -- Show in toast and update research tab badge
})
```

### Managing Notifications

```lua
-- Get pending notifications
local pending = gui.notifications:getPending()

-- Mark as read
gui.notifications:markRead(notificationId)

-- Clear all of specific type
gui.notifications:clearType("info")

-- Pause/resume auto-dismiss
gui.notifications:setAutoDismiss(false)
```

## Integration Points

### Game Systems
- **Geoscape**: UFO detections, mission completions, base alerts
- **Battlescape**: Unit deaths, objective updates, turn changes
- **Base Management**: Research completions, construction finishes, resource alerts
- **UFOPedia**: New entries unlocked, research discoveries

### UI Components
- **Status Bar**: Shows active critical notifications
- **Tab Headers**: Display badge counts for pending items
- **Minimap**: Shows tactical alerts and warnings
- **Modal Dialogs**: Can trigger notifications on close

## Performance Considerations

### Optimization Strategies
- **Batching**: Group similar notifications to reduce screen clutter
- **Throttling**: Rate-limit rapid-fire notifications of the same type
- **Pooling**: Reuse notification objects to minimize memory allocation
- **Lazy Loading**: Load notification assets only when needed

### Memory Management
- **Cleanup**: Automatic removal of expired notifications
- **Archiving**: Move old notifications to persistent storage
- **Limits**: Maximum concurrent notifications per channel
- **Compression**: Store large notification histories efficiently

## Accessibility Features

### Screen Reader Support
- **Announcement**: New notifications announced with priority levels
- **Navigation**: Keyboard shortcuts to access notification history
- **Details**: Full notification content available on demand

### Visual Accommodations
- **High Contrast**: Enhanced visibility for notification elements
- **Animation Reduction**: Respect motion sensitivity preferences
- **Size Scaling**: Notifications scale with UI text size settings

## Testing & QA

### Automated Testing
- **Notification Creation**: Verify correct type assignment and content
- **Channel Delivery**: Ensure notifications appear in correct locations
- **Persistence**: Test notification survival across scene changes
- **Accessibility**: Validate screen reader announcements

### Manual Testing
- **Visual Verification**: Check notification appearance across themes
- **Interaction Testing**: Verify click actions and dismissals work correctly
- **Performance Testing**: Monitor notification impact on frame rate
- **Edge Cases**: Test maximum notification loads and error conditions

## Modding Support

### Extension Points
- **Custom Types**: Mods can define new notification types
- **Channel Plugins**: Add custom delivery channels
- **Filter Rules**: Custom notification filtering and prioritization
- **Theme Integration**: Notification styling through theme system

### API Access
- **Registration**: Mods register with notification system on load
- **Hooks**: Pre/post processing hooks for notification creation
- **Overrides**: Ability to replace default notification handling

## Future Enhancements

### Planned Features
- **Notification Groups**: Related notifications can be grouped and collapsed
- **Smart Timing**: AI-driven timing based on user attention patterns
- **Cross-Platform**: Platform-specific notification delivery (desktop notifications)
- **Advanced Filtering**: User-defined rules for notification handling

### Integration Improvements
- **Voice Synthesis**: Text-to-speech for critical notifications
- **Haptic Feedback**: Controller vibration for important alerts
- **Email/Webhooks**: External notification delivery for long-running games
- **Analytics**: Notification effectiveness and user response tracking