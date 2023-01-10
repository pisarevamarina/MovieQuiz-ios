//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Марина Писарева on 09.01.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuestion(quiz step: QuizStepViewModel) 
    func showResultAlert(_ result: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
        
    func enableButtons()
    
    func showNetworkError(message: String)
}
