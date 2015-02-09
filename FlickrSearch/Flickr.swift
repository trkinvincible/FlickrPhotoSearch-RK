import UIKit

let FLICKR_API_KEY = "978d7216fb7560fbd505ddc25c7bc264"

class Flickr {
  
  enum SearchResult {
    case Results([FlickrPhoto])
    case Error
  }
  
  typealias SearchCompletion = (result: SearchResult) -> Void
  
  class func search(term: String, completion: SearchCompletion) {
    let encodedTerm = (term as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let searchURLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FLICKR_API_KEY)&text=\(encodedTerm)&per_page=30&format=json&nojsoncallback=1"
    let request = NSURLRequest(URL: NSURL(string: searchURLString)!)
    
    var error:NSError?
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) in
      
        if error != nil {
         println("Flickr error: \(error)")
         completion(result: .Error)
         return
        }
        
        let resultDict:NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        if error != nil{
            completion(result: .Error)
        }else{
            let status:String = resultDict.objectForKey("stat") as String
            
            if status == "fail"{
                completion(result: .Error)
            }else{
                let resultArray:NSArray = resultDict.objectForKey("photos")?.objectForKey("photo") as NSArray
                
                var flickrPhotos: [FlickrPhoto] = []
                for photo in resultArray {
                    let photoDict:NSDictionary = photo as NSDictionary
                    flickrPhotos.append(FlickrPhoto.createFromJSON(photoDict))
                }
                completion(result: .Results(flickrPhotos))
                return
            }
        }
      }
    }
    
//    class func upload {
//
//    }
  }
