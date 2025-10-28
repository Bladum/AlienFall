# GUI & Widget System Architecture

**System:** User Interface & Widgets  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The GUI system provides a comprehensive widget framework for building game interfaces with a 24×24 pixel grid system.

---

## Widget System Architecture

```mermaid
classDiagram
    class Widget {
        +x: number
        +y: number
        +width: number
        +height: number
        +visible: boolean
        +enabled: boolean
        +parent: Widget
        +update(dt)
        +draw()
        +mousepressed(x, y, button)
        +keypressed(key)
    }
    
    class Container {
        +children: Widget[]
        +padding: number
        +layout_type: string
        +addChild(widget)
        +removeChild(widget)
        +layout()
    }
    
    class Panel {
        +title: string
        +background: color
        +border: boolean
        +draggable: boolean
        +onDrag()
    }
    
    class Button {
        +text: string
        +callback: function
        +hovered: boolean
        +pressed: boolean
        +icon: Image
        +onClick()
        +onHover()
    }
    
    class Label {
        +text: string
        +font: Font
        +align: string
        +color: color
        +wrap: boolean
    }
    
    class TextBox {
        +text: string
        +placeholder: string
        +cursor: number
        +maxLength: number
        +password: boolean
        +onChange()
        +onSubmit()
    }
    
    class List {
        +items: any[]
        +selectedIndex: number
        +scrollOffset: number
        +itemHeight: number
        +onSelect()
        +onDoubleClick()
    }
    
    class ScrollPanel {
        +content: Widget
        +scrollX: number
        +scrollY: number
        +scrollbarWidth: number
        +onScroll()
    }
    
    class Checkbox {
        +checked: boolean
        +label: string
        +onToggle()
    }
    
    class Slider {
        +value: number
        +min: number
        +max: number
        +step: number
        +onValueChange()
    }
    
    class ProgressBar {
        +value: number
        +max: number
        +color: color
        +showText: boolean
    }
    
    Widget <|-- Container
    Widget <|-- Button
    Widget <|-- Label
    Widget <|-- TextBox
    Widget <|-- Checkbox
    Widget <|-- Slider
    Widget <|-- ProgressBar
    
    Container <|-- Panel
    Container <|-- List
    Container <|-- ScrollPanel
```

---

## Event Flow

```mermaid
sequenceDiagram
    participant User
    participant Input as Input System
    participant Root as Root Container
    participant Panel
    participant Button
    participant App as Application
    
    User->>Input: Mouse Click (x, y)
    Input->>Root: mousepressed(x, y, button)
    
    Root->>Root: Check bounds
    
    alt Inside Root
        Root->>Panel: mousepressed(x, y, button)
        Panel->>Panel: Check bounds
        
        alt Inside Panel
            Panel->>Button: mousepressed(x, y, button)
            Button->>Button: Check bounds
            
            alt Inside Button
                Button->>Button: Set pressed = true
                Button->>Button: Play click sound
                Button->>Button: onClick()
                Button->>App: Execute callback()
                Button-->>Panel: Event handled = true
            else Outside Button
                Button-->>Panel: Event handled = false
            end
            
            Panel-->>Root: Propagate result
        else Outside Panel
            Panel-->>Root: Event handled = false
        end
        
        Root-->>Input: Event result
    else Outside Root
        Root-->>Input: Event not handled
    end
```

---

## Layout System

```mermaid
graph TD
    Container[Container Widget] --> LayoutType{Layout Type?}
    
    LayoutType -->|Horizontal| HLayout[Horizontal Layout]
    LayoutType -->|Vertical| VLayout[Vertical Layout]
    LayoutType -->|Grid| GLayout[Grid Layout]
    LayoutType -->|Absolute| ALayout[Absolute Position]
    
    HLayout --> HCalc[Calculate X Positions]
    HCalc --> HSpace[Apply Spacing]
    HSpace --> HAlign[Apply Alignment]
    HAlign --> HChildren[Position Children Left-to-Right]
    
    VLayout --> VCalc[Calculate Y Positions]
    VCalc --> VSpace[Apply Spacing]
    VSpace --> VAlign[Apply Alignment]
    VAlign --> VChildren[Position Children Top-to-Bottom]
    
    GLayout --> GCalc[Calculate Grid Cells]
    GCalc --> GRows[Rows × Columns]
    GRows --> GAlign[Cell Alignment]
    GAlign --> GChildren[Position Children in Grid]
    
    ALayout --> AChild[Use Widget x,y]
    AChild --> AChildren[No Auto-positioning]
    
    HChildren --> Padding[Apply Padding]
    VChildren --> Padding
    GChildren --> Padding
    AChildren --> Padding
    
    Padding --> Render[Render Children]
    
    style Container fill:#FFD700
    style Render fill:#87CEEB
```

---

## Grid System (24×24 pixels)

```mermaid
graph LR
    Screen[Screen Resolution<br/>960×720] --> Grid[24×24 Grid]
    
    Grid --> Cols[40 Columns<br/>24px each]
    Grid --> Rows[30 Rows<br/>24px each]
    
    Cols --> Widget1[Button: 6 cols<br/>144px wide]
    Cols --> Widget2[Panel: 20 cols<br/>480px wide]
    
    Rows --> Widget3[Label: 1 row<br/>24px tall]
    Rows --> Widget4[List: 10 rows<br/>240px tall]
    
    Widget1 --> Align[Snap to Grid]
    Widget2 --> Align
    Widget3 --> Align
    Widget4 --> Align
    
    style Screen fill:#90EE90
    style Grid fill:#FFD700
    style Align fill:#87CEEB
```

### Grid Layout Table

| Element | Grid Size | Pixel Size | Use Case |
|---------|-----------|------------|----------|
| **Icon** | 1×1 | 24×24 | Small icons, buttons |
| **Button** | 6×2 | 144×48 | Standard button |
| **Panel Header** | 20×1 | 480×24 | Panel title bar |
| **Input Field** | 10×2 | 240×48 | Text input |
| **List Item** | 15×1 | 360×24 | List row |
| **Dialog** | 20×15 | 480×360 | Modal dialog |
| **Full Screen** | 40×30 | 960×720 | Full UI |

---

## Widget States

```mermaid
stateDiagram-v2
    [*] --> Normal: Widget Created
    
    Normal --> Hovered: Mouse Enter
    Hovered --> Normal: Mouse Leave
    
    Hovered --> Pressed: Mouse Down
    Pressed --> Hovered: Mouse Up (inside)
    Pressed --> Normal: Mouse Up (outside)
    
    Normal --> Disabled: Disable()
    Hovered --> Disabled: Disable()
    Pressed --> Disabled: Disable()
    
    Disabled --> Normal: Enable()
    
    Normal --> Focused: Click / Tab
    Focused --> Normal: Click Outside / Blur
    
    Focused --> Typing: Keyboard Input
    Typing --> Focused: Enter / Done
    
    any --> Hidden: visible = false
    Hidden --> Normal: visible = true
```

---

## Theme System

```mermaid
graph TD
    Theme[UI Theme] --> Colors[Color Palette]
    Theme --> Fonts[Font Definitions]
    Theme --> Sprites[Sprite Assets]
    Theme --> Sounds[Sound Effects]
    
    Colors --> Primary[Primary: #FFD700]
    Colors --> Secondary[Secondary: #87CEEB]
    Colors --> Background[Background: #2C3E50]
    Colors --> Text[Text: #FFFFFF]
    Colors --> Accent[Accent: #E74C3C]
    
    Fonts --> Normal[Normal: 14px]
    Fonts --> Bold[Bold: 16px]
    Fonts --> Title[Title: 20px]
    
    Sprites --> ButtonNormal[button_normal.png]
    Sprites --> ButtonHover[button_hover.png]
    Sprites --> ButtonPress[button_pressed.png]
    Sprites --> PanelBG[panel_bg.png]
    
    Sounds --> Click[click.wav]
    Sounds --> Hover[hover.wav]
    Sounds --> Error[error.wav]
    
    style Theme fill:#FFD700
```

---

## Common UI Patterns

```mermaid
graph LR
    Patterns[UI Patterns] --> Dialog[Dialog Pattern]
    Patterns --> Toolbar[Toolbar Pattern]
    Patterns --> SidePanel[Side Panel Pattern]
    Patterns --> TabView[Tab View Pattern]
    
    Dialog --> Modal[Modal Dialog<br/>Centered<br/>Backdrop]
    
    Toolbar --> Top[Top Toolbar<br/>Horizontal<br/>Icons + Text]
    
    SidePanel --> Left[Left Panel<br/>Vertical List<br/>Collapsible]
    
    TabView --> Tabs[Tab Bar<br/>Switch Content<br/>Preserve State]
    
    style Patterns fill:#FFD700
```

---

## Responsive Scaling

```mermaid
graph TD
    Resolution[Window Resolution] --> Check{Resolution?}
    
    Check -->|960×720| Scale1[Scale: 1.0x<br/>Grid: 24px]
    Check -->|1920×1080| Scale2[Scale: 2.0x<br/>Grid: 48px]
    Check -->|1280×720| Scale3[Scale: 1.33x<br/>Grid: 32px]
    
    Scale1 --> Apply[Apply Scale to UI]
    Scale2 --> Apply
    Scale3 --> Apply
    
    Apply --> Font[Scale Fonts]
    Apply --> Widgets[Scale Widgets]
    Apply --> Spacing[Scale Spacing]
    
    Font --> Render[Render UI]
    Widgets --> Render
    Spacing --> Render
    
    style Resolution fill:#90EE90
    style Apply fill:#FFD700
    style Render fill:#87CEEB
```

---

## Animation System

```mermaid
sequenceDiagram
    participant Widget
    participant Anim as Animation Controller
    participant Tween
    participant Render
    
    Widget->>Anim: Animate property
    Anim->>Tween: Create tween
    
    Tween->>Tween: Set start value
    Tween->>Tween: Set end value
    Tween->>Tween: Set duration
    Tween->>Tween: Set easing function
    
    loop Animation Loop
        Anim->>Tween: Update(dt)
        Tween->>Tween: Calculate progress (0-1)
        Tween->>Tween: Apply easing
        Tween->>Tween: Interpolate value
        Tween-->>Widget: Set property value
        Widget->>Render: Draw with new value
    end
    
    Tween->>Anim: Animation complete
    Anim->>Widget: onComplete callback
```

---

## Widget Lifecycle

```mermaid
graph TD
    Create[Create Widget] --> Initialize[Initialize Properties]
    
    Initialize --> AddToParent[Add to Parent Container]
    
    AddToParent --> Layout[Layout Calculation]
    Layout --> Visible[Set Visible = true]
    
    Visible --> UpdateLoop[Update Loop]
    
    UpdateLoop --> Update[update(dt)]
    Update --> HandleInput[Handle Input Events]
    HandleInput --> Draw[draw()]
    Draw --> UpdateLoop
    
    UpdateLoop --> Remove[Remove Widget]
    
    Remove --> Cleanup[Cleanup Resources]
    Cleanup --> RemoveFromParent[Remove from Parent]
    RemoveFromParent --> Destroy[Destroy Widget]
    
    style Create fill:#90EE90
    style UpdateLoop fill:#FFD700
    style Destroy fill:#FF6B6B
```

---

## Performance Optimization

```mermaid
graph LR
    Optimize[UI Optimization] --> Culling[Viewport Culling]
    Optimize --> Caching[Sprite Batching]
    Optimize --> Lazy[Lazy Updates]
    Optimize --> Pool[Object Pooling]
    
    Culling --> CullOff[Don't Draw Off-Screen]
    Caching --> BatchDraw[Batch Similar Widgets]
    Lazy --> DirtyFlag[Only Update When Changed]
    Pool --> ReuseWidgets[Reuse Widget Objects]
    
    CullOff --> FPS[60 FPS Stable]
    BatchDraw --> FPS
    DirtyFlag --> FPS
    ReuseWidgets --> FPS
    
    style Optimize fill:#FFD700
    style FPS fill:#90EE90
```

---

## Widget Library

| Widget | Purpose | Common Props | Example |
|--------|---------|--------------|---------|
| **Button** | Clickable action | text, onClick | "Start Mission" |
| **Label** | Display text | text, color | "Health: 25/30" |
| **TextBox** | Text input | text, maxLength | Enter name |
| **Panel** | Container with frame | title, draggable | Settings panel |
| **List** | Scrollable items | items, onSelect | Soldier roster |
| **Checkbox** | Boolean toggle | checked, onToggle | Enable autosave |
| **Slider** | Number range | value, min, max | Volume: 0-100 |
| **ProgressBar** | Show progress | value, max | Loading: 75% |
| **ScrollPanel** | Scrollable content | content | Long text |
| **TabView** | Multiple pages | tabs, content | Options tabs |

---

## Accessibility Features

```mermaid
graph TD
    Access[Accessibility] --> Keyboard[Keyboard Navigation]
    Access --> ScreenReader[Screen Reader Support]
    Access --> ColorBlind[Colorblind Modes]
    Access --> Scaling[UI Scaling]
    
    Keyboard --> Tab[Tab Order]
    Keyboard --> Shortcuts[Keyboard Shortcuts]
    Keyboard --> Focus[Focus Indicators]
    
    ScreenReader --> Labels[ARIA Labels]
    ScreenReader --> Announcements[State Announcements]
    
    ColorBlind --> Deuteranopia[Deuteranopia Mode]
    ColorBlind --> Protanopia[Protanopia Mode]
    ColorBlind --> Tritanopia[Tritanopia Mode]
    
    Scaling --> Small[100% - Small]
    Scaling --> Medium[150% - Medium]
    Scaling --> Large[200% - Large]
    
    style Access fill:#FFD700
```

---

**End of GUI & Widget System Architecture**

