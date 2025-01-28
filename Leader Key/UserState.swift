import SwiftUI

final class UserState: ObservableObject {
  var userConfig: UserConfig!

  @Published var display: String?
  @Published var currentGroup: Group?
    @Published var currentTimeout: Int

  init(userConfig: UserConfig!, lastChar: String? = nil, currentGroup: Group? = nil) {
    self.userConfig = userConfig
    display = lastChar
    self.currentGroup = currentGroup
      self.currentTimeout = 2000
  }

  func clear() {
    display = nil
      currentGroup = userConfig.root.group
      currentTimeout = userConfig.root.timeout
  }
}
