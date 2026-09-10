import SwiftUI

struct ProjectEditorView: View {
    @Binding var project: DevProject

    var body: some View {
        Form {
            Section("Project") {
                TextField("Name", text: $project.name)
                LabeledContent("Folder") {
                    Text(project.path)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Picker("Editor", selection: $project.editor) {
                    ForEach(DevProject.Editor.allCases) { editor in
                        Text(editor.displayName).tag(editor)
                    }
                }
            }

            Section("Development") {
                TextField("Start command", text: $project.startCommand, prompt: Text("npm run dev"))
                    .font(.system(.body, design: .monospaced))

                TextField("Local port", text: portBinding, prompt: Text("3000"))
                    .font(.system(.body, design: .monospaced))

                Text("The start command runs from the project folder using zsh.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Repository") {
                TextField("Repository URL", text: $project.repositoryURL, prompt: Text("https://github.com/owner/repo"))
            }
        }
        .formStyle(.grouped)
        .navigationTitle(project.name)
    }

    private var portBinding: Binding<String> {
        Binding(
            get: { project.port.map(String.init) ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    project.port = nil
                } else if let port = Int(trimmed), (1...65535).contains(port) {
                    project.port = port
                }
            }
        )
    }
}
