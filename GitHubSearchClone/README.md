# GitHubSearchClone

[GitHubSearch](https://github.com/ReactorKit/ReactorKit/tree/master/Examples/GitHubSearch) 예제를 보고 만든 클론 프로젝트 입니다.

### 주요 기능
+ tableView에 State mapping
+ 무한 스크롤 구현
+ mutate()에서 API 비동기 호출

## 예제와 다르게 구현한 부분
### 1. reactor 주입

기존 예제에서는 AppDelegate에서 reactor 주입을 구현하였으나 SceneDelegate에서 구현하였다.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        guard let rootVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "GitHubSearchViewController") as? GitHubSearchViewController else { return }
        rootVC.reactor = GitHubSearchViewReactor()
        
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBar.prefersLargeTitles = true
        
        window?.rootViewController = navigationController
    }
```

### 2. newState return 

기존 예제에서는 아래와 같이 상태 마다 각각 새로운 newState를 return 하도록 하였지만 

```swift
 func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case let .setQuery(query):
      var newState = state
      newState.query = query
      return newState

    case let .setRepos(repos, nextPage):
      var newState = state
      newState.repos = repos
      newState.nextPage = nextPage
      return newState

    case let .appendRepos(repos, nextPage):
      var newState = state
      newState.repos.append(contentsOf: repos)
      newState.nextPage = nextPage
      return newState

    case let .setLoadingNextPage(isLoadingNextPage):
      var newState = state
      newState.isLoadingNextPage = isLoadingNextPage
      return newState
    }
  }
  
  ```
Swift의 switch 문은 다른 언어와 다르게 해당하는 case문이 종료되면 switch 문 자체가 종료되기 때문에 모든 case 내에 return을 작성하지 않아도 되기 때문에 아래와 같이 하나의 newState를 return하도록 하였다. 

```swift
func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .setQuery(let query):
            newState.query = query
            
        case .setRepos(let repos, let nextPage):
            newState.repos = repos
            newState.nextPage = nextPage
            
        case .setLoadingNextPage(let isLoadingNextPage):
            newState.isLoadingNextPage = isLoadingNextPage
            
        case .appendRepos(let repos, nextPage: let nextPage):
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
        }
        
        return newState
    }
```
### 3. throttle의 latest 추가
latest 매개변수는 작성하지 않는 경우 default로 true지만 명시적으로 보여주기 위해서 아래와 같이 latest 매개변수르 추가하였다.
```swift
.throttle(.milliseconds(300), latest: true, scheduler: MainScheduler.instance)
```

## GitHubSearchClone 을 통해 배운 점
### - throttle
지정한 시간 범위내에서 발생한 이벤트 중 하나의 이벤트만 방출하도록 하는 operator이다.
latest가 true 인 경우 가장 최신의 이벤트를, false인 경우 시간 범위 내에서 첫번째 이벤트 방출
```swift
.throttle(.milliseconds(300), latest: true, scheduler: MainScheduler.instance
```
### - reactor?.currentState
 View에서 Reactor의 현재 State 프로퍼티 값을 알려주는 프로퍼티
```swift
reactor.state.map { $0.State의프로퍼티 }
```
기존엔 위의 방법으로 reactor의 state 값이 변하여 상태를 전달받을 때만 View가 Reactor의 State를 알 수 있는 줄 알았다. 그러나 reactor.currentState 프로퍼티를 사용하면 현재 reactor의 State를 알 수 있다.
