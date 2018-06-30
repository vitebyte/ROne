//
//  ActivityViewController.swift
//  BenefitWellness
//
//  Created by Benefit Wellness on 03/01/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
import Social

let stepsTarget:Int64 = 10000
let gymTarget:Int64 = 1
let pTarget:Int64 = 1
let distanceTarget:Float = 1.0 // Km 
let caloriesTarget:Float = 1000.0
let healthScoreTargetStatic = 100 //not fixed yet

class ActivityViewController: BaseViewController {
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var circleViewPTrainer: UIView!
    
    @IBOutlet weak var circleViewGymToday: UIView!
    
    @IBOutlet weak var circleViewStepsToday: UIView!
    
    @IBOutlet weak var timerView: UIView!
    
    @IBOutlet weak var fbShareButton: UIButton!
    
    @IBOutlet weak var stepsTodayInfoLabel: UILabel!
    
    @IBOutlet weak var pTrainerTodayInfoLabel: UILabel!
    
    @IBOutlet weak var stepsBarInfoLabel: UILabel!
    
    @IBOutlet weak var gymBarInfoLabel: UILabel!
    
    @IBOutlet weak var tierValLabel: UILabel!
    
    @IBOutlet weak var pTrainerBarInfoLabel: UILabel!
    
    @IBOutlet weak var distanceBarInfoLabel: UILabel!
    
    @IBOutlet weak var staticStepsTodayLabel: UILabel!
    
    @IBOutlet weak var staticGymVisitTodayLabel: UILabel!
    
    @IBOutlet weak var staticPTSessionTodayLabel: UILabel!
    
    @IBOutlet weak var staticGymLabel: UILabel!
    
    @IBOutlet weak var staticStepsLabel: UILabel!
    
    @IBOutlet weak var staticCaloriesLabel: UILabel!
    
    @IBOutlet weak var staticPTsessionLabel: UILabel!
    
    @IBOutlet weak var staticdistanceLabel: UILabel!
    
    @IBOutlet weak var caloriesBarInfoLabel: UILabel!
    
    @IBOutlet weak var gymTodayInfoLabel: UILabel!
    
    @IBOutlet weak var goalTimeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var stepsGoalBar: BWGoalBarView!
    
    @IBOutlet weak var gymVisitGoalBar: BWGoalBarView!
    
    @IBOutlet weak var personalTrainerGoalBar: BWGoalBarView!
    
    @IBOutlet weak var distanceGoalBar: BWGoalBarView!
    
    @IBOutlet weak var caloriesGoalBar: BWGoalBarView!
    
    @IBOutlet weak var timeRemaingLabel: UILabel!
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var goalView: UIView!
    
    @IBOutlet weak var myTeamLabel: UILabel!
    
    @IBOutlet weak var healthScoreView: UIView!
    
    @IBOutlet weak var healthScoreLabel: UILabel!
    
    @IBOutlet weak var healthScoreValueLabel: UILabel!
    
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var aScrollView: UIScrollView!

    
    var schedular   =   Timer()
    
    var activityModel:ActivityGoalsDataModel?
    
    var circleChart:PNCircleChart? = nil
    
    var timer: CLTimer!
    
    var inviatationAccepted: Bool? = true
    
    var list:Array<MyTeamList>?
    
    
    
    //MARK:- View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpScreenUI()
        self.setUpUserProfile()
        self.updateTimerLabel()
        self.callService()
        self.callAcceptedTeamList()
        self.addDelegatesOnGoalsBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setTabBarHideShow(hideTabBar: false)
        
        self.perform(#selector(self.reloadView), with: nil, afterDelay: 0.1)

        self.unreadCountLabel.layer.cornerRadius = self.unreadCountLabel.frame.width/2
        self.unreadCountLabel.layer.masksToBounds = true
        self.unreadCountLabel.text = kAppDelegate.getNotificationCountWithKey()
        
    }
    
    
    func callService() {
        //self.view.showLoader(mainTitle: "", subTitle: "")
        DispatchQueue.global(qos: .background).async { [weak self]
            () -> Void in
            ActivityGoalManager.sharedManager().getGoalsInfoData(params: [:]) { (response, success, user, error) -> (Void) in
                //self.view.hideLoader()
                guard let strongSelf = self else {return }
                let res = response as! Response
                if success {
                    
                    //
                    if let usertype = user?.userType{
                       UserManager.sharedManager().activeUser.userType = usertype
                    }
                    
                    DispatchQueue.main.async {
                        () -> Void in
                        strongSelf.setupUserGoalData(user: user!)
                    }
                    
                }
                else {
                    DispatchQueue.main.async {
                        () -> Void in
                        strongSelf.showAlertViewWithMessage(title: "", message: res.message())
                    }
                    
                }
            }
        }
    }
    
    // MARK:- Private Methods
    func reloadView() {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.aScrollView.contentOffset = CGPoint(x: 0, y: 0)
                
            }, completion: { (status) in
                //
            })
        }

        if self.goalTimeSegmentControl == nil {
            let goalSegmentControl = UISegmentedControl()
            goalSegmentControl.selectedSegmentIndex = 0
            self.segmentControlChanged(goalSegmentControl)

        } else {
            if let segmentcontrol = self.goalTimeSegmentControl {
                segmentcontrol.selectedSegmentIndex = 0
                self.segmentControlChanged(segmentcontrol)

            }

        }
        
    }
    
    func setUpScreenUI() {
        self.list = Array()
        
        self.headerTitle.attributedText = String.createAttributedString(text: StringConstants.kActivityGoals.uppercased(), font: UIFont.akkuratLight(size: 14), color: UIColor.charcoalColor(), spacing: 1.2)
        
        self.myTeamLabel.attributedText = String.createAttributedString(text: StringConstants.kMyTeamHeader, font: UIFont.akkuratLight(size: 14), color: UIColor.charcoalColor(), spacing: 1.2)
        self.designFbButton()
        
        self.timeRemaingLabel.attributedText = String.createAttributedString(text: StringConstants.kTimeRemaining.uppercased(), font: UIFont.akkuratRegular(size: 10), color: UIColor.colorWith(109.0, 111.0, 125.0, 1.0), spacing: 1.0)
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

       // self.goalTimeSegmentControl.
        
        if Constants.ScreenSize.SCREEN_MAX_LENGTH  > 667.0 {
            self.collectionViewLeadingConstraint.constant = 176.0 // 6 plus
            
        } else if Constants.ScreenSize.SCREEN_MAX_LENGTH  > 568.0 && Constants.ScreenSize.SCREEN_MAX_LENGTH  <= 667.0 {
            self.collectionViewLeadingConstraint.constant = 160.0 // 6
            
        } else {
            self.collectionViewLeadingConstraint.constant = 130.0 //5
        }
    }
    
    func designFbButton() {
        let submitStr = StringConstants.kShareProgress
        let signInAttributedString = String.createAttributedString(text: (submitStr?.uppercased(with: NSLocale.current))!, font: UIFont.akkuratRegular(size: 8), color: UIColor.colorWith(255.0, 255.0, 255.0, 1.0), spacing: 0.5)
        self.fbShareButton.setAttributedTitle(signInAttributedString, for: .normal)
        
        self.fbShareButton.layer.cornerRadius = 12.0
        if Localizer.sharedInstance.isCurrentLanguageRTL() {
             self.fbShareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -50)
        }
        else
        {
            self.fbShareButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0)
        }
        
        self.fbShareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
    }
    
    
    func addHealthScore(user: User) {
        
        var healthScoreValue = 0
        if user.healthScore != nil {
             healthScoreValue = (user.healthScore?.intValue)!
        }
        let daysDifference = BWDateLogicManager().getNumberOfDaysUsingForUserCreatedDate(createdDateStr: user.createdAt!)
        let healthScoreTarget = daysDifference * 3
        healthScoreLabel.attributedText = String.addTextSpacing(0.8, StringConstants.kHealthScore.uppercased(), UIFont.akkuratRegular(size: 8), color: UIColor.colorWith(89.0, 203.0, 232.0, 1.0))
        let healthScoreValStr = String(format:"%d",healthScoreValue)
        self.healthScoreValueLabel.attributedText = String.addTextSpacing(0.0, healthScoreValStr, UIFont.akkuratRegular(size: 16), color: healthScoreFilledColor)
        
        
        let circlePTrainerChart = PNCircleChart(frame:self.healthScoreView.bounds, total:healthScoreTarget as NSNumber!, current: healthScoreValue as NSNumber!, clockwise: true, andLineWidth:1.5)
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
    
    
    func drawCircleChart(user:User) {
       
        let targetGoalVal = goalAchievedInTier(currentTier: user.currentTier!)
        let targetGoalStr = String(format:"%d",targetGoalVal)
        var goalsAchieved = 0
        if let currentGoalsDict =  user.currentWeekGoal {
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
    

    func setUpUserProfile() {
        self.profileImageView.layer.cornerRadius  = 30
        if let activeUser = UserManager.sharedManager().activeUser {
            
            if let imageUrl = activeUser.image {
                if imageUrl.length > 0 {
                    profileImageView.sd_setImage(with: URL(string: imageUrl)!, placeholderImage: UIImage(named: "user"))
                }
            }
            let nameStr = activeUser.fullName()
            self.userName.text = nameStr?.uppercased()
        }
    }
    
    
    func setupUserGoalData(user:User) {
        setBorderColorByTier(currentTier: user.currentTier!, onImageView: self.profileImageView)
        self.tierValLabel.text = textByTier(currentTier: user.currentTier!)
        self.tierValLabel.textColor = colorByTier(currentTier: user.currentTier!)
        drawCircleChart(user:user)
        addHealthScore(user:user)
    }
    
    // MARK:- Weekly Timer
    func updateTimerLabel() {
        self.timerView.layoutIfNeeded()
        let diffRemaing = BWDateLogicManager().logicDate()
        timer = CLTimer(frame:self.timerView.bounds)
        
        self.timerView.addSubview(timer)
        
        //timer.cltimer_delegate=self
        timer.startTimer(withSeconds: diffRemaing, format:.Minutes , mode: .Reverse)
    }
    
    
    // MARK:- Database
    func displayDailyDataFromDatabase() {
        
        let startDate:NSDate = TimerCounter.timeAtBeginningOfTheDay(for: Date()) as NSDate
        let endDate:NSDate = TimerCounter.timeAtEndingOfTheDay(for: Date()) as NSDate
        
        LogManager.DLog(message: "startDate: \(startDate)" as AnyObject, function: #function)
        LogManager.DLog(message: "endDate: \(endDate)" as AnyObject, function: #function)
        
        
        let list:[DailyFitness] = DatabaseManager.database().fetchDailyFitnessBasedOnHourly(startDate: startDate, endDate: endDate)!
        
        var steps:Int64 = 0
        var distance:Float = 0
        var calories:Float = 0
        var gymVisit:Int64 = 0
        var personalTrainer:Int64 = 0
        
        var aDict:[String:String]?
        
        for item in list {

            //get String from Date
            LogManager.DLog(message: " item.calories: \(String(describing: item.calories))" as AnyObject)
            LogManager.DLog(message: " ite,.distance: \(String(describing: item.distance))" as AnyObject)

            
            let aDateString:String = FitnessDataUtility.sharedPreferences().convertDateToStringInUTCTimeZone(date: item.fitnessDate! as Date, format: Date.dateFormatYYYYMMDDhhmmssPlusDashed())
            
            
            if (item.fitnessId?.length)! > 0 {
                let hour:String = getHourValueFromDateString(dateValue: item.fitnessId!)
                
                if hour.length > 0 {
                    steps = steps + Int64(item.steps!)!
                    distance = distance + Float(item.distance!)!
                    calories = calories + Float(item.calories!)!
                }

            }

        }
        
        
        // FETCH PTSessions
        let ptSessionlist:[PTSessions] = DatabaseManager.database().fetchPTSessionsBasedOnHourly(startDate: startDate, endDate: endDate)!
        
        for item in ptSessionlist {
            
            let aDateString:String = item.ptSessionDate!
            
            if (aDateString.length) > 0 {
                let hour:String = getHourValueFromDateString(dateValue: aDateString)
                
                if hour.length > 0 {
                    personalTrainer = personalTrainer + item.ptSessionsCount
                }
            }
            
        }
        
        // FETCH GymVisits
        let gymVisitlist:[GymVisits] = DatabaseManager.database().fetchGymVisitBasedOnHourly(startDate: startDate, endDate: endDate)!
        
        for item in gymVisitlist {
            
            let aDateString:String = item.gymVisitDate!
            
            if (aDateString.length) > 0 {
                let hour:String = getHourValueFromDateString(dateValue: aDateString)
                
                if hour.length > 0 {
                    gymVisit = gymVisit + item.gymVisitCount
                }
            }
        }
        
        
        let stepsCountToday = steps
        let gymCountToday = gymVisit
        let pTrainerSessionToday = personalTrainer
        self.stepsTodayInfoLabel.text = String(format:"%d",stepsCountToday)
        self.gymTodayInfoLabel.text = String(format:"%d",gymCountToday)
        self.pTrainerTodayInfoLabel.text = String(format:"%d",pTrainerSessionToday)
        
        
        // Draw step circle chart
        for view in self.circleViewStepsToday.subviews {
            view.removeFromSuperview()
        }
        for view in self.circleViewGymToday.subviews {
            view.removeFromSuperview()
        }
        for view in self.circleViewPTrainer.subviews {
            view.removeFromSuperview()
        }
        let circleStepsChart = PNCircleChart(frame:self.circleViewStepsToday.bounds, total:stepsTarget as NSNumber!, current: steps as NSNumber!, clockwise: true, andLineWidth:2.0)
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
        
        self.stepsBarInfoLabel.text = String(format:"%02d",steps)
        
       

        if FitnessDataUtility.sharedPreferences().checkIfDeviceConnected() {
            // To show distance in Km
            if deviceTypeId() == NSNumber(value: 0) {
                self.distanceBarInfoLabel.text = String(format:"%.02f",distance/1000)
                
            } else {
                self.distanceBarInfoLabel.text = String(format:"%.02f",distance)
            }
        } else {
            //self.distanceBarInfoLabel.text = String(format:"%.02f",distance)
            self.distanceBarInfoLabel.text = String(format:"%.02f",distance/1000)

        }

        let roundOffCaloriesValue = round(calories)
        self.caloriesBarInfoLabel.text = String(format:"%d",Int(roundOffCaloriesValue))
        
        
        // Draw gymVisit circle chart
        
        let circleGymVisitChart = PNCircleChart(frame:self.circleViewGymToday.bounds, total:gymTarget as NSNumber!, current: gymVisit as NSNumber!, clockwise: true, andLineWidth:2.0)
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
        
        self.gymBarInfoLabel.text = String(format:"%d",gymVisit)
        
        
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
        self.pTrainerBarInfoLabel.text = String(format:"%d",pTrainerSessionToday)
        
    }
    
    func displayDayWiseDataFromDatabase() {
        
        let listOfDates = TimerCounter.timeAtBeginningOfTheMonth(for: Date())
        LogManager.DLog(message: "listOfDates: \(listOfDates)" as AnyObject, function: #function)
        
        var dailySteps:Int64 = 0
        var dailyDistance:Float = 0
        var dailyCalories:Float = 0
        var dailyGymVisit:Int64 = 0
        var dailyPersonalTrainer:Int64 = 0

        var stepsList:[[String:NSNumber]] = []

        for date in listOfDates {
            
            let currentDate = Date()

            if date <= currentDate {
                let startDate:NSDate = TimerCounter.timeAtBeginningOfTheDay(for: date) as NSDate
                let endDate:NSDate = TimerCounter.timeAtEndingOfTheDay(for: date) as NSDate
                
                let list:[DailyFitness] = DatabaseManager.database().fetchDailyFitnessBasedOnHourly(startDate: startDate, endDate: endDate)!
                
                let ptSessionlist:[PTSessions] = DatabaseManager.database().fetchPTSessionsBasedOnHourly(startDate: startDate, endDate: endDate)!
                
                let gymVisitlist:[GymVisits] = DatabaseManager.database().fetchGymVisitBasedOnHourly(startDate: startDate, endDate: endDate)!


                for item in ptSessionlist {
                    dailyPersonalTrainer = dailyPersonalTrainer + item.ptSessionsCount
                }
                
                for item in gymVisitlist {
                    dailyGymVisit = dailyGymVisit + item.gymVisitCount
                }
                
                
                
                for item in list {
                    dailySteps = dailySteps + Int64(item.steps!)!
                    dailyDistance = dailyDistance + Float(item.distance!)!
                    dailyCalories = dailyCalories + Float(item.calories!)!
                    
                    
                    let stepsNumber = NSNumber(value:dailySteps)
                    let distanceCoveredNumber = NSNumber(value:dailyDistance)
                    let caloriesNumber = NSNumber(value:dailyCalories)
                    let gymVisitNumber = NSNumber(value:dailyGymVisit)
                    let personalTrainerNumber = NSNumber(value:dailyPersonalTrainer)
                    
                    
                    let aDay:String = FitnessDataUtility.sharedPreferences().convertDateToStringInUTCTimeZone(date: item.fitnessDate! as Date, format: Date.dateFormatDDMMYYYYDashed())
                    
                    print("aDay....", aDay)
                    
                    if let idx = aDay.characters.index(of: "-") {
                        
                        let dayValue = aDay.substring(to: idx)
                        print("aDay....", dayValue)
                        let aDict = ["steps": stepsNumber, "distanceCovered": distanceCoveredNumber, "caloriesBurned": caloriesNumber, "gymVisits": gymVisitNumber, "ptSessions": personalTrainerNumber, "hourKey": NSNumber(value: Int(dayValue)!)]
                        
                        stepsList.append(aDict)

                    }

                }
                
                LogManager.DLog(message: "dailyTotalSteps: \(dailySteps)" as AnyObject, function: #function)
            }
        }
        
        LogManager.DLog(message: "stepsList: \(stepsList)" as AnyObject, function: #function)
        
        
        let maxCount = listOfDates.count + 1
        let numberOfStepsValuesAvailable = stepsList.count
        var tempStepsList:[[String:NSNumber]] = []
        
        for j in 1...maxCount {
            let dict = ["steps": 0, "distanceCovered": 0, "caloriesBurned": 0, "gymVisits": 0, "ptSessions": 0,"hourKey": NSNumber(value: j)] as [String : NSNumber]
            tempStepsList.append(dict)
        }
        
        
        if numberOfStepsValuesAvailable > 0 {
            // Replace HourKey Data with existing Step Value
            for i in 0..<numberOfStepsValuesAvailable {
                
                let aDict:[String:NSNumber] = stepsList[i]
                
                if aDict["hourKey"] != nil {
                    
                    let tempDict:[String:NSNumber] = ["hourKey":aDict["hourKey"]!,"steps":aDict["steps"]!, "distanceCovered": aDict["distanceCovered"]!, "caloriesBurned": aDict["caloriesBurned"]!, "gymVisits": aDict["gymVisits"]!, "ptSessions": aDict["ptSessions"]!]
                    
                    
                    LogManager.DLog(message: "tempDict: \(tempDict)" as AnyObject, function: #function)
                    
                    LogManager.DLog(message: "hourKey \(tempDict["hourKey"]!)" as AnyObject, function: #function)

                    let m = tempDict["hourKey"]!.intValue  // m is an `Int64`

                    tempStepsList[m] = tempDict
                    
                    LogManager.DLog(message: "tempDict: \(tempStepsList)" as AnyObject, function: #function)

                    //tempStepsList[Int("hourKey")!] = tempDict
                    
                }
            }
        }

        
        // TO Display Data on Graph, added in Model Class
        let mainModelObj = ActivityGoalsDataModel()
        mainModelObj.createModelObjectsforDaily(currentDateDataArr: tempStepsList as NSArray)
        self.activityModel = mainModelObj
        
    }
    
    
    func displayWeeklyDataFromDatabase() {
        let listOfDates = TimerCounter.timeAtBeginningOfTheWeek(for: Date())
        
        LogManager.DLog(message: "listOfDates: \(listOfDates)" as AnyObject, function: #function)
        
        
        var stepsList:[[String:NSNumber]] = []
        
        for date in listOfDates {
            
            
            let startDate:NSDate = TimerCounter.timeAtBeginningOfTheDay(for: date) as NSDate
            let endDate:NSDate = TimerCounter.timeAtEndingOfTheDay(for: date) as NSDate
            
            let list:[DailyFitness] = DatabaseManager.database().fetchDailyFitnessBasedOnHourly(startDate: startDate, endDate: endDate)!
            
            var steps:Int64 = 0
            var distance:Float = 0
            var calories:Float = 0
            var gymVisit:Int64 = 0
            var personalTrainer:Int64 = 0
            for item in list {
                steps = steps + Int64(item.steps!)!
                distance = distance + Float(item.distance!)!
                calories = calories + Float(item.calories!)!
                gymVisit = gymVisit + item.gymVisit
                personalTrainer = personalTrainer + item.personalTrainer
            }
            
            let stepsNumber = NSNumber(value:steps)
            let distanceCoveredNumber = NSNumber(value:distance)
            let caloriesNumber = NSNumber(value:calories)
            let gymVisitNumber = NSNumber(value:gymVisit)
            let personalTrainerNumber = NSNumber(value:personalTrainer)
            
            let aDict = ["steps": stepsNumber, "distanceCovered": distanceCoveredNumber, "caloriesBurned": caloriesNumber, "gymVisits": gymVisitNumber, "ptSessions": personalTrainerNumber]
            
            stepsList.append(aDict)
            
        }
        
        
        var weeklySteps:Int64 = 0
        var weeklyDistance:Float = 0
        var weeklyCalories:Float = 0
        var weeklyGymVisit:Int64 = 0
        var weeklyPTrainer:Int64 = 0
        
        var aDict:[String:NSNumber]?
        for i in 0..<7 {
            aDict = stepsList[i]
            weeklySteps = weeklySteps + Int64(aDict!["steps"]!)
            weeklyDistance = weeklyDistance + Float(aDict!["distanceCovered"]!)
            weeklyCalories = weeklyCalories + Float(aDict!["caloriesBurned"]!)
            weeklyGymVisit = weeklyGymVisit + Int64(aDict!["gymVisits"]!)
            weeklyPTrainer = weeklyPTrainer + Int64(aDict!["ptSessions"]!)
            
            LogManager.DLog(message: "Date: \(listOfDates[i]) --- Steps: \(stepsList[i])" as AnyObject, function: #function)
            
            LogManager.DLog(message: "--- total Steps: \(weeklySteps)" as AnyObject, function: #function)
            
        }
        
        self.setUpLabelContent(steps: weeklySteps, distance: weeklyDistance, calories: weeklyCalories, gymVisit: weeklyGymVisit, personalTrainer: weeklyPTrainer)
        
        
        // TO Display Data on Graph, added in Model Class
        let mainModelObj = ActivityGoalsDataModel()
        mainModelObj.createModelObjectsforWeekData(weeklyDataArr: stepsList as NSArray)
        self.activityModel = mainModelObj
        
        
    }
    
    func displayMonthlyDataFromDatabase() {
        
        let listOfDates = TimerCounter.timeAtBeginningOfTheMonth(for: Date())
        LogManager.DLog(message: "listOfDates: \(listOfDates)" as AnyObject, function: #function)
        let calendar = Calendar.current
        var dates:[[Date]] = []
        var currentWeek = 1
        var week:[Date] = []
        for date in listOfDates {
            let components = calendar.dateComponents([.weekOfMonth], from: date)
            if components.weekOfMonth != currentWeek {
                currentWeek += 1
                dates.append(week)
                week = []
            }
            week.append(date)
        }
        dates.append(week)
        
        LogManager.DLog(message: "dates : \(dates)" as AnyObject, function: #function)
        
        var weeklyTotalSteps:[[String:NSNumber]] = []
        
        let currentDate = Date()
        
        for aWeek in dates {
            
            var weeklySteps:Int64 = 0
            var weeklyDistance:Float = 0
            var weeklyCalories:Float = 0
            var weeklyGymVisit:Int64 = 0
            var weeklyPersonalTrainer:Int64 = 0
            
            
            for date in aWeek {
                
                if date <= currentDate {
                    let startDate:NSDate = TimerCounter.timeAtBeginningOfTheDay(for: date) as NSDate
                    let endDate:NSDate = TimerCounter.timeAtEndingOfTheDay(for: date) as NSDate
                    
                    let list:[DailyFitness] = DatabaseManager.database().fetchDailyFitnessBasedOnHourly(startDate: startDate, endDate: endDate)!
                    
                    for item in list {
                        weeklySteps = weeklySteps + Int64(item.steps!)!
                        weeklyDistance = weeklyDistance + Float(item.distance!)!
                        weeklyCalories = weeklyCalories + Float(item.calories!)!
                        weeklyGymVisit = weeklyGymVisit + item.gymVisit
                        weeklyPersonalTrainer = weeklyPersonalTrainer + item.personalTrainer
                        
                    }
                }
            }
            let weeklyStepsNumber = NSNumber(value:weeklySteps)
            let weeklyDistanceNumber = NSNumber(value:weeklyDistance)
            let weeklyCaloriesNumber = NSNumber(value:weeklyCalories)
            let weeklyGymVisitNumber = NSNumber(value:weeklyGymVisit)
            let weeklyPersonalTrainerNumber = NSNumber(value:weeklyPersonalTrainer)
            
            let aDict = ["steps": weeklyStepsNumber, "distanceCovered": weeklyDistanceNumber, "caloriesBurned": weeklyCaloriesNumber, "gymVisits": weeklyGymVisitNumber, "ptSessions": weeklyPersonalTrainerNumber]
            
            weeklyTotalSteps.append(aDict)
            
        }
        
        LogManager.DLog(message: "weeklyTotalSteps: \(weeklyTotalSteps)" as AnyObject, function: #function)
        
        var weeklySteps:Int64 = 0
        var weeklyDistance:Float = 0
        var weeklyCalories:Float = 0
        var weeklyGymVisit:Int64 = 0
        var weeklyPersonalTrainer:Int64 = 0
        
        var aDict:[String:NSNumber]?
        
        for i in 0..<weeklyTotalSteps.count {
            aDict = weeklyTotalSteps[i]
            weeklySteps = weeklySteps + Int64(aDict!["steps"]!)
            weeklyDistance = weeklyDistance + Float(aDict!["distanceCovered"]!)
            weeklyCalories = weeklyCalories + Float(aDict!["caloriesBurned"]!)
            weeklyGymVisit = weeklyGymVisit + Int64(aDict!["gymVisits"]!)
            weeklyPersonalTrainer = weeklyPersonalTrainer + Int64(aDict!["ptSessions"]!)
            
        }
        self.setUpLabelContent(steps: weeklySteps, distance: weeklyDistance, calories: weeklyCalories, gymVisit: weeklyGymVisit, personalTrainer: weeklyPersonalTrainer)
        
        // TO Display Data on Graph, added in Model Class
        let mainModelObj = ActivityGoalsDataModel()
        mainModelObj.createModelObjectsforMonthData(weeklyDataArr: weeklyTotalSteps as NSArray)
        self.activityModel = mainModelObj
        
    }
    
    func displayYearlyDataFromDatabase() {
        
        let listOfDates = TimerCounter.timeAtBeginningOfTheYear(for: Date())
        
        LogManager.DLog(message: "listOfDates: \(listOfDates)" as AnyObject, function: #function)
        
        let calendar = Calendar.current
        var dates:[[Date]] = []
        var currentMonth = 1
        var month:[Date] = []
        for date in listOfDates {
            let components = calendar.dateComponents([.month], from: date)
            if components.month != currentMonth {
                currentMonth += 1
                dates.append(month)
                month = []
            }
            month.append(date)
        }
        dates.append(month)
        LogManager.DLog(message: "dates : \(dates)" as AnyObject, function: #function)
        
        var monthlyTotalSteps:[[String:NSNumber]] = []
        
        let currentDate = Date()
        
        for aMonth in dates {
            
            var monthlySteps:Int64 = 0
            var monthlyDistance:Float = 0
            var monthlyCalories:Float = 0
            var monthlyGymVisit:Int64 = 0
            var monthlyPersonalTrainer:Int64 = 0
            
            for date in aMonth {
                
                if date <= currentDate {
                    let startDate:NSDate = TimerCounter.timeAtBeginningOfTheDay(for: date) as NSDate
                    let endDate:NSDate = TimerCounter.timeAtEndingOfTheDay(for: date) as NSDate
                    
                    LogManager.DLog(message: "startDate \(startDate)" as AnyObject, function: #function)
                    
                    LogManager.DLog(message: "endDate \(endDate)" as AnyObject, function: #function)
                    
                    
                    let list:[DailyFitness] = DatabaseManager.database().fetchDailyFitnessBasedOnHourly(startDate: startDate, endDate: endDate)!
                    
                    
                    for item in list {
                        monthlySteps = monthlySteps + Int64(item.steps!)!
                        monthlyDistance = monthlyDistance + Float(item.distance!)!
                        monthlyCalories = monthlyCalories + Float(item.calories!)!
                        monthlyGymVisit = monthlyGymVisit + item.gymVisit
                        monthlyPersonalTrainer = monthlyPersonalTrainer + item.personalTrainer
                        
                    }
                }
            }
            let monthlyStepsNumber = NSNumber(value:monthlySteps)
            let monthlyDistanceNumber = NSNumber(value:monthlyDistance)
            let monthlyCaloriesNumber = NSNumber(value:monthlyCalories)
            let monthlyGymVisitNumber = NSNumber(value:monthlyGymVisit)
            let monthlyPersonalTrainerNumber = NSNumber(value:monthlyPersonalTrainer)
            
            //monthlyTotalSteps.append(monthlySteps)
            
            let aDict = ["steps": monthlyStepsNumber, "distanceCovered": monthlyDistanceNumber, "caloriesBurned": monthlyCaloriesNumber, "gymVisits": monthlyGymVisitNumber, "ptSessions": monthlyPersonalTrainerNumber]
            
            monthlyTotalSteps.append(aDict)
            
        }
        
        
        LogManager.DLog(message: "monthlyTotalSteps: \(monthlyTotalSteps)" as AnyObject, function: #function)
        
        var yearlySteps:Int64 = 0
        var yearlyDistance:Float = 0
        var yearlyCalories:Float = 0
        var yearlyGymVisit:Int64 = 0
        var yearlyPTrainer:Int64 = 0
        
        var aDict:[String:NSNumber]?
        
        for i in 0..<monthlyTotalSteps.count {
            aDict = monthlyTotalSteps[i]
            yearlySteps = yearlySteps + Int64(aDict!["steps"]!)
            yearlyDistance = yearlyDistance + Float(aDict!["distanceCovered"]!)
            yearlyCalories = yearlyCalories + Float(aDict!["caloriesBurned"]!)
            yearlyGymVisit = yearlyGymVisit + Int64(aDict!["gymVisits"]!)
            yearlyPTrainer = yearlyPTrainer + Int64(aDict!["ptSessions"]!)
            
        }
        self.setUpLabelContent(steps: yearlySteps, distance: yearlyDistance, calories: yearlyCalories, gymVisit: yearlyGymVisit, personalTrainer: yearlyPTrainer)
        
        let mainModelObj = ActivityGoalsDataModel()
        mainModelObj.createModelObjectsforYearlyData(monthlyDataArr: monthlyTotalSteps as NSArray)
        self.activityModel = mainModelObj
        
    }
    
    
    func setUpLabelContent(steps:Int64, distance:Float, calories:Float, gymVisit:Int64, personalTrainer:Int64) {
        
        self.stepsBarInfoLabel.text = String(format:"%02d",steps)
        // To show distance in Km
        if deviceTypeId() == NSNumber(value: 0) {
            self.distanceBarInfoLabel.text = String(format:"%.02f",distance/1000)
            
        } else {
            self.distanceBarInfoLabel.text = String(format:"%.02f",distance)
            
        }

        let roundOffCaloriesValue = round(calories)
        self.caloriesBarInfoLabel.text = String(format:"%d",Int(roundOffCaloriesValue))
        self.gymBarInfoLabel.text = String(format:"%d",gymVisit)
        self.pTrainerBarInfoLabel.text = String(format:"%d",personalTrainer)
    }
    
    
    //MARK: Events
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        
        self.setupLabelsText(selectedIndex: sender.selectedSegmentIndex)
        
        if self.activityModel != nil {
            
            self.stepsGoalBar.setUpLayer(barType: sender.selectedSegmentIndex, dataModel:self.activityModel!, fitDataType: .steps,isOthers: false)
            
            self.gymVisitGoalBar.setUpLayer(barType: sender.selectedSegmentIndex, dataModel:self.activityModel!, fitDataType: .gymVisit,isOthers: false)
            
            self.personalTrainerGoalBar.setUpLayer(barType: sender.selectedSegmentIndex, dataModel:self.activityModel!, fitDataType: .ptrainer,isOthers: false)
            
            self.distanceGoalBar.setUpLayer(barType: sender.selectedSegmentIndex, dataModel:self.activityModel!, fitDataType: .distance,isOthers: false)
            
            self.caloriesGoalBar.setUpLayer(barType: sender.selectedSegmentIndex, dataModel:self.activityModel!, fitDataType: .calories,isOthers: false)
        }
        
    }
    
    func setupLabelsText(selectedIndex:Int) {
        
        if selectedIndex == GoalBarType.weekly.rawValue {
            self.displayWeeklyDataFromDatabase()
        }
        else if selectedIndex == GoalBarType.monthly.rawValue {
            self.displayMonthlyDataFromDatabase()
        }
        else if selectedIndex == GoalBarType.yearly.rawValue {
            self.displayYearlyDataFromDatabase()
        }
        else if selectedIndex == GoalBarType.daily.rawValue {
            self.displayDailyDataFromDatabase()
            self.displayDayWiseDataFromDatabase()
        }
    }
    
    //MARK: Events
    @IBAction func fbShare_action(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet?.setInitialText("Share on Facebook")
            facebookSheet?.add(UIImage(named: Constants.placeholderImage))
            self.present(facebookSheet!, animated: true, completion: nil)

        }
        else {
            self.showAlertViewWithMessage(title: StringConstants.kFBLoginErrorTitle, message: StringConstants.kFBLoginErrorMessage)
        }
        
    }
    @IBAction func menuButtonAction(_ sender: Any) {
        slideMenuController()?.toggleLeft()
    }
    
    
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard.mainStoryboard()
        let notificationController = mainStoryboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(notificationController, animated: true)
    }
    
}

// MARK:- API

extension ActivityViewController {

    func callAcceptedTeamList() {
        
        //self.view.showLoader(mainTitle: "", subTitle: "")

        self.list?.removeAll()
        
        DispatchQueue.global(qos: .background).async { [weak self]
            () -> Void in
            guard let strongSelf = self else {return }
        MyTeamList().accepetedUserList(params: [:]) {(response, success, error) -> (Void) in
            
            let list = NSArray(array: response) as? Array<MyTeamList>
            if list != nil {
                for obj in list! {
                    strongSelf.list?.append(obj)
                }
            }
            
            if strongSelf.list?.count == 0 {
                
                
            } else {
                let numberOfItems = CGFloat((list?.count)!)
                let cellSize:CGFloat = 50.0
                
                DispatchQueue.main.async {
                    () -> Void in
                    if numberOfItems > 1  {
                        let collectionWidth = (numberOfItems * cellSize) + 15
                        let remaingWidth = UIScreen.main.bounds.size.width - collectionWidth
                        let requiredLeading = (remaingWidth/2.0)
                        
                        strongSelf.collectionViewLeadingConstraint.constant = requiredLeading
                        strongSelf.collectionViewTrailingConstraint.constant = requiredLeading
                        
                        if strongSelf.collectionViewLeadingConstraint.constant <= 10.0  {
                            strongSelf.collectionViewLeadingConstraint.constant = 16.0
                            strongSelf.collectionViewTrailingConstraint.constant = 16.0
                            
                        }
                    }
                    
                    strongSelf.contentCollectionView.reloadData()
                    strongSelf.contentCollectionView.scrollToItem(at: IndexPath(item: (strongSelf.list?.count)!, section: 0), at: .left, animated: false)
                }
                


            }
            //self.view.hideLoader()

        }
            DispatchQueue.main.async {
                () -> Void in
                strongSelf.view.layoutIfNeeded()
                strongSelf.view.updateConstraintsIfNeeded()
            }
        

        }
    }
}



