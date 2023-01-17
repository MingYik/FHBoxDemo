//
//  ViewController.m
//  ObjectCDemo
//
//  Created by apple on 2023/1/9.
//

#import "ViewController.h"
#import "FuhaiRbox-Swift.h"
#import "Masonry.h"

@interface ViewController ()
@property (nonatomic, strong) NSString *boxShowLog;
@property (nonatomic, strong) NSString *fh_macid;
@property (nonatomic, strong) NSString *fh_recycleId;
@property (nonatomic, strong) NSString *fh_md5;
@property (nonatomic, assign) NSInteger fh_time;

@property (nonatomic, strong) UILabel *debugLab;
@property (nonatomic, strong) UISwitch *debugSwitch;
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UITextView *codeView;
@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UIButton *md5Btn;
@property (nonatomic, strong) UIButton *openBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addAllSubviews];
    [self addAllConstraints];
    [self addLogEvent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configFRbox:NO];
}

- (void)dealloc {
    NSLog(@"****%s",__func__);
}


#pragma mark -  UI Component
// 获取安全区域
- (UIEdgeInsets)safeArea {
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        inset = self.view.safeAreaInsets;
        if (inset.bottom <= 0) {
            inset = UIEdgeInsetsMake(20, 0, 0, 0);
        }
    }
    return inset;
}

- (void)addAllSubviews {
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
    }
    [self.view addSubview:self.debugSwitch];
    [self.view addSubview:self.debugLab];
    [self.view addSubview:self.codeView];
    [self.view addSubview:self.scanBtn];
    [self.view addSubview:self.md5Btn];
    [self.view addSubview:self.openBtn];
    [self.view addSubview:self.clearBtn];
}

- (void)addAllConstraints {
    [_codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(self.safeArea.top + 64);
        make.left.offset(10);
        make.right.offset(-10);
        make.height.offset(350);
    }];
    
    [_debugSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.offset(51);
        make.height.offset(31);
    }];

    [_debugLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.debugSwitch.mas_bottom).offset(5);
    }];

    [_scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.debugLab.mas_bottom).offset(20);
        make.left.offset(60);
        make.width.offset(100);
        make.height.offset(50);
    }];
    
    [_md5Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.debugLab.mas_bottom).offset(20);
        make.right.offset(-60);
        make.width.offset(100);
        make.height.offset(50);
    }];
    
    [_openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanBtn.mas_bottom).offset(20);
        make.left.offset(60);
        make.width.offset(100);
        make.height.offset(50);
    }];
    
    [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanBtn.mas_bottom).offset(20);
        make.right.offset(-60);
        make.width.offset(100);
        make.height.offset(50);
    }];
}

- (UISwitch *)debugSwitch {
    if (!_debugSwitch) {
        _debugSwitch = [[UISwitch alloc]init];
        [_debugSwitch addTarget:self action:@selector(debugSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _debugSwitch;
}

- (UILabel *)debugLab {
    if (!_debugLab) {
        _debugLab = [[UILabel alloc]init];
        _debugLab.font = [UIFont boldSystemFontOfSize:14];
        _debugLab.text = @"发布环境";
    }
    return _debugLab;
}

- (UITextView *)codeView {
    if (!_codeView) {
        _codeView= [[UITextView alloc]init];
        _codeView.backgroundColor = [[UIColor alloc]initWithWhite:0.5 alpha:0.1];
        _codeView.layer.cornerRadius = 8;
        _codeView.editable = NO;
        if (@available(iOS 15.0, *)) {
            [self setContentScrollView:nil forEdge:NSDirectionalRectEdgeNone];
        }
        return _codeView;
    }
    return _codeView;
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _clearBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_clearBtn setTitle:@"清除日志" forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearboxShowLog) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

- (UIButton *)scanBtn {
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _scanBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_scanBtn setTitle:@"二维码扫描" forState:UIControlStateNormal];
        [_scanBtn addTarget:self action:@selector(scanFRbox) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

- (UIButton *)md5Btn {
    if (!_md5Btn) {
        _md5Btn = [UIButton buttonWithType:UIButtonTypeSystem];
        _md5Btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_md5Btn setTitle:@"获取MD5密码" forState:UIControlStateNormal];
        [_md5Btn addTarget:self action:@selector(requestMd5) forControlEvents:UIControlEventTouchUpInside];
    }
    return _md5Btn;
}

- (UIButton *)openBtn {
    if (!_openBtn) {
        _openBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _openBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_openBtn setTitle:@"Rbox开箱" forState:UIControlStateNormal];
        [_openBtn addTarget:self action:@selector(openFRbox) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openBtn;
}


#pragma mark -  开箱子方法
- (void)clearboxShowLog {
    self.codeView.text = @"";
    self.boxShowLog = @"";
}

- (void)configFRbox:(BOOL)isDebug {
    NSString *appKey = @"queinier0va9yae2aimohchie4awooPh";
    NSString *appSecret = @"queisheewahnahNgoveeXai7iShei4ooyo3cu0hoh3ahsoo9Jeeshoh7Aif4Xee1";
    [FRbox configWithAppKey:appKey appSecret:appSecret isDebug:isDebug block:^(NSInteger code) {
    }];
}

- (void)scanFRbox {
    __weak typeof(self) weakSelf = self;
    [FRbox scanRboxWithBlock:^(NSInteger code, NSString *macid) {
        if (code == 200) {
            weakSelf.fh_macid = macid;
        }
    }];
}

- (void)openFRbox {
    if (_fh_md5.length > 0 && _fh_time > 0 && _fh_recycleId.length > 0) {
        __weak typeof(self) weakSelf = self;
        [FRbox openRboxWithMd5:_fh_md5 time:_fh_time recycleId:_fh_recycleId block:^(NSInteger code) {
            weakSelf.fh_time = 0;
            weakSelf.fh_md5 = nil;
            weakSelf.fh_recycleId = nil;
        }];
    }else {
        self.boxShowLog = [NSString stringWithFormat:@"%@请先获取Md5和时间戳和循环Id\n",self.boxShowLog];
        self.codeView.text = self.boxShowLog;
    }
}


// MARK: - 测试专用方法
- (void)addLogEvent {
    __weak typeof(self) weakSelf = self;
    [FRbox logEventWithBlock:^(NSString * msg) {
        weakSelf.boxShowLog = [NSString stringWithFormat:@"%@%@\n",self.boxShowLog,msg];
        weakSelf.codeView.text = weakSelf.boxShowLog;
    }];
}

- (void)debugSwitch:(UISwitch *)sender {
    if(sender.isOn) {
        self.debugLab.text = @"Debug环境";
    }else {
        self.debugLab.text = @"Release环境";
    }
    /// 重新验证授权
    [self configFRbox:sender.isOn];
}

- (void)requestMd5 {
    if (self.fh_macid.length > 0) {
        __weak typeof(self) weakSelf = self;
        [FRbox md5PwdWithMacId:_fh_macid block:^(NSInteger code, NSString *md5, NSInteger time, NSString *recycleId) {
            if (code == 200) {
                weakSelf.fh_time = time;
                weakSelf.fh_md5 = md5;
                weakSelf.fh_recycleId = recycleId;
            }
        }];
    }else {
        self.boxShowLog = [NSString stringWithFormat:@"%@请先扫描运单号获取MacId\n",self.boxShowLog];
        self.codeView.text = self.boxShowLog;
    }
}

@end
