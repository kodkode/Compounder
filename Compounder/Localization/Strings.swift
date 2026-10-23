import Foundation

/// All user-facing copy. Every entry carries both languages so a missing
/// translation is impossible: `pick(hebrew, english)`.
struct Strings {
    let language: AppLanguage

    private var isHebrew: Bool { language == .hebrew }
    private func pick(_ hebrew: String, _ english: String) -> String { isHebrew ? hebrew : english }

    // MARK: Common
    var appName: String { "Compounder" }
    var savings: String { pick("ריבית דריבית", "Compound") }
    var mortgage: String { pick("משכנתא", "Mortgage") }
    var cancel: String { pick("ביטול", "Cancel") }
    var save: String { pick("שמירה", "Save") }
    var done: String { pick("אישור", "Done") }
    var share: String { pick("שיתוף", "Share") }
    var delete: String { pick("מחיקה", "Delete") }

    func years(_ n: Int) -> String {
        if isHebrew {
            switch n {
            case 1: return "שנה אחת"
            case 2: return "שנתיים"
            default: return "\(n) שנים"
            }
        }
        return n == 1 ? "1 year" : "\(n) years"
    }

    func inYears(_ n: Int) -> String {
        pick("בעוד \(years(n))", "in \(years(n))")
    }

    // MARK: Tabs
    var tabHome: String { pick("בית", "Home") }
    var tabCompare: String { pick("השוואה", "Compare") }
    var tabCalculator: String { pick("מחשבון", "Calculator") }
    var tabSaved: String { pick("שמורים", "Saved") }
    var tabSettings: String { pick("הגדרות", "Settings") }

    // MARK: Calculator
    var calculatorTitle: String { pick("מחשבון", "Calculator") }
    var saveScenario: String { pick("שמירת תרחיש", "Save scenario") }
    var editInputs: String { pick("עריכת נתונים", "Edit inputs") }
    var hideAmounts: String { pick("הסתרת סכומים", "Hide amounts") }
    var showAmounts: String { pick("הצגת סכומים", "Show amounts") }
    var detailGrowth: String { pick("צמיחה", "Growth") }
    var detailChart: String { pick("גרף", "Chart") }
    var detailByYear: String { pick("פירוט שנתי", "By year") }
    var detailSchedule: String { pick("לוח סילוקין", "Schedule") }
    var detailAdjust: String { pick("עריכה", "Adjust") }
    var planSavings: String { pick("חיסכון", "SAVINGS") }
    var planMortgage: String { pick("משכנתא", "HOME LOAN") }

    var fieldInitialShort: String { pick("התחלה", "Start") }
    var fieldInitial: String { pick("הפקדה ראשונית", "Initial deposit") }
    var fieldMonthlyShort: String { pick("חודשי", "Monthly") }
    var fieldMonthly: String { pick("הפקדה חודשית", "Monthly deposit") }
    var fieldReturnShort: String { pick("תשואה", "Return") }
    var fieldReturn: String { pick("תשואה שנתית", "Annual return") }
    var fieldYearsShort: String { pick("שנים", "Years") }
    var fieldSavingsYears: String { pick("תקופת החיסכון", "Time invested") }
    var fieldPriceShort: String { pick("מחיר", "Price") }
    var fieldPrice: String { pick("מחיר הנכס", "Property price") }
    var fieldDownShort: String { pick("הון עצמי", "Equity") }
    var fieldDown: String { pick("הון עצמי", "Down payment") }
    var fieldRateShort: String { pick("ריבית", "Rate") }
    var fieldRate: String { pick("ריבית שנתית", "Interest rate") }
    var fieldTerm: String { pick("תקופת ההלוואה", "Loan term") }

    func heroSavingsSub(interest: String, years n: Int) -> String {
        pick("+\(interest) רווח · \(years(n))", "+\(interest) interest · \(years(n))")
    }
    var perMonth: String { pick("לחודש", "/mo") }
    func totalInterest(_ amount: String) -> String { pick("סה״כ ריבית \(amount)", "Total interest \(amount)") }

    var footDeposits: String { pick("הפקדות", "Deposits") }
    var footInterest: String { pick("רווח", "Interest") }
    var footLoan: String { pick("הלוואה", "Loan") }
    var footPayoff: String { pick("סיום", "Paid off") }

    var chartSavingsTitle: String { pick("יתרה לאורך זמן", "Balance over time") }
    var chartMortgageTitle: String { pick("יתרת הלוואה מול ריבית", "Balance vs. interest paid") }
    var legendBalance: String { pick("יתרה", "Balance") }
    var legendDeposits: String { pick("הפקדות", "Deposits") }
    var legendLoanBalance: String { pick("יתרת הלוואה", "Balance left") }
    var legendInterestPaid: String { pick("ריבית ששולמה", "Interest paid") }
    var chartHint: String { pick("גררו על הגרף כדי לראות שנה מסוימת", "Drag across the chart to inspect a year") }

    var statGrowth: String { pick("מכפיל", "Growth") }
    var statTotalInterest: String { pick("סה״כ ריבית", "Total interest") }
    var statTotalCost: String { pick("עלות כוללת", "Total cost") }

    func yearRow(_ year: Int, calendarYear: Int) -> String {
        pick("שנה \(year) · \(calendarYear)", "Year \(year) · \(calendarYear)")
    }
    func deposited(_ amount: String) -> String { pick("הופקד \(amount)", "Deposited \(amount)") }
    func balance(_ amount: String) -> String { pick("יתרה \(amount)", "Balance \(amount)") }
    func principal(_ amount: String) -> String { pick("קרן \(amount)", "Principal \(amount)") }
    func interest(_ amount: String) -> String { pick("ריבית \(amount)", "Interest \(amount)") }

    func savingsNote(compounding: Compounding, depositAtStart: Bool) -> String {
        let compoundingText: String
        switch compounding {
        case .monthly: compoundingText = pick("הריבית נצברת מדי חודש", "Interest compounds monthly")
        case .yearly: compoundingText = pick("הריבית נצברת פעם בשנה", "Interest compounds once a year")
        }
        let depositText = depositAtStart
            ? pick("וההפקדות נוספות בתחילת כל חודש.", "and deposits are added at the start of each month.")
            : pick("וההפקדות נוספות בסוף כל חודש.", "and deposits are added at the end of each month.")
        return compoundingText + ", " + depositText
    }
    var mortgageNote: String {
        pick("החזר חודשי קבוע (שפיצר), קרן וריבית בלבד — ללא הצמדה למדד, ביטוחים ועמלות.",
             "Fixed monthly payment (Spitzer), principal and interest only. No CPI linkage, insurance or fees.")
    }
    var tapValueHint: String { pick("הקישו על הסכום כדי להקליד ערך מדויק", "Tap a value to type an exact number") }
    func allowedRange(_ low: String, _ high: String) -> String {
        pick("טווח: \(low) – \(high)", "Range: \(low) – \(high)")
    }

    var scenarioName: String { pick("שם התרחיש", "Scenario name") }
    var scenarioNamePlaceholder: String { pick("למשל: חיסכון לדירה", "e.g. Saving for an apartment") }
    var savedToast: String { pick("התרחיש נשמר", "Scenario saved") }

    func shareSavings(fv: String, years n: Int, monthly: String, rate: String, interest: String) -> String {
        pick("תוכנית חיסכון: \(monthly) לחודש בתשואה של \(rate) יגיעו ל-\(fv) \(inYears(n)) (רווח של \(interest)). חושב ב-Compounder.",
             "Savings plan: \(monthly)/month at \(rate) grows to \(fv) \(inYears(n)) (\(interest) interest). Calculated with Compounder.")
    }
    func shareMortgage(payment: String, loan: String, rate: String, years n: Int, interest: String) -> String {
        pick("משכנתא של \(loan) בריבית \(rate) ל-\(years(n)): החזר חודשי \(payment), סה״כ ריבית \(interest). חושב ב-Compounder.",
             "Mortgage of \(loan) at \(rate) over \(years(n)): \(payment) per month, \(interest) total interest. Calculated with Compounder.")
    }

    // MARK: Home
    func greeting(hour: Int) -> String {
        switch hour {
        case 5..<12: return pick("בוקר טוב", "Good morning")
        case 12..<17: return pick("צהריים טובים", "Good afternoon")
        case 17..<22: return pick("ערב טוב", "Good evening")
        default: return pick("לילה טוב", "Good night")
        }
    }
    var homeSubtitle: String { pick("מה נחשב היום?", "What shall we calculate today?") }
    var searchSaved: String { pick("חיפוש בתרחישים", "Search scenarios") }
    var forecastTitle: String { pick("תחזית החיסכון שלך", "Your savings forecast") }
    var forecastEmpty: String {
        pick("שמרו תוכנית חיסכון מהמחשבון כדי לראות כאן את התחזית המשולבת שלכם.",
             "Save a savings plan from the calculator to see your combined forecast here.")
    }
    func forecastPlans(_ n: Int) -> String {
        if isHebrew { return n == 1 ? "תוכנית אחת" : "\(n) תוכניות" }
        return n == 1 ? "1 plan" : "\(n) plans"
    }
    var newCalculation: String { pick("חישוב חדש", "New calculation") }
    var quickSavingsSubtitle: String { pick("כמה החיסכון שלך יצמח", "See how your savings grow") }
    var quickMortgageSubtitle: String { pick("כמה תשלמו בכל חודש", "See your monthly payment") }
    var recentTitle: String { pick("תרחישים אחרונים", "Recent scenarios") }
    var seeAll: String { pick("הכל", "See all") }
    var noScenariosYet: String {
        pick("עוד לא שמרתם תרחישים. שמרו חישוב מהמחשבון והוא יופיע כאן.",
             "No saved scenarios yet. Save a calculation and it will show up here.")
    }
    var rule72Title: String { pick("כלל ה-72", "The rule of 72") }
    var rule72Body: String {
        pick("חלקו 72 בתשואה השנתית, וקבלו בערך תוך כמה שנים הכסף שלכם יוכפל.",
             "Divide 72 by the annual return to estimate how many years it takes your money to double.")
    }
    var yearsToDouble: String { pick("שנים עד להכפלה", "years to double") }

    // MARK: Compare
    var compareTitle: String { pick("השוואה", "Compare") }
    var swapScenarios: String { pick("החלפת תרחישים", "Swap scenarios") }
    var tagA: String { pick("א׳", "A") }
    var tagB: String { pick("ב׳", "B") }
    func scenarioLabel(_ tag: String) -> String { pick("תרחיש \(tag)", "Scenario \(tag)") }
    func leadsBy(_ tag: String, _ amount: String) -> String { pick("תרחיש \(tag) מוביל ב-\(amount)", "Scenario \(tag) leads by \(amount)") }
    func savesBy(_ tag: String, _ amount: String) -> String { pick("תרחיש \(tag) חוסך \(amount)", "Scenario \(tag) saves \(amount)") }
    var tie: String { pick("התרחישים שקולים", "Both scenarios are equal") }
    func interestComparison(_ a: String, _ b: String) -> String {
        pick("רווח מריבית: א׳ \(a) · ב׳ \(b)", "Interest earned: A \(a) · B \(b)")
    }
    func paymentDifference(_ amount: String) -> String {
        pick("הפרש בהחזר החודשי: \(amount)", "Monthly payment difference: \(amount)")
    }
    func editing(_ name: String) -> String { pick("עריכת \(name)", "Edit \(name)") }
    var chartLoanBalance: String { pick("יתרת הלוואה", "Loan balance") }

    // MARK: Saved
    var savedTitle: String { pick("שמורים", "Saved") }
    var searchPlaceholder: String { pick("חיפוש תרחיש", "Search scenarios") }
    var filterAll: String { pick("הכל", "All") }
    var filterSavings: String { pick("חיסכון", "Savings") }
    var filterMortgage: String { pick("משכנתא", "Mortgage") }
    var noMatchTitle: String { pick("לא נמצאו תרחישים", "No scenarios found") }
    var noMatchBody: String { pick("נסו מילת חיפוש או סינון אחרים.", "Try a different search or filter.") }
    var emptyTitle: String { pick("אין עדיין תרחישים שמורים", "No saved scenarios yet") }
    var emptyBody: String {
        pick("הקישו על סמל הסימנייה במחשבון כדי לשמור חישוב.",
             "Tap the bookmark in the calculator to save a calculation.")
    }
    var newScenario: String { pick("תרחיש חדש", "New scenario") }
    func savedOn(_ date: String) -> String { pick("נשמר ב-\(date)", "Saved \(date)") }
    func savingsMeta(monthly: String, rate: String, years n: Int) -> String {
        pick("\(monthly) לחודש · \(rate) · \(years(n))", "\(monthly)/mo · \(rate) · \(years(n))")
    }
    func mortgageMeta(price: String, down: String, rate: String) -> String {
        pick("\(price) · \(down) הון עצמי · \(rate)", "\(price) · \(down) down · \(rate)")
    }
    func perMonthOver(_ n: Int) -> String { pick("לחודש · \(years(n))", "per month · \(years(n))") }

    // MARK: Settings
    var settingsTitle: String { pick("הגדרות", "Settings") }
    var languageTitle: String { pick("שפה", "Language") }
    var languageNote: String {
        pick("כל האפליקציה מתהפכת בהתאם: עברית מימין לשמאל, אנגלית משמאל לימין.",
             "The whole app switches direction: Hebrew is right-to-left, English is left-to-right.")
    }
    var currencyTitle: String { pick("מטבע", "Currency") }
    func currencyName(_ currency: AppCurrency) -> String {
        switch currency {
        case .ils: return pick("שקל חדש (ILS)", "Israeli new shekel (ILS)")
        case .usd: return pick("דולר אמריקאי (USD)", "US dollar (USD)")
        case .eur: return pick("אירו (EUR)", "Euro (EUR)")
        }
    }
    var calculationsTitle: String { pick("חישובים", "Calculations") }
    var compoundingTitle: String { pick("צבירת ריבית", "Compounding") }
    var monthly: String { pick("חודשית", "Monthly") }
    var yearly: String { pick("שנתית", "Yearly") }
    var depositAtStart: String { pick("הפקדה בתחילת החודש", "Deposit at start of month") }
    var depositAtStartHint: String { pick("במקום בסוף כל חודש", "Instead of at the end of each month") }
    var hideOnLaunch: String { pick("הסתרת סכומים בפתיחה", "Hide amounts on launch") }
    var hideOnLaunchHint: String { pick("שימושי במקומות ציבוריים", "Handy in public places") }
    var aboutTitle: String { pick("אודות", "About") }
    var version: String { pick("גרסה", "Version") }
    var disclaimer: String {
        pick("החישובים להמחשה בלבד ואינם מהווים ייעוץ פיננסי.",
             "Calculations are for illustration only and are not financial advice.")
    }
}
