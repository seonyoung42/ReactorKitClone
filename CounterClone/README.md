# CounterClone
[Counter](https://github.com/ReactorKit/ReactorKit/tree/master/Examples/Counter) 예제를 보고 만든 클론 프로젝트 입니다.

## CounterClone을 통해 배운 점

### 1. UIActivityIndicatorView
UIActivityIndicatorView의 **hidesWhenstopped** : animating 상태가 아닌 경우에는 ActivityIndicatorView르 hidden해주는 프로퍼티

```swift
reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityView.isHidden = true
                    self?.activityView.startAnimating()
                } else {
                    self?.activityView.isHidden = false
                    self?.activityView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
```
hidesWhenStopped를 몰랐기 때문에 기존에는 isLoading를 subscibe하고 isLoading의 상태에 따라 hidden처리와 animating 상태를 변경해주었습니다.

```swift

override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView.hidesWhenStopped = true
    }
    
reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityView.rx.isAnimating)
            .disposed(by: disposeBag)
```
그러나 hidesWehnStopped를 사용하면 다음과 같이 activitiyView의 isAnimating 만 bind하면 되기 때문에 훨씬 더 간결하게 코드를 작성할 수 있습니다.

### 2. Pulse
Pulse는 @propertyWrapper로 정의된 타입으로, 새로운 값이 할당되었을 때만 이벤트를 방출하도록 합니다.
mutation에 의해 새로운 State가 반환될 때마다 State의 프로퍼티 중 변화가 없는 프로퍼티들도 이에 영향을 받게 되는데,
여태까지는 '.distinctUntilChanged()'를 사용하여 이를 제어하였지만 이전과 값은 값이 새로이 할당된 경우를 구별할 수 없다는 단점이 있었습니다. Pulse를 사용하면 이러한 문제를 해결할 수 있습니다.

```swift
 struct State {
        var count = 0
        var isLoading = false
        @Pulse var alertMessage: String?
    }
``` 
먼저 Reactor에서 State의 프로퍼티 중 Pulse를 적용할 프로퍼티 앞에 @Pulse라고 작성하고

```swift
 reactor.pulse(\.$alertMessage)
            .subscribe(onNext: { [weak self] message in
                let activityVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                activityVC.addAction(action)
                self?.present(activityVC, animated: false)
            })
            .disposed(by: disposeBag)
```
다음과 같이 View에서 reactor의 pulse 중 해당하는 프로퍼티를 가져와 다른 프로퍼티와 동일하게 사용하면 됩니다.

### 3. CompactMap
compactMap 이란 1차원 배열에서 nil을 제거하고 옵셔널 바인딩을 해주는 고차함수입니다. 동작을 코드로 확인하면 다음과 같습니다.

```swift
let testArray :[Int?] = [0, 1, 2, nil, 4, 5]
let compactMapArray = testArray.compactMap { $0 }
print(compactMapArray) // [0,1,2,4,5] 출력
```
기존 예제에서 compactMap은 아래와 같이 사용되었습니다.
```swift
reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                let activityVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                activityVC.addAction(action)
                self?.present(activityVC, animated: false)
            })
            .disposed(by: disposeBag)
```
alertMessage가 String? 타입이라 nil인 경우를 대비해서 compactMap을 넣은 것 같은데 alertMessage가 @Pulse로 정의되어 있고 alertMessage가 변화하는 부분에는 그 String 값이 항상 정의되어있기 때문에 compactMap의 필요성을 느끼지 못하였고, 저는 아래와 같이 compactMap을 제거하였습니다.

```swift
reactor.pulse(\.$alertMessage)
            .subscribe(onNext: { [weak self] message in
                let activityVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                activityVC.addAction(action)
                self?.present(activityVC, animated: false)
            })
            .disposed(by: disposeBag)
```
