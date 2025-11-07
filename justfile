# DMS GnomeSearch Plugin Development Justfile
# 
# This file provides commands for developing, debugging, and testing the plugin

# Default recipe - show available commands
default:
    @just --list

# Show this plugin's log messages in real-time
logs:
    @echo "📋 Watching DMS logs for GnomeSearch plugin..."
    @echo "Press Ctrl+C to stop"
    journalctl --user -f -u dms.service | grep -i --color=always "gnomeSearchProviders\|gnome.*search\|bazaar"

# Show all DMS/Quickshell logs
logs-all:
    @echo "📋 Watching all DMS/Quickshell logs..."
    @echo "Press Ctrl+C to stop"
    journalctl --user -f -u dms.service

# Restart DMS to reload the plugin
restart:
    @echo "🔄 Restarting DMS..."
    @systemctl --user restart dms.service
    @echo "✅ DMS restarted"

# Stop DMS
stop:
    @echo "🛑 Stopping DMS..."
    @systemctl --user stop dms.service
    @echo "✅ DMS stopped"

# Start DMS
start:
    @echo "▶️  Starting DMS..."
    @systemctl --user start dms.service
    @echo "✅ DMS started"

# Show DMS service status
status:
    @systemctl --user status dms.service

# Restart and immediately show logs
dev: restart
    @sleep 1
    @just logs

# Test if Bazaar search provider is available
test-bazaar:
    @echo "🔍 Testing Bazaar search provider..."
    @if gdbus call --session --dest io.github.kolunmi.Bazaar --object-path /io/github/kolunmi/Bazaar/SearchProvider --method org.freedesktop.DBus.Introspectable.Introspect > /dev/null 2>&1; then \
        echo "✅ Bazaar search provider is available"; \
    else \
        echo "❌ Bazaar search provider not found"; \
        echo "   Make sure Bazaar is installed and running"; \
    fi

# Test if Files (Nautilus) search provider is available
test-files:
    @echo "🔍 Testing Files (Nautilus) search provider..."
    @if gdbus call --session --dest org.gnome.Nautilus.SearchProvider --object-path /org/gnome/Nautilus/SearchProvider --method org.freedesktop.DBus.Introspectable.Introspect > /dev/null 2>&1; then \
        echo "✅ Files search provider is available"; \
    else \
        echo "❌ Files search provider not found"; \
    fi

# Test if Calculator search provider is available
test-calculator:
    @echo "🔍 Testing Calculator search provider..."
    @if gdbus call --session --dest org.gnome.Calculator.SearchProvider --object-path /org/gnome/Calculator/SearchProvider --method org.freedesktop.DBus.Introspectable.Introspect > /dev/null 2>&1; then \
        echo "✅ Calculator search provider is available"; \
    else \
        echo "❌ Calculator search provider not found"; \
    fi

# Test if Characters search provider is available
test-characters:
    @echo "🔍 Testing Characters search provider..."
    @if gdbus call --session --dest org.gnome.Characters.SearchProvider --object-path /org/gnome/Characters/SearchProvider --method org.freedesktop.DBus.Introspectable.Introspect > /dev/null 2>&1; then \
        echo "✅ Characters search provider is available"; \
    else \
        echo "❌ Characters search provider not found"; \
    fi

# Test all search providers
test-all: test-bazaar test-files test-calculator test-characters

# List all available DBus services (helpful for finding new providers)
list-dbus:
    @echo "🔍 Searching for GNOME search providers on DBus..."
    @gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.ListNames | tr ',' '\n' | grep -i "search\|gnome" | sort

# Validate QML syntax (requires qml tool)
validate:
    @echo "🔍 Validating QML syntax..."
    @if command -v qml > /dev/null; then \
        qml -c GnomeSearchProvidersLauncher.qml && echo "✅ Launcher QML is valid"; \
        qml -c GnomeSearchProvidersSettings.qml && echo "✅ Settings QML is valid"; \
    else \
        echo "⚠️  qml tool not found, skipping validation"; \
    fi

# Validate plugin.json
validate-json:
    @echo "🔍 Validating plugin.json..."
    @if command -v jq > /dev/null; then \
        jq empty plugin.json && echo "✅ plugin.json is valid"; \
    else \
        python3 -m json.tool plugin.json > /dev/null && echo "✅ plugin.json is valid"; \
    fi

# Show recent DMS errors
errors:
    @echo "🔍 Recent DMS errors:"
    @journalctl --user -t quickshell -p err --since "10 minutes ago"

# Show recent DMS warnings and errors
warnings:
    @echo "🔍 Recent DMS warnings and errors:"
    @journalctl --user -t quickshell -p warning --since "10 minutes ago"

# Full development cycle: validate, restart, and watch logs
full: validate-json restart
    @sleep 1
    @just logs

# Debug: Show detailed information about the plugin
debug:
    @echo "🔍 Plugin Debug Information"
    @echo "=========================="
    @echo ""
    @echo "📁 Plugin Location:"
    @pwd
    @echo ""
    @echo "📋 Plugin Files:"
    @ls -lh *.qml *.json 2>/dev/null || true
    @echo ""
    @echo "🔌 DMS Service Status:"
    @systemctl --user is-active dms.service || echo "Not running"
    @echo ""
    @echo "🔍 Available Search Providers:"
    @just test-all
    @echo ""
    @echo "📜 Recent Plugin Logs:"
    @journalctl --user -t quickshell --since "5 minutes ago" | grep -i "gnome\|bazaar\|search" | tail -20 || echo "No recent logs"

# Clean up any temporary files (if needed in the future)
clean:
    @echo "🧹 Cleaning up..."
    @rm -f *.log *.tmp
    @echo "✅ Clean complete"

# Install just completion (optional)
install-completion:
    @echo "📦 Installing just completion..."
    @mkdir -p ~/.local/share/bash-completion/completions
    @just --completions bash > ~/.local/share/bash-completion/completions/just
    @echo "✅ Completion installed"
