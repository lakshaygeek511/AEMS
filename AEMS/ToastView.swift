import UIKit

class ToastView: UIView
{

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(message: String, image: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        layer.cornerRadius = 10
        
        addSubview(messageLabel)
        messageLabel.text = message
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])
        
        if let image = image {
            addSubview(imageView)
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


