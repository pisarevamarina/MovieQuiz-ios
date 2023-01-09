import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alert: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        alert = AlertPresenter(controller: self)
        statisticService = StatisticServiceImplementation()
        
        presenter.viewController = self
        
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
        showLoadingIndicator()
        
        presenter.questionFactory = questionFactory
        presenter.alert = alert
        presenter.statisticService = statisticService
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }

    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
   
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func showQuestion(question: QuizQuestion) {
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = viewModel.image
            self?.textLabel.text = viewModel.question
            self?.counterLabel.text = viewModel.questionNumber
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
        }
    }
    
    private func showNextQuestionOrResults() {
        presenter.correctAnswers = correctAnswers
        
        presenter.showNextQuestionOrResults()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
                        title: "Ошибка",
                        message: message,
                        buttonText: "Попробовать ещё раз") { [weak self] in
                            guard let self = self else { return }
                            self.questionFactory?.loadData()
                            self.showLoadingIndicator()
                    }
        alert?.showAlert(result: alertModel)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: String) {
        showNetworkError(message: error)
    }
}
