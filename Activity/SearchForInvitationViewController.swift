//
//  SearchForInvitationViewController.swift
//  BenefitWellness
//
//  Created by Gaurav Garg on 09/02/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
class SearchForInvitationViewController: BaseViewController,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var noResultView: UIControl!
    var refreshControl:UIRefreshControl!
    var currentSearchStr:String?
    var usersArray:NSArray = NSArray()
    var oldStatus:Int = 0
    var searchResultChanged = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreenUI()
        //Search for Friend
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarHideShow(hideTabBar: false)
    }
    
    func setupScreenUI()
    {
        self.headerTitleLabel.attributedText = String.createAttributedString(text: StringConstants.kMyTeamInvitationTitle, font: UIFont.akkuratLight(size: 14), color: UIColor.charcoalColor(), spacing: 1.2)
        self.searchBar.placeholder = StringConstants.kInvitationSearchPlaceholder
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)

    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        if (self.searchBar.text?.characters.count)! >= 3 {
            self.fetchUsers(searchStr: self.searchBar.text!,isLoaderNeedsToShow: false)
        }
        else
        {
            self.refreshControl.endRefreshing()
        }
       
    }
    func fetchUsers(searchStr:String,isLoaderNeedsToShow: Bool)
    {
        var params : [String : Any]? = nil
        let accesTokenStr  = accessToken()
        if isLoaderNeedsToShow
        {
            self.view.showLoader(mainTitle: "", subTitle: "")
        }
        params = ["deviceType": "ios", "userToken":accesTokenStr!,"name":searchStr]
        self.currentSearchStr = searchStr
        InviteFriendsManager.sharedManager().searchForFriends(params: params! as [String : AnyObject], completion: { (response, userArr,success, error) -> (Void) in                        self.view.hideLoader()
            self.searchResultChanged = true
            if success {
                
                if self.currentSearchStr == searchStr
                {
                    self.view.hideAllLoader()
                }
                self.usersArray = userArr!
                if self.usersArray.count > 0
                {
                    self.isTableNeedsToShow(isDataAvailable: true)
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    
                }
                else
                {
                    self.isTableNeedsToShow(isDataAvailable: false)
                }
            }
            else {
                self.isTableNeedsToShow(isDataAvailable: false)
            }
        })
    }
    func postInvitationStatusForUser(selectedUser:InviteFriendUser)
    {
        self.searchResultChanged = false
        let accesTokenStr  = accessToken()
        let aDict:[String:String] = ["userToken":accesTokenStr!,"invitedUserId" : String(format:"%d",(selectedUser.userId?.intValue)!), "type" : "1"]
        
        InviteFriends().inviteWithEmail(params: aDict as [String : AnyObject], completion: { (response, success, error) -> (Void) in
            if response.success
            {
                if let inviteInfo = response.resultDictionary?.value(forKey:"result") as? NSDictionary
                {
                     selectedUser.inviteReceiverInfo?.inviteId = inviteInfo["inviteId"] as? NSNumber //setting invited ID
                }
            }
            else {
                //wrost case check if inviteReciverInfo not created needs to check in failure case
                selectedUser.inviteReceiverInfo?.status = NSNumber.init(value: InvitedUserState.cancelled.rawValue)
                if self.searchResultChanged == false
                {
                    self.tableView.reloadData()
                }
               //needs to reload user if visible
            }
        })

        
    }
    func postWithdrawStatusForUser(selectedUser:InviteFriendUser)
    {
        self.searchResultChanged = false
        if let inviteIDNum = selectedUser.inviteReceiverInfo!.inviteId
        {
            let accesTokenStr  = accessToken()//inviteId
             let aDict:[String:String] = ["userToken":accesTokenStr!,"inviteId":String(format:"%d",inviteIDNum.intValue)]
            InviteFriends().withdrawInviteFromUser(params: aDict as [String : AnyObject], completion: { (response, success, error) -> (Void) in
                if response.success
                {
                }
                else {
                    //wrost case
                    selectedUser.inviteReceiverInfo?.status = NSNumber.init(value: self.oldStatus)
                    if self.searchResultChanged == false
                    {
                        self.tableView.reloadData()
                    }
                    //needs to reload user if visible
                }
            })

        }
       
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.searchBar.resignFirstResponder()
    }
    @IBAction func didPressNoResultView(_ sender: Any)
    {
        self.searchBar.resignFirstResponder()
    }

    private func isTableNeedsToShow(isDataAvailable:Bool)
    {
        if isDataAvailable == false {
            self.view.hideAllLoader()
        }
        self.tableView.isHidden = !isDataAvailable
        self.noResultView.isHidden = isDataAvailable
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (self.searchBar.text?.characters.count)! >= 3 {
            self.fetchUsers(searchStr: self.searchBar.text!,isLoaderNeedsToShow: true)
        }
        else if self.searchBar.text?.characters.count == 0
        {
            self.isTableNeedsToShow(isDataAvailable: false)
        }
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar.resignFirstResponder()
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell  = tableView.dequeueReusableCell(withIdentifier: String(describing: InviteFrienTableCell.self), for: indexPath as IndexPath) as! InviteFrienTableCell
        if self.usersArray.count > 0 {
            let user = self.usersArray[indexPath.row] as! InviteFriendUser
            
            listCell.nameLabel.text = user.firstName!+" "+user.lastName!
            listCell.inviteButton.addTarget(self, action: #selector(didPressInviteButton(sender:)), for: .touchUpInside)
            if user.inviteReceiverInfo == nil {
                self.changeUIAppreanceOFCellButton(cell: listCell, titleStr: StringConstants.kInviteText, isDottedImage: false)
            }
            else
            {
                if user.inviteReceiverInfo!.status!.intValue == InvitedUserState.rejected.rawValue ||  user.inviteReceiverInfo!.status!.intValue == InvitedUserState.cancelled.rawValue
                {
                    self.changeUIAppreanceOFCellButton(cell: listCell, titleStr: StringConstants.kInviteText, isDottedImage: false)
                }
                else if user.inviteReceiverInfo!.status!.intValue == InvitedUserState.acceted.rawValue
                {
                    self.changeUIAppreanceOFCellButton(cell: listCell, titleStr: StringConstants.kInviteFriendText, isDottedImage: false)
                }
                else if user.inviteReceiverInfo!.status!.intValue == InvitedUserState.pending.rawValue
                {
                    self.changeUIAppreanceOFCellButton(cell: listCell, titleStr: StringConstants.kInvitePendingText, isDottedImage: true)
                }
            }
            //Status(0=Pending 1=Accepted 2=Rejected , 3 = Canceled)
            
            if user.image != nil
            {
                let url = URL(string:user.image!)
                listCell.userImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "bLetterActive"))
            }
            else{
                listCell.userImageView.image = UIImage(named: "bLetterActive")
            }
           
        }
        return listCell
    }
    func changeUIAppreanceOFCellButton(cell:InviteFrienTableCell,titleStr:String,isDottedImage:Bool)
    {
        if isDottedImage {
            cell.inviteButton.setBackgroundImage(UIImage(named: "InviteBtnWithdot"), for: .normal)
            let newTitle = String(format:"   %@",titleStr)
            cell.inviteButton.setTitle(newTitle, for: .normal)
            cell.inviteButton.contentHorizontalAlignment = .left
        }
        else
        {
            cell.inviteButton.setBackgroundImage(UIImage(named: "InviteBtnImage"), for: .normal)
            cell.inviteButton.contentHorizontalAlignment = .center
            cell.inviteButton.setTitle(titleStr, for: .normal)
        }
    }
    func didPressInviteButton(sender:UIButton)
    {
        let buttonPosition:CGPoint = sender.convert(.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let user = self.usersArray[indexPath!.row] as! InviteFriendUser
        if user.inviteReceiverInfo == nil
        {
            user.inviteReceiverInfo = InviteInfo()
            self.inviteUser(selectedUser: user,onIndexPath:indexPath!)
        }
        else
        {
            if user.inviteReceiverInfo!.status!.intValue == InvitedUserState.rejected.rawValue ||  user.inviteReceiverInfo!.status!.intValue == InvitedUserState.cancelled.rawValue
            {
                self.inviteUser(selectedUser: user,onIndexPath:indexPath!)
            }
            else if  user.inviteReceiverInfo!.status!.intValue == InvitedUserState.acceted.rawValue || user.inviteReceiverInfo!.status!.intValue == InvitedUserState.pending.rawValue
            {
                let alertController = UIAlertController(title: StringConstants.kMessage, message: StringConstants.kWithDrawMessage, preferredStyle: .alert)
                
                let currentLocAction = UIAlertAction(title: StringConstants.kYes.uppercased(), style: .default, handler: {
                    action in
                    self.oldStatus = user.inviteReceiverInfo!.status!.intValue
                    self.withDrawUser(selectedUser: user,onIndexPath:indexPath!)
                })
                alertController.addAction(currentLocAction)
                let defaultAction = UIAlertAction(title: StringConstants.kNo.uppercased(), style: .default, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    func withDrawUser(selectedUser:InviteFriendUser,onIndexPath:IndexPath)
    {
        selectedUser.inviteReceiverInfo?.status = NSNumber.init(value: InvitedUserState.cancelled.rawValue)
        self.tableView.reloadRows(at: [onIndexPath], with: .automatic)
        self.postWithdrawStatusForUser(selectedUser: selectedUser)
    }
    func inviteUser(selectedUser:InviteFriendUser,onIndexPath:IndexPath)
    {
        selectedUser.inviteReceiverInfo?.status = NSNumber.init(value: InvitedUserState.pending.rawValue)
        self.tableView.reloadRows(at: [onIndexPath], with: .automatic)
        self.postInvitationStatusForUser(selectedUser: selectedUser)
    }
}
