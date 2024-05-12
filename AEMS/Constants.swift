
import Foundation

// GENRERAL CONSTS

let USER_USERNAME = "USER_USERNAME"
let USER_PASSWORD = "USER_PASSWORD"
let USER_LOGGED_IN = "USER_LOGGED_IN"
let USER_TYPE = "USER_TYPE"
let IS_NOT_FIRST_LAUNCH = "IS_NOT_FIRST_LAUNCH"
let ENC_DEC_KEY = "ccC2H19lDDbQDfakxcrtNMQdd0FloLGG"
let ENC_DEC_IV = "ggGGHUiDD0Qjhuvv"
let API_KEY_GMAPS = "AIzaSyDMkaLZNzZxqZ0l7XxlR9d7px4ROhNz3zU"
let HOST_IP = "http://localhost:8083"
let DATE_FORMAT = "dd-MMM-yyyy"
let NO_ENQUIRES = "No Enquires"
let ENQUIRY_DETAILS = "Enquiry Details"

// SEL CONSTS

let SEL_USER = "   Select User"
let SEL_LOC = "   Select Location"
let SEL_PROD = "   Select Product"
let SEL_STATUS = "   Select Status"

// FILTER CONSTS

let NONE_FILTER = "None"
let RETAIL_FILTER = "Retail"
let CLOSED_FILTER = "Closed"

var CAL_COLOR = 0
var LAT = 0.0
var LONG = 0.0

// MENU CONSTS

let products = ["AC", "Oven", "Laptop", "Iron", "Phone", "Fridge", "TWS"]

let cityCoordinates: [String: (Double, Double)] =
[
    "New York": (40.7128, -74.0060),
    "Los Angeles": (34.0522, -118.2437),
    "Chicago": (41.8781, -87.6298),
    "Houston": (29.7604, -95.3698),
    "San Francisco": (37.7749, -122.4194)
]

let cities = ["New York", "Los Angeles", "Chicago", "Houston", "San Francisco"]

var status = ["In Progress","Closed","Retailed","New"]

// OPERATION CONSTS

let ENQUIRY_SUCCESS_ALERT = "Enquiry was Created"
let ENQUIRY_UPDATE_SUCCESS_ALERT = "Enquiry was Updated"
let ENQUIRY_STATUS_ALERT = "Enquiry was Closed"


// Segue Constants

let MAP_SEGUE = "mapsegue"
let SIGN_OUT_SEGUE = "signoutsegue"
let SIGN_IN_UP_SEGUE = "signinupsegue"
let SIGN_UP_IN_SEGUE = "signupinsegue"
let SIGN_IN_HOME_SEGUE = "signinhomesegue"
let MAP_BACK_SEGUE = "mapbacksegue"


let STATUS_PROGRESS = "In Progress"
let STATUS_RETAIL = "Retailed"
let STATUS_CLOSED = "Closed"

let PROGRESS_IMAGE = "arrow.triangle.2.circlepath.circle.fill"
let RETAIL_IMAGE = "bookmark"
let CLOSED_IMAGE = "xmark.circle.fill"
let DEFAULT_IMAGE = "list.bullet.clipboard"
