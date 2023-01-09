//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Марина Писарева on 08.01.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var alert: AlertPresenterProtocol?
    var statisticService: StatisticService?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        viewController?.showNetworkError(message: error)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        viewController?.showQuestion(question: question)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        viewController?.showAnswerResult(isCorrect: isCorrect)
        
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func yesButtonClicked() {
        didAnswer(givenAnswer: true)
    }
        
    func noButtonClicked() {
        didAnswer(givenAnswer: false)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(givenAnswer: isCorrect)

        viewController?.showAnswerResult(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            self.statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            guard let gamesCount = statisticService?.gamesCount else {return}
            guard let bestGame = statisticService?.bestGame else {return}
            guard let totalAccuracy = statisticService?.totalAccuracy else {return}

            let message = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(gamesCount) Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            let alertModel = AlertModel(
                            title: "Этот раунд окончен!",
                            message: message,
                            buttonText: "Сыграть еще раз",
                            completion: {
                                self.restartGame()
                                self.questionFactory?.requestNextQuestion()
                            })
            alert?.showAlert(result: alertModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
