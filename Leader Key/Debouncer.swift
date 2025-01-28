import Foundation

class Debouncer {
    private var workItem: DispatchWorkItem?
    /// In milliseconds
    private var delay: Int
    private let action: () -> Void
    
    /// Instance of debouncer used only to dismiss the application
    static var appDismissDebouncer: Debouncer?
    
    init(delay: Int, action: @escaping () -> Void){
        self.delay = delay
        self.action = action
    }
    
    func setNewDelay(delay: Int){
        self.delay = delay
    }
    
    func call() {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem { self.action() }
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.delay), execute: newWorkItem)
    }
}
