//
//  BarcoderEnums.swift
//  AdyenBarcoder
//
//  Created by Taras Kalapun on 1/26/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation
import CoreFoundation

@objc
public class Barcode: NSObject {
    public var codeId: Barcoder.CodeId = .Undefined
    public var aimId: Barcoder.AimId = .Undefined
    public var symbolId: Barcoder.SymId = .Undefined
    public var text: String = ""
}

extension Barcoder {

    internal enum Resp: UInt32 {
        case ACK    = 0x00000000
        case NAK    = 0x00000001
        case DATA   = 0x80000000
        case STATUS = 0x80000001
    }
    

// Code ID is one of the industry standard and parameter changes will refer to a specific code ID.
// each code ID has an associated code ASCII character that needs to be displayed in the retail environment.
// Refer to symb_code array for asscociation between code ID and code ASCII char.
// Every succesfull decoded data will have a unique symbology as one of the return values
///
@objc
public enum CodeId: UInt8 {
    case Undefined
    case UPC_EA = 0x01
    case CODE39_32 = 0x02
    case CODABAR = 0x03
    case CODE128_ISBT = 0x04
    case CODE93 = 0x05
    case INTL2OF5 = 0x06
    case DISC2OF5 = 0x07
    case CODE11 = 0x08
    case MSI = 0x09
    case GSI128 = 0x0A
    case BOOKLAND_EAN = 0x0B
    case TRIOPTIC39 = 0x0C
    case COUPONCODE = 0x0D
    case GS1DATABAR = 0x0E
    case MATRIX2OF5 = 0x0F
    case UCCCOMPOS = 0x10
    case CHINESE2OF5 = 0x11
    case KOREAN3OF5 = 0x12
    case PDF417_ISSNEAN = 0x13
    case AZTEC_RUNE = 0x14
    case DATA_MATRIX = 0x15
    case QRCODE_MICRO = 0x16
    case MAXICODE = 0x17
    case US_POSTNET = 0x18
    case US_PLANET = 0x19
    case JAPAN_POSTAL = 0x1A
    case UK_POSTAL = 0x1B
    case POSTBAR_CA = 0x1C
    case NETH_KIX = 0x1D
    case AUS_POST = 0x1E
    case USPS_4CB = 0x1F
    case UPU_FICS = 0x20
    case SCANLET_WEB = 0x21
    case CUECAT = 0x22
    
    
    public var name: String {
        get { return String(describing: self) }
    }
    public var description: String {
        get { return String(reflecting: self) }
    }
}

// AIM ID is altrenate industry standard and only used for display purpose.
// each AIM ID has an associated AIM ASCII character that needs to be displayed in the retail environment.
// Refer to symb_AIM array for asscociation between AIM ID and AIM ASCII char.
// Every succesfull decoded data will have a unique symbology as one of the return values
@objc
public enum AimId: UInt8 {
    case Undefined
    case CODE39_32 = 0x01
    case CODE128_ISBT_GS1 = 0x02
    case DATAMATRIX = 0x03
    case UPC_EAN_COUPON = 0x04
    case GS1DATABAR = 0x05
    case CODEBAR = 0x06
    case CODE93 = 0x07
    case CODE11 = 0x08
    case INTL2OF5 = 0x09
    case PDF417 = 0x0A
    case TLC39 = 0x0B
    case MSI = 0x0C
    case QRCODE_MICROQR = 0x0D
    case DISC2OF5 = 0x0E
    case MAXICODE = 0x0F
    case AZTEC_RUNE = 0x10
    case X = 0x11
    case COMP_EC = 0x12
    case COMP_EE = 0x13
    case COMP_RS = 0x14
    
    
    public var name: String {
        get { return String(describing: self) }
    }
    public var description: String {
        get { return String(reflecting: self) }
    }
}


// 16-bit symbology values in barcode data response
@objc
public enum SymId: UInt16 {
    case Undefined
    case CODE39 = 0x0001
    case CODABAR = 0x0002
    case CODE128 = 0x0003
    case D25 = 0x0004
    case IATA = 0x0005
    case ITF = 0x0006
    case CODE93 = 0x0007
    case UPCA = 0x0008
    case UPCE = 0x0009
    case EAN8 = 0x000A
    case EAN13 = 0x000B
    case CODE11 = 0x000C
    case MSI = 0x000D
    case EAN128 = 0x000E
    case UPCE1 = 0x000F
    case PDF417 = 0x0010
    case CODE39FULL = 0x0011
    case TRIOPTIC = 0x0012
    case BOOKLAND = 0x0013
    case COUPONCODE = 0x0014
    case ISBT128 = 0x0015
    case MICROPDF = 0x0016
    case DATAMATRIX = 0x0017
    case QRCODE = 0x0018
    case POSTNETUS = 0x0019
    case PLANETUS = 0x001A
    case CODE32 = 0x001B
    case ISBT128CONC = 0x001C
    case POSTALJAPAN = 0x001D
    case POSTALAUST = 0x001E
    case POSTALDUTCH = 0x001F
    case MAXICODE = 0x0020
    case POSTBARCA = 0x0021
    case POSTALUK = 0x0022
    case MACROPDF417 = 0x0023
    case RSS14 = 0x0024
    case RSSLIMIT = 0x0025
    case RSSEXPAND = 0x0026
    case SCANLETWEB = 0x0027
    case CUECAT = 0x0028
    case UPCA_2 = 0x0029
    case UPCE_2 = 0x002A
    case EAN8_2 = 0x002B
    case EAN13_2 = 0x002C
    case UPCE1_2 = 0x002D
    case CCA_EAN128 = 0x002E
    case CCA_EAN13 = 0x002F
    case CCA_EAN8 = 0x0030
    case CCA_RSSEXPAND = 0x0031
    case CCA_RSSLIMIT = 0x0032
    case CCA_RSS14 = 0x0033
    case CCA_UPCA = 0x0034
    case CCA_UPCE = 0x0035
    case CCC_EAN128 = 0x0036
    case TLC39 = 0x0037
    case CCB_EAN128 = 0x0038
    case CCB_EAN13 = 0x0039
    case CCB_EAN8 = 0x003A
    case CCB_RSSEXPAND = 0x003B
    case CCB_RSSLIMIT = 0x003C
    case CCB_RSS14 = 0x003D
    case CCB_UPCA = 0x003E
    case CCB_UPCE = 0x003F
    case KOR3OF5 = 0x0040
    case UPCA_5 = 0x0041
    case UPCE_5 = 0x0042
    case EAN8_5 = 0x0043
    case EAN13_5 = 0x0044
    case UPCE1_5 = 0x0045
    case MACROPDF = 0x0046
    
    
    public var name: String {
        get { return String(describing: self) }
    }
    public var description: String {
        get { return String(reflecting: self) }
    }
}

// Commands
@objc
enum Cmd: UInt8 {
    case BAR_DEV_OPEN     = 0x1A
    case BAR_DEV_CLOSE    = 0x1B
    case START_SCAN       = 0x01
    case STOP_SCAN        = 0x02
    case SET_TRIG_MODE    = 0x05
    case BEEP_IMMEDIATE   = 0x06
    case EN_CONTINUOUS_RD = 0x10
    case RESTORE_DEFAULTS = 0x0B
    case SYMBOLOGY        = 0x18
    case DISABLE_ALL_SYMB = 0x19
    case AUTO_BEEP_CONFIG = 0x1C
    
    var name: String {
        get { return String(describing: self) }
    }
}
    
@objc
enum GenPid: UInt8 {
    //general parameter IDs
    // asterick (*) in the comments indicate default value
    case PASS_THRU = 0xFF //reserved value
    case SET_TRIG_MODE = 0xFE //8 bit value,0 edge,1 *level,2 soft, 3 passive
    case BEEP_IMMEDIATE = 0xFD //value starts with no of beeps followed no. of T_BEEP_PAUSE
    case RESTORE_DEFAULTS = 0xFC //value is not required and reserved for future
    case PICKLIST_MODE = 0xFB //value 0 *disabled,1 enabled
    case SCAN_TIMEOUT = 0xFA //value range 1 to 255 secs,*60 sec in continuous,*10 sec in single scan
    case TIMEOUT_BW_SAME_SYM = 0xF9 //value range 0 to 9.9 sec (99 decimal), *0.6 sec(= 0x06)
    case TIMEOUT_BW_DIFF_SYM = 0xF8 //value range 1 to 9.9 sec (99 decimal), *0.2 sec(= 0x02)
    case CONTINUOUS_READ = 0xF7 //value 0 disabled,1 *enabled
    case UNIQUE_CODE_REPORT = 0xF6 //value 0 *disabled,1 enabled
    case MOBILE_PHONE_MODE = 0xF5 //value 0 *disabled,1 enabled
    case PREFIX_KEY = 0xF4 //value is 1 when host sends prefix value
    case PREFIX_VAL = 0xF3 //value any 3 digit number 0-255,*<CR>(= 0x0D)
    case SUFFIX1_KEY = 0xF2 //value is 1 when host sends prefix value
    case SUFFIX1_VAL = 0xF1 //value any 3 digit number 0-255,*<CR>(= 0x0D)
    case SUFFIX2_KEY = 0xF0 //value is 1 when host sends prefix value EXAMPLE HEADER FILE e255 BARCODE APPLICATION PROGRAMMERS GUIDE 47
    case SUFFIX2_VAL = 0xEF //value any 3 digit number 0-255,*<CR>(= 0x0D)
    case SCAN_DATA_XMIT_FMT = 0xEE //value 0 *data as is, 1 sufix1, 2 sufix2,3 sufix1&2,4 prefix, 5 Prefix&sufix1,6 prefix&sufix2, 7 prefix&suffixes
    case AIM_PATTERN_EN = 0xED //value 0 disabled,1 *enabled
    case AUTO_BEEP_MODE = 0xEC //value 0 *disabled,1 config scan beep only,2 config error beep only, 3 config both
    case AUTO_BEEP_SCAN = 0xEB //scan beep value in format T_BEEP_DEF
    case AUTO_BEEP_ERROR = 0xEA //error beep value in format T_BEEP_DEF
}

@objc
public enum SymPid: UInt8 {
    //code 128
    case EN_CODE128 = 0x00 //value 1 for *enable, 0 disable
    case SETLEN_1DISCRETE_C128 = 0x01 //one byte input value
    case SETLEN_2DISCRETE_C128 = 0x02 //two bytes input value
    case SETLEN_RANGE_C128 = 0x03 //Range is set by two byte input value
    case SETLEN_ANY_C128 = 0x04 //*No input value expected for this parameter
    case EN_GS1128 = 0x05 //value 1 for *enable, 0 disable
    case EN_ISBT = 0x06 //value 1 for *enable, 0 disable
    case ISBT_CONCATE = 0x07 //value 1 for enable, 0 *disable, 2 auto
    case CHECK_ISBT_TABLE = 0x08 //value 1 for *enable, 0 disable
    case ISBT_CONCATE_REDUN = 0x09 //value range is 2 to 20, *= 0x0A
    //code UPC
    case EN_UPCA = 0x0A //value 1 for *enable, 0 disable
    case EN_UPCE = 0x0B //value 1 for *enable, 0 disable
    case EN_UPCE1 = 0x0C //value 1 for enable, 0 *disable
    case EN_EAN8_JAN8 = 0x0D //value 1 for *enable, 0 disable
    case EN_EAN13_JAN13 = 0x0E //value 1 for *enable, 0 disable
    case EN_BOOKLAND_EAN = 0x0F //value 1 for *enable, 0 disable
    case EN_ISBN_FORMAT = 0x10 //value 1 for enabling ISBN-13 & 0 *ISBN-10
    case SUPPLIMENTS_UPC_EAN = 0x11 //possible values of this parameter are given below
    
    case USER_PROG_SUPP1 = 0x12 //3 digit value input
    case USER_PROG_SUPP2 = 0x13 //3 digit value input
    case UPC_EAN_JAN_SUPP_REDUN = 0x14 //range is 2 to 30, *= 0x0A
    case XMIT_UPCA_CHECK_DIGIT = 0x15 //value 1 for *enable,0 disable
    case XMIT_UPCE_CHECK_DIGIT = 0x16 //value 1 for *enable,0 disable
    case XMIT_UPCE1_CHECK_DIGIT = 0x17 //value 1 for *enable,0 disable
    case XMIT_UPCA_PREAMBLE = 0x18 //value 0 for No Preamble,1 *system char & 2 country code & system char
    case XMIT_UPCE_PREAMBLE = 0x19 //value 0 for No Preamble,1 *system char & 2 country code & system char
    case XMIT_UPCE1_PREAMBLE = 0x1A //value 0 for No Preamble,1 *system char & 2 country code & system char
    case CONVERT_UPCE_2_UPCA = 0x1B //value 1 for enable,0 *disable
    case CONVERT_UPCE1_2_UPCA = 0x1C //value 1 for enable,0 *disable
    case EAN8_JAN8_EXTEND = 0x1D //value 1 for enable,0 *disable
    case UCC_COUPON_EXTEND = 0x1E //value 1 for enable,0 *disable
    case COUPON_REPORT = 0x1F //value 0 for old coupon symbols,1 *new coupon symbol,2 both coupons
    case ISSN_EAN = 0x20 //value 1 for enable,0 disable
    //code 39
    case EN_CODE39 = 0x21 //value 1 for *enable,0 disable
    case EN_TRIOPTIC_CODE39 = 0x22 //value 1 for enable,0 *disable
    case CONV_CODE39_2_CODE32 = 0x23 //value 1 for enable,0 *disable
    case CODE32_PREFIX = 0x24 //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_C39 = 0x25 //one byte input value
    case SETLEN_2DISCRETE_C39 = 0x26 //two bytes input value
    case SETLEN_RANGE_C39 = 0x27 //*Range is set by two byte input value,*= 0x02-= 0x37
    case SETLEN_ANY_C39 = 0x28 //No input value expected for this parameter
    case CODE39_CHK_DIGIT = 0x29 //value 1 for enable,0 *disable
    case XMIT_CODE39_CHK_DIGIT = 0x2A //value 1 for enable,0 *disable
    case CODE39_FULL_ASCII = 0x2B //value 1 for enable,0 *disable
    case CODE39_BUFFERING = 0x2C //value 1 for enable,0 *disable
    //Interleaved 2 of 5
    case EN_INTER2OF5 = 0x2D //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_I2OF5 = 0x2E //*one byte input value, *= 0x0E
    case SETLEN_2DISCRETE_I2OF5 = 0x2F //two bytes input value
    case SETLEN_RANGE_I2OF5 = 0x30 //Range is set by two byte input value
    case SETLEN_ANY_I2OF5 = 0x31 //No input value expected for this parameter
    case I2OF5_CHECK_DIGIT = 0x32 //value 1 for enable,0 *disable
    case XMIT_I2OF5_CHECK_DIGIT = 0x33 //value 1 for enable,0 *disable
    case CONV_I2OF5_EAN13 = 0x34 //value 1 for enable,0 *disable
    //2D,QR code
    case EN_QR_CODE = 0x35 //value 1 for *enable,0 disable
    //2D,QR Inverse
    case EN_QR_INVERSE = 0x36 //value 0 *regular,1 Inverse,2 Auto
    //2D, MicroQR
    case EN_MICRO_QR = 0x37 //value 1 for *enable,0 disable
    //2D,Data Matrix
    case EN_DATA_MATRIX = 0x38 //value 1 for *enable,0 disable
    case EN_DATA_MATRIX_INVERSE = 0x39 //value 0 *regular,1 Inverse,2 Auto
    case EN_MIRROR_IMAGES = 0x3A //value 0 regular,1 Inverse, 2 *Auto
    //Code 93
    case EN_CODE93 = 0x3B //value 1 for enable, 0 *disable
    case SETLEN_1DISCRETE_C93 = 0x3C //one byte input value
    case SETLEN_2DISCRETE_C93 = 0x3D //two bytes input value
    case SETLEN_RANGE_C93 = 0x3E //*Range is set by two byte input value, *= 0x04-= 0x37
    case SETLEN_ANY_C93 = 0x3F //No input value expected for this parameter
    //Code 11
    case EN_CODE11 = 0x40 //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_C11 = 0x41 //one byte input value
    case SETLEN_2DISCRETE_C11 = 0x42 //two bytes input value
    case SETLEN_RANGE_C11 = 0x43 //Range is set by two byte input value,*= 0x04-= 0x37
    case SETLEN_ANY_C11 = 0x44 //No input value expected for this parameter
    case CODE11_CHK_DIGIT = 0x45 //value 0 for *disable,1 one check digit & 2 two check digits
    case XMIT_CODE11_CHK_DIGIT = 0x46 //value 1 for enable,0 *disable
    //Discrete 2 of 5
    case EN_DISC2OF5 = 0x47 //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_D2OF5 = 0x48 //*one byte input value, = 0x0C
    case SETLEN_2DISCRETE_D2OF5 = 0x49 //two bytes input value
    case SETLEN_RANGE_D2OF5 = 0x4A //Range is set by two byte input value
    case SETLEN_ANY_D2OF5 = 0x4B //No input value expected for this parameter
    //Codabar
    case EN_CODABAR = 0x4C //value 1 for enable,0 disable
    case SETLEN_1DISCRETE_CBAR = 0x4D //one byte input value
    case SETLEN_2DISCRETE_CBAR = 0x4E //two bytes input value
    case SETLEN_RANGE_CBAR = 0x4F //*Range is set by two byte input value,*= 0x05-= 0x37
    case SETLEN_ANY_CBAR = 0x50 //No input value expected for this parameter
    case EN_CLSI = 0x51 //value 1 for enable,0 *disable
    case EN_NOTIS = 0x52 //value 1 for enable,0 *disable
    case START_STOP_CASE = 0x53 //value 1 for lower case,0 *upper case
    //MSI
    case EN_MSI = 0x54 //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_MSI = 0x55 //one byte input value
    case SETLEN_2DISCRETE_MSI = 0x56 //two bytes input value
    case SETLEN_RANGE_MSI = 0x57 //*Range is set by two byte input value,*= 0x04-= 0x37
    case SETLEN_ANY_MSI = 0x58 //No input value expected for this parameter
    case MSI_CHK_DIGIT = 0x59 //value 0 for *one check digit,1 two check digits
    case XMIT_MSI_CHK_DIGIT = 0x5A //value 1 for enable,0 *disable
    case MSI_CHK_DIGIT_ALGOR = 0x5B //value 0 for MOD 10/11 algorithm,1 *MOD10/MOD10 algorithm
    //CHINESE 2 of 5
    case EN_CHINESE2OF5 = 0x5C //value 1 for enable,0 *disable
    //MATRIX 2 of 5
    case EN_MATRIX2OF5 = 0x5D //value 1 for enable,0 *disable
    case SETLEN_1DISCRETE_M2OF5 = 0x5E //*one byte input value,*= 0x0E
    case SETLEN_2DISCRETE_M2OF5 = 0x5F //two bytes input value
    case SETLEN_RANGE_M2OF5 = 0x60 //Range is set by two byte input value
    case SETLEN_ANY_M2OF5 = 0x61 //No input value expected for this parameter
    case M2OF5_CHK_DIGIT = 0x62 //value 1 for enable,0 *disable
    case XMIT_M2OF5_CHK_DIGIT = 0x63 //value 1 for enable,0 *disable
    //KOREAN 3 of 5
    case EN_KOREAN3OF5 = 0x64 //value 1 for enable,0 *disable
    //INVERSE 1D
    case EN_INVERSE1D = 0x65 //value 0 for *regular,1 inverse & 2 inverse auto detect
    //POSTAL CODES
    case EN_US_POSTNET = 0x66 //value 1 for enable,0 *disable
    case EN_US_PLANET = 0x67 //value 1 for enable,0 *disable
    case XMIT_US_POST_CHK_DIGIT = 0x68 //value 1 for *enable,0 disable
    case EN_UK_POSTAL = 0x69 //value 1 for enable,0 *disable
    case XMIT_UK_POST_CHK_DIGIT = 0x6A //value 1 for *enable,0 disable
    case EN_JAPAN_POSTAL = 0x6B //value 1 for enable,0 *disable
    case EN_AUSTRALIA_POST = 0x6C //value 1 for enable,0 *disable
    case EN_AUST_POST_FMT = 0x6D //value 0 for *auto,1 raw format,2 alphanum enc,3 num enc
    case EN_NETHERLANDS_KIX = 0x6E //value 1 for enable,0 *disable
    case EN_USPS_4CB = 0x6F //value 1 for enable,0 *disable
    case EN_UPU_FICS = 0x70 //value 1 for enable,0 *disable
    //GS1 DataBar
    case EN_GS1_DATABAR = 0x71 //value 1 for *enable,0 disable
    case EN_GS1_LIMITED = 0x72 //value 1 for enable,0 *disable
    case LTD_SECURITY = 0x73 //value 1 for security level 1,2 level2,3 *level3,4 level4 EXAMPLE HEADER FILE 46 e255 BARCODE APPLICATION PROGRAMMERS GUIDE
    case EN_GS1_EXPANDED = 0x74 //value 1 for *enable,0 disable
    case EN_CONV_UPC_EAN = 0x75 //value 1 for enable,0 *disable
    //COMPOSITE
    case EN_COMP_CC_C = 0x76 //value 1 for enable,0 *disable
    case EN_COMP_CC_A_B = 0x77 //value 1 for enable,0 *disable
    case EN_COMP_TLC_39 = 0x78 //value 1 for enable,0 *disable
    case UPC_COMP_MODE = 0x79 //value 0 for UPC never linked, 1 *always linked,2 auto
    case EN_GS1_128_EMULATION = 0x7A //value 1 for enable,0 *disable
    //2D, PDF417
    case EN_PDF417 = 0x7B //value 1 for *enable,0 disable
    //2D, MICRO PDF417
    case EN_MICRO_PDF417 = 0x7C //value 1 for enable,0 *disable
    //2D, Maxicode
    case EN_MAXICODE = 0x7D //value 1 for enable,0 *disable
    //2D, Aztec
    case EN_AZTEC = 0x7E //value 1 for *enable,0 disable
    //2D, Aztec Inverse
    case EN_AZTEC_INVERSE = 0x7F //value 0 for regular,1 inverse, 2 *inverse auto detect
}

@objc
enum SymPidUpc: UInt8 {
    case IGNORE_UPC_EAN_W_SUPPLIMENTS = 0x00
    case DECODE_UPC_EAN_W_SUPPLIMENTS = 0x01
    case AUTODESCRIMINATE_SUPPLIMENTS = 0x02
    case ENABLE_378_379_SUPPLIMENTS = 0x04
    case ENABLE_978_979_SUPPLIMENTS = 0x05
    case ENABLE_977_SUPPLIMENT = 0x07
    case ENABLE_414_419_434_439 = 0x06
    case ENABLE_491_SUPPLIMENTS = 0x08
    case ENABLE_SMART_SUPPLIMENT = 0x03
    case SUPPLIMENT_USER_PROG1 = 0x09
    case SUPPLIMENT_USER_PROG1_2 = 0x0A
    case SMART_SUPPLIMENT_USER_PROG1 = 0x0B
    case SMART_SUPPLIMENT_USER_PROG1_2 = 0x0C
}

}
