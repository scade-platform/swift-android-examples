
import Foundation
import Dispatch
import CJNI


private var jniEnv: UnsafeMutablePointer<JNIEnv>? = nil

// Returns JNINativeInterface instance from samed JNIEnv pointer
private var jni: JNINativeInterface {
    return jniEnv!.pointee.pointee
}

// Executes callback in main activity
private func executeActivityCallback(activity: JavaObject, str: String) {
    // getting class of activity object
    let cls = jni.GetObjectClass(jniEnv!, activity)
    
    // searching for onDataLoaded method in activity class
    let methodId = jni.GetMethodID(jniEnv!, cls, "onDataLoaded", "(Ljava/lang/String;)V")

    // converting swift string to java string
    let jStr = jni.NewStringUTF(jniEnv!, str)
    
    // building array of arguments
    let args: [JavaParameter] = [JavaParameter(object: jStr)]
    
    // executing onDataLoaded method
    jni.CallVoidMethod(jniEnv!, activity, methodId, args)
    
}

// Downloads data from specified URL. Executes callback in main activity after download is finised.
@MainActor
public func downloadData(activity: JavaObject, url: String) async {
    do {
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        let dataStr = String(data: data, encoding: String.Encoding.utf8) ?? "<can't convert data to string>'"
        executeActivityCallback(activity: activity, str: dataStr)
    }
    catch {
        var userInfoStr = ""
        if let nsError = error as? NSError {
            userInfoStr = "\(nsError.userInfo)"
        }
        executeActivityCallback(activity: activity, str: "ERROR loading from URL '\(url)': \(error) \(userInfoStr)")
    }
    
    // removing JNI global reference to activity object
    jni.DeleteGlobalRef(jniEnv!, activity)
}


 // NOTE: Use @_silgen_name attribute to set native name for a function called from Java
 @_silgen_name("Java_com_example_swiftandroidexample_MainActivity_loadData")
 public func MainActivity_loadData(env: UnsafeMutablePointer<JNIEnv>, activity: JavaObject, javaUrl: JavaString) {
     // Save the JNI environment pointer for future use
     jniEnv = env
 
     // Create a new JNI global reference to the activity object
     let mainActivity = jni.NewGlobalRef(env, activity)!

     // Convert the Java string (javaUrl) to a Swift string
     let chars = jni.GetStringUTFChars(jniEnv!, javaUrl, nil)     
     let str = String(cString: chars)
     jni.ReleaseStringUTFChars(jniEnv!, javaUrl, chars)

     // Start the data download asynchronously in the main actor
     Task {
         await downloadData(activity: mainActivity, url: str)
     }
 }
 