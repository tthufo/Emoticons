//
//  EM_First_ViewController.m
//  Emoticon
//
//  Created by thanhhaitran on 2/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_First_ViewController.h"

#import "TFHpple.h"

#define ratio 0.55

@interface EM_First_ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * dataList, * menuList;
    
    int count;
    
    IBOutlet UICollectionView * collectionView;
    
    NSString * url;
    
    UIView * menu;
    
    BOOL isShow;
}

@end

@implementation EM_First_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    count = 1;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:@"#EDC8AE"];
        self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:@"#EDC8AE"];
    }
    
    UIBarButtonItem * menuB = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressMenu)];
    self.navigationItem.leftBarButtonItem = menuB;
    
    UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressShare)];
    self.navigationItem.rightBarButtonItem = share;
    
    [collectionView registerNib:[UINib nibWithNibName:@"EM_Cells" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    dataList = [NSMutableArray new];
    
    __block  EM_First_ViewController * weakSelf = self;
    
    [collectionView addFooterWithBlock:^{
        
        [weakSelf didLoadMore];
        
    }];
    
    menu = [self returnView];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/wsrju6x3tq6xojj/Emoticon1_1.plist",@"overrideError":@(1),@"overrideLoading":@(1),@"host":self} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        if(!isValidated)
        {
            return ;
        }
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary *dict = [self returnDictionary:[XMLReader dictionaryForXMLData:data
                                                                            options:XMLReaderOptionsProcessNamespaces
                                                                              error:&er]];
        
        [System addValue:@{@"banner":dict[@"banner"],@"fullBanner":dict[@"fullBanner"],@"adsMob":dict[@"ads"]} andKey:@"adsInfo"];
        
        isShow = [dict[@"show"] boolValue];
        
        [self didPrepareData:isShow];
        
        BOOL isUpdate = [dict[@"version"] compare:[self appInfor][@"majorVersion"] options:NSNumericSearch] == NSOrderedDescending;
        
        if(isUpdate)
        {
            [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Close",@"buttons":@[@"Download now"],@"title":@"New Update",@"message":dict[@"update_message"]} andCompletion:^(int indexButton, id object) {
                switch (indexButton)
                {
                    case 0:
                    {
                        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:dict[@"url"]]])
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"url"]]];
                        }
                    }
                        break;
                    case 1:
                        
                        break;
                    default:
                        break;
                }
            }];
        }
        [self didShowAdsBanner];
    }];
}

- (void)didShowAdsBanner
{
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if([[System getValue:@"adsInfo"][@"adsMob"] boolValue] && [System getValue:@"adsInfo"][@"banner"])
        {
            [[Ads sharedInstance] G_didShowBannerAdsWithInfor:@{@"host":self,@"X":@(320),@"Y":@(screenHeight - 64 - 50),@"adsId":[System getValue:@"adsInfo"][@"banner"]/*,@"device":@""*/} andCompletion:^(BannerEvent event, NSError *error, id banner) {
                
                switch (event)
                {
                    case AdsDone:
                        
                        break;
                    case AdsFailed:
                        
                        break;
                    default:
                        break;
                }
            }];
        }
    }
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if(![[System getValue:@"adsInfo"][@"adsMob"] boolValue])
        {
            [[Ads sharedInstance] S_didShowBannerAdsWithInfor:@{@"host":self,@"Y":@(screenHeight - 64 - 50)} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
                switch (event)
                {
                    case AdsDone:
                    {
                        
                    }
                        break;
                    case AdsFailed:
                    {
                        
                    }
                        break;
                    case AdsWillPresent:
                    {
                        
                    }
                        break;
                    case AdsWillLeave:
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}


- (NSDictionary*)returnDictionary:(NSDictionary*)dict
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    for(NSDictionary * key in dict[@"plist"][@"dict"][@"key"])
    {
        result[key[@"jacknode"]] = dict[@"plist"][@"dict"][@"string"][[dict[@"plist"][@"dict"][@"key"] indexOfObject:key]][@"jacknode"];
    }
    
    return result;
}

- (void)didPrepareData:(BOOL)isShow
{
    self.title = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"title"];

    url = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"cat"];
    
    menuList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"]];
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    [self didRequestData];
}

- (void)didPressShare
{
    [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!",@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100",[UIImage imageNamed:@"Icon-76"]] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
        
    }];
}

- (UIView*)returnView
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][0];
    
    ((UITableView *)[self withView:mem tag:11]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:11]).dataSource = self;

    return mem;
}

- (void)didPressMenu
{
    BOOL isMenu = [self.view.subviews containsObject:menu];

    if(!isMenu)
    {
        menu.frame = CGRectMake( - screenWidth * ratio, 0, screenWidth * ratio, screenHeight - 64);
        
        [self.view addSubview:menu];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = menu.frame;
        
        rect.origin.x += isMenu ? - screenWidth * ratio : screenWidth * ratio;
        
        menu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && menu.frame.origin.x != 0)
        {
            [menu removeFromSuperview];
        }
        
    }];
}

- (void)didLoadMore
{
    count ++;
    
    [self didRequestData];
}

- (void)didReceiveData:(NSString*)data andIsReset:(BOOL)isReset
{
    if(count == 1)
        [dataList removeAllObjects];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *pathQuery = @"//div[@class='mdCMN05Img']/img";
    
    NSArray *nodes = [parser searchWithXPathQuery:pathQuery];
    
    for (TFHppleElement *element in nodes)
    {
        [dataList addObject:@{@"image":[element objectForKey:@"src"]}];
    }
    
    [collectionView reloadData];
    
    [collectionView footerEndRefreshing];
    
    if(isReset)
        [collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)didRequestData
{
    NSString * requestUrl = [NSString stringWithFormat:url, count];
    
    [[LTRequest sharedInstance] didInitWithUrl:@{@"absoluteLink":requestUrl/*,@"overrideError":@(1)*/,@"host":self} withCache:^(NSString *cacheString) {
        
        [self didReceiveData:cacheString andIsReset:YES];
        
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        if(!error)
            
            [self didReceiveData:responseString andIsReset:NO];
    }];
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return menuList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    }
    
    ((UILabel*)[self withView:cell tag:11]).text = menuList[indexPath.row][@"title"];
    
    ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#FFFFFF"];

    cell.accessoryType = [menuList[indexPath.row][@"title"] isEqualToString:self.title] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
    {
        [self didPressMenu];
        
         return;
    }
    
    count = 1;
    
    self.title = menuList[indexPath.row][@"title"];
    
    [_tableView reloadData];
    
    url = menuList[indexPath.row][@"cat"];
    
    [self didRequestData];
    
    [self didPressMenu];
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [((UIImageView*)[self withView:cell tag:11]) sd_setImageWithURL:[NSURL URLWithString:[((NSString*)dataList[indexPath.item][@"image"]) encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        if (image && cacheType == SDImageCacheTypeNone)
        {
            [UIView transitionWithView:((UIImageView*)[self withView:cell tag:11])
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [((UIImageView*)[self withView:cell tag:11]) setImage:image];
                            } completion:NULL];
        }
    }];
    
    [((UIImageView*)[self withView:cell tag:11]) withBorder:@{@"Bcorner":@(12),@"Bwidth":@(2),@"Bhex":@"#EDC8AE"}];
    
    [((UIImageView*)[self withView:cell tag:12]) withBorder:@{@"Bcorner":@(12)}];

    NSArray * data = [System getFormat:@"key=%@" argument:@[dataList[indexPath.item][@"image"]]];
    
    ((UIImageView*)[self withView:cell tag:12]).alpha = data.count == 0 ? 0 : 1.0;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 3 - 1.5, screenWidth / 3 - 1.5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.5;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *imageURL = [NSURL URLWithString:dataList[indexPath.item][@"image"]];
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    EM_MenuView * menuView = [[EM_MenuView alloc] initWithMenu:@{@"image":image}];
    
    [menuView showWithCompletion:^(int index) {
        
        [menuView close];
        
        switch (index)
        {
            case 12:
            {
                if(image)
                {
                    UIImageWriteToSavedPhotosAlbum(image,self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(dataList[indexPath.item][@"image"]));
                }
                else
                {
                    [self alert:@"Attention" message:@"Image can't be saved, please try again"];
                }
            }
                break;
            case 14:
            {
                if(image)
                {
                    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                    appPasteBoard.persistent = YES;
                    [appPasteBoard setImage:image];
                }
                else
                {
                    [self alert:@"Attention" message:@"Image can't be copied, please try again"];
                }
            }
                break;
            case 15:
            {
                if(image)
                {
                    [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!", @"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100", image] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
        
                        }];
                }
                else
                {
                    [self alert:@"Attention" message:@"Image can't be shared, please try again"];
                }
            }
                break;
            default:
                break;
        }
        
        if(![self getValue:@"detail"])
        {
            [self addValue:@"1" andKey:@"detail"];
        }
        else
        {
            int k = [[self getValue:@"detail"] intValue] + 1 ;
            
            [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detail"];
        }
        
        if([[self getValue:@"detail"] intValue] % 4 == 0)
        {
            [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
        }
        
    }];
}

- (void)showAds
{
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if(![[System getValue:@"adsInfo"][@"adsMob"] boolValue])
        {
            [[Ads sharedInstance] S_didShowFullAdsWithInfor:@{} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
                switch (event)
                {
                    case AdsDone:
                    {
                        
                    }
                        break;
                    case AdsFailed:
                    {
                        
                    }
                        break;
                    case AdsWillPresent:
                    {
                        
                    }
                        break;
                    case AdsWillLeave:
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
        else
        {
            if([System getValue:@"adsInfo"][@"fullBanner"])
            {
                [[Ads sharedInstance] G_didShowFullAdsWithInfor:@{@"host":self,@"adsId":[System getValue:@"adsInfo"][@"fullBanner"]/*,@"device":@""*/} andCompletion:^(BannerEvent event, NSError *error, id banner) {
                    
                    switch (event)
                    {
                        case AdsDone:
                            
                            break;
                        case AdsFailed:
                            
                            break;
                        default:
                            break;
                    }
                }];
            }
        }
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [self showSVHUD:@"Photo not saved, try again later" andOption:2];
    }
    else
    {
        [self showSVHUD:@"Done" andOption:1];
        
        [System addValue:(__bridge NSString*)contextInfo andKey:(__bridge NSString*)contextInfo];
        
        [collectionView reloadData];
    }
}

- (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

@implementation UIImage (AverageColor)

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] == 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end

