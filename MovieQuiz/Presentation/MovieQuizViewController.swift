import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var alert: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alert = AlertPresenter(controller: self)
        showLoadingIndicator()
    
        presenter.alert = alert
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
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
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            
            self.presenter.proceedToNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
                        title: "Ошибка",
                        message: message,
                        buttonText: "Попробовать ещё раз") { [weak self] in
                            guard let self = self else { return }
                            self.presenter.questionFactory?.loadData()
                            self.showLoadingIndicator()
                    }
        alert?.showAlert(result: alertModel)
        presenter.restartGame()
    }
}
