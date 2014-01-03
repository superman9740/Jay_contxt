//
//  CustomCameraViewController.m
//  CameraApp
//
//  Created by Shane Dickson on 12/17/13.
//  Copyright (c) 2013 Jay. All rights reserved.
//

#import "CustomCameraViewController.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}


@interface CustomCameraViewController ()

@end

@implementation CustomCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    images = [[NSMutableArray alloc] initWithCapacity:10];
    [_cameraView.layer addSublayer:_previewLayer];
    //_previewLayer.frame = _cameraView.frame;
    [self setupCaptureSession:[self backCamera]];
  
    UITapGestureRecognizer* tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateScrollBarPosition:)];
    [_triangleButton addGestureRecognizer:tapGestureRecog];
  
    
    UITapGestureRecognizer* tapGestureRecog2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_cameraView addGestureRecognizer:tapGestureRecog2];
    
    [self.view bringSubviewToFront:_topView];
  

    
    int offset = 0;

for (int i = 5; i > 0; i--)
{
    
    
    CGRect frame;
    int val = offset * i;
    if(val == 0)
    {
    
        frame.origin.x = 16;
        
    }
    else
    {
   
        frame.origin.x = offset * i + 20;
        
    }
    
    offset = 60;
    
    frame.origin.y = 0;
    frame.size.height = 40;
    frame.size.width = 40;
    
    Highlighter* subview = [[Highlighter alloc] initWithFrame:frame];
    subview.backgroundColor = [UIColor blackColor];
    subview.alpha = .10;
    
    [self.thumbnailView addSubview:subview];
    
}
    
}



-(void)viewDidAppear:(BOOL)animated
{
    
    
    
}

- (void)setupCaptureSession:(AVCaptureDevice*)camera
{
    NSError *error = nil;
    
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    
    error=nil;
    AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:cameraInput];
    
    [_session startRunning];
    
    
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = _cameraView.frame;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [_cameraView.layer addSublayer:_previewLayer];
    
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    
    [_session addOutput:[self stillImageOutput]];
    
    
    [self setTorchAutoButton:nil];
    
    
}
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer;
{
    CGPoint touchPoint = [recognizer locationInView:[recognizer.view superview]];
    CustomCameraTapToFocusRectangle* view = [[CustomCameraTapToFocusRectangle alloc] initWithFrame:CGRectMake((touchPoint.x-25), (touchPoint.y-25), 100, 100)];
    [self.view addSubview:view];
         
         
         
         NSArray *devices = [AVCaptureDevice devices];
         
         for (AVCaptureDevice *device in devices) {
             
             NSLog(@"Device name: %@", [device localizedName]);
             
             if ([device hasMediaType:AVMediaTypeVideo])
             {
                 if ([device isFocusPointOfInterestSupported]) {
                     NSError *error;
                     if ([device lockForConfiguration:&error]) {
                         [device setFocusPointOfInterest:touchPoint];
                         [device setExposurePointOfInterest:touchPoint];
                         
                         [device setFocusMode:AVCaptureFocusModeAutoFocus];
                         if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                             [device setExposureMode:AVCaptureExposureModeAutoExpose];
                         }
                         [device unlockForConfiguration];
                     }
                 }
                 
                 
             }
         }
    
}


-(IBAction)takePhoto:(id)sender
{
    if([[UIDevice currentDevice] orientation] != UIInterfaceOrientationPortrait)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Unsupported orientation" message:@"Taking landscape photos is not supported." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        
        return;
    }
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments)
                                                             {
                                                                 NSLog(@"attachements: %@", exifAttachments);
                                                             } else
                                                             {
                                                                 NSLog(@"no attachments");
                                                             }
                                                             
                                                             
                                                             UIImage *image=[self imageFromSampleBuffer:imageSampleBuffer];
                                                             if(images.count == 5)
                                                             {
                                                                 [images removeLastObject];
                                                             }
                                                             
                                                             [images addObject:image];
                                                             [self performSelectorOnMainThread:@selector(updatePicRollView:) withObject:nil waitUntilDone:NO];
                                                             
                                                             error  = NULL;
                                                             
                                                             
                                                             
                                                         }];
    
    
    
    [self updatePicRollView:self];
    
    
}


- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    //return image;
    
    CFRelease(context);
    
    
        CGSize size = CGSizeMake(3000,3000);
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(size);
        
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, size.width/2, size.height/2);
        
        CGContextRotateCTM(bitmap, radians(90));
        CGContextScaleCTM(bitmap, 1.0f, -1.0f);
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), [image CGImage]);
        
        UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
     
    
        return rotatedImage;
    
    
}
-(IBAction)switchCameras:(id)sender
{
    [_session stopRunning];
    if(usingFrontCamera)
    {
        [self setupCaptureSession:[self backCamera]];
        
    }
    else
    {
        [self setupCaptureSession:[self frontCamera]];
        
    }
    
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront)
        {
            usingFrontCamera = YES;
            [_session beginConfiguration];
            [device lockForConfiguration:nil];
            
          //  [device setTorchMode:AVCaptureTorchModeAuto];
            [device unlockForConfiguration];
            [_session commitConfiguration];
            
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)backCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            usingFrontCamera = NO;
            [_session beginConfiguration];
            [device lockForConfiguration:nil];
            
          //  [device setTorchMode:AVCaptureTorchModeAuto];
            [device unlockForConfiguration];
            [_session commitConfiguration];
            
            return device;
        }
    }
    return nil;
}


-(IBAction)updatePicRollView:(id)sender
{
    @autoreleasepool
    {
        int offset = 0;
        for (long i = images.count; i > 0; i--)
        {
            
            
            CGRect frame;
            long val = offset * i;
            if(val == 0)
            {
                
                frame.origin.x = 16;
                
            }
            else
            {
                
                frame.origin.x = offset * i + 20;
                
            }
            
            offset = 60;
            
            frame.origin.y = 0;
            frame.size.height = 40;
            frame.size.width = 40;
            
            UIImageView* subview = [[UIImageView alloc] initWithFrame:frame];
            subview.contentMode = UIViewContentModeScaleToFill;
            
            subview.image = images[i-1];
                                    
            [self.thumbnailView addSubview:subview];
            
        }
    }
    
    self.thumbnailView.contentSize = CGSizeMake(60 * [images count], self.thumbnailView.frame.size.height);
    [self.thumbnailView setContentOffset:CGPointMake(0, 0)];
    
}

-(IBAction)selectFromCameraRoll:(id)sender;
{
    pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    pickerController.mediaTypes =     [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
    
    
}

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        [images addObject:imageToSave];
        [self updatePicRollView:self];
        
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(IBAction)updateScrollBarPosition:(id)sender
{
 if(!isHidden)
 {
        
   
     float degrees = 90.0;
     float radians = (degrees/180.0) * M_PI;
     
     [UIView animateWithDuration:1.0 animations:^{
        
        CGRect newRect = CGRectMake(_thumbnailView.frame.origin.x + _thumbnailView.frame.size.width, _thumbnailView.frame.origin.y, _thumbnailView.frame.size.width, _thumbnailView.frame.size.height);
        _thumbnailView.frame = newRect;
         _triangleButton.transform = CGAffineTransformMakeRotation(radians);
         
        
    }];
        isHidden = YES;
     
 }
  else
  {
   
      float degrees = 360.0;
      float radians = (degrees/180.0) * M_PI;
      
      [UIView animateWithDuration:1.0 animations:^{
          
          CGRect newRect = CGRectMake(_thumbnailView.frame.origin.x - _thumbnailView.frame.size.width, _thumbnailView.frame.origin.y, _thumbnailView.frame.size.width, _thumbnailView.frame.size.height);
          _thumbnailView.frame = newRect;
          _triangleButton.transform = CGAffineTransformMakeRotation(radians);
          
          
      }];
      isHidden = NO;
      
  }
    
}
-(IBAction)done:(id)sender
{
    
    [_delegate didFinishImageSelection:images];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark flash methods
-(IBAction)turnTorchOn:(id)sender
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
            if(device.torchAvailable)
            {
            
                [_session beginConfiguration];
                [device lockForConfiguration:nil];
                
                [device setTorchMode:AVCaptureTorchModeOn];
                [device unlockForConfiguration];
                [_session commitConfiguration];
                
            }
            
       // _torchOffButton.enabled = NO;
       // _torchAutoButton.enabled = NO;
        
        
    }

    
}
-(IBAction)turnTorchOff:(id)sender
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
            if(device.torchAvailable)
            {
                
                [_session beginConfiguration];
                [device lockForConfiguration:nil];
                
                [device setTorchMode:AVCaptureTorchModeOff];
                [device unlockForConfiguration];
                [_session commitConfiguration];
                
                
            }
            
       // _torchOnButton.enabled = NO;
       // _torchAutoButton.enabled = NO;
        
       
    }

    
}
-(IBAction)setTorchToAuto:(id)sender
{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
          if(device.torchAvailable)
          {
              
              [_session beginConfiguration];
              [device lockForConfiguration:nil];
              [device setTorchMode:AVCaptureTorchModeAuto];
              [device unlockForConfiguration];
              [_session commitConfiguration];
              
              
          }
            
     //   _torchOffButton.enabled = NO;
     //   _torchOnButton.enabled = NO;
        
        
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
