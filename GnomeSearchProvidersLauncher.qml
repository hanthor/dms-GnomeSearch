import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Item {
    id: root

    // Plugin properties
    property var pluginService: null
    property string trigger: ""  // Empty trigger by default

    // Plugin interface signals
    signal itemsChanged()

    // List of known GNOME search providers
    property var searchProviders: [
        {
            service: "io.github.kolunmi.Bazaar",
            path: "/io/github/kolunmi/Bazaar/SearchProvider",
            name: "Bazaar",
            icon: "material:shopping_bag",
            priority: 10
        },
        {
            service: "org.gnome.Nautilus.SearchProvider",
            path: "/org/gnome/Nautilus/SearchProvider",
            name: "Files",
            icon: "material:folder",
            priority: 5
        },
        {
            service: "org.gnome.Calculator.SearchProvider",
            path: "/org/gnome/Calculator/SearchProvider",
            name: "Calculator",
            icon: "material:calculate",
            priority: 8
        },
        {
            service: "org.gnome.Characters.SearchProvider",
            path: "/org/gnome/Characters/SearchProvider",
            name: "Characters",
            icon: "material:emoji_emotions",
            priority: 3
        },
        {
            service: "org.gnome.Settings.SearchProvider",
            path: "/org/gnome/Settings/SearchProvider",
            name: "Settings",
            icon: "material:settings",
            priority: 7
        }
    ]

    property var enabledProviders: []
    property int maxResultsPerProvider: 5
    
    Component.onCompleted: {
        console.info("GnomeSearchProviders: Plugin loaded")

        // Load settings
        if (pluginService) {
            trigger = pluginService.loadPluginData("gnomeSearchProviders", "trigger", "")
            enabledProviders = pluginService.loadPluginData("gnomeSearchProviders", "enabledProviders", [])
            maxResultsPerProvider = pluginService.loadPluginData("gnomeSearchProviders", "maxResultsPerProvider", 5)
        }
        
        // If no providers configured, enable all by default
        if (enabledProviders.length === 0) {
            enabledProviders = searchProviders.map(p => p.service)
        }
    }

    // Check if a search provider service is available
    function isProviderAvailable(serviceName) {
        const process = Process.createObject(root)
        if (!process) return false
        
        process.command = ["gdbus", "introspect", "--session", "--dest", serviceName, "--object-path", "/"]
        
        let available = false
        process.finished.connect(() => {
            available = (process.exitCode === 0)
            process.destroy()
        })
        
        process.running = true
        
        // Wait briefly for result (synchronous for simplicity)
        let timeout = 0
        while (process.running && timeout < 50) {
            Qt.callLater(() => {})
            timeout++
        }
        
        if (process.running) {
            process.running = false
            process.destroy()
            return false
        }
        
        return available
    }

    // Required function: Get items for launcher
    function getItems(query) {
        if (!query || query.trim() === "") {
            return []
        }

        const results = []
        const terms = query.trim().split(/\s+/)
        
        // Sort providers by priority (higher first)
        const sortedProviders = searchProviders.slice().sort((a, b) => b.priority - a.priority)
        
        // Search each enabled provider
        for (let i = 0; i < sortedProviders.length; i++) {
            const provider = sortedProviders[i]
            
            // Skip if not enabled
            if (enabledProviders.length > 0 && !enabledProviders.includes(provider.service)) {
                continue
            }
            
            // Get results from this provider
            const providerResults = searchProvider(provider, terms)
            
            // Add to results (limited per provider)
            for (let j = 0; j < Math.min(providerResults.length, maxResultsPerProvider); j++) {
                results.push(providerResults[j])
            }
        }

        return results
    }

    // Search a specific provider
    function searchProvider(provider, terms) {
        const process = Process.createObject(root)
        if (!process) return []

        // Build terms array for gdbus
        const termsArray = terms.map(t => `"${t}"`).join(", ")
        
        process.command = [
            "gdbus", "call",
            "--session",
            "--dest", provider.service,
            "--object-path", provider.path,
            "--method", "org.gnome.Shell.SearchProvider2.GetInitialResultSet",
            `[${termsArray}]`
        ]

        let output = ""
        process.standardOutput.newData.connect((data) => {
            output += data
        })

        process.finished.connect(() => {
            process.destroy()
        })

        process.running = true

        // Wait for completion
        let timeout = 0
        while (process.running && timeout < 100) {
            Qt.callLater(() => {})
            timeout++
        }

        if (process.running) {
            process.running = false
            process.destroy()
            return []
        }

        // Parse result IDs
        const resultIds = parseGdbusArrayResponse(output)
        
        if (resultIds.length === 0) {
            return []
        }

        // Get metadata for results
        return getResultMetas(provider, resultIds)
    }

    // Get metadata for search results
    function getResultMetas(provider, resultIds) {
        const process = Process.createObject(root)
        if (!process) return []

        // Build IDs array for gdbus
        const idsArray = resultIds.map(id => `"${id}"`).join(", ")
        
        process.command = [
            "gdbus", "call",
            "--session",
            "--dest", provider.service,
            "--object-path", provider.path,
            "--method", "org.gnome.Shell.SearchProvider2.GetResultMetas",
            `[${idsArray}]`
        ]

        let output = ""
        process.standardOutput.newData.connect((data) => {
            output += data
        })

        process.finished.connect(() => {
            process.destroy()
        })

        process.running = true

        let timeout = 0
        while (process.running && timeout < 100) {
            Qt.callLater(() => {})
            timeout++
        }

        if (process.running) {
            process.running = false
            process.destroy()
            return []
        }

        // Parse metadata and create items
        return parseResultMetas(output, resultIds, provider)
    }

    // Parse gdbus array response to extract result IDs
    function parseGdbusArrayResponse(output) {
        const ids = []
        // Match: (['result1', 'result2'],)
        const arrayMatch = output.match(/\(\[([^\]]*)\]/)
        if (!arrayMatch) return ids
        
        const content = arrayMatch[1]
        // Match quoted strings
        const regex = /'([^']+)'/g
        let match
        while ((match = regex.exec(content)) !== null) {
            ids.push(match[1])
        }
        
        return ids
    }

    // Parse result metadata from gdbus response
    function parseResultMetas(output, resultIds, provider) {
        const results = []
        
        // Try to extract metadata dictionaries
        // Format: ([{'id': <'...'>, 'name': <'...'>, 'description': <'...'>}, ...],)
        
        // For each result ID, try to extract name and description
        for (let i = 0; i < resultIds.length; i++) {
            const id = resultIds[i]
            
            // Find the metadata for this ID
            const idPattern = new RegExp(`'id':\\s*<'${id.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}'>`)
            const idMatch = output.match(idPattern)
            
            if (!idMatch) {
                // Fallback: use ID as name
                results.push({
                    name: id.split('.').pop() || id,
                    icon: provider.icon,
                    comment: `From ${provider.name}`,
                    action: `activate:${provider.service}:${provider.path}:${id}`,
                    categories: ["GNOME Search Providers"]
                })
                continue
            }
            
            // Find the metadata block for this result
            const startIdx = output.indexOf(idMatch[0])
            const blockMatch = output.substring(startIdx).match(/\{[^}]+\}/)
            
            if (!blockMatch) {
                results.push({
                    name: id,
                    icon: provider.icon,
                    comment: `From ${provider.name}`,
                    action: `activate:${provider.service}:${provider.path}:${id}`,
                    categories: ["GNOME Search Providers"]
                })
                continue
            }
            
            const block = blockMatch[0]
            
            // Extract name
            const nameMatch = block.match(/'name':\s*<'([^']+)'>/)
            const name = nameMatch ? nameMatch[1] : id
            
            // Extract description
            const descMatch = block.match(/'description':\s*<'([^']+)'>/)
            const description = descMatch ? descMatch[1] : ""
            
            results.push({
                name: name,
                icon: provider.icon,
                comment: (description ? description + " • " : "") + provider.name,
                action: `activate:${provider.service}:${provider.path}:${id}`,
                categories: ["GNOME Search Providers"]
            })
        }
        
        return results
    }

    // Required function: Execute item action
    function executeItem(item) {
        if (!item || !item.action) {
            console.warn("GnomeSearchProviders: No action defined for item")
            return
        }

        const parts = item.action.split(":")
        if (parts.length < 4 || parts[0] !== "activate") {
            console.warn("GnomeSearchProviders: Invalid action format:", item.action)
            return
        }

        const service = parts[1]
        const path = parts[2]
        const resultId = parts.slice(3).join(":")  // Rejoin in case ID contains colons

        // Call ActivateResult to open the item
        activateResult(service, path, resultId)
    }

    // Activate a search result (opens in the provider's application)
    function activateResult(service, path, resultId) {
        const process = Process.createObject(root)
        if (!process) {
            console.error("GnomeSearchProviders: Failed to create activation process")
            return
        }

        process.command = [
            "gdbus", "call",
            "--session",
            "--dest", service,
            "--object-path", path,
            "--method", "org.gnome.Shell.SearchProvider2.ActivateResult",
            `"${resultId}"`,
            "[]",
            "uint32:0"
        ]

        process.finished.connect(() => {
            if (process.exitCode !== 0) {
                console.error("GnomeSearchProviders: Failed to activate result:", resultId)
            }
            process.destroy()
        })

        process.running = true

        // Show feedback
        if (typeof ToastService !== "undefined") {
            ToastService.showInfo("Opening...")
        }
    }
}
