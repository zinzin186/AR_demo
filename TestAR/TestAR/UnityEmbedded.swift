//
//  UnityEmbedded.swift
//  TestAR
//
//  Created by Din Vu Dinh on 27/03/2024.
//

import Foundation
import UnityFramework

class UnityEmbedded: UIResponder, UIApplicationDelegate, UnityFrameworkListener{
    
    private struct UnityMessage {
        let objectName : String?
        let methodName : String?
        let messageBody : String?
    }
    
    private static var instance : UnityEmbedded!
    private var ufw : UnityFramework!
    private static var hostMainWindow : UIWindow! //Window to return to when exitting Unity window
    private static var launchOpts : [UIApplication.LaunchOptionsKey: Any]?
    
    private static var cachedMessages = [UnityMessage]()
    
    //Static functions that can be called from other scripts
    static func setHostMainWindow(_ hostMainWindow : UIWindow?) {
        UnityEmbedded.hostMainWindow = hostMainWindow
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    static func setLaunchinOptions(_ launchingOptions :  [UIApplication.LaunchOptionsKey: Any]?) {
        UnityEmbedded.launchOpts = launchingOptions
    }
    
    static func showUnity() {
        print("Show/Init Unity embedded player")
        
        if(UnityEmbedded.instance == nil || UnityEmbedded.instance.unityIsInitialized() == false) {
            UnityEmbedded().initUnityWindow()
        }
        else {
            UnityEmbedded.instance.showUnityWindow()
        }
    }
    
    static func hideUnity() {
        UnityEmbedded.instance?.hideUnityWindow()
    }
    
    static func unloadUnity() {
        UnityEmbedded.instance?.unloadUnityWindow()
    }
    
    static func sendUnityMessage(_ objectName : String, methodName : String, message : String) {
        let msg : UnityMessage = UnityMessage(objectName: objectName, methodName: methodName, messageBody: message)
        
        
        //Send the message right away if Unity is initialized, else cache it
        if(UnityEmbedded.instance != nil && UnityEmbedded.instance.unityIsInitialized()) {
            UnityEmbedded.instance.ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
        }
        else {
            UnityEmbedded.cachedMessages.append(msg)
        }
    }
    
    //Callback from UnityFrameworkListener
    func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        ufw = nil
        UnityEmbedded.hostMainWindow?.makeKeyAndVisible()
    }
    
    //Private functions called within the class
    private func unityIsInitialized() -> Bool {
        return ufw != nil && (ufw.appController() != nil)
    }
    
    private func initUnityWindow() {
        if unityIsInitialized() {
            showUnityWindow()
            return
        }
        
        STProgressHUD.showHUD()
        ufw = UnityFrameworkLoad()!
        ufw.setDataBundleId("com.unity3d.framework")
        ufw.register(self)
        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
        
        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: UnityEmbedded.launchOpts)
        
        sendUnityMessageToGameObject()
        
        UnityEmbedded.instance = self
        STProgressHUD.hideHUD()
    }
    
    private func showUnityWindow() {
        if unityIsInitialized() {
            ufw.showUnityWindow()
            sendUnityMessageToGameObject()
        }
    }
    
    private func hideUnityWindow() {
        if(UnityEmbedded.hostMainWindow == nil) {
            print("WARNING: hostMainWindow is nil! Cannot switch from Unity window to previous window")
        }
        else {
            UnityEmbedded.hostMainWindow?.makeKeyAndVisible()
        }
    }
    
    private func unloadUnityWindow() {
        if unityIsInitialized() {
            UnityEmbedded.cachedMessages.removeAll()
            ufw.unloadApplication()
        }
    }
    
    private func quitUnityWindow() {
        if unityIsInitialized() {
            UnityEmbedded.cachedMessages.removeAll()
            ufw.quitApplication(0)
        }
    }
    
    private func sendUnityMessageToGameObject() {
        if(UnityEmbedded.cachedMessages.count >= 0 && unityIsInitialized())
        {
            for msg in UnityEmbedded.cachedMessages {
                ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
            }
            
            UnityEmbedded.cachedMessages.removeAll()
        }
    }
    
    private func UnityFrameworkLoad() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        
        let bundle = Bundle(path: bundlePath )
        if bundle?.isLoaded == false {
            bundle?.load()
        }
        
        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            // unity is not initialized
            //            ufw?.executeHeader = &mh_execute_header
            
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
            
            ufw!.setExecuteHeader(machineHeader)
        }
        return ufw
    }
}

extension UnityEmbedded: NativeCallsProtocol {
    /// NativeCallsProtocol
    func showHostMainWindow(_ color: String!) {
        print("show host main window")
    }
    
    func touchBack() {
        print("touch back button on unity")
        unloadUnityWindow()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDidEndUnityFramework), object: nil)
    }
}

class STProgressHUD {
    public static func showHUD() {
//        SVProgressHUD.setBackgroundColor(.clear)
//        SVProgressHUD.setForegroundColor(.primary)
//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
    }
    
    public static func hideHUD() {
//        SVProgressHUD.dismiss()
    }
}
let kDidEndUnityFramework = "kDidEndUnityFramework"
