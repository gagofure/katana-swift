//
//  ObserverInterceptorTests.swift
//  Katana
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Quick
import Nimble
@testable import Katana

class ObserverInterceptorTests: QuickSpec {
  // simple state change observer
  // simple typed state change observer
  // notification observer
  // dispatched observer
  // multiple dispatched observer
  // multiple observers to the store
  
  override func spec() {
    describe("The Observer Interceptor") {
      
      // MARK: State
      describe("When listening for state changes") {
        it("works") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenStateChange({ (prev: AppState, curr: AppState) -> Bool in
              return prev.todo.todos.count != curr.todo.todos.count
            }, [StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
        
        it("works with multiple items to dispatch") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenStateChange({ (prev: AppState, curr: AppState) -> Bool in
              return prev.todo.todos.count != curr.todo.todos.count
            }, [StateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(2))
        }
        
        it("handles nil init") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenStateChange({ (prev: AppState, curr: AppState) -> Bool in
              return prev.todo.todos.count != curr.todo.todos.count
            }, [NilStateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
      }
      
      
      // MARK: Any State
      describe("When listening for any state changes") {
        it("works") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenAnyStateChange({ (prev: State, curr: State) -> Bool in
              guard let s = prev as? AppState, let c = curr as? AppState else {
                return false
              }
              return s.todo.todos.count != c.todo.todos.count
            }, [StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
        
        it("works with multiple items to dispatch") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenAnyStateChange({ (prev: State, curr: State) -> Bool in
              guard let s = prev as? AppState, let c = curr as? AppState else {
                return false
              }
              return s.todo.todos.count != c.todo.todos.count
            }, [StateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(2))
        }
        
        it("handles nil init") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenAnyStateChange({ (prev: State, curr: State) -> Bool in
              guard let s = prev as? AppState, let c = curr as? AppState else {
                return false
              }
              return s.todo.todos.count != c.todo.todos.count
            }, [NilStateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
      }
      
      // MARK: Dispatchable
      describe("When listening for dispatchable") {
        it("works") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenDispatched(AddTodo.self, [StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
        
        it("works with multiple items to dispatch") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenDispatched(AddTodo.self, [StateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(2))
        }
        
        it("handles nil init") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .whenDispatched(AddTodo.self, [NilStateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          let todo = Todo(title: "title", id: "id")
          store.dispatch(AddTodo(todo: todo))
          
          expect(store.state.todo.todos.count).toEventually(equal(1))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
      }
      
      // MARK: Notifications
      describe("When listening for notifications") {
        let testNotification = Notification.Name("Test_Notification")
        
        it("works") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .onNotification(testNotification, [StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])

          expect(store.isReady).toEventually(beTrue())
          NotificationCenter.default.post(name: testNotification, object: nil)
          
          expect(store.state.todo.todos.count).toEventually(equal(0))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
        
        it("works with multiple items to dispatch") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .onNotification(testNotification, [StateChangeAddUser.self, StateChangeAddUser.self])
            ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          expect(store.isReady).toEventually(beTrue())
          NotificationCenter.default.post(Notification(name: testNotification))
          
          expect(store.state.todo.todos.count).toEventually(equal(0))
          expect(store.state.user.users.count).toEventually(equal(2))
        }
        
        it("handles nil init") {
          let interceptor = ObserverInterceptor<AppState>.observe([
            .onNotification(testNotification, [NilStateChangeAddUser.self, StateChangeAddUser.self])
          ])
          
          let store = Store<AppState, TestDependenciesContainer>(interceptors: [interceptor])
          
          expect(store.isReady).toEventually(beTrue())
          NotificationCenter.default.post(Notification(name: testNotification))
          
          expect(store.state.todo.todos.count).toEventually(equal(0))
          expect(store.state.user.users.count).toEventually(equal(1))
        }
      }
    }
  }
}

private struct AddTodo: TestStateUpdater {
  let todo: Todo
  
  func updateState(_ state: inout AppState) {
    state.todo.todos.append(self.todo)
  }
}

private struct AddUser: TestStateUpdater {
  let user: User
  
  func updateState(_ state: inout AppState) {
    state.user.users.append(self.user)
  }
}

private struct AddTodoWithDelay: TestStateUpdater {
  let todo: Todo
  let waitingTime: TimeInterval
  
  func updateState(_ state: inout AppState) {
    // Note: this is just for testing, never do things like this in real apps
    Thread.sleep(forTimeInterval: self.waitingTime)
    state.todo.todos.append(self.todo)
  }
}

private struct StateChangeAddUser: TestStateUpdater, StateObserverDispatchable, DispatchObserverDispatchable, NotificationObserverDispatchable {
  init?(prevState: State, currentState: State) {
    
  }
  
  init?(dispatchedItem: Dispatchable, prevState: State, currentState: State) {

  }
  
  init?(notification: Notification) {
    
  }
  
  func updateState(_ state: inout AppState) {
    state.user.users.append(User(username: "the username"))
  }
}

private struct NilStateChangeAddUser: TestStateUpdater, StateObserverDispatchable, DispatchObserverDispatchable, NotificationObserverDispatchable {
  init?(prevState: State, currentState: State) {
    return nil
  }
  
  init?(dispatchedItem: Dispatchable, prevState: State, currentState: State) {
    return nil
  }
  
  init?(notification: Notification) {
    return nil
  }
  
  func updateState(_ state: inout AppState) {
    state.user.users.append(User(username: "the username"))
  }
}