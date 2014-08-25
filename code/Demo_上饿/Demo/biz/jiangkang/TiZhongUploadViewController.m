//
//  XueYaUploadViewController.m
//  Demo
//
//  Created by llbt_wgh on 14-5-10.
//  Copyright (c) 2014年 llbt. All rights reserved.
//

#import "TiZhongUploadViewController.h"
#import "MBTextField.h"
#import "MBBaseScrollView.h"
#import "MBAccessoryView.h"
#import "MBSelectView.h"
#import "SoapHelper.h"
#import "MBIIRequest.h"
#import "NSDateUtilities.h"
@interface TiZhongUploadViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,MBAccessoryViewDelegate>
{
    UIDatePicker *_picker;
    MBSelectView *_seleView;
    MBTextField*_threeTF;
    MBTextField*_fourTF;
    MBTextField*_fiveTF;
}
@end

@implementation TiZhongUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)backViewUPloadView
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"数据上传";
    self.view.backgroundColor=HEX(@"#ffffff");
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        UIBarButtonItem *leftBarItem =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backView.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backViewUPloadView)];
        self.navigationItem.leftBarButtonItem=leftBarItem;
    }else
    {
        UIButton *btnLeft =[UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.frame=CGRectMake(0, 0, 12, 20);
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"backView.png"] forState:UIControlStateNormal];
        [btnLeft addTarget:self action:@selector(backViewUPloadView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        [self.navigationItem.rightBarButtonItem setTintColor:HEX(@"#5ec4fe")];

    }
      self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadData)];
    [self oneStepView];
}

-(void)goToLoginViewAbout
{
    MBNotLogViewController *notLogin =[[MBNotLogViewController alloc]init];
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:notLogin];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)uploadData
{
    if (_fiveTF.text.length<1) {
        MBAlert(@"请输入身高");
        return;
    }
    if (_threeTF.text.length<1) {
        MBAlert(@"请输入体重");
        return;
    }
    BOOL isLogin =[[[NSUserDefaults standardUserDefaults]valueForKey:LOGINSTATUS] boolValue];
    if (!isLogin) {
        [self goToLoginViewAbout];
    }else{
    NSMutableDictionary *allUserDic =(NSMutableDictionary*)[[NSUserDefaults standardUserDefaults]valueForKey:ALLLOGINPEROPLE];
    
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:MBNonEmptyStringNo_([allUserDic allValues][0][@"UserID"]),@"userID", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"5",@"paramType", nil]];

    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[_seleView.dateValue dateString],@"testTime", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"OML601",@"hardVender", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"手动输入",@"hardNo", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"OML601",@"computerName", nil]];

        NSInteger beichu = [_threeTF.text integerValue];
        float chushu =[_fiveTF.text integerValue]/100.0;
        float resutSendData=0;
        if (_fourTF.text.length<1) {
            resutSendData=0.00;
        }else
        {
            resutSendData=[_fourTF.text floatValue];
        }
       
    NSString *valueStr =[NSString stringWithFormat:@"<string>%@</string><string>%0.2f</string><string>%@</string>",_threeTF.text,resutSendData,[NSString stringWithFormat:@"%0.2f",beichu/(chushu*chushu)]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:valueStr,@"value", nil]];

    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"AddHealthData"];
    NSLog(@"%@",soapMsg);
    __block TiZhongUploadViewController *blockSelf = self;
    
    MBRequestItem*item =[MBRequestItem itemWithMethod:@"AddHealthData" params:@{@"soapMessag":soapMsg}];
    
    [MBIIRequest requestXMLWithItems:@[item] success:^(id JSON) {
        
        [blockSelf GetNewHealthDataAndResultSuccess:[[NSString alloc]initWithData:JSON encoding:NSUTF8StringEncoding]];
        
        
    } failure:^(NSError *error, id JSON) {
        
    }];
    }
    
}
-(void)GetNewHealthDataAndResultSuccess:(NSString*)str
{
    NSLog(@"%@",str);
    NSDictionary *dic=[NSDictionary dictionaryWithXMLString:str];
    NSLog(@"%@",dic);
    if ([MBNonEmptyStringNo_(dic[@"soap:Body"][@"AddHealthDataResponse"][@"AddHealthDataResult"]) isEqualToString:@"1"]) {
        MBAlertWithDelegate(@"上传成功", self);
    }else
    {
        MBAlert(@"上传失败,请重新上传");
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"TiZhiZiCheUploadSuccess" object:nil];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TiZhiZiCheUploadSuccess" object:nil];
    [self backViewUPloadView];
}
-(void)oneStepView
{
    CGFloat heig0=8;
    if (IOS7_OR_LATER) {
        heig0=30;
    }
    UITableView *tablevew=[[UITableView alloc]initWithFrame:CGRectMake(0, -heig0, kScreenWidth, 250) style:UITableViewStyleGrouped];
    tablevew.delegate=self;
    tablevew.dataSource=self;
    tablevew.scrollEnabled=NO;
    tablevew.backgroundColor=[UIColor clearColor];
    tablevew.backgroundView=[[UIView alloc]init];
    [self.view addSubview:tablevew];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr =@"UITableViewCell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellStr];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    
    }
    for (id sender in [cell subviews]) {
        if ([sender isKindOfClass:[UITextField class]]) {
            [sender removeFromSuperview];
        }if ([sender isKindOfClass:[MBSelectView class]]) {
            [sender removeFromSuperview];
        }
    }

    cell.textLabel.font=kNormalTextFont;
    if (indexPath.row==0) {
       
        
        cell.textLabel.text=@"测量日期:";
        
        
        
        _seleView=[[MBSelectView alloc]initWithFrame:CGRectMake(210, 10, 180, 30)];
        _seleView.selectType=MBSelectTypeDate;
        _seleView.tag=100000;
        _seleView.value=@"请选择日期";
        [cell addSubview:_seleView];
        
          }
    if (indexPath.row==2) {
        _threeTF=[[MBTextField alloc]initWithFrame:CGRectMake(40, 10, 270, 30)];
        _threeTF.textAlignment=UITextAlignmentRight;
        _threeTF.keyboardType=UIKeyboardTypeNumberPad;
        _threeTF.font=kNormalTextFont;
        [cell addSubview:_threeTF];
        cell.textLabel.text=@"体重:";
        _threeTF.placeholder=@"请输入体重kg";

    }if (indexPath.row==3) {
        _fourTF=[[MBTextField alloc]initWithFrame:CGRectMake(40, 10, 270, 30)];
        _fourTF.textAlignment=UITextAlignmentRight;
        _fourTF.keyboardType=UIKeyboardTypeNumberPad;
        _fourTF.font=kNormalTextFont;
        [cell addSubview:_fourTF];
        cell.textLabel.text=@"体脂率:";
        _fourTF.placeholder=@"请输入体脂率%";

    }if (indexPath.row==1) {
        _fiveTF=[[MBTextField alloc]initWithFrame:CGRectMake(40, 10, 270, 30)];
        _fiveTF.textAlignment=UITextAlignmentRight;
        _fiveTF.keyboardType=UIKeyboardTypeNumberPad;
        _fiveTF.font=kNormalTextFont;
        [cell addSubview:_fiveTF];
        cell.textLabel.text=@"身高:";
        _fiveTF.placeholder=@"请输入身高cm";

    }
    return cell;
    
}

@end
