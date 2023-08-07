
import Foundation
import Dispatch
import Java


// Downloads data from specified URL. Executes callback in main activity after download is finised.
@MainActor
public func downloadData(activity: JObject, url: String) async {
    do {
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        let dataStr = String(data: data, encoding: String.Encoding.utf8) ?? "<can't convert data to string>'"
        activity.call(method: "onDataLoaded", dataStr)
    }
    catch {
        var userInfoStr = ""
        if let nsError = error as? NSError {
            userInfoStr = "\(nsError.userInfo)"
        }
        activity.call(method: "onDataLoaded", "ERROR loading from URL '\(url)': \(error) \(userInfoStr)")
    }
}

// NOTE: Use @_silgen_name attribute to set native name for a function called from Java
@_silgen_name("Java_com_example_swiftandroidexample_MainActivity_loadData")
public func MainActivity_loadData(env: UnsafeMutablePointer<JNIEnv>, activity: JavaObject, javaUrl: JavaString) {
    // Create JObject wrapper for activity object
    let mainActivity = JObject(activity)

    // Convert the Java string to a Swift string
    let str = String.fromJavaObject(javaUrl)

    // Start the data download asynchronously in the main actor
    Task {
        await downloadData(activity: mainActivity, url: str)
    }
}
