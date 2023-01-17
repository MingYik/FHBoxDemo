#### iOS SDK 集成指南

### 前言

*   SDK的打包方式是纯Swift的.a静态库，导入需要做些简单配置。
*   下载包已经兼容了Swift项目和OC项目，有相应的Demo案例可以使用测试。
*   目前仅支持手动方式导入SDK静态库进行集成，后续会提供更多集成方式。
*   项目配置简单，但需要仔细阅读文档和对应的Demo工程
*   本文档适用SDK版本：1.0.0 及以后。
*   [点击前往下载iOS SDK](https://github.com/MingYik/FuhaiRbox.git)

### 1. 创建应用

*   进入“开发者中心-应用管理”，点击“创建应用”。创建应用指南
*   点击应用配置，获取到相应的`AppKey`、`AppSecret`信息。

### 2. 手动集成

**iOS SDK资料包结构**

    FuhaiRbox/
      |- README.md （SDK集成指南）
      |- libFuhaiRbox/ （SDK完整资源）
      |    |- FuhaiRbox.bundle （SDK媒体资源包）
      |    |- libFuhaiRbox.a （SDK静态链接库）  
      |    |- include/ （仅OC项目需要导入的SDK头文件）
      |    |   |- FuhaiRbox/ 
      |    |        |- FuhaiRbox-Swift.h（SDK的.h头文件）
      |    |- FuhaiRbox.swiftmodule/
      |    |   |- .swiftdoc（Swift注释文档）
      |    |   |- .swiftmodule（包含序列化过的ATS，也包含SIL） 
      |    |   |- .swiftinterface（模块稳定性，swfit5.0可以向后兼容） 
      |    |   |- Project/ 
      |    |        |- .swiftsourceinfo（Swift源码的补充信息）
      | - SwiftDemo/ （Swift手动集成演示Demo工程）
      | - ObjectCDemo/ （Objective-C手动集成演示Demo工程）

- SwiftDemo：Swift手动集成演示Demo工程。
- ObjectCDemo：Objective-C 手动集成演示Demo工程。
- 支持`x86_64`、`arm64`，因此同时支持 Simulator 和 Device 设备
- 仅支持 swift5.0 及以后，系统版本最低支持 iOS 11.0

**在项目设置中添加以下系统库支持**

```
  |- UIKit
  |- Foundation
  |- AVFoundation
  |- CoreBluetooth
  |- CoreFoundation
  |- CoreGraphics
  |- QuartzCore
  |- SystemConfiguration
  |- CommonCrypto
  |- ...
```

### 3.Swift项目SDK资源导入
- 打开项目工程（.xcworkspace或者.xcodeproj），将libFuhaiRbox添加到项目工程目录下
- 弹窗提示选项请同时勾选`Copy items if needed`和`Create groups`确认完成继续
- 导入后swift项目可以删除`include`这个文件夹
- 在导入时，Xcode正常情况下会自动添加引用，但是偶尔也会不添加，注意检查下用路径，如果报错找不到库或者头文件，一般都是下面的引用没有添加，我们需要在 Xcode - Targets - Build Settings - Search Paths - Library Search Paths 中引入：`$(PROJECT_DIR)/项目名称/FuhaiRbox`
- 由于 Swift 的 Module 机制，我们需要手动在 Xcode - Targets - Build Settings - Swift Compiler - Search Paths - Import Paths 中引入：`$(PROJECT_DIR)/项目名称/FuhaiRbox`

**需要在info.plist增加配置和授权说明**
- Xcode - Targets - info - Custom iOS Target Properties 中增加配置
- 蓝牙外设权限`Privacy - Bluetooth Peripheral Usage Description`
- 蓝牙权限`Privacy - Bluetooth Always Usage Description`
- 相机权限`Privacy - Camera Usage Description`
- 网络安全`App Transport Security Settings` 下增加 `Allow Arbitrary Loads` 设置 YES

**项目中使用静态库**
- 添加库引用`import FuhaiRbox`
- 调用静态库公共类的方法

```Swift
@objc public class FRbox : NSObject {

    /// FRbox初始化配置
    /// - Parameters:
    ///   - appKey: 应用appKey
    ///   - appSecret: 应用AppSecret
    ///   - isDebug: 调试模式
    ///   - block: 回调`(code) => (状态码)`
    @objc public class func config(appKey: String, appSecret: String, isDebug: Bool, block: @escaping (Int) -> Void)

    /// FRbox开启扫描
    /// - Parameters:
    ///   - block: 回调`(code,macId) => (状态码,蓝牙地址)`
    @objc public class func scanRbox(block: @escaping (Int, String) -> Void)

    /// FRbox密码开箱
    /// - Parameters:
    ///   - md5: 加密串
    ///   - time: 时间戳
    ///   - recycleId: 循环标识
    ///   - block: 回调`(code) => (状态码)`
    @objc public class func openRbox(md5: String, time: Int, recycleId: String, block: @escaping (Int) -> Void)

    /// 开启日志打印
    /// - Parameters:
    ///   - block: 回调`(msg) => (日志信息)`
    @objc public class func logEvent(block: @escaping (String) -> Void)

    /// 获取MD5加密密码
    /// - Parameters:
    ///   - macId: 蓝牙地址
    ///   - block: 回调`(code,md5,time,recycleId) => (状态码,加密串,时间戳,循环标识)`
    @objc public class func md5Pwd(macId: String, block: @escaping (Int, String, Int, String) -> Void)
    
}

```

### 4.Object-C项目SDK资源导入
- 打开项目工程（.xcworkspace或者.xcodeproj），将libFuhaiRbox添加到项目工程目录下
- 弹窗提示选项请同时勾选`Copy items if needed`和`Create groups`确认完成继续
- 在导入时，Xcode正常情况下会自动添加引用，但是偶尔也会不添加，注意检查下用路径，如果报错找不到库或者头文件，一般都是下面的引用没有添加，我们需要在 Xcode - Targets - Build Settings - Search Paths - Library Search Paths 中引入：`$(PROJECT_DIR)/项目名称/FuhaiRbox`
- 本库Swift的.a静态库，需要swift的标准库支持。由于只有在iOS12.2以后的版本，系统才会包含Swift的标准库，而我们最低版本支持iOS11.0，所以xcode需要设置Xcode - Targets - Build Settings - Build Options - Always Embed Swift Standard Libraries 设置 YES
- 由于Swift标准库版本不同，Object-C项目可能会找不到swift的各种基础库。终极简单解决办法就是在Object-C项目新建一空的swift文件（项目已经存在就不需要创建了）。如需新建空的Swift文件则会提示创建桥接文件，此时可以不用创建，点击`Don't Create`继续完新建Swift文件

**需要在info.plist增加配置和授权说明**
- Xcode - Targets - info - Custom iOS Target Properties 中增加配置
- 蓝牙外设权限`Privacy - Bluetooth Peripheral Usage Description`
- 蓝牙权限`Privacy - Bluetooth Always Usage Description`
- 相机权限`Privacy - Camera Usage Description`
- 网络安全`App Transport Security Settings` 下增加 `Allow Arbitrary Loads` 设置 YES

**项目中使用静态库**
- 添加库引用`#import "FuhaiRbox-Swift.h"`
- 调用静态库公共类的方法

```ObjectiveC
@interface FRbox : NSObject

/// FRbox初始化配置
/// \param appKey 应用appKey
/// \param appSecret 应用AppSecret
/// \param isDebug 调试模式
/// \param block 回调<code>(code) => (状态码)</code>
+ (void)configWithAppKey:(NSString * _Nonnull)appKey appSecret:(NSString * _Nonnull)appSecret isDebug:(BOOL)isDebug block:(void (^ _Nonnull)(NSInteger))block;

/// FRbox开启扫描
/// \param block 回调<code>(code,macId) => (状态码,蓝牙地址)</code>
+ (void)scanRboxWithBlock:(void (^ _Nonnull)(NSInteger, NSString * _Nonnull))block;

/// FRbox密码开箱
/// \param md5 加密串
/// \param time 时间戳
/// \param recycleId 循环标识
/// \param block 回调<code>(code) => (状态码)</code>
+ (void)openRboxWithMd5:(NSString * _Nonnull)md5 time:(NSInteger)time recycleId:(NSString * _Nonnull)recycleId block:(void (^ _Nonnull)(NSInteger))block;

/// 开启日志打印
/// \param block 回调<code>(msg) => (日志信息)</code>
+ (void)logEventWithBlock:(void (^ _Nonnull)(NSString * _Nonnull))block;

/// 获取MD5加密密码
/// \param macId 蓝牙地址
/// \param block 回调<code>(code,md5,time,recycleId) => (状态码,加密串,时间戳,循环标识)</code>
+ (void)md5PwdWithMacId:(NSString * _Nonnull)macId block:(void (^ _Nonnull)(NSInteger, NSString * _Nonnull, NSInteger, NSString * _Nonnull))block;

@end

```

### 5.使用说明
- 本静态库不支持`Enable Bitcode`，如需开启`Enable Bitcode`请联系研发定制
- 本静态库仅仅支持最新系统架构`x86_64`、`arm64`，如需要提供兼容旧版架构请联系研发定制
- 使用过程中可能因项目不同兼容性会有些许问题，解决不了的需要改版的请与研发沟通定制
- 使用接口功能会有各种状态和数据输出，请根据不同的情况做出正确的应对。以下状态说明适用SDK版本：1.0.0

**回调块如有返回状态码和数据，有且仅有状态码为成功状态，数据才会返回**

|状态码 | 状态说明 | - |状态码 | 状态说明
|---|---|---|---|---
| 1001 | 无可用网络         |  | 1201 | MD5开箱失败
| 1002 | 摄像头未授权       |  | 1202 | 超级开箱失败
| 1003 | 蓝牙未授权         |  | 1203 | RTC时间同步失败
| 1004 | 蓝牙未开启或不可用 |  | 1204 | 综合查询失败
| 1101 | 蓝牙连接失败       |  | 1301 | 网络请求超时
| 1102 | 蓝牙连接超时       |  | 1302 | 初始化配置失败
| 1103 | 蓝牙繁忙写入等待   |  | 1303 | 条形码查询MacID失败
| 1104 | 蓝牙响应错误       |  | 1304 | 二维码查询MacID失败
| 1105 | 蓝牙响应超时       |  | 1305 | 开箱上报失败
| 200  | 执行操作成功       |  |      | 
