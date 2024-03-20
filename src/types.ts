export type {
  Frame,
  FrameProcessorPlugin,
  FrameProcessor,
} from 'react-native-vision-camera';
import type { CameraProps, CameraDevice } from 'react-native-vision-camera';

export interface FaceDetectionOptions {
  performanceMode?: 'fast' | 'accurate';
  landmarkMode?: 'none' | 'all';
  contourMode?: 'none' | 'all';
  classificationMode?: 'none' | 'all';
  minFaceSize?: number;
  trackingEnabled?: boolean;
}

export type CameraTypes = {
  callback: Function;
  options: FaceDetectionOptions;
  device: CameraDevice;
} & CameraProps;
