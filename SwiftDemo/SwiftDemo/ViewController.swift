//
//  ViewController.swift
//  DemoTest
//
//  Created by yiyi on 2022/12/4.
//

import UIKit
import SnapKit
import FuhaiRbox

class ViewController: UIViewController {
    var boxShowLog: String = ""
    var fh_macid: String?
    var fh_time: Int?
    var fh_md5: String?
    var fh_recycleId: String?
    
    lazy var debugLab: UILabel = {
        let label = UILabel.init()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "发布环境"
        return label
    }()
    
    lazy var debugSwitch: UISwitch = {
        let deSwitch = UISwitch.init()
        deSwitch.isOn = false
        deSwitch.addTarget(self, action: #selector(debugSwitch(sender:)), for: .valueChanged)
        return deSwitch
    }()
    
    lazy var clearBtn: UIButton = {
        let button = UIButton.init(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitle("清除日志", for: .normal)
        button.addTarget(self, action: #selector(clearboxShowLog), for: .touchUpInside)
        return button
    }()
    
    lazy var codeView: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        view.layer.cornerRadius = 8
        view.isEditable = false
        if #available(iOS 15.0, *) {
            self.setContentScrollView(nil)
        }
        return view
    }()
    
    lazy var scanBtn: UIButton = {
        let button = UIButton.init(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitle("二维码扫描", for: .normal)
        button.addTarget(self, action: #selector(scanFRbox), for: .touchUpInside)
        return button
    }()
    
    lazy var md5Btn: UIButton = {
        let button = UIButton.init(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitle("获取MD5密码", for: .normal)
        button.addTarget(self, action: #selector(requestMd5), for: .touchUpInside)
        return button
    }()
    
    lazy var openBtn: UIButton = {
        let button = UIButton.init(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitle("Rbox开箱", for: .normal)
        button.addTarget(self, action: #selector(openFRbox), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addAllSubviews()
        addAllConstraints()
        addLogEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configFRbox()
    }
    
    deinit {
        print("***\(Self.self) \(#function)")
    }
    
    
    // MARK: - UI Component
    func addAllSubviews() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        view.addSubview(self.debugSwitch)
        view.addSubview(self.debugLab)
        view.addSubview(self.codeView)
        view.addSubview(self.scanBtn)
        view.addSubview(self.md5Btn)
        view.addSubview(self.openBtn)
        view.addSubview(self.clearBtn)
    }
    
    func addAllConstraints() {
        
        codeView.snp.makeConstraints { make in
            make.top.equalTo(safeArea.top + 64)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(350)
        }
        
        debugSwitch.snp.makeConstraints { make in
            make.top.equalTo(codeView.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(51)
            make.height.equalTo(31)
        }
    
        debugLab.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(debugSwitch.snp.bottom).offset(5)
        }

        scanBtn.snp.makeConstraints { make in
            make.top.equalTo(debugLab.snp.bottom).offset(20)
            make.left.equalTo(60)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        md5Btn.snp.makeConstraints { make in
            make.top.equalTo(debugLab.snp.bottom).offset(20)
            make.right.equalTo(-60)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        openBtn.snp.makeConstraints { make in
            make.top.equalTo(scanBtn.snp.bottom).offset(20)
            make.left.equalTo(60)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        clearBtn.snp.makeConstraints { make in
            make.top.equalTo(scanBtn.snp.bottom).offset(20)
            make.right.equalTo(-60)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
    }
    
    
    // MARK: - 开箱子方法
    @objc func clearboxShowLog() {
        codeView.text = ""
        boxShowLog = ""
    }
    
    @objc func configFRbox(isDebug: Bool = false) {
        let appKey = "queinier0va9yae2aimohchie4awooPh"
        let appSecret = "queisheewahnahNgoveeXai7iShei4ooyo3cu0hoh3ahsoo9Jeeshoh7Aif4Xee1"
        FRbox.config(appKey:appKey, appSecret: appSecret, isDebug: isDebug){_ in }
    }
    
    @objc func scanFRbox() {
        FRbox.scanRbox {[weak self] code, data in
            if code == 200 {
                self?.fh_macid = data
            }
        }
    }
    
    @objc func openFRbox() {
        guard let md5 = fh_md5, let time = fh_time, let recycleId = fh_recycleId else {
            boxShowLog = boxShowLog + "请先获取Md5和时间戳和循环Id\n"
            codeView.text = boxShowLog
            return
        }
        FRbox.openRbox(md5: md5, time: time, recycleId: recycleId) {[weak self] _ in
            self?.fh_time = nil
            self?.fh_md5 = nil
            self?.fh_recycleId = nil
        }
    }
    
    
    // MARK: - 测试专用方法
    func addLogEvent() {
        FRbox.logEvent {[weak self] data in
            self?.boxShowLog = (self?.boxShowLog ?? "") + data + "\n"
            self?.codeView.text = self?.boxShowLog
        }
    }
    
    @objc func debugSwitch(sender: UISwitch) {
        if(sender.isOn) {
            debugLab.text = "Debug环境"
        }else {
            debugLab.text = "Release环境"
        }
        /// 重新验证授权
        configFRbox(isDebug: sender.isOn)
    }
    
    @objc func requestMd5() {
        guard let macid = fh_macid else {
            boxShowLog = boxShowLog + "请先扫描运单号获取MacId\n"
            codeView.text = boxShowLog
            return
        }
        FRbox.md5Pwd(macId: macid) {[weak self] code, md5, time, recycleId  in
            self?.fh_macid = nil
            if code == 200 {
                self?.fh_md5 = md5
                self?.fh_time = time
                self?.fh_recycleId = recycleId
            }
        }
    }
}


extension ViewController {
    // 获取安全区域
    var safeArea: UIEdgeInsets {
        var inset =  UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        guard #available(iOS 11.0, *) else { return inset }
        inset = view.safeAreaInsets
        if inset.bottom <= 0 {
            inset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return inset
    }
}

