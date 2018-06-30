//
//  ActivityViewController+InviteFriends.swift
//  BenefitWellness
//
//  Created by Preeti Bhatia on 29/01/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
import UIKit

extension ActivityViewController: UICollectionViewDataSource, UICollectionViewDelegate,UIPopoverPresentationControllerDelegate, BWGoalBarDelegate {
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list!.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (self.list?.count == indexPath.row) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        if (self.list?.count)! > 0 {
            let notificationModel:MyTeamList = self.list![indexPath.row]
            cell.configureMyTeamCell(data: notificationModel, imageName: "", indexPath: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.list?.count == indexPath.row) {
            // TODO://
            
            self.inviteFriendsButtonPressed()
            self.contentCollectionView.performBatchUpdates({
                self.contentCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                
            }, completion: nil)
        }
        else {
            let notificationModel:MyTeamList = self.list![indexPath.row]
            self.viewMyTeamActivity(myTeam: notificationModel)
        }
    }
    
    func inviteFriendsButtonPressed() {
        let mainStoryboard = UIStoryboard.goalStoryboard()
        let inviteFriends = mainStoryboard.instantiateViewController(withIdentifier: "SearchForInvitationViewController") as! SearchForInvitationViewController
        self.navigationController?.pushViewController(inviteFriends, animated: true)
    }
    
    func viewMyTeamActivity(myTeam:MyTeamList) {
        let mainStoryboard = UIStoryboard.goalStoryboard()
        let activityFriend = mainStoryboard.instantiateViewController(withIdentifier: "ActivityFriendViewController") as! ActivityFriendViewController
        activityFriend.myTeamDataModel = myTeam
        self.navigationController?.pushViewController(activityFriend, animated: true)
    }
    
    func addDelegatesOnGoalsBar() {
        self.stepsGoalBar.delegate = self
        self.caloriesGoalBar.delegate = self
        self.distanceGoalBar.delegate = self
        self.personalTrainerGoalBar.delegate = self
        self.gymVisitGoalBar.delegate = self
    }
    
    //MARK:GoalBarDelegates
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func didTapGoalBar(tappedPoint:CGPoint,value:Float,fitnessType:FitnessDataType) {

        let popoverViewController = UIStoryboard.goalStoryboard().instantiateViewController(withIdentifier: "popOverSeque") as! ActivityPopOver
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.preferredContentSize = CGSize(width: 70, height: 70)
        popoverViewController.definesPresentationContext = true
        popoverViewController.popoverPresentationController?.sourceView = self.view
        let popOver = popoverViewController.popoverPresentationController!
        popOver.permittedArrowDirections = .down
        
        if fitnessType == .steps {
            popOver.sourceView = self.stepsGoalBar
            popoverViewController.valueFitStr = String(format:"%02d",Int(value))
        }
        else if fitnessType == .gymVisit {
            popOver.sourceView = self.gymVisitGoalBar
            popoverViewController.valueFitStr = String(format:"%02d",Int(value))
        }
        else if fitnessType == .ptrainer {
            popOver.sourceView = self.personalTrainerGoalBar
            popoverViewController.valueFitStr = String(format:"%02d",Int(value))
        }
        else if fitnessType == .distance {
            
            popOver.sourceView = self.distanceGoalBar
            popoverViewController.valueFitStr = String(format:"%.02f",value/1000)
            
        }
        else if fitnessType == .calories {
            popOver.sourceView = self.caloriesGoalBar
            popoverViewController.valueFitStr = String(format:"%.02f",value)
        }
        popOver.sourceRect = CGRect(x: tappedPoint.x, y: 0, width: 0, height: 0)
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
}

