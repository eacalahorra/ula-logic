![Graphic that reads "ULA PERIOD TRACKER, OFFICIAL AUDIT CODE REPOSITORY](.github/ULA%20PERIOD%20TRACKER.png)

# ULA Period Tracker -- Official Audit Code Repository
---

## Welcome to the ULA Period Tracking App Audit Code Repository!

Hello! Welcome, this code repo was designed for privacy audits of the ULA Period Tracker app! Please feel free to roam around the different modules of the ULA Logic code.

---

## ULA Documentation

### Preface:

The ULA Period Tracker is a Period Tracking Application designed to be completely private and secure, born out of discussion about the failures of other similar apps in terms of service and ***privacy***, selling health data to the highest bidder, and even acting against their users, in aiding prosecutors pursue criminal cases against women in cases of lost pregnancies. Something I consider unacceptable.

In the age of digital communication, and ever-increasing Data Surveillance, an alternative is necessary. ULA is that alternative.

### Privacy Principles:

ULA’s privacy principle is simple. The app simply does not communicate with any server, external API, or any other network-reliant service, opting instead for on-device data management. No one but the User has access to their data, and it can be erased at the click of a button, the information is never relayed to a central server, and it cannot be seen in any way by anyone other than the Data Owner. Be it the original device where the First Installation of ULA occurred, or subsequent devices via the Export/Import of the Main Data file, accessible only through App Infrastructure.
At present, data is stored via a series of JSON files, wrapped in a Schema Wrapper to allow for backwards and forwards compatibility with the addition of new features, such as new measurement capabilities.

In the future, I intend to implement the Realm Database System, for On-Device stable persistence, and optimal indexing of User Data.

### System Infrastructure:

ULA works via a modularized, integrated, SSOT-based Model-View-ViewModel (MVVM) architecture.

Each Data Entry Model, Analytical Engine, Predictive Engine, Data Management Engine, as well as each UI element, is completely independent of each other System, Engine, Model or Element, relying upon a centralized aggregator, or Manager to facilitate communication between data input, processing, storage, and UI functions.

To further my privacy-first ideology for ULA, all prediction and analysis systems are, in their majority, Probabilistic and Adaptive, with Deterministic exceptions.

### System Infrastructure: Data Models:

System Infrastructure: Data Models:

ULA tracks a plethora of entries, and following a determined set of rules makes predictions about the User’s Menstrual Cycle.

For Version v1.0, upon consultation with Uterus-Possessing Colleagues, I have included the following measurable variables:

**Bleeding Episodes**: The user can log whenever they experience a bleeding episode, this is stored as a numeric value from 0 to 4, ranging:
- 0 - No bleeding
- 1 - Spotting/Light
- 2 - Regular/Moderate
- 3 - Heavy
- 4 - Severe/Ultra Heavy

**Period Episodes**: The user has to manually log the start of a Menstrual period.

**Sex Events**: The user can log Sexual Activity, and whether the interaction was protected or not.

**Symptoms**: The user can log which symptoms they are experiencing based on the following list:
- Cramps
- Bloating
- Headache
- Back Pain
- Tender Breasts
- Fatigue
- Cravings
- Mood Swings
- Nausea
- Acne
- Insomnia
- Diarrhea
- Constipation
- Mittelschmerz - Ovulation Pain

**User Configuration**: The user can override app functionality regarding period functions, this is done to correct misinputs in Period Start, as well as a flag for irregularity, which is crucial for the Prediction Algorithm.

Based upon the inputted data of these fields the Logic component can predict the User’s Cycle, detect Irregularities, and make accommodations for Medical Irregularities, including those caused by PCOS and/or PMS (with varying degrees of success)

### System Infrastructure: DataManager:

For the whole Logic system, the aggregator and Single Source of Truth, is the DataManager, as it handles all inputs from the User, all data operations via the JSONStorage, LocalStorage and SchemaWrapper interfaces, and all outputs via the Logic Engines. Formally it stores all daily entries, i.e. Period Starts, Bleeding Episodes, and SexEvents, as well as Symptoms, Cycles, both Regular and Irregular, Cycle Predictions, including Ovulation and the Peak Fertility Window, Moon Phase Calculations, and through the MonthBuilder (a UI-Logic layer that needed separate integration) the coloring of the in-app calendar.However, the DataManager is not a proactive agent, it is merely reactive, all entries inputted always trigger a Logic Re-run, making sure all information and calculations are up-to-date as soon as the user needs them.

Originally the DataManager used to calculate automatic period starts, by noticing two days of bleeding >2 in a row, and assuming that meant period start. This was an unexpected consequence of automatizing predictions. This has been changed to a manual start each time. The deprecation of automated Period Starts, allowed also the integration of the Period Undo, in case the user accidentally begins a period ahead of time, they can undo it without altering their personalized predictions.

It also handles the change of Cycle Phases, which determine several UI aspects.

It does all of this by utilizing the @MainActor and @Published classes, UI-Safe classes that SwiftUI reacts to, and through the @Published states, it orchestrates all business logic.

It divides the functioning in Published Properties and Dependency Services, connecting the inputted data, i.e. @Published properties, with the corresponding Dependency, i.e. appropriate Logic Engine, and utilizing a refreshAllLogic() function  after each input.

As mentioned also handled by the DataManager is ULA Data Management, done via the ULASchemaWrapper, which contains, the schemaVersion, appVersion, entries, sexEvents and symptoms. All the data necessary to reconstruct all equation predictions from zero.

As such the centralized structure of the DataManager aggregator allows for flexibility, scaling and modular modification without the destruction of the system…

### System Infrastructure: UI:

The UI is also heavily modular and depends upon two SSOTs, one for Design and another for actual function.

The Design SSOT, the DesignSystem, establishes all color, corner and type statuses for cohesion in visual style.

The UI function SSOT, ContentView, centralizes all functions following the following structure.

**[ContentView] <- [TabView] <- [Screens]**

The Screens are the main UI/UX slices the User interacts with, they are individually connected to the @Published states of the DataManager, depending their needs. However, the way this occurs is modular. By calling preexisting and premade UI components, such as the CentralOrbView, the GlassyDateRow, or even the StandardDIalogScreen (SDIS), and calling the DataManager() @EnvironmentObject, the premade UI components interact with the logic layer and are completely modifiable per-situation. The Logic-Interacting “Screen” files, then are displayed via a centralized TabView, which enables User Navigation, and is called into existence via the ContentView, which governs all UI functioning separate from Logic, ensuring a coherent and stable User Experience.

### Disclaimer: 

UI is not provided as it is proprietary, and other than reading @Published states via DataManager it has no logic or functioning of its own.

### Techincal Structure Documentation:

As generated by Xcode:

**Classes**
class CycleTheme
class DataManager

**Protocols**
protocol LocalStorage

**Structures**
struct ActionButton
struct AnalyticsEngine
struct CalendarView
struct CentralOrbView
struct ContentView
struct ContributeView
struct Cycle
struct CycleAnalyzer
struct CycleBar
struct CycleHistoryItem
struct CycleStats
struct DataManagementView
struct DayCell
struct DayDetailPopover
struct DayEntry
struct GlassyDateRow
struct InsightsView
struct IrregularCycle
struct IrregularStats
struct JSONStorage
struct LegendItem
struct MainScreen
struct MetricCard
struct MonthBuilder
struct MonthDay
struct MoonPhaseEngine
struct OnboardingExplanation
struct OnboardingLastPeriod
struct OnboardingRegularity
struct OnboardingRootView
struct OnboardingWelcome
struct PeriodDetector
struct PeriodEpisode
struct PeriodStats
struct PhaseEngine
struct PredictionConfidence
struct PredictionEngine
struct SDISRequest
struct ScaleButtonStyle
struct SettingsPage
struct SexEvent
struct StandardDialogSheet
struct Symptom
struct SymptomRow
struct SymptomsEngine
struct TodayView
struct TodayView_Previews
struct ULASchemaWrapper
struct UlaApp
struct UserSettings

**Enumerations**
enum CyclePhase
enum DayAction
enum DesignSystem
enum IrregularReason
enum MoonPhase
enum RegularityChoice
enum SDISMode
enum SymptomType
enum UlaCyclePhase