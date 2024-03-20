package com.visioncamerav3facedetection

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.mrousavy.camera.frameprocessor.FrameProcessorPluginRegistry



class VisionCameraV3FaceDetectionPackage : ReactPackage {
  companion object {
    init {
      FrameProcessorPluginRegistry.addFrameProcessorPlugin("scanFaces") {proxy,options ->
        VisionCameraV3FaceDetectionModule(proxy,options)
      }
    }
  }
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    return emptyList()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return emptyList()
  }
}
