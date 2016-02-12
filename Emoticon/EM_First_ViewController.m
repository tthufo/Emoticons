//
//  EM_First_ViewController.m
//  Emoticon
//
//  Created by thanhhaitran on 2/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_First_ViewController.h"

#import "TFHpple.h"

#import "XMLReader.h"

@import GoogleMobileAds;

typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}BannerType;

#define BANNER_TYPE kBanner_Portrait_Bottom

#define ratio 0.55//IS_IPAD ? 0.55 : 0.55

@interface EM_First_ViewController ()<UITableViewDataSource, UITableViewDelegate, GADInterstitialDelegate, GADBannerViewDelegate>
{
    NSMutableArray * dataList, * menuList;
    
    int count;
    
    IBOutlet UICollectionView * collectionView;
    
    NSString * url;
    
    UIView * menu;
    
    GADBannerView *mBannerView;
    
    GADInterstitial *interstitial;
    
    BannerType mBannerType;
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
    
//    [self createBanner];
//    
//    [self createAndLoadInterstitial];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/nkxnf14bldgndyo/Emoticon.plist",@"overrideError":@(1),@"overrideLoading":@(1),@"host":self} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&er];
        
        NSMutableDictionary * option = [[XMLReader recursionRemoveTextNode:dict] mutableCopy];
        
        [self didPrepareData:[option[@"plist"][@"dict"][@"key"] boolValue]];
        
    }];
    
    [[StartAds sharedInstance] didShowBannerAdsWithInfor:@{@"host":self,@"Y":@(screenHeight - 64 - 50)} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
        switch (event)
        {
            case AdsDone:
            {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            }
                break;
            case AdsFailed:
            {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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

- (void)didPrepareData:(BOOL)isShow
{
    self.title = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"title"];

    url = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"cat"];
    
    menuList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"]];
    
    [self didRequestData];
}

//-(void)createBanner
//{
//    mBannerType = BANNER_TYPE;
//    
//    if(mBannerType <= kBanner_Portrait_Bottom)
//        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
//    else
//        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
//    
////    mBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake((screenWidth - mBannerView.frame.size.width) / 2, screenHeight - 64 -64 - 50, mBannerView.frame.size.width, mBannerView.frame.size.height)];
//    
////    mBannerView.backgroundColor = [UIColor redColor];
//    
//    mBannerView.delegate = self;
//    
//    mBannerView.frame = CGRectMake((screenWidth - mBannerView.frame.size.width) / 2, screenHeight - 64 - 50, mBannerView.frame.size.width, mBannerView.frame.size.height);
//    
//    mBannerView.adUnitID = bannerAPI;
//    
//    mBannerView.rootViewController = self;
//    
//    [self.view addSubview:mBannerView];
//    
//    GADRequest *request = [GADRequest request];
//    
//    
////#ifdef DEBUG
//    
////    request.testDevices = @[
////                            kGADSimulatorID,@"a104de0d0aca5165d505f82e691ba8cd"
////                            ];
////#endif
//    
//    [mBannerView loadRequest:request];
//}
//
//- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
//{
//    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
//}
//
//- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//}
//
//- (void)createAndLoadInterstitial
//{
//    interstitial = [[GADInterstitial alloc] initWithAdUnitID:fullBannerAPI];
//    
//    interstitial.delegate = self;
//    
//    GADRequest *request = [GADRequest request];
//    
////    request.testDevices = @[
////                            kGADSimulatorID,@"a104de0d0aca5165d505f82e691ba8cd"
////                            ];
//    
//    [interstitial loadRequest:request];
//}
//
//- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    //NSLog(@"%@",error);
//}
//
//- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
//{
//    [self createAndLoadInterstitial];
//}

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

- (void)didRequestData
{
    [self showSVHUD:@"Loading" andOption:0];

    if(count == 1)
    {
        [dataList removeAllObjects];
    }
    
    NSURL * requestUrl = [NSURL URLWithString:[NSString stringWithFormat:url, count]];

    NSString * cc = [NSString stringWithFormat:@"%i",count + 100];
    
    dispatch_queue_t imageQueue = dispatch_queue_create([cc UTF8String],NULL);
    
    dispatch_async(imageQueue, ^{
        
        NSError* error = nil;
        
        NSData* htmlData = [NSData dataWithContentsOfURL:requestUrl options:NSDataReadingUncached error:&error];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
        
        NSString *pathQuery = @"//div[@class='mdCMN05Img']/img";
        
//        NSString *pathQuery = @"//div[@class='sticker-icons-container']";
        
        NSArray *nodes = [parser searchWithXPathQuery:pathQuery];
        
        for (TFHppleElement *element in nodes)
        {
            [dataList addObject:@{@"image":[element objectForKey:@"src"]}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [collectionView reloadData];
            
            [collectionView footerEndRefreshing];
            
            [self hideSVHUD];

            if(count == 1)
                
                [collectionView setContentOffset:CGPointZero animated:NO];
        });
    });
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
    
    ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#EDC8AE"];

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
    
    [((UIImageView*)[self withView:cell tag:11]) sd_setImageWithURL:[NSURL URLWithString:dataList[indexPath.item][@"image"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
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
                UIImageWriteToSavedPhotosAlbum(image,self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(dataList[indexPath.item][@"image"]));
            }
                break;
            case 14:
            {
                UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                appPasteBoard.persistent = YES;
                [appPasteBoard setImage:image];
            }
                break;
            case 15:
            {
                [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!", @"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100", image] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
    
                    }];
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
        
        if([[self getValue:@"detail"] intValue] % 4 == 0) //&& interstitial.isReady)
        {
            [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
        }
        
    }];
}

- (void)showAds
{
//    [interstitial presentFromRootViewController:self];
    [[StartAds sharedInstance] didShowFullAdsWithInfor:@{} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
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

