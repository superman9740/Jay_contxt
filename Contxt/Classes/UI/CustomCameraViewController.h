//
//  CustomCameraViewController.h
//  CameraApp
//
//  Created by Shane Dickson on 12/17/13.
//  Copyright (c) 2013 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Highlighter.h"

@import CoreImage;
@import CoreMedia;
@import ImageIO;
@import QuartzCore;
@import MobileCoreServices;


@protocol CustomCameraDelegate <NSObject>
@required
-(void)didFinishImageSelection:(NSArray*)images;


@end;

@interface CustomCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray* images;
    UIImagePickerController* pickerController;
   
    BOOL isHidden;
    BOOL usingFrontCamera;
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) IBOutlet UIScrollView* thumbnailView;
@property (nonatomic, strong) IBOutlet UIView* cameraView;

@property (nonatomic, strong) IBOutlet UIView* bottomView;

@property (nonatomic, strong) IBOutlet UIView* topView;


@property (strong, nonatomic) AVCaptureStillImageOutput* stillImageOutput;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;

@property (strong, nonatomic) IBOutlet UIImageView* triangleButton;


-(IBAction)takePhoto:(id)sender;
-(IBAction)updatePicRollView:(id)sender;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

-(void)setupCaptureSession:(AVCaptureDevice*)camera;
-(IBAction)selectFromCameraRoll:(id)sender;

-(IBAction)updateScrollBarPosition:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)switchCameras:(id)sender;

@end
