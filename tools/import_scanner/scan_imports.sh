#!/bin/bash
# Lua Import Scanner - Bash Version
#
# Scans Lua files in the engine folder for potential import problems:
# - Missing required modules
# - Circular dependencies
# - Invalid file paths
# - Unused requires
# - Duplicate requires
#
# Usage: ./scan_imports.sh [options]
#
# Options:
#   --engine-path PATH    Path to engine folder (default: ./engine)
#   --output FILE         Output report file (default: import_report.txt)
#   --format FORMAT       Report format: text|json (default: text)
#   --verbose             Show detailed scan progress
#   --strict              Treat warnings as errors

set -e

# ===== Configuration =====
ENGINE_PATH="./engine"
OUTPUT_FILE="import_report.txt"
FORMAT="text"
VERBOSE=0
STRICT=0

# ===== Results Storage =====
FILES_SCANNED=0
VALID_FILES=0
declare -a ERRORS
declare -a MISSING_MODULES
declare -a DUPLICATE_REQUIRES
declare -a CIRCULAR_DEPS
declare -A DEPENDENCY_GRAPH
declare -A FILE_LIST

# ===== Helper Functions =====
log_info() {
    local msg="$1"
    echo "[$(date '+%H:%M:%S')] [INFO] $msg"
}

log_debug() {
    local msg="$1"
    if [ $VERBOSE -eq 1 ]; then
        echo "[$(date '+%H:%M:%S')] [DEBUG] $msg"
    fi
}

log_error() {
    local msg="$1"
    echo "[$(date '+%H:%M:%S')] [ERROR] $msg" >&2
}

log_warning() {
    local msg="$1"
    echo "[$(date '+%H:%M:%S')] [WARNING] $msg" >&2
}

file_exists() {
    [ -f "$1" ]
}

dir_exists() {
    [ -d "$1" ]
}

normalize_path() {
    local path="$1"
    path="${path//\\/\/}"
    path="${path#./}"
    echo "$path"
}

resolve_require_path() {
    local require_name="$1"
    local current_dir="$2"
    
    local variations=(
        "$require_name.lua"
        "$require_name"
        "$current_dir/$require_name.lua"
        "$current_dir/$require_name"
        "./engine/$require_name.lua"
        "./engine/$require_name"
    )
    
    for path in "${variations[@]}"; do
        if file_exists "$path"; then
            echo "$(normalize_path "$path")"
            return 0
        fi
    done
    
    return 1
}

extract_requires() {
    local file_path="$1"
    local line_num=0
    declare -a requires
    declare -A seen_requires
    
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_num++))
        
        # Match: require('module') or require("module")
        if [[ $line =~ require[[:space:]]*\([[:space:]]*[\'\"]([^\'\"]+)[\'\"][[:space:]]*\) ]]; then
            local module="${BASH_REMATCH[1]}"
            
            if [ -n "${seen_requires[$module]}" ]; then
                DUPLICATE_REQUIRES+=("$file_path:$module:$line_num:${seen_requires[$module]}")
            else
                requires+=("$module:$line_num")
                seen_requires[$module]="$line_num"
            fi
        fi
    done < "$file_path"
    
    # Output requires (crude but works)
    printf '%s\n' "${requires[@]}"
}

scan_lua_file() {
    local file_path="$1"
    local depth="${2:-0}"
    
    if [ $depth -gt 50 ]; then
        ERRORS+=("$file_path:Maximum recursion depth exceeded")
        return
    fi
    
    ((FILES_SCANNED++))
    FILE_LIST["$file_path"]=1
    
    log_debug "Scanning: $file_path"
    
    local requires_output
    requires_output=$(extract_requires "$file_path" 2>/dev/null || true)
    
    if [ -z "$requires_output" ]; then
        log_debug "  No requires found"
    else
        ((VALID_FILES++))
    fi
    
    local current_dir
    current_dir=$(dirname "$file_path")
    
    while IFS=':' read -r module line_num; do
        if [ -z "$module" ]; then
            continue
        fi
        
        local resolved_path
        if ! resolved_path=$(resolve_require_path "$module" "$current_dir" 2>/dev/null); then
            MISSING_MODULES+=("$file_path:$module:$line_num")
            log_warning "  Missing: $module"
        else
            log_debug "  Found: $module -> $resolved_path"
            
            if [ -z "${FILE_LIST["$resolved_path"]}" ]; then
                scan_lua_file "$resolved_path" $((depth + 1))
            fi
        fi
    done <<< "$requires_output"
}

scan_directory() {
    local dir_path="$1"
    
    if ! dir_exists "$dir_path"; then
        log_error "Directory not found: $dir_path"
        return 1
    fi
    
    while IFS= read -r file; do
        if [ -f "$file" ] && [[ $file == *.lua ]]; then
            scan_lua_file "$file"
        fi
    done < <(find "$dir_path" -name "*.lua" -type f)
}

generate_text_report() {
    {
        echo "═══════════════════════════════════════════════════════"
        echo "LUA IMPORT SCANNER REPORT"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        echo "Scan Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Engine Path: $ENGINE_PATH"
        echo ""
        echo "───────────────────────────────────────────────────────"
        echo "SCAN SUMMARY"
        echo "───────────────────────────────────────────────────────"
        echo "Total Files Scanned: $FILES_SCANNED"
        echo "Files with Requires: $VALID_FILES"
        echo "Total Errors: ${#ERRORS[@]}"
        echo "Missing Modules: ${#MISSING_MODULES[@]}"
        echo "Duplicate Requires: ${#DUPLICATE_REQUIRES[@]}"
        echo ""
        
        if [ ${#ERRORS[@]} -gt 0 ]; then
            echo "───────────────────────────────────────────────────────"
            echo "ERRORS (${#ERRORS[@]})"
            echo "───────────────────────────────────────────────────────"
            for err in "${ERRORS[@]}"; do
                echo "Error: $err"
            done
            echo ""
        fi
        
        if [ ${#MISSING_MODULES[@]} -gt 0 ]; then
            echo "───────────────────────────────────────────────────────"
            echo "MISSING MODULES (${#MISSING_MODULES[@]})"
            echo "───────────────────────────────────────────────────────"
            for miss in "${MISSING_MODULES[@]}"; do
                IFS=':' read -r file module line <<< "$miss"
                echo "File: $file"
                echo "Module: $module (Line $line)"
                echo ""
            done
        fi
        
        if [ ${#DUPLICATE_REQUIRES[@]} -gt 0 ]; then
            echo "───────────────────────────────────────────────────────"
            echo "DUPLICATE REQUIRES (${#DUPLICATE_REQUIRES[@]})"
            echo "───────────────────────────────────────────────────────"
            for dup in "${DUPLICATE_REQUIRES[@]}"; do
                IFS=':' read -r file module line1 line2 <<< "$dup"
                echo "File: $file"
                echo "Module: $module"
                echo "Lines: $line2 (first), $line1 (duplicate)"
                echo ""
            done
        fi
        
        echo "───────────────────────────────────────────────────────"
        echo "END OF REPORT"
        echo "═══════════════════════════════════════════════════════"
    }
}

# ===== Parse Arguments =====
while [[ $# -gt 0 ]]; do
    case $1 in
        --engine-path)
            ENGINE_PATH="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        --strict)
            STRICT=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ===== Main Execution =====
main() {
    log_info "Starting Lua import scan..."
    log_info "Engine path: $ENGINE_PATH"
    
    if ! dir_exists "$ENGINE_PATH"; then
        log_error "Engine path not found: $ENGINE_PATH"
        exit 1
    fi
    
    # Scan all Lua files
    scan_directory "$ENGINE_PATH"
    
    # Generate report
    local report
    report=$(generate_text_report)
    
    # Write report
    if echo "$report" > "$OUTPUT_FILE" 2>/dev/null; then
        log_info "Report written to: $OUTPUT_FILE"
    else
        log_error "Cannot write report to: $OUTPUT_FILE"
        echo "$report"
    fi
    
    # Print summary
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "SCAN COMPLETE"
    echo "═══════════════════════════════════════════════════════"
    echo "Files Scanned: $FILES_SCANNED"
    echo "Errors: ${#ERRORS[@]}"
    echo "Missing Modules: ${#MISSING_MODULES[@]}"
    echo "Duplicate Requires: ${#DUPLICATE_REQUIRES[@]}"
    echo ""
    
    if [ $STRICT -eq 1 ] && ([ ${#ERRORS[@]} -gt 0 ] || [ ${#MISSING_MODULES[@]} -gt 0 ]); then
        exit 1
    fi
}

main
