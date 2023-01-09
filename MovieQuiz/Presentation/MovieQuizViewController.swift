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
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
   
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showResultAlert(_ result: AlertModel) {
        alert?.showAlert(result: result)
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
