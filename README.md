# LTSV.swift

LTSV Decoder / Encoder written in Swift

## Installation

LTSV.swift requires Xcode 12.4 or a Swift 5.3+ toolchain with the Swift Package Manager

### Swift Package Manager

```swift
// dependencies
.package(url: "https://github.com/griffin-stewie/LTSV.swift", .upToNextMinor(from: "0.1.0")),
```

```swift
// target.dependencies
.product(name: "LTSV", package: "LTSV.swift")
```

### CococaPods

I won't support it.

### Carthage

I won't support it.

## Usage

LTSV.swift supports `Codable` types.

```swift
import Foundation
import LTSV

struct Model: Codable {
    let label1: String
    let label2: String
}

let string = "label1:value1\tlabel2:value2"

let decoder = LTSVDecoder()
let model = try decoder.decode(Model.self, from: string)

let encoder = LTSVEncoder()
let result = try encoder.encode(model)

print(result)
// label1:value1\tlabel2:value2
```

It supports lines of LTSV strings into Array of Codable type as well.

## License

MIT licensed.
