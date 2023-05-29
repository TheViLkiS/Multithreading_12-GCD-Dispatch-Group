//
//  ViewController.swift
//  Multithreading_12 GCD Dispatch Group
//
//  Created by Дмитрий Гусев on 28.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    let viewIm = EightImage(frame: CGRect(x: 100, y: 170, width: 700, height: 900))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        
//        let dispatchGroupTest1 = DispatchGroupTest1()
//        dispatchGroupTest1.loadInfo()
        
        let dispatchGroupTest2 = DispatchGroupTest2()
        dispatchGroupTest2.loadInfo()
      
        print(imageURLs.count)
        
        asyncGroup()
        asyncUrlSession()
        view.addSubview(viewIm)
        

    }
    
    func asyncLoadImage(imageURL: URL,
                        runQueue: DispatchQueue,
                        completionQueue: DispatchQueue,
                        completion: @escaping (UIImage?, Error?) -> ()) {
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                completionQueue.async { completion(UIImage(data: data), nil)}
            } catch let error {
                completionQueue.async { completion(nil, error) }
            }
        }
       
    }

    func asyncGroup() {
        let aGroup = DispatchGroup()
        
        for i in 0...3 {
            aGroup.enter()
            asyncLoadImage(imageURL: URL(string: imageURLs[i])!, runQueue: .global(), completionQueue: .main) { result, error in
                guard let image1 = result else {return}
                images.append(image1)
                aGroup.leave()
            }
        }
        aGroup.notify(queue: .main) {
            for i in 0...3 {
                self.viewIm.ivs[i].image = images[i]
                
            }
        }

        
    }
    
    func asyncUrlSession() {
        for i in 4...7 {
            let url = URL(string: imageURLs[i - 4])
            let request = URLRequest(url: url!)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.viewIm.ivs[i].image = UIImage(data: data!)
                }
            }
            task.resume()
        }
        
        
    }


}



class DispatchGroupTest1 {
    
    private let serialQueue = DispatchQueue(label: "The Swift")
    
    private let groupRed = DispatchGroup()
    
    
    func loadInfo() {
        serialQueue.async(group: groupRed) {
            sleep(1)
            print("1")
        }
        serialQueue.async(group: groupRed) {
            sleep(1)
            print("2")
        }
        groupRed.notify(queue: .main) {
            print("groupRed finish all")
        }
        
    }
    
}

class DispatchGroupTest2 {
    
    private let concQueue = DispatchQueue(label: "The Swift", attributes: .concurrent)
    
    private let groupBlack = DispatchGroup()
    
    
    func loadInfo() {

        groupBlack.enter()
        
        concQueue.async {
            sleep(1)
            print("1")
            self.groupBlack.leave()
        }
        
        groupBlack.enter()
        
        concQueue.async {
            sleep(1)
            print("2")
            self.groupBlack.leave()
        }
        
        
        groupBlack.wait()
        
        print("finish all")
        
        groupBlack.notify(queue: .main) {
            print("groupBlack finish all")
        }
        
    }
    
}

let imageURLs = ["https://www.citypng.com/public/uploads/preview/-11597442890aiquard6ux.png", "https://www.citypng.com/public/uploads/preview/-11597442890aiquard6ux.png", "https://www.citypng.com/public/uploads/preview/-11597442890aiquard6ux.png", "https://www.citypng.com/public/uploads/preview/-11597442890aiquard6ux.png"]
var images = [UIImage]()

class EightImage: UIView {
    public var ivs = [UIImageView]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        ivs.append(UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 0, y: 100, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 100, y: 0, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100)))

        ivs.append(UIImageView(frame: CGRect(x: 0, y: 300, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 100, y: 300, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 0, y: 400, width: 100, height: 100)))
        ivs.append(UIImageView(frame: CGRect(x: 100, y: 400, width: 100, height: 100)))
        
        
        for i in 0...7 {
            ivs[i].contentMode = .scaleAspectFit
            ivs[i].backgroundColor = UIColor(red: .random(in: 0...1), green: .random(), blue: .random(), alpha: 1)
            self.addSubview(ivs[i])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}



