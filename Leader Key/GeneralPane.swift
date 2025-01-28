import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralPane: View {
  private let contentWidth = 600.0
  @EnvironmentObject private var config: UserConfig

  var body: some View {
    Settings.Container(contentWidth: contentWidth) {
      Settings.Section(
        title: "Config", bottomDivider: true, verticalAlignment: .top
      ) {
        VStack(alignment: .leading) {
          VStack {
              ConfigEditorView(group: $config.root.group)
              .frame(height: 400)
          }
          .padding(8)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .inset(by: 1)
              .stroke(Color.primary, lineWidth: 1)
              .opacity(0.1)
          )

            VStack{
                HStack {
                    Picker("Timeout", selection: $config.root.timeout) {
                        Text("500ms").tag(500)
                        Text("1s").tag(1000)
                        Text("2s").tag(2000)
                      }
                      .frame(width: 150)
                    Spacer()
                }
                HStack {
                  Button("Save to file") {
                    config.saveConfig()
                  }

                  Button("Reload from file") {
                    config.reloadConfig()
                  }

                  Button("Reveal config file in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([config.fileURL()])
                  }
                
                  Spacer()
                }

            }
        }
      }

      Settings.Section(title: "Shortcut") {
        KeyboardShortcuts.Recorder(for: .activate)
      }

      Settings.Section(title: "App") {
        LaunchAtLogin.Toggle()
      }
    }
  }
}

struct GeneralPane_Previews: PreviewProvider {
  static var previews: some View {
    return GeneralPane()
      .environmentObject(UserConfig())
  }
}
