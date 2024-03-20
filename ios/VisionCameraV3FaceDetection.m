#import <MLKitFaceDetection/MLKitFaceDetection.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/VisionCameraProxy.h>
#import <VisionCamera/Frame.h>
@import MLKitVision;

@interface VisionCameraV3FaceDetectionPlugin : FrameProcessorPlugin

@property(nonatomic, strong) MLKFaceDetectorOptions *options;

@end

@implementation VisionCameraV3FaceDetectionPlugin

- (instancetype _Nonnull)initWithProxy:(VisionCameraProxyHolder*)proxy
                           withOptions:(NSDictionary* _Nullable)options {
    self = [super initWithProxy:proxy withOptions:options];
    if (self) {
        self.options = [[MLKFaceDetectorOptions alloc] init];
        NSString *performanceMode = options[@"performanceMode"];
        if ([performanceMode isEqualToString:@"accurate"]) {
            self.options.performanceMode = MLKFaceDetectorPerformanceModeAccurate;
        } else {
            self.options.performanceMode = MLKFaceDetectorPerformanceModeFast;
        }

        NSString *landmarkMode = options[@"landmarkMode"];
        if ([landmarkMode isEqualToString:@"all"]) {
            self.options.landmarkMode = MLKFaceDetectorLandmarkModeAll;
        } else {
            self.options.landmarkMode = MLKFaceDetectorLandmarkModeNone;
        }

        NSString *classificationMode = options[@"classificationMode"];
        if ([classificationMode isEqualToString:@"all"]) {
            self.options.classificationMode = MLKFaceDetectorClassificationModeAll;
        } else {
            self.options.classificationMode = MLKFaceDetectorClassificationModeNone;
        }

        NSString *contourMode = options[@"contourMode"];
        if ([contourMode isEqualToString:@"all"]) {
            self.options.contourMode = MLKFaceDetectorContourModeAll;
        } else {
            self.options.contourMode = MLKFaceDetectorContourModeNone;
        }

        NSNumber *minFaceSize = options[@"minFaceSize"];
        if (minFaceSize != nil) {
            self.options.minFaceSize = [minFaceSize floatValue];
        }

        NSNumber *trackingEnabled = options[@"trackingEnabled"];
        if ([trackingEnabled boolValue]) {
            self.options.trackingEnabled = YES;
        }
    }
    return self;
}

- (id _Nullable)callback:(Frame* _Nonnull)frame
           withArguments:(NSDictionary* _Nullable)arguments {
    CMSampleBufferRef buffer = frame.buffer;
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:buffer];
    MLKFaceDetector *faceDetector = [MLKFaceDetector faceDetectorWithOptions:self.options];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [faceDetector processImage:image
                        completion:^(NSArray<MLKFace *> *faces,NSError *error){
            if (!weakSelf) {
                NSLog(@"Self is nil!");
                return;
            }
            if (error || !faces || faces.count == 0) {
                NSLog(@"No Face Found !");
                dispatch_group_leave(dispatchGroup);
                return;
            }

            for (MLKFace *face in faces) {
                CGRect frame = face.frame;
                data[@"width"] = @(frame.size.width);
                data[@"height"] = @(frame.size.height);
                data[@"top"] = @(frame.origin.y);
                data[@"bottom"] = @(frame.origin.y + frame.size.height);
                data[@"left"] = @(frame.origin.x);
                data[@"right"] = @(frame.origin.x + frame.size.width);

                if (face.hasHeadEulerAngleX) {
                    data[@"rotX"] = @(face.headEulerAngleX);
                }
                if (face.hasHeadEulerAngleY) {
                    data[@"rotY"] = @(face.headEulerAngleY);
                }
                if (face.hasHeadEulerAngleZ) {
                    data[@"rotZ"] = @(face.headEulerAngleZ);
                }

                if (face.hasSmilingProbability) {
                    data[@"smileProb"] = @(face.smilingProbability);
                }
                if (face.hasRightEyeOpenProbability) {
                    data[@"rightEyeOpenProb"] = @(face.rightEyeOpenProbability);
                }
                if (face.hasLeftEyeOpenProbability) {
                    data[@"leftEyeOpenProb"] = @(face.leftEyeOpenProbability);
                }


                MLKFaceLandmark *leftEar = [face landmarkOfType:MLKFaceLandmarkTypeLeftEar];
                if (leftEar) {
                    data[@"leftEarPositionX"] = @(leftEar.position.x);
                    data[@"leftEarPositionY"] = @(leftEar.position.y);
                }

                MLKFaceLandmark *rightEar = [face landmarkOfType:MLKFaceLandmarkTypeRightEar];
                if (rightEar) {
                    data[@"rightEarPositionX"] = @(rightEar.position.x);
                    data[@"rightEarPositionY"] = @(rightEar.position.y);
                }

                MLKFaceLandmark *leftCheek = [face landmarkOfType:MLKFaceLandmarkTypeLeftCheek];
                if (leftCheek) {
                    data[@"leftCheekPositionX"] = @(leftCheek.position.x);
                    data[@"leftCheekPositionY"] = @(leftCheek.position.y);
                }

                MLKFaceLandmark *rightCheek = [face landmarkOfType:MLKFaceLandmarkTypeRightCheek];
                if (rightCheek) {
                    data[@"rightCheekPositionX"] = @(rightCheek.position.x);
                    data[@"rightCheekPositionY"] = @(rightCheek.position.y);
                }

                MLKFaceLandmark *noseBase = [face landmarkOfType:MLKFaceLandmarkTypeNoseBase];
                if (noseBase) {
                    data[@"noseBasePositionX"] = @(noseBase.position.x);
                    data[@"noseBasePositionY"] = @(noseBase.position.y);
                }

                MLKFaceLandmark *rightEye = [face landmarkOfType:MLKFaceLandmarkTypeRightEye];
                if (rightEye) {
                    data[@"rightEyePositionX"] = @(rightEye.position.x);
                    data[@"rightEyePositionY"] = @(rightEye.position.y);
                }

                MLKFaceLandmark *leftEye = [face landmarkOfType:MLKFaceLandmarkTypeLeftEye];
                if (leftEye) {
                    data[@"leftEyePositionX"] = @(leftEye.position.x);
                    data[@"leftEyePositionY"] = @(leftEye.position.y);
                }

                MLKFaceContour *leftEyeContour = [face contourOfType:MLKFaceContourTypeLeftEye];
                if (leftEyeContour) {
                    data[@"leftEyePoints"] = leftEyeContour.points;
                }

                MLKFaceContour *rightEyeContour = [face contourOfType:MLKFaceContourTypeRightEye];
                if (rightEyeContour) {
                    data[@"rightEyePoints"] = rightEyeContour.points;
                }

                MLKFaceContour *noseBottom = [face contourOfType:MLKFaceContourTypeNoseBottom];
                if (noseBottom) {
                    data[@"noseBottomPoints"] = noseBottom.points;
                }

                MLKFaceContour *noseBridge = [face contourOfType:MLKFaceContourTypeNoseBridge];
                if (noseBridge) {
                    data[@"noseBridgePoints"] = noseBridge.points;
                }

                MLKFaceContour *upperLipBottomContour = [face contourOfType:MLKFaceContourTypeUpperLipBottom];
                if (upperLipBottomContour) {
                    data[@"upperLipBottomPoints"] = upperLipBottomContour.points;
                }

                MLKFaceContour *upperLipUpContour = [face contourOfType:MLKFaceContourTypeUpperLipTop];
                if (upperLipUpContour) {
                    data[@"upperLipUpContourPoints"] = upperLipUpContour.points;
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
