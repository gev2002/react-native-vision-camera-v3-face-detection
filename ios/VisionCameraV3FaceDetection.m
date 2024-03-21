#import <MLKitFaceDetection/MLKitFaceDetection.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/VisionCameraProxy.h>
#import <VisionCamera/Frame.h>
@import MLKitVision;

@interface VisionCameraV3FaceDetectionPlugin : FrameProcessorPlugin
@end

@implementation VisionCameraV3FaceDetectionPlugin

- (instancetype _Nonnull)initWithProxy:(VisionCameraProxyHolder*)proxy
                           withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];

    return self;
  }



- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    CMSampleBufferRef buffer = frame.buffer;
    UIImageOrientation orientation = frame.orientation;
    
    MLKFaceDetectorOptions *options = [[MLKFaceDetectorOptions alloc] init];
    NSString *performanceMode = arguments[@"performanceMode"];
    if ([performanceMode isEqualToString:@"accurate"]) {
        options.performanceMode = MLKFaceDetectorPerformanceModeAccurate;
    } else {
        options.performanceMode = MLKFaceDetectorPerformanceModeFast;
    }
    NSString *landmarkMode = arguments[@"landmarkMode"];
    if ([landmarkMode isEqualToString:@"all"]) {
        options.landmarkMode = MLKFaceDetectorLandmarkModeAll;
    } else {
        options.landmarkMode = MLKFaceDetectorLandmarkModeNone;
    }

    NSString *classificationMode = arguments[@"classificationMode"];
    if ([classificationMode isEqualToString:@"all"]) {
        options.classificationMode = MLKFaceDetectorClassificationModeAll;
    } else {
        options.classificationMode = MLKFaceDetectorClassificationModeNone;
    }

    NSString *contourMode = arguments[@"contourMode"];
    if ([contourMode isEqualToString:@"all"]) {
        options.contourMode = MLKFaceDetectorContourModeAll;
    } else {
        options.contourMode = MLKFaceDetectorContourModeNone;
    }

    NSNumber *minFaceSize = arguments[@"minFaceSize"];
    if (minFaceSize != nil) {
        options.minFaceSize = [minFaceSize floatValue];
    }
    NSNumber *trackingEnabled = arguments[@"trackingEnabled"];
    if ([trackingEnabled boolValue]) {
        options.trackingEnabled = YES;
    }
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:buffer];
    image.orientation = orientation;
    MLKFaceDetector *faceDetector = [MLKFaceDetector faceDetectorWithOptions:options];
    NSMutableArray *data = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [faceDetector processImage:image
                        completion:^(NSArray<MLKFace *> *faces,NSError *error){
            if (error != nil) {
                RCTResponseErrorBlock error;
                return;
                
            }
            if (faces.count > 0) {
                
                for (MLKFace *face in faces) {
                    NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
                    
                    CGRect frame = face.frame;
                    obj[@"width"] = @(frame.size.width);
                    obj[@"height"] = @(frame.size.height);
                    obj[@"top"] = @(frame.origin.y);
                    obj[@"bottom"] = @(frame.origin.y + frame.size.height);
                    obj[@"left"] = @(frame.origin.x);
                    obj[@"right"] = @(frame.origin.x + frame.size.width);
                    
                    if (face.hasHeadEulerAngleX) {
                        obj[@"rotX"] = @(face.headEulerAngleX);
                    }
                    if (face.hasHeadEulerAngleY) {
                        obj[@"rotY"] = @(face.headEulerAngleY);
                    }
                    if (face.hasHeadEulerAngleZ) {
                        obj[@"rotZ"] = @(face.headEulerAngleZ);
                    }
                    
                    if (face.hasSmilingProbability) {
                        obj[@"smileProb"] = @(face.smilingProbability);
                    }
                    if (face.hasRightEyeOpenProbability) {
                        obj[@"rightEyeOpenProb"] = @(face.rightEyeOpenProbability);
                    }
                    if (face.hasLeftEyeOpenProbability) {
                        obj[@"leftEyeOpenProb"] = @(face.leftEyeOpenProbability);
                    }
                    
                    
                    MLKFaceLandmark *leftEar = [face landmarkOfType:MLKFaceLandmarkTypeLeftEar];
                    if (leftEar) {
                        obj[@"leftEarPositionX"] = @(leftEar.position.x);
                        obj[@"leftEarPositionY"] = @(leftEar.position.y);
                    }
                    
                    MLKFaceLandmark *rightEar = [face landmarkOfType:MLKFaceLandmarkTypeRightEar];
                    if (rightEar) {
                        obj[@"rightEarPositionX"] = @(rightEar.position.x);
                        obj[@"rightEarPositionY"] = @(rightEar.position.y);
                    }
                    
                    MLKFaceLandmark *leftCheek = [face landmarkOfType:MLKFaceLandmarkTypeLeftCheek];
                    if (leftCheek) {
                        obj[@"leftCheekPositionX"] = @(leftCheek.position.x);
                        obj[@"leftCheekPositionY"] = @(leftCheek.position.y);
                    }
                    
                    MLKFaceLandmark *rightCheek = [face landmarkOfType:MLKFaceLandmarkTypeRightCheek];
                    if (rightCheek) {
                        obj[@"rightCheekPositionX"] = @(rightCheek.position.x);
                        obj[@"rightCheekPositionY"] = @(rightCheek.position.y);
                    }
                    
                    MLKFaceLandmark *noseBase = [face landmarkOfType:MLKFaceLandmarkTypeNoseBase];
                    if (noseBase) {
                        obj[@"noseBasePositionX"] = @(noseBase.position.x);
                        obj[@"noseBasePositionY"] = @(noseBase.position.y);
                    }
                    
                    MLKFaceLandmark *rightEye = [face landmarkOfType:MLKFaceLandmarkTypeRightEye];
                    if (rightEye) {
                        obj[@"rightEyePositionX"] = @(rightEye.position.x);
                        obj[@"rightEyePositionY"] = @(rightEye.position.y);
                    }
                    
                    MLKFaceLandmark *leftEye = [face landmarkOfType:MLKFaceLandmarkTypeLeftEye];
                    if (leftEye) {
                        obj[@"leftEyePositionX"] = @(leftEye.position.x);
                        obj[@"leftEyePositionY"] = @(leftEye.position.y);
                    }
                    
                    MLKFaceContour *leftEyeContour = [face contourOfType:MLKFaceContourTypeLeftEye];
                    if (leftEyeContour) {
                        obj[@"leftEyePoints"] = leftEyeContour.points;
                    }
                    
                    MLKFaceContour *rightEyeContour = [face contourOfType:MLKFaceContourTypeRightEye];
                    if (rightEyeContour) {
                        obj[@"rightEyePoints"] = rightEyeContour.points;
                    }
                    
                    MLKFaceContour *noseBottom = [face contourOfType:MLKFaceContourTypeNoseBottom];
                    if (noseBottom) {
                        obj[@"noseBottomPoints"] = noseBottom.points;
                    }
                    
                    MLKFaceContour *noseBridge = [face contourOfType:MLKFaceContourTypeNoseBridge];
                    if (noseBridge) {
                        obj[@"noseBridgePoints"] = noseBridge.points;
                    }
                    
                    MLKFaceContour *upperLipBottomContour = [face contourOfType:MLKFaceContourTypeUpperLipBottom];
                    if (upperLipBottomContour) {
                        obj[@"upperLipBottomPoints"] = upperLipBottomContour.points;
                    }
                    
                    MLKFaceContour *upperLipUpContour = [face contourOfType:MLKFaceContourTypeUpperLipTop];
                    if (upperLipUpContour) {
                        obj[@"upperLipUpContourPoints"] = upperLipUpContour.points;
                    }
                    [data addObject:obj];
                    
                    
                }
            }
            dispatch_group_leave(dispatchGroup);
        }];
    });
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    return data;
}

VISION_EXPORT_FRAME_PROCESSOR(VisionCameraV3FaceDetectionPlugin, scanFaces)

@end
