
import UIKit

class MeSenderCell: UITableViewCell {
    private let messageView = UIView()
    private let messageTextLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .mainBlack
        contentView.backgroundColor = .mainBlack
        selectionStyle = .none
        setupMessageView()
    }
    
    func updateMeSenderCell(with text: String) {
        messageTextLabel.text = text
    }
    
    private func setupMessageView() {
        contentView.addSubview(messageView)
        messageView.backgroundColor = .systemBlue
        messageView.layer.cornerRadius = 10
        messageView.addSubview(messageTextLabel)
        
        messageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
        }
        
        messageTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        messageTextLabel.numberOfLines = 0
        messageTextLabel.lineBreakMode = .byWordWrapping
        messageTextLabel.font = UIFont.systemFont(ofSize: 18)
        messageTextLabel.textColor = .white
        messageTextLabel.textAlignment = .right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
