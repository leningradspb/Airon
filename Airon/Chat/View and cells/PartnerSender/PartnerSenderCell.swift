
import UIKit

class PartnerSenderCell: UITableViewCell {
    private let partnerImageView = UIImageView(image: UIImage(named: "ai-girl-chat"))
    private let messageView = UIView()
    private let messageTextLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .mainBlack
        contentView.backgroundColor = .mainBlack
        selectionStyle = .none
        setupMessageView()
    }
    
    func updatePartnerSenderCell(with text: String) {
        messageTextLabel.text = text
    }
    
    private func setupMessageView() {
        contentView.addSubview(partnerImageView)
        contentView.addSubview(messageView)
        
        partnerImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(40)
        }
        partnerImageView.layer.cornerRadius = 20
        partnerImageView.clipsToBounds = true
        
        messageView.backgroundColor = .darkGray
        messageView.layer.cornerRadius = 10
        messageView.addSubview(messageTextLabel)
        
        messageView.snp.makeConstraints {
            $0.leading.equalTo(partnerImageView.snp.trailing).offset(12)
            $0.bottom.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        messageTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        messageTextLabel.numberOfLines = 0
        messageTextLabel.lineBreakMode = .byWordWrapping
        messageTextLabel.font = UIFont.systemFont(ofSize: 18)
        messageTextLabel.textColor = .white
        messageTextLabel.textAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
