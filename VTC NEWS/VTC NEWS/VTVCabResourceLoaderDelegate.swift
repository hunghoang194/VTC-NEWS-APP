
import AVFoundation
import AVKit
import GoSwiftyM3U8
open class VTVCabResourceLoaderDelegate : NSObject{
    fileprivate static let instance = VTVCabResourceLoaderDelegate()
    private var token : String?
    private var errorDelegate : VTVCabHelperDelegate?
    private var streamUrl : String?
    private var host : String?
    private let queue = DispatchQueue(label: "com.anhtriu.queue")
 
    public  static var shared: VTVCabResourceLoaderDelegate {
        get {
            return instance
        }
    }

    open func error_delegate(delegate : VTVCabHelperDelegate){
        self.errorDelegate = delegate
    }
    
    open func setHeader(_ token : String){
        self.token = "Bearer "+token
    }
    open func getHeader() -> String {
        return self.token!
    }
    
    open func playerItem(with url: String) -> AVPlayerItem {
        self.streamUrl = url
        let url1 = NSURL(string: url)
        let urlAsset = AVURLAsset(url: url1! as URL, options: nil)
        self.host = URL(string: url)?.absoluteURL.host
        urlAsset.resourceLoader.setDelegate(self, queue: queue)
        urlAsset.resourceLoader.preloadsEligibleContentKeys = true
        let item = AVPlayerItem(asset: urlAsset)
         NotificationCenter.default.addObserver(self, selector: #selector(self.playbackStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: item)
        return item
    }
    
    @objc open func playbackStalled(_ notification: Notification?) {
        self.errorDelegate!.error()
    }
    
    open func handleRedirect(url : String, _ loadingRequest : AVAssetResourceLoadingRequest)->Bool{
  
            let newUrl = url.replacingOccurrences(of: "sdk", with: "http")
            
            if let url = URL(string: newUrl) {
                
                loadingRequest.redirect = URLRequest(url: url)
                loadingRequest.response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
                loadingRequest.finishLoading()
                
            } else {
                
                loadingRequest.finishLoading()
            }
        return true
    }
    
   
    open func handleManifest(_ loadingRequest : AVAssetResourceLoadingRequest){
        DispatchQueue.main.async {
            let parser = M3U8Parser()
            var originalURIStrings = [String]()
            var updatedURIStrings = [String]()
            let playlist = try? String.init(contentsOf: URL(string: self.convertScheme(url: loadingRequest.request.url!, old: "sdk", new: "http"))!)
            if let playlist = playlist{
                let params = M3U8Parser.Params(playlist: playlist, playlistType: .master, baseUrl: URL(string: "http://"+self.host!)!)
                var original = ""
                do {
                    let playlistResult = try parser.parse(params: params, extraParams: nil)
                    if case let .master(masterPlaylist) = playlistResult {
                        // use masterPlaylist
                        original =  masterPlaylist.originalText
                        let array = original.components(separatedBy: CharacterSet.newlines)
                        for line in array{
                            if(line.contains("EXT-X-KEY:")){
                                let furtherComponents = line.components(separatedBy: ",")
                                
                                for component in furtherComponents {
                                    
                                    if component.contains("URI") {
                                        
                                        originalURIStrings.append(component)
                                        
                                        let a = "###"
                                        let replaceString = "ckey://61.28.235.91:8787/hlsdrm-service/api/getkey?kid="
                                        let finalString = component.replacingOccurrences(of: a, with: replaceString)
                                        updatedURIStrings.append(finalString)
                                    }
                                }
                            }
                        }
                        if originalURIStrings.count == updatedURIStrings.count {
                            
                            for uriElement in originalURIStrings {
                                
                                original = original.replacingOccurrences(of: uriElement, with: updatedURIStrings[originalURIStrings.index(of: uriElement)!])
                            }
                            
                        }
                        let data = original.data(using: String.Encoding.utf8)!
                        loadingRequest.dataRequest?.respond(with: data)
                        loadingRequest.finishLoading()
                    }
                } catch {
                    // handle error
                }
            }
            
        }
    }
    
    open func getActualURL(url: URL) -> String {
        var actualURLComponents = URLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        if url.scheme == "ckey" {
            actualURLComponents!.scheme = "http"
        }
        return url.absoluteString.replacingOccurrences(of: "ckey", with: "http")
    }
    
    open func convertScheme(url : URL, old : String, new : String)->String{
        return url.absoluteString.replacingOccurrences(of: old, with: new)
    }
    
    open func getKey(_ request : AVAssetResourceLoadingRequest, _ url : URL){
        let queryString = getActualURL(url: url).replacingOccurrences(of: "+", with: "%2b")
        let ckcURL = URL(string: queryString)!
        var request1 = URLRequest(url: ckcURL)
        request1.httpMethod = "GET"
        request1.addValue(self.getHeader(), forHTTPHeaderField: "Authorization")
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request1) { data, response, error in
            if let data = data {
                let length = Int.init(16)
                let range = (0..<length)
                let data1 = data.subdata(in: range)
                request.dataRequest?.respond(with: data1)
                request.finishLoading()
            } else {
                request.finishLoading(with: NSError(domain: "anhtriu.com", code: -4, userInfo: nil))
            }
        }
        task.resume()
    }
}

extension VTVCabResourceLoaderDelegate: URLSessionDelegate {
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace?) -> Bool {
        return protectionSpace?.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("HOSTTTTTT",challenge.protectionSpace.host)
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if (challenge.protectionSpace.host == self.host || challenge.protectionSpace.host == "61.28.235.91") {
                var credential: URLCredential? = nil
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    credential = URLCredential(trust: serverTrust)
                }
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
}
extension VTVCabResourceLoaderDelegate : AVAssetResourceLoaderDelegate{
    open func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("Aaaa")
    }
    open func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let url = loadingRequest.request.url?.absoluteString
        let scheme = loadingRequest.request.url?.scheme
        
        if url!.hasSuffix(".ts") {
            return handleRedirect(url: url!, loadingRequest)
        }
        
        if(scheme == "sdk"){
            handleManifest(loadingRequest)
            return true
        }
        
        if(scheme == "ckey"){
            DispatchQueue.main.async {
                self.getKey(loadingRequest,loadingRequest.request.url!)
            }
            return true
        }
        return false
    }
}
