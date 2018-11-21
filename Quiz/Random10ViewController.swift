//
//  Random10ViewController.swift
//  Quiz
//
//  Created by Rodrigo Martín Martín on 21/11/2018.
//  Copyright © 2018 Rodri. All rights reserved.
//

import UIKit

struct Random10Quiz: Codable {
    let id: Int?
    let question: String?
    let answer: String?
    let author: Usuario?
    let attachment: Attachment?
    let favourite: Bool?
    let tips: [String]
}

class Random10ViewController: UIViewController {

    let URLBASE = "https://quiz2019.herokuapp.com/api/quizzes/random10wa?token=f2079b1d0cee0c8adbf2"
    var quizzes = [Random10Quiz]()
    var numberOfQuizzes = 0
    var quizzesAsked = 0
    var score = 0
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        downloadQuizzes()
    }
    
    func downloadQuizzes() {
        
        guard let url = URL(string: URLBASE) else { return }
    
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url){
                
                if let quizzes = try? JSONDecoder().decode([Random10Quiz].self, from: data) {
                    
                    DispatchQueue.main.async {
            
                        self.quizzes = quizzes
                        self.play()
                        self.numberOfQuizzes = quizzes.count
                    }
                } else {
                    print("Error Decoder")
                }
            }
        }
    }
    
    func play() {
        questionLabel.text = quizzes[quizzesAsked].question
        answerTextField.text = ""
        scoreLabel.text = "Score: \(score)"
        
        DispatchQueue.global().async {
            if let url = URL(string: (self.quizzes[self.quizzesAsked].attachment?.url)!),
                let data = try? Data(contentsOf: url),
                let img = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    
                    self.quizImageView.image = img
                }
            }
        }
    }
    
    @IBAction func accept(_ sender: UIButton) {
        
        if answerTextField.text?.lowercased() == quizzes[quizzesAsked].answer?.lowercased() {
            quizzesAsked += 1
            score += 1
            if quizzesAsked < numberOfQuizzes {
                play()
            }
        } else {
            
            let ac = AlertController()
            ac.showAlert("Final score: \(score)")
            self.present(ac.alert!, animated: true)
            score = 0
            quizzesAsked = 0
            downloadQuizzes()
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}