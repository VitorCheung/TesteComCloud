//
//  ViewController.swift
//  TesteComCloud
//
//  Created by Vitor Cheung on 19/08/22.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var share:CKShare?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelText()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func share(_ sender: Any) {
        print("entrei no share")
        guard let view = makeUIViewController()
        else {
            return
            
        }
        present(view, animated: true)
    }
    @IBAction func postButton(_ sender: Any) {
        Task.init{
            do{
                _ = try await modelCloudKit.shared.postMorte(9991)
            } catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func labelText() {
        Task.init {
           let mortes = try? await modelCloudKit.shared.fetchSharedMorteRecords()
            self.label.text = "\(String(describing: mortes?.first?.MORTE))"
        }
    }
    
    func makeUIViewController() -> UICloudSharingController? {
        
        Task.init {
            do {
                share = try await modelCloudKit.shared.shareMorteRecords()
            } catch {
                print(error.localizedDescription)
            }
        }

        guard let share = share else {
            return nil
        }
        let sharingController = UICloudSharingController(
            share: share,
            container: modelCloudKit.shared.container
        )
        sharingController.availablePermissions = [.allowReadOnly, .allowPrivate]
        sharingController.modalPresentationStyle = .formSheet
        return sharingController
    }

//    func updateUIViewController(
//        _ uiViewController: ViewController
//    ) { }

}


