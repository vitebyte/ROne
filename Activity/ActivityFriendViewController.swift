//
//  ActivityFriendViewController.swift
//  BenefitWellness
//
//  Created by Gaurav Garg on 28/02/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
let healthScoreUnFilledColor = UIColor.colorWith(151.0, 151.0, 151.0, 1.0)
let healthScoreFilledColor = UIColor.colorWith(39.0, 191.0, 229.0, 1.0)
class ActivityFriendViewController: BaseViewController {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var circleViewPTrainer: UIView!
    @IBOutlet weak var circleViewGymToday: UIView!
    @IBOutlet weak var circleViewStepsToday: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var stepsTodayInfoLabel: UILabel!
    @IBOutlet weak var pTrainerTodayInfoLabel: UILabel!
    @IBOutlet weak var stepsBarInfoLabel: UILabel!
    @IBOutlet weak var gymBarInfoLabel: UILabel!
    @IBOutlet weak var pTrainerBarInfoLabel: UILabel!
    @IBOutlet weak var distanceBarInfoLabel: UILabel!
    @IBOutlet weak var caloriesBarInfoLabel: UILabel!
    @IBOutlet weak var gymTodayInfoLabel: UILabel!
    @IBOutlet weak var goalTimeSegmentControl: UISegmentedControl!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var stepsGoalBar: BWGoalBarView!
    @IBOutlet weak var gymVisitGoalBar: BWGoalBarView!
    @IBOutlet weak var personalTrainerGoalBar: BWGoalBarView!
    @IBOutlet weak var distanceGoalBar: BWGoalBarView!
    @IBOutlet weak var caloriesGoalBar: BWGoalBarView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var myTeamLabel: UILabel!
    @IBOutlet weak var collectionViewX: NSLayoutConstraint!
    @IBOutlet weak var highFiveLabel: UILabel!
    @IBOutlet weak var tierValLabel: UILabel!
    @IBOutlet weak var healthScoreView: UIView!
    @IBOutlet weak var healthScoreLabel: UILabel!
    @IBOutlet weak var healthScoreValueLabel: UILabel!
    @IBOutlet weak var staticStepsTodayLabel: UILabel!
    @IBOutlet weak var staticGymVisitTodayLabel: UILabel!
    @IBOutlet weak var staticPTSessionTodayLabel: UILabel!
    @IBOutlet weak var staticGymLabel: UILabel!
    @IBOutlet weak var staticStepsLabel: UILabel!
    @IBOutlet weak var staticCaloriesLabel: UILabel!
    @IBOutlet weak var staticPTsessionLabel: UILabel!
    @IBOutlet weak var staticdistanceLabel: UILabel!
    
    @IBOutlet weak var collectionViewTrailingConstraint: NSLayoutConstraint!
    
    var fitnessModel:Fitness?
    var myTeamDataModel:MyTeamList?
    var circleChart:PNCircleChart? = nil
    var activityModel:ActivityGoalsDataModel?
    var list:Array<MyTeamList>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDelegatesOnGoalsBar()
        setUpScreenUI()
        self.setUpUserProfile()
        callService()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarHideShow(hideTabBar: false)
        self.callAcceptedTeamList()
    }
    
    func setUpScreenUI() {
        self.list = Array()
        
        self.headerTitle.attributedText = String.createAttributedString(text: StringConstants.kActivityGoals.uppercased(), font: UIFont.akkuratLight(size: 14), color: UIColor.charcoalColor(), spacing: 1.2)
        
       //
        
        self.staticStepsTodayLabel.attributedText = String.createAttributedString(text: StringConstants.kStepsToday, font: UIFont.akkuratRegular(size: 8), color: UIColor.battleShipGreyColor(), spacing: 0.8)
        self.staticGymVisitTodayLabel.attributedText = String.createAttributedString(text: StringConstants.kGymVisits, font: UIFont.akkuratRegular(size: 8), color: UIColor.battleShipGreyColor(), spacing: 0.8)
        self.staticPTSessionTodayLabel.attributedText = String.createAttributedString(text: StringConstants.kPTSessions, font: UIFont.akkuratRegular(size: 8), color: UIColor.battleShipGreyColor(), spacing: 0.8)
        
        self.staticStepsLabel.text = StringConstants.kStepsText.uppercased()
        self.staticGymLabel.text = StringConstants.kGymVisits
        self.staticPTsessionLabel.text = StringConstants.kPTSessions
        self.staticdistanceLabel.text = StringConstants.kDistancetext
        self.staticCaloriesLabel.text = StringConstants.kCaloriestext.uppercased()
        //self.goalTimeSegmentControl.numberOfSegments = 4
        self.goalTimeSegmentControl.removeAllSegments()
        self.goalTimeSegmentControl.insertSegment(withTitle: StringConstants.kDaytext, at: 0, animated: false)
        self.goalTimeSegmentControl.insertSegment(withTitle: StringConstants.kWeektext, at: 1, animated: false)
        self.goalTimeSegmentControl.insertSegment(withTitle: StringConstants.kMonthtext, at: 2, animated: false)
        self.goalTimeSegmentControl.insertSegment(withTitle: StringConstants.kYeartext, at: 3, animated: false)
        self.goalTimeSegmentControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        
        if Constants.ScreenSize.SCREEN_MAX_LENGTH  > 667.0 {
            self.collectionViewLeadingConstraint.constant = 176.0 // 6 plus
            
        } else if Constants.ScreenSize.SCREEN_MAX_LENGTH  > 568.0 && Constants.ScreenSize.SCREEN_MAX_LENGTH  <= 667.0 {
            self.collectionViewLeadingConstraint.constant = 160.0 // 6
            
        } else {
            self.collectionViewLeadingConstraint.constant = 130.0 //5
        }

        
    }
    
    func setUpUserProfile()
    {
        self.profileImageView.layer.cornerRadius  = 30
        if let reciever = myTeamDataModel!.receiver {
            
            if ((reciever.image?.length) != nil) && (reciever.image?.length)! > 0 {
                let imageString = myTeamDataModel!.receiver?.image
                profileImageView.sd_setImage(with: URL(string: imageString!)!, placeholderImage: UIImage(named: "user"))
                
            }
            let nameStr = reciever.firstName! + " " + reciever.lastName!
            self.userName.text = nameStr.uppercased()
            
            var teamNameStr = reciever.firstName! + "'s " + StringConstants.kTeamText
            if Localizer.sharedInstance.isCurrentLanguageRTL() {
                teamNameStr = reciever.firstName! + " " + StringConstants.kTeamText
            }
            self.myTeamLabel.attributedText = String.createAttributedString(text: teamNameStr.uppercased(), font: UIFont.akkuratLight(size: 14), color: UIColor.charcoalColor(), spacing: 1.2)
            
            var str = StringConstants.kHighFive + reciever.firstName!
            if Localizer.sharedInstance.isCurrentLanguageRTL() {
                 str = reciever.firstName! + StringConstants.kHighFive
            }
            self.highFiveLabel.attributedText = String.createAttributedString(text: (str.uppercased()), font: UIFont.akkuratRegular(size: 8), color: UIColor.HighFiveColor(), spacing: 0.8)
            setBorderColorByTier(currentTier: reciever.currentTier!, onImageView: self.profileImageView)
            self.tierValLabel.text = textByTier(currentTier: reciever.currentTier!)
            self.tierValLabel.textColor = colorByTier(currentTier: reciever.currentTier!)
            drawCircleChart()
            addHealthScore()

        }
    }
    func drawCircleChart() {
        if let reciever = myTeamDataModel!.receiver {
            let targetGoalVal = goalAchievedInTier(currentTier: reciever.currentTier!)
            let targetGoalStr = String(format:"%d",targetGoalVal)
            var goalsAchieved = 0
            if let currentGoalsDict =  reciever.currentWeekGoal {
                goalsAchieved = (currentGoalsDict.goalAchieved?.intValue)!
            }
            if goalsAchieved > targetGoalVal {
                goalsAchieved = targetGoalVal
            }

           // let percentageGained = (Float(goalsAchieved)/Float(targetGoalVal))*100
            let  goalAchivedStr = String(format:"%d",goalsAchieved)
            self.circleChart = PNCircleChart(frame: CGRect(x: 0, y: 0, width: 180, height: 180), total: targetGoalVal as NSNumber!, current: goalsAchieved as NSNumber!, clockwise: true, overlineWidth: 6.0)
            self.circleChart?.backgroundColor = UIColor.clear
            if #available(iOS 10.0, *) {
                self.circleChart?.strokeColor = UIColor(displayP3Red: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
            } else {
                // Fallback on earlier versions
                self.circleChart?.strokeColor = UIColor(colorLiteralRed: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
            }
            
            self.circleChart?.addGoalLabel(goalAchivedStr, andTargetGoals: targetGoalStr);
            self.circleChart?.stroke()
            self.goalView .addSubview(self.circleChart!)
            self.goalView.layoutIfNeeded()
            
        }
    }
    func addHealthScore()
    {
        if let reciever = myTeamDataModel!.receiver {
            var healthScoreValue = 0
            if reciever.healthScore != nil
            {
                if reciever.healthScore!.healthScore != nil {
                     healthScoreValue = (reciever.healthScore!.healthScore!.intValue)
                }
               
            }
            var healthScoreTarget = healthScoreTargetStatic
            if let createdDateStr = reciever.createdAt  {
                let daysDifference = BWDateLogicManager().getNumberOfDaysUsingForUserCreatedDate(createdDateStr: createdDateStr)
                healthScoreTarget = daysDifference * 3
            }
           
            healthScoreLabel.attributedText = String.addTextSpacing(0.8, StringConstants.kHealthScore.uppercased(), UIFont.akkuratRegular(size: 8), color: UIColor.colorWith(89.0, 203.0, 232.0, 1.0))
            let healthScoreValStr = String(format:"%d",healthScoreValue)
            self.healthScoreValueLabel.attributedText = String.addTextSpacing(1.0, healthScoreValStr, UIFont.akkuratRegular(size: 16), color: healthScoreFilledColor)
            
            
            let circlePTrainerChart = PNCircleChart(frame:self.healthScoreView.bounds, total:healthScoreTarget as NSNumber!, current: healthScoreValue as NSNumber!, clockwise: true, andLineWidth:2.0)
            circlePTrainerChart?.backgroundColor = UIColor.clear
            
            //circlePTrainerChart?.circleBackgroundStrokeColor = healthScoreUnFilledColor
            //circlePTrainerChart?.strokeColor = healthScoreFilledColor
            if #available(iOS 10.0, *) {
                circlePTrainerChart?.strokeColor = UIColor(displayP3Red: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
            } else {
                // Fallback on earlier versions
                circlePTrainerChart?.strokeColor = UIColor(colorLiteralRed: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
            }
            circlePTrainerChart?.stroke()
            self.healthScoreView.addSubview((circlePTrainerChart)!)
        }
        
    }
    func callService()
    {
        guard let userID = self.myTeamDataModel?.receiver?.userId else {
            return
        }
        var params : [String : AnyObject]? = nil

        params = ["userid":String(format:"%d",userID.intValue) as AnyObject]
        ActivityGoalManager.sharedManager().getActivityGoalsData_MyTeam(params: params! , completion: { (response, success,goalsModelObj, error) -> (Void) in
            self.view.hideLoader()
            let res = response as! Response
            if success {
                self.activityModel = goalsModelObj!
                self.goalTimeSegmentControl.selectedSegmentIndex = 0
                self.segmentControlChanged(self.goalTimeSegmentControl)
                self.setUpGraphsOfDaily()
                
            }
            else {
                self.showAlertViewWithMessage(title: "", message: res.message())
            }
        })
    }
    @IBAction func highFive_action(_ sender: UIButton)
    {
        //myTeamDataModel?.receiver?.userId?.intValue
        guard let userID = self.myTeamDataModel?.receiver?.userId else {
            return
        }
        var params : [String: Any] = [String: Any]()
        params  = ["forUserId" : userID.intValue]
        self.view.showLoader(mainTitle: "", subTitle: "")
        
         ActivityGoalManager.sharedManager().sendHighFiveRequest(params: params as [String: AnyObject] , completion: { (response, success, error) -> (Void) in
            self.view.hideLoader()
            
            let response = response as! Response
            if response.success {
                self.showAlertViewWithMessage(title: "", message: response.message())
            }else{
                self.showAlertViewWithMessage(title: "", message: response.message())
            }
        })
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        self.setupLabelsText(selectedIndex: sender.selectedSegmentIndex)
        self.stepsGoalBar.setUpLayer(barType: sender.selectedSegmentIndex,dataModel:self.activityModel!,fitDataType: .steps,isOthers: true)
        self.gymVisitGoalBar.setUpLayer(barType: sender.selectedSegmentIndex,dataModel:self.activityModel!,fitDataType: .gymVisit,isOthers: true)
        self.personalTrainerGoalBar.setUpLayer(barType: sender.selectedSegmentIndex,dataModel:self.activityModel!,fitDataType: .ptrainer,isOthers: true)
        self.distanceGoalBar.setUpLayer(barType: sender.selectedSegmentIndex,dataModel:self.activityModel!,fitDataType: .distance,isOthers: true)
        self.caloriesGoalBar.setUpLayer(barType: sender.selectedSegmentIndex,dataModel:self.activityModel!,fitDataType: .calories,isOthers: true)
        
    }
    
    func setupLabelsText(selectedIndex:Int) {
        if selectedIndex == GoalBarType.daily.rawValue
        {
            let stepsWeeklyCount = BWPredicateManager.sharedManager().sumDailyStepsVal(activityDataModel: self.activityModel!)
            let gymVisitsWeeklyCount = BWPredicateManager.sharedManager().sumDailyGymVisitsVal(activityDataModel: self.activityModel!)
            let pTrainerWeeklyCount = BWPredicateManager.sharedManager().sumDailyPTrainerVal(activityDataModel: self.activityModel!)
            let caloriesWeeklyCount = BWPredicateManager.sharedManager().sumDailyCaloriesVal(activityDataModel: self.activityModel!)
            let distanceCoveredWeekly = BWPredicateManager.sharedManager().sumDailyDistanceCoveredVal(activityDataModel: self.activityModel!)
            
            self.setUpLabelContent(steps: stepsWeeklyCount, distance: distanceCoveredWeekly, calories: caloriesWeeklyCount, gymVisit: gymVisitsWeeklyCount, personalTrainer: pTrainerWeeklyCount)
        }
        else if selectedIndex == GoalBarType.weekly.rawValue {
            let stepsWeeklyCount = BWPredicateManager.sharedManager().sumWeeklyStepsVal(activityDataModel: self.activityModel!)
            let gymVisitsWeeklyCount = BWPredicateManager.sharedManager().sumWeeklyGymVisitsVal(activityDataModel: self.activityModel!)
            let pTrainerWeeklyCount = BWPredicateManager.sharedManager().sumWeeklyPTrainerVal(activityDataModel: self.activityModel!)
            let caloriesWeeklyCount = BWPredicateManager.sharedManager().sumWeeklyCaloriesVal(activityDataModel: self.activityModel!)
            let distanceCoveredWeekly = BWPredicateManager.sharedManager().sumWeeklyDistanceCoveredVal(activityDataModel: self.activityModel!)
            
            self.setUpLabelContent(steps: stepsWeeklyCount, distance: distanceCoveredWeekly, calories: caloriesWeeklyCount, gymVisit: gymVisitsWeeklyCount, personalTrainer: pTrainerWeeklyCount)
        }
        else if selectedIndex == GoalBarType.monthly.rawValue {
            let stepsMonthlyCount = BWPredicateManager.sharedManager().sumMonthlyStepsVal(activityDataModel: self.activityModel!)
            let gymVisitsMonthlyCount = BWPredicateManager.sharedManager().sumMonthlyGymVisitsVal(activityDataModel: self.activityModel!)
            let pTrainerMonthlyCount = BWPredicateManager.sharedManager().sumMonthlyPTrainerVal(activityDataModel: self.activityModel!)
            let caloriesMonthlyCount = BWPredicateManager.sharedManager().sumMonthlyCaloriesVal(activityDataModel: self.activityModel!)
            let distanceCoveredMonthly = BWPredicateManager.sharedManager().sumMonthlyDistanceCoveredVal(activityDataModel: self.activityModel!)
            self.setUpLabelContent(steps: stepsMonthlyCount, distance: distanceCoveredMonthly, calories: caloriesMonthlyCount, gymVisit: gymVisitsMonthlyCount, personalTrainer: pTrainerMonthlyCount)
            
        }
        else if selectedIndex == GoalBarType.yearly.rawValue {
            let stepsYearlyCount = BWPredicateManager.sharedManager().sumYearlyStepsVal(activityDataModel: self.activityModel!)
            let gymVisitsYearlyCount = BWPredicateManager.sharedManager().sumYearlyGymVisitsVal(activityDataModel: self.activityModel!)
            let pTrainerYearlyCount = BWPredicateManager.sharedManager().sumYearlyPTrainerVal(activityDataModel: self.activityModel!)
            let caloriesYearlyCount = BWPredicateManager.sharedManager().sumYearlyCaloriesVal(activityDataModel: self.activityModel!)
            let distanceCoveredYearly = BWPredicateManager.sharedManager().sumYearlyDistanceCoveredVal(activityDataModel: self.activityModel!)
            
            self.setUpLabelContent(steps: stepsYearlyCount, distance: distanceCoveredYearly, calories: caloriesYearlyCount, gymVisit: gymVisitsYearlyCount, personalTrainer: pTrainerYearlyCount)
        }
    }
    
    func setUpGraphsOfDaily() {
        let stepsCountToday  = BWPredicateManager.sharedManager().sumDailyStepsVal(activityDataModel: self.activityModel!)
        let gymCountToday = BWPredicateManager.sharedManager().sumDailyGymVisitsVal(activityDataModel: self.activityModel!)
        let pTrainerSessionToday = BWPredicateManager.sharedManager().sumDailyPTrainerVal(activityDataModel: self.activityModel!)
        
        self.stepsTodayInfoLabel.text = String(format:"%d",stepsCountToday)
        self.gymTodayInfoLabel.text = String(format:"%d",gymCountToday)
        self.pTrainerTodayInfoLabel.text = String(format:"%d",pTrainerSessionToday)
        
        
        // Draw step circle chart
        let circleStepsChart = PNCircleChart(frame:self.circleViewStepsToday.bounds, total:stepsTarget as NSNumber!, current: stepsCountToday as NSNumber!, clockwise: true, andLineWidth:2.0)
        circleStepsChart?.backgroundColor = UIColor.clear
        if #available(iOS 10.0, *) {
            circleStepsChart?.strokeColor = UIColor(displayP3Red: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        } else {
            // Fallback on earlier versions
            circleStepsChart?.strokeColor = UIColor(colorLiteralRed: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        }
        
        circleStepsChart?.addImageView(forImage: "StepsToday", andFor: CGSize(width:13,height:16))
        circleStepsChart?.stroke()
        self.circleViewStepsToday.addSubview((circleStepsChart)!)
        
       
        
        
        // Draw gymVisit circle chart
        
        let circleGymVisitChart = PNCircleChart(frame:self.circleViewGymToday.bounds, total:gymTarget as NSNumber!, current: gymCountToday as NSNumber!, clockwise: true, andLineWidth:2.0)
        circleGymVisitChart?.backgroundColor = UIColor.clear
        if #available(iOS 10.0, *) {
            circleGymVisitChart?.strokeColor = UIColor(displayP3Red: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        } else {
            // Fallback on earlier versions
            circleGymVisitChart?.strokeColor = UIColor(colorLiteralRed: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        }
        circleGymVisitChart?.addImageView(forImage: "GymVisityToday", andFor: CGSize(width:20,height:15))
        circleGymVisitChart?.stroke()
        self.circleViewGymToday.addSubview((circleGymVisitChart)!)
        
        
        
        
        // Draw PTrainer circle chart
        
        let circlePTrainerChart = PNCircleChart(frame:self.circleViewPTrainer.bounds, total:pTarget as NSNumber!, current: pTrainerSessionToday as NSNumber!, clockwise: true, andLineWidth:2.0)
        circlePTrainerChart?.backgroundColor = UIColor.clear
        if #available(iOS 10.0, *) {
            circlePTrainerChart?.strokeColor = UIColor(displayP3Red: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        } else {
            // Fallback on earlier versions
            circlePTrainerChart?.strokeColor = UIColor(colorLiteralRed: 52.0/255, green: 191.0/255, blue: 227.0/255, alpha: 1.0)
        }
        circlePTrainerChart?.addImageView(forImage: "PTrainerToday", andFor: CGSize(width:26,height:17))
        circlePTrainerChart?.stroke()
        self.circleViewPTrainer.addSubview((circlePTrainerChart)!)

    }
    func setUpLabelContent(steps:Int, distance:Float, calories:Float, gymVisit:Int, personalTrainer:Int) {
        
        self.stepsBarInfoLabel.text = String(format:"%02d",steps)
        self.distanceBarInfoLabel.text = String(format:"%.02f",distance/1000)
        let roundOffCaloriesValue = round(calories)
        self.caloriesBarInfoLabel.text = String(format:"%d",Int(roundOffCaloriesValue))
        self.gymBarInfoLabel.text = String(format:"%d",gymVisit)
        self.pTrainerBarInfoLabel.text = String(format:"%d",personalTrainer)
    }
}

let cellSizeWidth = 40.0 as CGFloat
extension ActivityFriendViewController {
    
    func callAcceptedTeamList() {
        self.list?.removeAll()
        
        self.collectionViewLeadingConstraint.constant = 160
        var params : [String : AnyObject]? = nil
        let userid = myTeamDataModel?.receiver?.userId?.intValue
        params = ["userid":String(format:"%d",userid!) as AnyObject]
        self.view.showLoader(mainTitle: "", subTitle: "")
        
        MyTeamList().accepetedUserList(params: params!) {(response, success, error) -> (Void) in
            
            let list = NSArray(array: response) as? Array<MyTeamList>
            if list != nil {
                for obj in list! {
                    self.list?.append(obj)

                    
                }
            }
            
            if self.list?.count == 0 {
                
            } else {
                self.contentCollectionView.reloadData()

                print("the frame is \(self.contentCollectionView.frame)")
                let numberOfItems = CGFloat((list?.count)!)
                let cellSize:CGFloat = 60.0
                
                if numberOfItems > 1  {
                    let collectionWidth = (numberOfItems * cellSize) + 15
                    let remaingWidth = UIScreen.main.bounds.size.width - collectionWidth
                    let requiredLeading = remaingWidth/2.0
                    
                    self.collectionViewLeadingConstraint.constant = requiredLeading
                    self.collectionViewTrailingConstraint.constant = requiredLeading
                    
                    if self.collectionViewLeadingConstraint.constant <= 0.0  {
                        self.collectionViewLeadingConstraint.constant = 16.0
                        self.collectionViewTrailingConstraint.constant = 16.0

                    }
                }
                
//                self.contentCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: true)

            }
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraintsIfNeeded()
//        self.contentCollectionView.layoutIfNeeded()

        self.view.hideLoader()
        
    }
}
