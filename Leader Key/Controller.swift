import Cocoa
import Combine

enum KeyHelpers: UInt16 {
  case Return = 36
  case Tab = 48
  case Space = 49
  case Backspace = 51
  case Escape = 53
}

class Controller {
  var window: Window!
  var userState: UserState
  var userConfig: UserConfig

  var focusCancellable: AnyCancellable?

  var subjectInputCancellable: AnyCancellable?
  var subjectCancellable: AnyCancellable?

  var actionInputCancellable: AnyCancellable?

  init(userState: UserState, userConfig: UserConfig) {
    self.userState = userState
    self.userConfig = userConfig
  }

  func show() {
    window.show()
  }

  func hide() {
    window.hide {
      self.clear()
    }
  }

  func keyDown(with event: NSEvent) {
      Debouncer.appDismissDebouncer?.call()

    if event.modifierFlags.contains(.command) {
      switch event.charactersIgnoringModifiers {
      case ",":
        NSApp.sendAction(#selector(AppDelegate.settingsMenuItemActionHandler(_:)), to: nil, from: nil)
        hide()
        return
      case "w":
        hide()
        return
      case "q":
        NSApp.terminate(nil)
        return
      default:
        break
      }
    }

    switch event.keyCode {
    case KeyHelpers.Backspace.rawValue: clear()
    case KeyHelpers.Escape.rawValue: hide()
    default:
      let char = event.charactersIgnoringModifiers?.lowercased()

        let list = (userState.currentGroup != nil) ? userState.currentGroup : userConfig.root.group

      let hit = list?.actions.first { item in
        switch item {
        case let .group(group):
          if group.key?.lowercased() == char {
            return true
          }
        case let .action(action):
          if action.key.lowercased() == char {
            return true
          }
        }
        return false
      }

      switch hit {
      case let .action(action):
        runAction(action)
        hide()
      case let .group(group):
        userState.display = group.key
        userState.currentGroup = group
      case .none:
        window.shake()
      }
    }
  }

  private func runAction(_ action: Action) {
    switch action.type {
    case .application:
      NSWorkspace.shared.openApplication(
        at: URL(fileURLWithPath: action.value), configuration: NSWorkspace.OpenConfiguration())
    case .url:
      NSWorkspace.shared.open(
        URL(string: action.value)!, configuration: DontActivateConfiguration.shared.configuration)
    case .command:
      CommandRunner.run(action.value)
    case .folder:
      NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: action.value)
    default:
      print("\(action.type) unknown")
    }
  }

  private func clear() {
    userState.clear()
  }
}

class DontActivateConfiguration {
  let configuration = NSWorkspace.OpenConfiguration()

  static var shared = DontActivateConfiguration()

  init() {
    configuration.activates = false
  }
}
