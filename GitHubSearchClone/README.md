# GitHubSearchClone

[GitHubSearch](https://github.com/ReactorKit/ReactorKit/tree/master/Examples/GitHubSearch) 예제를 보고 만든 클론 프로젝트 입니다.

### 주요 기능
+ tableView에 State mapping
+ 무한 스크롤 구현
+ mutate()에서 API 비동기 호출

## 예제와 다르게 구현한 부분
### 1. reactor 주입

기존 예제에서는 AppDelegate에서 reactor 를 주입을 구현하였지만 저는 SceneDelegate에서 구현하였습니다.

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
저는 아래와 같이 하나의 newState를 return하도록 하였습니다. 왜냐하면 swift의 switch 문은 다른 언어와 다르게 해당하는 case문이 종료되면 switch 문 자체가 종료되기 때문에 모든 case 내에 return을 작성하지 않아도 되기 때문입니다.

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
