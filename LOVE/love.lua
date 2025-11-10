---@meta love

---Love2D 12.0 Type Definitions for Lua LSP
---Provides type information for Love2D 12.0 APIs

---@class love
---@field conf fun(t: table) Configure Love2D before initialization
---@field load fun(arg: table) Called once at game start
---@field update fun(dt: number) Called every frame with delta time
---@field draw fun() Called every frame to draw graphics
---@field keypressed fun(key: string, scancode: string, isrepeat: boolean) Keyboard input
---@field keyreleased fun(key: string, scancode: string) Keyboard release
---@field mousepressed fun(x: number, y: number, button: number, istouch: boolean) Mouse input
---@field mousereleased fun(x: number, y: number, button: number, istouch: boolean) Mouse release
---@field mousemoved fun(x: number, y: number, dx: number, dy: number, istouch: boolean) Mouse movement
---@field textinput fun(text: string) Text input
---@field quit fun() Called when game should quit
---@field run fun() Main game loop (usually not overridden)
---@field errhand fun(msg: string) Error handler
love = {}

---Graphics module
---@class love.graphics
---@field getWidth fun(): number Get screen width
---@field getHeight fun(): number Get screen height
---@field setColor fun(r: number, g: number, b: number, a?: number) Set draw color
---@field setBackgroundColor fun(r: number, g: number, b: number, a?: number) Set background color
---@field clear fun(r?: number, g?: number, b?: number, a?: number) Clear screen
---@field rectangle fun(mode: string, x: number, y: number, w: number, h: number) Draw rectangle
---@field circle fun(mode: string, x: number, y: number, radius: number) Draw circle
---@field line fun(x1: number, y1: number, x2: number, y2: number, ...) Draw line
---@field print fun(text: string, x?: number, y?: number) Print text
---@field printf fun(text: string, x: number, y: number, limit: number, align?: string) Print formatted text
---@field draw fun(drawable: any, x?: number, y?: number, r?: number, sx?: number, sy?: number) Draw image/sprite
---@field newImage fun(filename: string): love.Image Create image
---@field newCanvas fun(width?: number, height?: number): love.Canvas Create canvas
---@field newFont fun(filename: string, size?: number): love.Font Create font
---@field setFont fun(font: love.Font) Set current font
---@field push fun() Push graphics state
---@field pop fun() Pop graphics state
---@field translate fun(x: number, y: number) Translate coordinate system
---@field scale fun(sx: number, sy?: number) Scale coordinate system
---@field rotate fun(angle: number) Rotate coordinate system
---@field setScissor fun(x: number, y: number, width: number, height: number) Set scissor rectangle
---@field setBlendMode fun(mode: string, alphamode?: string) Set blend mode
love.graphics = {}

---Image class
---@class love.Image
---@field getWidth fun(self): number Get image width
---@field getHeight fun(self): number Get image height
love.Image = {}

---Canvas class
---@class love.Canvas
---@field getWidth fun(self): number Get canvas width
---@field getHeight fun(self): number Get canvas height
love.Canvas = {}

---Font class
---@class love.Font
---@field getWidth fun(self, text: string): number Get text width
---@field getHeight fun(self): number Get font height
love.Font = {}

---Audio module
---@class love.audio
---@field newSource fun(filename: string, type?: string): love.Source Create audio source
---@field play fun(source: love.Source) Play audio
---@field stop fun(source?: love.Source) Stop audio
---@field setVolume fun(volume: number) Set master volume
love.audio = {}

---Source class
---@class love.Source
---@field play fun(self) Play this source
---@field stop fun(self) Stop this source
---@field pause fun(self) Pause this source
---@field setVolume fun(self, volume: number) Set volume
---@field setLooping fun(self, loop: boolean) Set looping
---@field isPlaying fun(self): boolean Check if playing
love.Source = {}

---Filesystem module
---@class love.filesystem
---@field read fun(filename: string): string Read file contents
---@field write fun(filename: string, data: string) Write file
---@field exists fun(filename: string): boolean Check if file exists
---@field getDirectoryItems fun(path: string): table Get directory contents
---@field load fun(filename: string): function Load and run Lua file
---@field getSaveDirectory fun(): string Get save directory
love.filesystem = {}

---Timer module
---@class love.timer
---@field getTime fun(): number Get current time
---@field getDelta fun(): number Get frame delta time
---@field sleep fun(seconds: number) Sleep for seconds
love.timer = {}

---Math module
---@class love.math
---@field random fun(min?: number, max?: number): number Random number
---@field randomNormal fun(mean?: number, stddev?: number): number Normal distribution random
---@field noise fun(x: number, y?: number, z?: number): number Perlin noise
love.math = {}

---Keyboard module
---@class love.keyboard
---@field isDown fun(key: string): boolean Check if key is pressed
---@field isScancodeDown fun(scancode: string): boolean Check if scancode is pressed
love.keyboard = {}

---Mouse module
---@class love.mouse
---@field getX fun(): number Get mouse X position
---@field getY fun(): number Get mouse Y position
---@field getPosition fun(): number, number Get mouse position
---@field setPosition fun(x: number, y: number) Set mouse position
---@field isDown fun(button: number): boolean Check if mouse button is pressed
love.mouse = {}

---Window module
---@class love.window
---@field setTitle fun(title: string) Set window title
---@field setMode fun(width: number, height: number, flags: table) Set window mode
---@field getMode fun(): number, number, table Get window mode
---@field setIcon fun(imagedata: any) Set window icon
---@field setPosition fun(x: number, y: number) Set window position
love.window = {}

---System module
---@class love.system
---@field getOS fun(): string Get operating system
---@field openURL fun(url: string) Open URL in default browser
love.system = {}

---Event module
---@class love.event
---@field quit fun() Quit the game
---@field push fun(event: string, ...) Push event to queue
love.event = {}

---Thread module
---@class love.thread
---@field newThread fun(filename: string): love.Thread Create thread
---@field newChannel fun(): love.Channel Create channel
love.thread = {}

---Thread class
---@class love.Thread
---@field start fun(self) Start thread
---@field wait fun(self) Wait for thread
---@field isRunning fun(self): boolean Check if running
love.Thread = {}

---Channel class
---@class love.Channel
---@field push fun(self, value: any) Push value to channel
---@field pop fun(self): any Pop value from channel
love.Channel = {}

return love