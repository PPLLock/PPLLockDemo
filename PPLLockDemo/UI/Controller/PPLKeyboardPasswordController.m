//
//  PPLKeyboardPasswordController.m
//  PPLLockDemo
//
//  Created by Samuel on 2019/6/17.
//  Copyright © 2019 Populstay. All rights reserved.
//

#import "PPLKeyboardPasswordController.h"
#import "BRDatePickerView.h"
#import "NSString+PPLTime.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PPLKeyboardPasswordController ()<UITextFieldDelegate>
{
    PPLLockHelper * _pplockHelper;
}


@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UIButton *endBtn;

@property (weak, nonatomic) IBOutlet UITextField *codeField;

@property (weak, nonatomic) IBOutlet UILabel *codeLab;

@property (weak, nonatomic) IBOutlet UITextField *deleteField;

@end

@implementation PPLKeyboardPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Password management";
    
    NSDateFormatter * fm = [[NSDateFormatter alloc] init];
    
    fm.dateFormat = @"yyyy-MM-dd HH:mm";
    
    [self.startBtn setTitle:[NSString PPL_currentAllDateWithFormatter:fm] forState:UIControlStateNormal];
    
    
    [self.endBtn setTitle:[NSString PPL_currentNextHourWithFormatter:fm] forState:UIControlStateNormal];
    
     _pplockHelper = [PPLLockHelper shareInstance];
}

- (IBAction)generateAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if (!_model) {
        
        [self showToast:@"Lock data is empty"];
        
        return;
    }
    
    NSString * customCode = self.codeField.text;
    
    if (customCode.length == 0) {
        
        [self showToast:@"Password must be entered"];
        
        return;
    }
    
    NSDate * start = [NSString PPL_timeForString:self.startBtn.currentTitle];
    
    NSDate * end = [NSString PPL_timeForString:self.endBtn.currentTitle];
    
    [SVProgressHUD show];
    
    [PPLLockHelper connectKey:_model connectBlock:^(BOOL succeed, id info) {
        
        if (!succeed) {
            
            [SVProgressHUD dismiss];
            
            [self showLockNotNearToast];
            
            return;
        
        }
        
        if (succeed) {
            
            [PPLLockHelper customKeyboardPwd:customCode startDate:start endDate:end key:self->_model complition:^(BOOL succeed, id info) {
                
                [SVProgressHUD dismiss];
            
                if (!succeed) {
                    
                   [self showOperationFailedToast];
                    
                    return;
                }
                
                [self showToast:@"Add password successfully"];
            
            }];
            
        }
 
    } ];
    
}

- (IBAction)reset:(UIButton *)sender {
    
     [self.view endEditing:YES];
    
    if (!_model) {
        
        [self showToast:@"Lock data is empty"];
        
        return;
    }
    
    [SVProgressHUD show];
    
    [PPLLockHelper connectKey:_model connectBlock:^(BOOL succeed, id info) {
        
        if (!succeed) {
            
            [SVProgressHUD dismiss];
            
            [self showLockNotNearToast];
            
            return;
            
        }
        
        [PPLLockHelper resetKeyboardPassword:self->_model complition:^(BOOL succeed, id info) {
            
            [SVProgressHUD dismiss];
            
            if(!succeed) {
                
                [self showOperationFailedToast];
                
                return;
            }
            
            
            [self showToast:@"Reset password successfully"];
            
            
        }];
        
    }];
    
}

- (IBAction)selectStartTime:(UIButton *)sender {
    
    NSString * defaultSelValue = sender.currentTitle;
    
    [BRDatePickerView showDatePickerWithTitle:@"Choose start time" dateType: BRDatePickerModeDateAndTime defaultSelValue:defaultSelValue resultBlock:^(NSString *selectValue) {
       
        [sender setTitle:selectValue forState:UIControlStateNormal];
        
    }];
}

- (IBAction)selectEndTime:(UIButton *)sender {

    NSString * defaultSelValue = sender.currentTitle;
    
    [BRDatePickerView showDatePickerWithTitle:@"Choose end time" dateType: BRDatePickerModeDateAndTime defaultSelValue:defaultSelValue resultBlock:^(NSString *selectValue) {
        
        [sender setTitle:selectValue forState:UIControlStateNormal];
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (IBAction)delete:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString * code = self.deleteField.text;
    
    if (code.length < 6 || code.length > 9) {
        
        [self showToast:LS(@"Password length error")];
        
        return;
    }
    
    if (!_model) {
        
        [self showToast:@"Lock data is empty"];
        
        return;
    }
    
    [SVProgressHUD show];
    
    [PPLLockHelper connectKey:_model connectBlock:^(BOOL succeed, id info) {
        
        if (!succeed) {
            
            [SVProgressHUD dismiss];
            
            [self showLockNotNearToast];
            
            return;
            
        }
        
        [PPLLockHelper deleteKeyboardPwd:code keyboardPsType:KeyboardPsTypePermanent key:self->_model complition:^(BOOL succeed, id info) {
            
            [SVProgressHUD dismiss];
            
            if(!succeed) {
                
                [self showOperationFailedToast];
                
                return;
            }
            
            
            [self showToast:@"Deleted password successfully"];
            
        }];
        
    }];
    
}

@end
