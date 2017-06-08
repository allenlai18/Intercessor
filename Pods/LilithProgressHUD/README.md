# LilithProgressHUD

[![Version](https://img.shields.io/cocoapods/v/LilithProgressHUD.svg?style=flat)](http://cocoapods.org/pods/LilithProgressHUD)
[![License](https://img.shields.io/cocoapods/l/LilithProgressHUD.svg?style=flat)](http://cocoapods.org/pods/LilithProgressHUD)
[![Platform](https://img.shields.io/cocoapods/p/LilithProgressHUD.svg?style=flat)](http://cocoapods.org/pods/LilithProgressHUD)

A beautiful, lightweight and elegant progress hud for iOS. 😎

![LilithProgressHUD Image](https://s4.postimg.org/4kd6bgtsd/Simulator_Screen_Shot_16_08_2016_8_06_52_AM.png)

## Features

- [x] Incredibly easy to use (no hoo-ha) 🙌🏼
- [x] Beautiful & customizable 😍
- [x] Made with love ❤️ 
- [x] I like watermelon 🍉

## Requirements

- iOS 8.0+
- Xcode 7.3

## Installation

### CocoaPods

LilithProgressHUD is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LilithProgressHUD'
```

### Manually 

1. Download and drop LilithProgressHUD.swift in your project.
2. Congratulations! 👏🏼

## Usage

** It's easy as pie. 😋 **

```swift
//Import LilithProgressHUD
import LilithProgressHUD

//Show the HUD
LilithProgressHUD.show()

... //Do something

//Hide the HUD
LilithProgressHUD.hide()
```

** If you want to be more specific... 😉 **

```swift
//Show the HUD on desired view
LilithProgressHUD.show(view)

... //Do something

//Hide all HUD's for a desired view
LilithProgressHUD.hide(view)
```

** Sexy extras. 😘 **

```swift
//The opacity for the hud
LilithProgressHUD.opacity = 0.75

//The size of the hud
LilithProgressHUD.size = 50

//The corner radius of the hud
LilithProgressHUD.cornerRadius = 3

//The fade in and out time
LilithProgressHUD.fadeTime = 1
```

## Contribute

We would love for you to contribute to **LilithProgressHUD**, check the ``LICENSE`` file for more info.

## License

LilithProgressHUD is available under the MIT license. See the LICENSE file for more info.
