import Foundation

struct ProjectDetector {
    func detect(at folderURL: URL) -> DevProject {
        let fileManager = FileManager.default
        var name = folderURL.lastPathComponent
        var editor: DevProject.Editor = .visualStudioCode
        var startCommand = ""
        var port: Int?

        let contents = (try? fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        if contents.contains(where: { $0.pathExtension == "xcworkspace" || $0.pathExtension == "xcodeproj" }) {
            editor = .xcode
        } else if fileManager.fileExists(atPath: folderURL.appendingPathComponent(".zed").path) {
            editor = .zed
        }

        let packageJSON = folderURL.appendingPathComponent("package.json")
        if let data = try? Data(contentsOf: packageJSON),
           let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let packageName = object["name"] as? String, !packageName.isEmpty {
                name = packageName
            }

            if let scripts = object["scripts"] as? [String: Any] {
                if scripts["dev"] != nil {
                    startCommand = "npm run dev"
                } else if scripts["start"] != nil {
                    startCommand = "npm start"
                }
            }

            if let scripts = object["scripts"] as? [String: Any],
               let devScript = scripts["dev"] as? String {
                port = parsePort(from: devScript)
            }
        }

        if startCommand.isEmpty {
            if fileManager.fileExists(atPath: folderURL.appendingPathComponent("Package.swift").path) {
                startCommand = "swift run"
            } else if fileManager.fileExists(atPath: folderURL.appendingPathComponent("docker-compose.yml").path) ||
                        fileManager.fileExists(atPath: folderURL.appendingPathComponent("compose.yml").path) {
                startCommand = "docker compose up"
            }
        }

        return DevProject(
            name: name,
            path: folderURL.path,
            editor: editor,
            startCommand: startCommand,
            repositoryURL: detectGitRemote(in: folderURL),
            port: port
        )
    }

    private func detectGitRemote(in folderURL: URL) -> String {
        let configURL = folderURL.appendingPathComponent(".git/config")
        guard let config = try? String(contentsOf: configURL, encoding: .utf8) else {
            return ""
        }

        let lines = config.components(separatedBy: .newlines)
        var insideOrigin = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("[") {
                insideOrigin = trimmed == "[remote \"origin\"]"
                continue
            }

            if insideOrigin, trimmed.hasPrefix("url =") {
                let raw = trimmed.replacingOccurrences(of: "url =", with: "")
                    .trimmingCharacters(in: .whitespaces)
                return normalizeGitRemote(raw)
            }
        }

        return ""
    }

    private func normalizeGitRemote(_ remote: String) -> String {
        var value = remote

        if value.hasPrefix("git@"), let colon = value.firstIndex(of: ":") {
            let hostStart = value.index(value.startIndex, offsetBy: 4)
            let host = String(value[hostStart..<colon])
            let pathStart = value.index(after: colon)
            let repoPath = String(value[pathStart...])
            value = "https://\(host)/\(repoPath)"
        } else if value.hasPrefix("ssh://git@") {
            value = value.replacingOccurrences(of: "ssh://git@", with: "https://")
        }

        if value.hasSuffix(".git") {
            value.removeLast(4)
        }

        return value
    }

    private func parsePort(from command: String) -> Int? {
        let patterns = [
            #"--port(?:=|\s+)(\d{2,5})"#,
            #"-p(?:=|\s+)(\d{2,5})"#,
            #"PORT=(\d{2,5})"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(command.startIndex..<command.endIndex, in: command)
            guard let match = regex.firstMatch(in: command, range: range),
                  match.numberOfRanges > 1,
                  let portRange = Range(match.range(at: 1), in: command),
                  let parsed = Int(command[portRange]),
                  (1...65535).contains(parsed) else {
                continue
            }
            return parsed
        }

        return nil
    }
}
