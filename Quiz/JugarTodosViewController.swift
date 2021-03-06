//
//  JugarTodosViewController.swift
//  Quiz
//
//  Created by Rodrigo Martín Martín on 20/11/2018.
//  Copyright © 2018 Rodri. All rights reserved.
//

import UIKit

struct randomPlay: Codable {
    let quiz: Quiz
    let score: Int
}

struct randomQuizChecked: Codable {
    let answer: String
    let quizId: Int
    let result: Bool
    let score: Int
}

class JugarTodosViewController: UIViewController, UITextFieldDelegate {

    let URLNEW = "https://quiz2019.herokuapp.com/api/quizzes/randomPlay/new?token=\(token)"
    let URLNEXT = "https://quiz2019.herokuapp.com/api/quizzes/randomPlay/next?token=\(token)"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.answerTextField.delegate = self
        play(URLNEW)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        answerTextField.resignFirstResponder()
        playNext(acceptButton)
        return true
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        answerTextField.endEditing(true)
    }
    
    
    func play(_ url: String) {
        
        guard let url = URL(string: url) else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url) {
                
                if let game = try? JSONDecoder().decode(randomPlay.self, from: data) {
                    
                    DispatchQueue.main.async {
                        
                        self.questionLabel.text = game.quiz.question
                        self.scoreLabel.text = "Score: \(game.score)"
                        self.answerTextField.text = ""
                        
                        if let url = URL(string: game.quiz.attachment?.url ?? ""),
                            let data = try? Data(contentsOf: url),
                            let img = UIImage(data: data) {
                            
                            self.quizImageView.image = img
                            
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            } else {
                self.play(self.URLNEW)
            }
        }
    }
    
    @IBAction func playNext(_ sender: UIButton) {
        
        let ac = AlertController()
        
        let URL_CHECK = "https://quiz2019.herokuapp.com/api/quizzes/randomPlay/check?token=\(token)&answer=\(answerTextField.text ?? "")"
        
        guard let url = URL(string: URL_CHECK.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url) {
                
                if let quiz = try? JSONDecoder().decode(randomQuizChecked.self, from: data) {
                    
                    DispatchQueue.main.async {
                        
                        if quiz.result == true {
                            
                            self.play(self.URLNEXT)
                        } else {
                            
                            ac.showAlert("Final score: \(quiz.score)")
                            self.present(ac.alert!, animated: true)
                            self.play(self.URLNEW)
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            } else {
                self.playNext(self.acceptButton)
            }
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
