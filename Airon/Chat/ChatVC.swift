

import UIKit
import FirebaseFirestore

class ChatVC: UIViewController {
    private let tableView = UITableView()
    private let inputMessageStack = HorizontalStackView(distribution: .fill, spacing: 10, alignment: .bottom)
    private let sentMessageButton = UIButton()
    private let messageTextView = UITextView()
    private var messages: [Message] = []
    private let placeholder = "Enter text"
    private let userImage = UIImageView()
    private let userNickName = UILabel()
    
    private var model: ChatInitModel
    init(model: ChatInitModel) {
        self.model = model
        let message = Message(formID: ReferenceKeys.aiSender, toID: ReferenceKeys.meSender, message: model.firstMessage)
        messages.append(message)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .black
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
        //        guard let navBar = navigationController?.navigationBar else { return }
        //        navigationItem.title = "Начать чат"
        //        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let userBar = UIView()
        //        userBar.backgroundColor = .green
        navigationItem.titleView = userBar
        userBar.addSubviews([userImage, userNickName])
        
        userImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(5)
            $0.height.width.equalTo(54)
            //            $0.bottom.equalToSuperview().offset(-5)
        }
        userImage.layer.cornerRadius = 27
        userImage.contentMode = .scaleAspectFill
        
        userNickName.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(userImage.snp.trailing)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview()
        }
        userNickName.textColor = .white
        userNickName.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        userBar.snp.makeConstraints {
            //            $0.top.equalToSuperview()
            //            $0.width.equalTo(150)
            $0.height.equalTo(44)
            //            $0.bottom.equalToSuperview()
        }
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
        tableView.backgroundColor = .black
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
        messageTextView.backgroundColor = .black
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.darkGray.cgColor
        messageTextView.text = placeholder
        messageTextView.textColor = .darkGray
        messageTextView.autocorrectionType = .no
        messageTextView.keyboardAppearance = .dark
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.textContainerInset = UIEdgeInsets(top: 13, left: 10, bottom: 10, right: 40)
    }
    
    @objc private func sendTapped() {
        sendMessage()
    }
    
    private func sendMessage(imageURL: String? = nil, imageSize: CGSize? = nil) {
//        let timestamp: Double = Date().timeIntervalSince1970
        let text = messageTextView.text ?? ""
//        let myID: String = self.myID!
        let message = Message(formID: ReferenceKeys.meSender, toID: ReferenceKeys.aiSender, message: text)
        messages.append(message)
        if let secondMessage = model.secondMessage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let secondMessageAI = Message(formID: ReferenceKeys.aiSender, toID: ReferenceKeys.meSender, message: secondMessage)
                self.messages.append(secondMessageAI)
                self.model.secondMessage = nil
                self.tableView.reloadData()
            }
        }
        
        tableView.reloadData()
        print("try send message", text)
    }
    
    struct ChatInitModel {
//        let formID: String
//        let toID: String
    //    let timestamp: Double
        let firstMessage: String
        var secondMessage: String?
        let prompt: String?
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
}

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            messageTextView.text = ""
            messageTextView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageTextView.text = placeholder
            messageTextView.textColor = .darkGray
        }
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
