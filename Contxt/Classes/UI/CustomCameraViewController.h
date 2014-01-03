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
#import "CustomCameraTapToFocusRectangle.h"

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
@property (strong, nonatomic) AVCaptureDevice* videoDevice;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;

@property (strong, nonatomic) IBOutlet UIImageView* triangleButton;

@property (strong, nonatomic) IBOutlet UIButton* torchOnButton;
@property (strong, nonatomic) IBOutlet UIButton* torchOffButton;
@property (strong, nonatomic) IBOutlet UIButton* torchAutoButton;


@property (strong, nonatomic) IBOutlet UIImageView* takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton* loadNativeCameraRoll;
@property (strong, nonatomic) IBOutlet UIButton* doneButton;




-(IBAction)takePhoto:(id)sender;
-(IBAction)updatePicRollView:(id)sender;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

-(void)setupCaptureSession:(AVCaptureDevice*)camera;
-(IBAction)selectFromCameraRoll:(id)sender;

-(IBAction)updateScrollBarPosition:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)switchCameras:(id)sender;
-(IBAction)turnTorchOn:(id)sender;
-(IBAction)turnTorchOff:(id)sender;
-(IBAction)setTorchToAuto:(id)sender;
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer;



@end
