

import UIKit
import FirebaseFirestore
import Lottie
import FloatingPanel

class ChatVC: UIViewController {
    private let tableView = UITableView()
    private let inputMessageStack = HorizontalStackView(distribution: .fill, spacing: 10, alignment: .bottom)
    private let sentMessageButton = UIButton()
    private let messageTextView = UITextView()
    private var messages: [Message] = []
    private let placeholder = "Enter text"
    private let navigationBarStack = VerticalStackView(spacing: 1)
    private let navigationTitleLabel = UILabel()
    private let typingView = UIView()
    private let typingLabel = UILabel()
    private let animationView = AnimationView()
    private var isNeedContinueTypingAnimation = true
    
    private var firstMessageAnswer: String?
    private var currentMessage: String?
    
    private var model: ChatInitModel
    init(model: ChatInitModel) {
        self.model = model
        let message = Message(formID: ReferenceKeys.aiSender, toID: ReferenceKeys.meSender, message: model.firstMessage)
        messages.append(message)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .mainBlack
        setupNavigationBar()
        setupTableView()
        setupInputMessageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAvoidingKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "gov", style: .plain, target: self, action: #selector(sendTapped))
        let config = UIImage.SymbolConfiguration(weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward", withConfiguration: config), style: .plain, target: self, action: #selector(popVC))
        navigationBarStack.addArranged(subviews: [navigationTitleLabel, typingView])
        navigationItem.titleView = navigationBarStack
        typingView.addSubviews([typingLabel, animationView])
        navigationTitleLabel.textColor = .white
        navigationTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        navigationTitleLabel.text = model.topicName
        navigationTitleLabel.textAlignment = .center
        typingLabel.text = "typing"
        typingLabel.font = .systemFont(ofSize: 12)
        typingLabel.textColor = .systemBlue
        typingLabel.textAlignment = .center
        typingLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.centerX.equalTo(navigationTitleLabel.snp.centerX)
            $0.bottom.equalToSuperview()
        }

        animationView.animation = ActivityView.Animations.dots
//        animationView.logHierarchyKeypaths()
        
//        animationView.backgroundColor = .black.withAlphaComponent(0.7)
        
        let blue = Color(r: (14/255), g: (122/255), b: (254/255), a: 1)
        let orangeColorValueProvider = ColorValueProvider(blue)

        // Set color value provider to animation view
        let keyPath = AnimationKeypath(keypath: "**.Shape Layer 2.Ellipse 1.Fill 1.Color")
        let keyPath1 = AnimationKeypath(keypath: "**.Shape Layer 1.Ellipse 1.Fill 1.Color")
        let keyPath3 = AnimationKeypath(keypath: "**.Shape Layer 3.Ellipse 1.Fill 1.Color")
        animationView.setValueProvider(orangeColorValueProvider, keypath: keyPath)
        animationView.setValueProvider(orangeColorValueProvider, keypath: keyPath1)
        animationView.setValueProvider(orangeColorValueProvider, keypath: keyPath3)
        
        animationView.snp.makeConstraints {
            $0.leading.equalTo(typingLabel.snp.trailing).offset(-10)
            $0.centerY.equalTo(typingLabel.snp.centerY)
            $0.height.equalTo(70)
            $0.width.equalTo(40)
        }
        
        typingView.isHidden = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            //            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            //            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .mainBlack
        tableView.separatorStyle = .none
        tableView.contentInset.top = 20
        tableView.register(MeSenderCell.self, forCellReuseIdentifier: MeSenderCell.identifier)
        tableView.register(PartnerSenderCell.self, forCellReuseIdentifier: PartnerSenderCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupInputMessageView() {
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        view.addSubview(inputMessageStack)
        
        inputMessageStack.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            //            $0.bottom.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        inputMessageStack.addArranged(subviews: [messageTextView])
       
        view.addSubview(sentMessageButton)
        sentMessageButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(messageTextView.snp.bottom).offset(-5)
            $0.trailing.equalTo(messageTextView.snp.trailing).offset(-10)
        }
        let sentImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: iconConfig)
        sentMessageButton.setImage(sentImage, for: .normal)
        sentMessageButton.tintColor = .systemBlue
        sentMessageButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        messageTextView.delegate = self
        messageTextView.backgroundColor = .mainBlack
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.white.cgColor
        messageTextView.text = placeholder
        messageTextView.textColor = .white
        messageTextView.autocorrectionType = .no
        messageTextView.keyboardAppearance = .dark
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 40)
    }
    
    private func showTyping() {
        isNeedContinueTypingAnimation = true
        typingView.isHidden = false
        playTypingAnimation()
    }
    
    private func hideTyping() {
        isNeedContinueTypingAnimation = false
        typingView.isHidden = true
//        stopTypingAnimation()
    }
    
    private func playTypingAnimation() {
        
        animationView.play { [weak self] isComplete in
            guard let self = self else { return }
            if self.isNeedContinueTypingAnimation {
                self.playTypingAnimation()
            }
        }
    }
    
    private func stopTypingAnimation() {
        isNeedContinueTypingAnimation = false
        animationView.stop()
    }
    
    private func showPurchaseModal() {
        messageTextView.endEditing(true)
        let vc = PurchaseModal()
        let fpc = FloatingPanelController()
        
        PurchaseService.shared.purchaseCompletion = { [weak self] in
            guard let self = self else { return }
//            vc.dismiss(animated: true)
            
            fpc.dismiss(animated: true)
        }
        
        fpc.delegate = self
        fpc.surfaceView.cornerRadius = 22
        fpc.backdropView.backgroundColor = UIColor(hex: "#001326")
        fpc.surfaceView.backgroundColor = .clear
        fpc.contentInsetAdjustmentBehavior = .never
        fpc.surfaceView.grabberHandle.barColor = UIColor.black.withAlphaComponent(0.08)
        fpc.isRemovalInteractionEnabled = true
        fpc.set(contentViewController: vc)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handlePreviewModalBackdropTap))
//        fpc.backdropView.addGestureRecognizer(tapGesture)
        
        DispatchQueue.main.async {
            fpc.addPanel(toParent: self, animated: true)
            fpc.updateLayout()
            fpc.updateLayout()
        }
    }
    
    @objc private func sendTapped() {
        let isFreeRequestsEnded = PurchaseService.shared.isFreeRequestsEnded
        
        guard PurchaseService.shared.isActivated || !isFreeRequestsEnded else {
            showPurchaseModal()
            return
        }
        
        
        currentMessage = messageTextView.text
        sendMessage()
    }
    
    @objc private func popVC() {
        stopTypingAnimation()
        navigationController?.popViewController(animated: true)
    }
    
    private func sendMessage() {
//        let timestamp: Double = Date().timeIntervalSince1970
        let text = currentMessage ?? ""
//        let myID: String = self.myID!
        let message = Message(formID: ReferenceKeys.meSender, toID: ReferenceKeys.aiSender, message: text)
        messages.append(message)
        messageTextView.text = ""
        tableView.reloadData()
        if !self.messages.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        if let secondMessage = model.secondMessage {
            self.firstMessageAnswer = text
            self.showTyping()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let secondMessageAI = Message(formID: ReferenceKeys.aiSender, toID: ReferenceKeys.meSender, message: secondMessage)
                self.messages.append(secondMessageAI)
                self.model.secondMessage = nil
                self.messageTextView.text = ""
//                self.messageTextView.endEditing(true)
                self.hideTyping()
                self.tableView.reloadData()
                if !self.messages.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
            return
        }
        
        requestToAI()
    }
    
    private func requestToAI() {
        self.showTyping()
        let text = currentMessage ?? ""
        let initPrompt = model.prompt ?? ""
        var prompt: String
        if let firstMessageAnswer = firstMessageAnswer {
            prompt = initPrompt + firstMessageAnswer + ":\n\n" + text
        } else {
            prompt = initPrompt + text
        }
        print("request prompt = \(prompt)")
        let requestModel = AIRequestModel(prompt: prompt)
        APIService.requestAI(model: requestModel) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let _ = error {
                    self.hideTyping()
                    self.messageTextView.endEditing(true)
                    self.showError()
                }
                
                if let choice = result?.choices?.first, let text = choice.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let message = Message(formID: ReferenceKeys.aiSender, toID: ReferenceKeys.meSender, message: text)
//                    self.firstMessageAnswer = nil
                    self.messages.append(message)
                    self.messageTextView.text = ""
//                    self.messageTextView.endEditing(true)
                    self.hideTyping()
                    self.tableView.reloadData()
                    if !self.messages.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                    
                    if !PurchaseService.shared.isActivated && !PurchaseService.shared.isFreeRequestsEnded && PurchaseService.shared.freeRequestCounter < 5 {
                        PurchaseService.shared.freeRequestCounter += 1
                        
                        if PurchaseService.shared.freeRequestCounter > 4 {
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isFreeRequestsEnded.rawValue)
                        }
                    }
                } else {
                    self.hideTyping()
                    self.messageTextView.endEditing(true)
                    self.showError()
                }
            }
        }
    }
    
    private func showError() {
        let modal = ErrorModal(errorText: "something went wrong🤯 we are terrible sorry🥺 if you see that message at first time please try again. if you see few times in a row please try later🙏")
        modal.tryAgainCompletion = { [weak self] in
            guard let self = self else { return }
            self.requestToAI()
        }
        self.window.addSubview(modal)
    }
    
    struct ChatInitModel {
//        let formID: String
//        let toID: String
    //    let timestamp: Double
        let firstMessage: String
        var secondMessage: String?
        let prompt: String?
        let topicName: String
    }
    
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < messages.count {
            let message = messages[indexPath.row]
            
            if message.formID == ReferenceKeys.meSender {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: MeSenderCell.identifier, for: indexPath) as! MeSenderCell
                cell.updateMeSenderCell(with: message.message)
                return cell
            } else {

                
                let cell = tableView.dequeueReusableCell(withIdentifier: PartnerSenderCell.identifier, for: indexPath) as! PartnerSenderCell
                cell.updatePartnerSenderCell(with: message.message)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < messages.count {
            let message = messages[row].message
            UIPasteboard.general.string = message
            let alert = UIAlertController(title: "Copied ✅", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            messageTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
        }
    }
}

extension ChatVC: FloatingPanelControllerDelegate
{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout?
    {
        return BottomSheetPresenter.PanelIntrinsicLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
//        startScanner()
//        weekTapped()
    }
}


extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}

struct Message: Codable {
    let formID: String
    let toID: String
//    let timestamp: Double
    let message: String
}

extension APIService {
    static func requestAI(model: AIRequestModel, completion: @escaping (_ result: AIResponseModel?, _ error: Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/completions")!)
        request.configure(.post)
        
        do {
            let data = try JSONEncoder().encode(model)
            request.httpBody = data
            print(data)
            print(String(data: data, encoding: .utf8) as Any)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("---------------------------------")
            print("Server response:")
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("DATA NOT FOUND!!! 🤯")
                completion(nil, error)
                return
            }
            print(String(data: data, encoding: .utf8) as Any)
//            print("JSON String: \(String(data: data, encoding: .utf8))")
            do {
                let history = try JSONDecoder().decode(AIResponseModel.self, from: data)
                print(history as Any)
                completion(history, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

struct AIRequestModel: Codable {
    let prompt: String
    let model = "text-davinci-003"
    let temperature = 0.5
    let max_tokens = 60
    let top_p = 1
    let frequency_penalty = 0.5
    let presence_penalty = 0.0
//        {
//          "model": "text-davinci-003",
//          "prompt": "Correct this to standard English:\n\noenter text you want to get correction",
//          "temperature": 0.5,
//          "max_tokens": 60,
//          "top_p": 1.0,
//          "frequency_penalty": 0.5,
//          "presence_penalty": 0.0
//        }
}

struct AIResponseModel: Codable {
    let choices: [Choice]?
    
    struct Choice: Codable {
        let text: String?
    }
}
