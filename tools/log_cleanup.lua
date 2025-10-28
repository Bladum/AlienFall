-- Log Cleanup Tool
-- Manages log rotation and retention policy
-- Part of the Logging & Analytics System (Pattern 9)

local LogCleanup = {}

-- Configuration
local RETENTION_DAYS = 30  -- Keep logs for 30 days
local ARCHIVE_DAYS = 90    -- Keep archives for 90 days
local LOG_CATEGORIES = {"game", "tests", "mods", "system", "analytics"}

-- Get file modification time in days
local function getFileAgeDays(filepath)
    local file = io.open(filepath, "r")
    if not file then return nil end
    file:close()

    -- Get file modification time
    local lfs = love and love.filesystem
    if lfs then
        local info = lfs.getInfo(filepath)
        if info then
            local age_seconds = os.time() - info.modtime
            return age_seconds / 86400  -- Convert to days
        end
    end

    return nil
end

-- List files in directory
local function listFiles(directory)
    local files = {}
    local lfs = love and love.filesystem

    if lfs then
        local items = lfs.getDirectoryItems(directory)
        for _, item in ipairs(items) do
            local filepath = directory .. "/" .. item
            local info = lfs.getInfo(filepath)
            if info and info.type == "file" then
                table.insert(files, filepath)
            end
        end
    else
        -- Fallback for non-Love2D environment
        local pfile = io.popen('dir "' .. directory .. '" /b')
        if pfile then
            for filename in pfile:lines() do
                table.insert(files, directory .. "/" .. filename)
            end
            pfile:close()
        end
    end

    return files
end

-- Delete old log files
function LogCleanup:cleanOldLogs()
    print("[LOG_CLEANUP] Starting log cleanup...")
    local deleted_count = 0
    local archived_count = 0

    for _, category in ipairs(LOG_CATEGORIES) do
        local log_dir = "logs/" .. category
        local files = listFiles(log_dir)

        for _, filepath in ipairs(files) do
            -- Skip README files
            if not filepath:match("README") then
                local age_days = getFileAgeDays(filepath)

                if age_days then
                    if age_days > RETENTION_DAYS and age_days <= ARCHIVE_DAYS then
                        -- Archive the file
                        local archive_dir = "logs/archive/" .. category
                        -- Create archive directory if needed
                        os.execute('mkdir "' .. archive_dir .. '" 2>nul')

                        -- Compress and move to archive (simple copy for now)
                        local filename = filepath:match("([^/]+)$")
                        local archive_path = archive_dir .. "/" .. filename

                        local success = os.rename(filepath, archive_path)
                        if success then
                            archived_count = archived_count + 1
                            print(string.format("[LOG_CLEANUP] Archived: %s", filename))
                        end

                    elseif age_days > ARCHIVE_DAYS then
                        -- Delete old archives
                        local success = os.remove(filepath)
                        if success then
                            deleted_count = deleted_count + 1
                            print(string.format("[LOG_CLEANUP] Deleted: %s (age: %d days)",
                                              filepath:match("([^/]+)$"), math.floor(age_days)))
                        end
                    end
                end
            end
        end
    end

    print(string.format("[LOG_CLEANUP] Complete. Archived: %d, Deleted: %d",
                        archived_count, deleted_count))
    return archived_count, deleted_count
end

-- Get current log statistics
function LogCleanup:getLogStats()
    local stats = {
        total_files = 0,
        total_size = 0,
        by_category = {}
    }

    for _, category in ipairs(LOG_CATEGORIES) do
        local log_dir = "logs/" .. category
        local files = listFiles(log_dir)
        local category_size = 0

        for _, filepath in ipairs(files) do
            local lfs = love and love.filesystem
            if lfs then
                local info = lfs.getInfo(filepath)
                if info then
                    category_size = category_size + info.size
                end
            end
        end

        stats.by_category[category] = {
            files = #files,
            size = category_size
        }
        stats.total_files = stats.total_files + #files
        stats.total_size = stats.total_size + category_size
    end

    return stats
end

-- Print log statistics
function LogCleanup:printStats()
    local stats = self:getLogStats()

    print("[LOG_CLEANUP] Log Statistics:")
    print(string.format("  Total files: %d", stats.total_files))
    print(string.format("  Total size: %.2f MB", stats.total_size / 1024 / 1024))
    print("  By category:")

    for category, cat_stats in pairs(stats.by_category) do
        print(string.format("    %s: %d files, %.2f MB",
                          category, cat_stats.files, cat_stats.size / 1024 / 1024))
    end
end

-- Run cleanup with stats
function LogCleanup:run()
    print("=== Log Cleanup Tool ===")
    print()

    -- Show current stats
    self:printStats()
    print()

    -- Run cleanup
    self:cleanOldLogs()
    print()

    -- Show new stats
    self:printStats()
    print()
    print("Cleanup complete!")
end

-- If run as standalone script
if not love then
    LogCleanup:run()
end

return LogCleanup

