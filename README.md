
Frame processor plugin to detect faces using Google ML Kit library for react-native-vision-camera with high performance and many options.


# 🚨 Required Modules
react-native-vision-camera => 3.9.0 <br/>
react-native-worklets-core = 0.4.0

## 💻 Installation

```sh
npm install react-native-vision-camera-v3-face-detection
yarn add react-native-vision-camera-v3-face-detection
```
## 👷Features
    Easy To Use.
    Works Just Writing few lines of Code.
    Works With React Native Vision Camera.
    Works for Both Cameras.
    Works Fast.
    Works With Android 🤖 and IOS.📱
    Writen With Kotlin and Objective-C.

## 💡 Usage

```js
import { Camera } from 'react-native-vision-camera-v3-face-detection';

const [faces,setFaces] = useState(null)

console.log(faces)

<Camera
  options={{
        performanceMode: 'fast',
    }}
  style={StyleSheet.absoluteFill}
  device={device}
  callback={(data) => setFaces(data)}
  {...props}
/>
```


---

## ⚙️ Options


| Name |  Type    |  Values  | Default |
| :---:   | :---: | :---: |  :---: |
| performanceMode | String  | fast, accurate    | fast |
| classificationMode | String   | none, all   |  none |
| landmarkMode | String   | none, all   | none |
| contourMode | String   | none, all    | none |
| trackingEnabled | Boolean   | false, true   | false |
| minFaceSize | Number   | 0| 0.1 |
















