//
//  LoginViewController.swift
//  Ptt
//
//  Created by You Gang Kuo on 2020/12/8.
//  Copyright © 2020 Ptt. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol LoginView: BaseView {
    var onCompleteAuth: (() -> Void)? { get set }
}

final class LoginViewController: ASDKViewController<ASDisplayNode>, LoginView{
    var onCompleteAuth: (() -> Void)?
    
    //private let apiClient: APIClientProtocol = nil
    
    enum UILoginState {
        case Login  // the default state
        case AttemptRegister // try to register
        case VerifyCode // wait for email code
        case Error // display error
        case FillInformation // register success, fill name, birthday, address, etc.
    }

    
    private let rootNode = ASDisplayNode()
    
    var scrollNode = ASScrollNode()
    
    var loginNode = ASDisplayNode()
    var registerNode = ASDisplayNode()
    
    var contentStackSpec:ASStackLayoutSpec?
    var contentCenterLayoutSpec:ASCenterLayoutSpec?
    var mloginStackSpec:ASStackLayoutSpec?
    
    var funcStackSpec:ASLayoutSpec?
    
    var switchNode:ASDisplayNode?
    
    
    
    var loginStackSpec:ASCenterLayoutSpec?
    var registerStackSpec:ASCenterLayoutSpec?
    
    let global_width = 265
    
    
    func init_layout() -> ASLayoutSpec {
                
        
        //
        let LeftfuncStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                   spacing: 5,
                                                   justifyContent: .start,
                                                   alignItems: .start,
                                                   children: [btnTypeLogin, lbLine, btnTypeRegister])
        LeftfuncStackSpec.style.preferredSize = CGSize(width: global_width, height: 44)
        let RightfuncStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                   spacing: 5,
                                                   justifyContent: .end,
                                                   alignItems: .start,
                                                   children: [btnRegisterProgress])
        RightfuncStackSpec.style.preferredSize = CGSize(width: global_width, height: 44)
        
        funcStackSpec = ASAbsoluteLayoutSpec(children: [RightfuncStackSpec, LeftfuncStackSpec])
        funcStackSpec?.style.preferredSize = CGSize(width: global_width, height: 44+43)

        initLoginViews() // init loginStackSpec and login views
        initRegisterViews() // init registerStackSpec and register views
        
        let switchLayoutSpec = ASAbsoluteLayoutSpec(children: [registerStackSpec!, loginStackSpec! ])
        //ASLayoutSpec(children: [loginStackSpec, registerStackSpec])
        contentStackSpec = ASStackLayoutSpec(direction: .vertical,
                                                   spacing: 0,
                                                   justifyContent: .center,
                                                   alignItems: .center,
                                                   children: [lbTitle, funcStackSpec!, switchLayoutSpec])

        // AS Login Node
        self.scrollNode.addSubnode(self.lbTitle)
        self.scrollNode.addSubnode(self.loginNode)
        self.scrollNode.addSubnode(self.registerNode)
        
        
        self.scrollNode.addSubnode(self.btnTypeLogin)
        self.scrollNode.addSubnode(self.btnTypeRegister)

        node.addSubnode(self.scrollNode) ;
        
        return contentStackSpec!
    }
    
    @objc func hideKeyboard() {
        if let tf = tfPassword.view as? UITextField {
            tf.endEditing(true)
        }
        if let tf = tfUsername.view as? UITextField {
            tf.endEditing(true)
        }
        if let tf = tfRegisterEmail.view as? UITextField {
            tf.endEditing(true)
        }
        if let tf = tfRegisterUsername.view as? UITextField {
            tf.endEditing(true)
        }
        if let tf = tfRegisterPassword.view as? UITextField {
            tf.endEditing(true)
        }
        
    }
    
    func bind_event(){
        btnTypeLogin.addTarget(self, action: #selector(switchTypeRegister), forControlEvents: ASControlNodeEvent.touchUpInside)
        btnTypeRegister.addTarget(self, action: #selector(switchTypeRegister), forControlEvents: ASControlNodeEvent.touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.node.view.addGestureRecognizer(tap)
        
        self.btnLogin.addTarget(self, action: #selector(loginPress), forControlEvents: ASControlNodeEvent.touchUpInside)
        self.btnUserAgreement.addTarget(self, action: #selector(userAgreementPress), forControlEvents: ASControlNodeEvent.touchUpInside)
        self.btnForget.addTarget(self, action: #selector(forgetPress), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    
    
    // not working
    func updateNode(_ parentNode:ASDisplayNode){
        DispatchQueue.main.async{
             parentNode.transitionLayout(withAnimation: false,
                                    shouldMeasureAsync: true,
                                    measurementCompletion: nil)
        }
    }

    func toggleState(_ state:UILoginState) {
        switch state {
        case .Login:
            print("Toggle State Login")
            //btnForget.isHidden = true
            toggleLoginView(isHidden: false)
            toggleRegisterView(isHidden: true)
            
        case .AttemptRegister:
            print("Toggle State AttemptRegister")
            //btnForget.isHidden = false
            toggleLoginView(isHidden: true)
            toggleRegisterView(isHidden: false)
            
        case .VerifyCode:
            print("Toggle State VerifyCode")
        case .Error:
            print("Toggle State Error")
        case .FillInformation:
            print("Toggle State FillInformation")
        }
        //self.updateNode(self.rootNode) // must be add???
        //self.rootNode.setNeedsLayout()
        //self.rootNode.layoutIfNeeded()
    }
    
    
    func justTest(){
        print("just test new api")
        APIClient.shared.attemptRegister(account: "sc30", email: "scsonic+sc30@gmail.com") {result in
            print("@@ account already exist=", type(of: result), result)
            
            APIClient.shared.attemptRegister(account: "scsonic", email: "scsonic@gmail.com") {result in
                print("@@ account can be use=", type(of: result), result)
            }
        }
    }
    
    override func viewDidLoad() {
        //justTest()
        print("login view did load") ;
        self.bind_event()
        toggleState(.Login)
    }

    override init() {
        super.init(node: rootNode)
        self.rootNode.backgroundColor = GlobalAppearance.backgroundColor // self.blackColor
        
        let stack = self.init_layout()
        
        self.scrollNode.automaticallyManagesSubnodes = true
        self.scrollNode.automaticallyManagesContentSize = false // false: can't scroll by user but keyboard
        self.scrollNode.view.showsHorizontalScrollIndicator = false
        self.scrollNode.view.showsVerticalScrollIndicator = false
        
        scrollNode.layoutSpecBlock = { node, constrainedSize in
            return stack
        }
        
        node.layoutSpecBlock = { _, _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.scrollNode)
        }
        
        node.automaticallyManagesSubnodes = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    func gotoRegisterWebview() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func switchTypeRegister(_ button:ASButtonNode) {
        
        if button == btnTypeRegister {
            btnTypeRegister.isSelected = true
            btnTypeLogin.isSelected = false
            toggleState(.AttemptRegister);
        }
        else if button == btnTypeLogin {
            btnTypeRegister.isSelected = false
            btnTypeLogin.isSelected = true
            toggleState(.Login)
        }
        self.hideKeyboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    lazy var btnRegisterProgress:ASButtonNode = {
        let button = ASButtonNode()
        let title = "AA BB CC"
        let attr: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline) //UIFont(name: "HelveticaNeue-Bold", size: 16)!
        ]
        
        button.setTitle(title, with: nil, with: PttColors.paleGrey.color, for: UIControl.State.selected)
        button.setTitle(title, with: nil, with: PttColors.slateGrey.color, for: UIControl.State.normal)
        
        button.isSelected = false
        return button
    }()
    
    
    lazy var btnTypeRegister:ASButtonNode = {
        let button = ASButtonNode()
        let title = L10n.register
        
        let attr: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline) //UIFont(name: "HelveticaNeue-Bold", size: 16)!
        ]
        
        button.setTitle(title, with: nil, with: PttColors.paleGrey.color, for: UIControl.State.selected)
        button.setTitle(title, with: nil, with: PttColors.slateGrey.color, for: UIControl.State.normal)
        
        button.isSelected = false
        return button
    }()
    
    
    lazy var btnTypeLogin:ASButtonNode = {
        let button = ASButtonNode()
        let title = L10n.login

        let attr: [NSAttributedString.Key : Any] = [
           .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline) // UIFont(name: "HelveticaNeue-Bold", size: 16)!
        ]
        button.setTitle(title, with: nil, with: PttColors.paleGrey.color, for: UIControl.State.selected)
        button.setTitle(title, with: nil, with: PttColors.slateGrey.color, for: UIControl.State.normal)

        button.isSelected = true
        
        return button
    }()
    
    lazy var lbLine:ASTextNode =  {
        let label = ASTextNode()
        let attr:[NSAttributedString.Key : Any] = [
            .foregroundColor: PttColors.paleGrey.color,
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)// UIFont(name: "HelveticaNeue-Bold", size: 16)!
        ]
        
        var title = NSAttributedString.init(string: "|", attributes: attr)
        label.attributedText = title
        return label
    }()
    
    lazy var lbTitle:ASTextNode =  {
        let label = ASTextNode()
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .left
        paragraphStyle.paragraphSpacing = 2
        paragraphStyle.lineSpacing = 0
        let attributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1), //UIFont.boldSystemFont(ofSize: 24),
            NSAttributedString.Key.foregroundColor: self.text_color,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        label.attributedText = NSAttributedString.init(string: "批踢踢實業坊\nPtt.cc", attributes: attributes)
        //label.backgroundColor = GlobalAppearance.backgroundColor
        return label
    }()
    
    
    lazy var tfRegisterEmail = ASDisplayNode.init { () -> UIView in
        var tf = LoginTextField(type: TextFieldType.Email)
        tf.title = NSLocalizedString("User Email", comment: "")
        
        tf.delegate = self
        tf.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        return tf
    }
    
    lazy var tfRegisterUsername = ASDisplayNode.init { () -> UIView in
        var tf = LoginTextField(type: TextFieldType.Username)
        tf.title = L10n.username
        
        tf.delegate = self
        tf.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        return tf
    }
    
    lazy var tfRegisterPassword = ASDisplayNode.init { () -> UIView in
        var tf = LoginTextField(type: TextFieldType.Password)
        tf.title = L10n.password
        
        tf.delegate = self
        tf.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        return tf
    }
    
    lazy var btnAttemptRegister: ASButtonNode = {
        let button = ButtonNode(type: .primary)
        button.title = "下一步"
        button.isEnabled = false
        return button
    }()
    
    
    lazy var btnRegisterUserAgreement:ASButtonNode = {
        let button = ASButtonNode()
        let title = NSLocalizedString("AgreeWhenYouUseApp", comment:"")
        
        let attr = [
            NSAttributedString.Key.foregroundColor: PttColors.paleGrey.color,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ] as [NSAttributedString.Key : Any]
        button.setAttributedTitle(NSAttributedString.init(string: title, attributes: attr), for: UIControl.State.normal)
        
        return button
    }()
    
    lazy var tfUsername = ASDisplayNode.init { () -> UIView in
        var textField:TextFieldWithPadding = TextFieldWithPadding()
        textField.background = UIImage.backgroundImg(from: self.textfield_backgroundcolor)

        let title = L10n.username
        let attr:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: self.text_color,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        ]
        textField.attributedPlaceholder = NSAttributedString.init(string: title, attributes:attr)
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = self.tint_color.cgColor
        textField.clipsToBounds = true
        
        textField.delegate = self
        textField.textColor = PttColors.paleGrey.color
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        
        textField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        
        textField.keyboardType = .asciiCapable
        
        textField.addSubview(self.lbUsernameResponse)
        textField.text = ""
        textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        return textField
    }
    
    
    lazy var lbRegisterEmailResponse:UILabel = {
        var label = UILabel()
        label.textColor = self.tint_color
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.frame = CGRect(x: 0, y:0, width:global_width-16, height:30)
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        return label
    }()
    
    
    lazy var lbUsernameResponse:UILabel = {
        var label = UILabel()
        label.textColor = self.tint_color
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.frame = CGRect(x: 0, y:0, width:global_width-16, height:30)
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var lbPasswordResponse:UILabel = {
        var label = UILabel()
        label.textColor = self.tint_color
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.frame = CGRect(x: 0, y:0, width:global_width-44, height:30)
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        return label
    }()
    
    
    lazy var btnTooglePassword:UIButton = {
        var btn = UIButton()
        btn.frame = CGRect(x:0, y:0, width:44, height:44)
        if #available(iOS 12.0, *) {
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        }
        btn.setImage(StyleKit.imageOfPasswdVisibilitySelected(), for: UIControl.State.selected)
        btn.setImage(StyleKit.imageOfPasswdVisibility(), for: UIControl.State.normal)

        btn.addTarget(self, action: #selector(self.togglePassword), for: UIControl.Event.touchDown)
        return btn
    }()
    
    lazy var tfPassword = ASDisplayNode.init { () -> UIView in
        var textField:TextFieldWithPadding = TextFieldWithPadding()

        textField.background = UIImage.backgroundImg(from: self.textfield_backgroundcolor)
        
        let title = L10n.password
        let attr = [
            NSAttributedString.Key.foregroundColor: self.text_color,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1
            )//UIFont.systemFont(ofSize: 12)
        ]
        textField.isSecureTextEntry = true
        textField.returnKeyType = .send
        textField.attributedPlaceholder = NSAttributedString.init(string: title, attributes:attr )
        
        textField.layer.cornerRadius = 15
        textField.clipsToBounds = true
        
        // TODO:Fellow color
        textField.layer.borderColor = self.tint_color.cgColor
        textField.textColor = PttColors.paleGrey.color
        
        textField.text = ""
        
        textField.rightViewMode = .always
        textField.rightView = self.btnTooglePassword
        
        textField.addSubview(self.lbPasswordResponse)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        return textField
    }
    
    class TextFieldWithPadding: UITextField {
        var textPadding = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.textRect(forBounds: bounds)
            return rect.inset(by: textPadding)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.editingRect(forBounds: bounds)
            return rect.inset(by: textPadding)
        }
    }
    
    @objc func togglePassword() {
        self.btnTooglePassword.isSelected = !self.btnTooglePassword.isSelected
        if let tf = tfPassword.view as? UITextField {
            tf.isSecureTextEntry = !tf.isSecureTextEntry
        }
    }
    
    func showAlert(title:String, msg:String) {
        let controller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: L10n.confirm, style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    @objc func loginPress() {
        print("login press")
        self.hideKeyboard()
        var account = ""
        var passwd = ""
        
        if let tf = self.tfUsername.view as? UITextField, let tfText = tf.text {
            account = tfText
        }
        if let tf = self.tfPassword.view as? UITextField, let tfText = tf.text {
            passwd = tfText
        }
  
        // block by btnLogin.isEnabled
//        if ( account.isEmpty ) {
//            self.lbUsernameResponse.text = "NOT FINISH:" + L10n.notFinish
//            tfUsername.layer.borderWidth = 1
//            return
//        }
//
//        if (passwd.isEmpty ){
//            self.lbPasswordResponse.text = "NOT FINISH:" + L10n.notFinish
//            tfPassword.layer.borderWidth = 1
//            return ;
//        }
        
        self.btnLogin.isEnabled = false
        APIClient.shared.login(account: account, password: passwd) { (result) in
            DispatchQueue.main.async {
                print("login using", account, " result", result)
                switch (result) {
                case .failure(let error):
                    print(error)
                    self.showAlert(title: L10n.error, msg: L10n.login + L10n.error + error.message)
                case .success(let token):
                    print(token.access_token)
                    self.onLoginSuccess(token: token.access_token)
                }
            }
        }
    }
    
    func onLoginSuccess(token:String) {
        _ = LoginKeyChainItem.shared.saveToken(token)
        // todo: push view
        DispatchQueue.main.async {
            print("ready to call finish flow in main thread")
            self.onCompleteAuth?()
        }
    }
    
    @objc func userAgreementPress() {
        print("user agreement press")
    }
    
    @objc func forgetPress() {
        print("forget press")
    }

    lazy var btnLogin: ASButtonNode = {
        let button = ButtonNode(type: .primary)
        button.title = L10n.login
        button.isEnabled = false
        return button
    }()
    
    lazy var btnUserAgreement:ASButtonNode = {
        let button = ASButtonNode()
        let title = NSLocalizedString("AgreeWhenYouUseApp", comment:"")
        
        let attr = [
            NSAttributedString.Key.foregroundColor: PttColors.paleGrey.color,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ] as [NSAttributedString.Key : Any]
        button.setAttributedTitle(NSAttributedString.init(string: title, attributes: attr), for: UIControl.State.normal)
        
        return button
    }()
    
    lazy var vLine:ASDisplayNode = {
        let line = ASDisplayNode()
        line.backgroundColor = PttColors.paleGrey.color
        return line
    }()
    
    
    
    lazy var btnForget: ASButtonNode = {
        let button = ButtonNode(type: .secondary)
        button.title = L10n.forget
//        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
//
//        button.backgroundColor = UIColor.systemGray
//        button.setAttributedTitle(NSAttributedString.init(string: title, attributes: attr), for: UIControl.State.normal)
//
//        button.layer.cornerRadius = 15
//        button.clipsToBounds = true
        return button
    }()
    
    
    
    var text_color : UIColor {
        if #available(iOS 11.0, *) {
            return PttColors.paleGrey.color
        } else {
            return UIColor(red: 240/255, green: 240/255, blue: 247/255, alpha: 1.0)
        }
    }
    
    var textfield_backgroundcolor : UIColor {
        if #available(iOS 11.0, *) {
            return PttColors.shark.color
        } else {
            return UIColor(red: 28/255, green: 28/255, blue: 31/255, alpha: 1.0)
        }
    }
    
    var tint_color : UIColor {
        if #available(iOS 11.0, *) {
            return PttColors.tangerine.color // UIColor(named: "tintColor-255-159-10")!
        } else {
            return UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 1.0)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            scrollViewToFitKeyboard(Int(keyboardHeight))
        }
    }
    
    func scrollViewToFitKeyboard(_ lastKeyboardHeight:Int){
        let screenHeight = Int(self.view.bounds.height)
        
        let keyboardHeight:Int = lastKeyboardHeight + Int(self.btnForget.frame.height + self.btnLogin.frame.height + 31) // 31 = login~forget height
        
        let margin_to_keyboard = 10
        let diff = Int(btnLogin.view.frame.origin.y) - (screenHeight-keyboardHeight) + margin_to_keyboard
        
//        print("screen height=", UIScreen.main.bounds.height)
//        print("btn login pos=", btnLogin.view.frame.origin, btnLogin.view.bounds)
//        print("screen diff=", diff)
        
        if ( diff > 0){
            let point = CGPoint(x: 0, y: Int(diff) )
            self.scrollNode.view.setContentOffset(point, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfUsername.view:
            tfPassword.becomeFirstResponder()
        case tfPassword.view:
            loginPress()
        default:
            break
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let point = CGPoint(x: 0, y: 0)
        self.scrollNode.view.setContentOffset(point, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lbPasswordResponse.text = ""
        self.lbUsernameResponse.text = ""
        self.tfPassword.layer.borderWidth = 0
        self.tfUsername.layer.borderWidth = 0
    }
    

}

extension LoginViewController {
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let usernameTextField = tfUsername.view as? UITextField,
           let passwordTextField = tfPassword.view as? UITextField,
           let username = usernameTextField.text,
           let password = passwordTextField.text,
           !username.isEmpty && !password.isEmpty {
            btnLogin.isEnabled = true
        } else {
            btnLogin.isEnabled = false
        }
    }
}
