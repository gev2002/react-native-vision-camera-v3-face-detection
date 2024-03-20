package com.visioncamerav3facedetection

import android.media.Image
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceContour
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.google.mlkit.vision.face.FaceLandmark
import com.mrousavy.camera.frameprocessor.Frame
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessor.VisionCameraProxy
import com.mrousavy.camera.types.Orientation

class VisionCameraV3FaceDetectionModule (proxy : VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {

  override fun callback(frame: Frame, arguments: Map<String, Any>?): Any {
      try {
        val performanceModeValue = if (arguments?.get("performanceMode") == "accurate") FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE else FaceDetectorOptions.PERFORMANCE_MODE_FAST
        val landmarkModeValue = if (arguments?.get("landmarkMode") == "all") FaceDetectorOptions.LANDMARK_MODE_ALL else FaceDetectorOptions.LANDMARK_MODE_NONE
        val classificationModeValue = if (arguments?.get("classificationMode") == "all") FaceDetectorOptions.CLASSIFICATION_MODE_ALL else FaceDetectorOptions.CLASSIFICATION_MODE_NONE
        val contourModeValue = if (arguments?.get("contourMode") == "all") FaceDetectorOptions.CONTOUR_MODE_ALL else FaceDetectorOptions.CONTOUR_MODE_NONE
        val minFaceSize = arguments?.get("minFaceSize")?.toString()?.toDoubleOrNull()?.toFloat() ?: 0.15f
        val options = FaceDetectorOptions.Builder()
          .setPerformanceMode(performanceModeValue)
          .setLandmarkMode(landmarkModeValue)
          .setContourMode(contourModeValue)
          .setClassificationMode(classificationModeValue)
          .setMinFaceSize(minFaceSize)
          .apply { if (arguments?.get("trackingEnabled") == "true") enableTracking() }
          .build()
        val mediaImage: Image = frame.image
        val orientation : Orientation = frame.orientation
        val detector = FaceDetection.getClient(options)
        val image = InputImage.fromMediaImage(mediaImage, orientation.toDegrees())
        val task: Task<List<Face>> = detector.process(image)
        val faces: List<Face> = Tasks.await(task)
        val array = WritableNativeArray()
        for (face in faces) {
          val map = WritableNativeMap()
          val bounds = face.boundingBox
          val rotY = face.headEulerAngleY
          val rotZ = face.headEulerAngleZ
          val rotX = face.headEulerAngleX
          map.putInt("width",bounds.width())
          map.putInt("height",bounds.height())
          map.putInt("top",bounds.top)
          map.putInt("bottom",bounds.bottom)
          map.putInt("left",bounds.left)
          map.putInt("right",bounds.right)
          map.putInt("rotY", rotY.toInt())
          map.putInt("rotZ", rotZ.toInt())
          map.putInt("rotX", rotX.toInt())
          val leftEar = face.getLandmark(FaceLandmark.LEFT_EAR)
          leftEar?.let {
            val leftEarPositionX = leftEar.position.x
            val leftEarPositionY = leftEar.position.x
            map.putInt("leftEarPositionX", leftEarPositionX.toInt())
            map.putInt("leftEarPositionY", leftEarPositionY.toInt())
          }
          val rightEar = face.getLandmark(FaceLandmark.RIGHT_EAR)
          rightEar?.let {
            val rightEarPositionX = rightEar.position.x
            val rightEarPositionY = rightEar.position.y
            map.putInt("leftEarPositionX", rightEarPositionX.toInt())
            map.putInt("leftEarPositionY", rightEarPositionY.toInt())
          }
          val leftCheek = face.getLandmark(FaceLandmark.LEFT_CHEEK)
          leftCheek?.let {
            val leftCheekPositionX = leftCheek.position.x
            val leftCheekPositionY = leftCheek.position.y
            map.putInt("leftCheekPositionX", leftCheekPositionX.toInt())
            map.putInt("leftCheekPositionY", leftCheekPositionY.toInt())
          }
          val rightCheek = face.getLandmark(FaceLandmark.RIGHT_CHEEK)
          rightCheek?.let {
            val rightCheekPositionX = rightCheek.position.x
            val rightCheekPositionY = rightCheek.position.y
            map.putInt("rightCheekPositionX", rightCheekPositionX.toInt())
            map.putInt("rightCheekPositionY", rightCheekPositionY.toInt())
          }
          val noseBase = face.getLandmark(FaceLandmark.NOSE_BASE)
          noseBase?.let {
            val noseBasePositionX = noseBase.position.x
            val noseBasePositionY = noseBase.position.y
            map.putInt("noseBasePositionX", noseBasePositionX.toInt())
            map.putInt("noseBasePositionY", noseBasePositionY.toInt())
          }
          val rightEye = face.getLandmark(FaceLandmark.RIGHT_EYE)
          rightEye?.let {
            val rightEyePositionX = rightEye.position.x
            val rightEyePositionY = rightEye.position.y
            map.putInt("rightEyePositionX", rightEyePositionX.toInt())
            map.putInt("rightEyePositionY", rightEyePositionY.toInt())
          }
          val leftEye = face.getLandmark(FaceLandmark.LEFT_EYE)
          leftEye?.let {
            val leftEyePositionX = leftEye.position.x
            val leftEyePositionY = leftEye.position.y
            map.putInt("leftEyePositionX", leftEyePositionX.toInt())
            map.putInt("leftEyePositionY", leftEyePositionY.toInt())
          }
          val rightEyePoints = face.getContour(FaceContour.RIGHT_EYE)?.points?.size
          val leftEyePoints = face.getContour(FaceContour.LEFT_EYE)?.points?.size
          if (rightEyePoints != null) {
            map.putInt("rightEyePoints",rightEyePoints)
          }
          if (leftEyePoints != null) {
            map.putInt("leftEyePoints",leftEyePoints)
          }
          val noseBottomPoints = face.getContour(FaceContour.NOSE_BOTTOM)?.points?.size
          val noseBridgePoints = face.getContour(FaceContour.NOSE_BRIDGE)?.points?.size
          val upperLipUpContourPoints = face.getContour(FaceContour.UPPER_LIP_TOP)?.points?.size
          val upperLipBottomPoints = face.getContour(FaceContour.UPPER_LIP_BOTTOM)?.points?.size
          if (noseBottomPoints != null) {
            map.putInt("noseBottomPoints",noseBottomPoints)
          }
          if (noseBridgePoints != null) {
            map.putInt("noseBridgePoints",noseBridgePoints)
          }
          if (upperLipUpContourPoints != null) {
            map.putInt("upperLipUpContourPoints",upperLipUpContourPoints)
          }
          if (upperLipBottomPoints != null) {
            map.putInt("upperLipBottomContour",upperLipBottomPoints)
          }
          if (face.smilingProbability != null) {
            val smileProb = face.smilingProbability
            if (smileProb != null) {
              map.putInt("smileProb",smileProb.toInt())
            }
          }
          if (face.rightEyeOpenProbability != null) {
            val rightEyeOpenProb = face.rightEyeOpenProbability
            if (rightEyeOpenProb != null) {
              map.putInt("rightEyeOpenProb",rightEyeOpenProb.toInt())
            }
          }
          if (face.leftEyeOpenProbability != null) {
            val leftEyeOpenProb = face.leftEyeOpenProbability
            if (leftEyeOpenProb != null) {
              map.putInt("leftEyeOpenProb",leftEyeOpenProb.toInt())
            }
          }
          array.pushMap(map)
        }
        return array.toArrayList()
      } catch (e: Exception) {
           throw Exception("Error processing face detection: $e")
      }
}

}

