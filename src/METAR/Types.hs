module METAR.Types
  ( METAR(METAR)
  , mkMetar
  , ICAOCode
  , mkICAOCode
  , Timestamp
  , mkTimestamp
  , WindInfo
  , mkWindInfo
  , WindSpeedUnit(KT, MPS)
  )
where

import           Data.Word                                ( Word )
import           Data.Char                                ( isUpper )

data METAR = METAR ICAOCode Timestamp WindInfo deriving (Eq, Show)

newtype ICAOCode = ICAOCode String deriving (Eq, Show)

data Timestamp = Timestamp Day Hours Minutes deriving (Eq, Show)
newtype Day = Day Word deriving (Eq, Show)
newtype Hours = Hours Word deriving (Eq, Show)
newtype Minutes = Minutes Word deriving (Eq, Show)

data WindInfo = WindInfo WindDirection WindSpeed (Maybe WindGusts) deriving (Eq, Show)
newtype WindDirection = WindDirection Word deriving (Eq, Show)
newtype WindSpeed = WindSpeed Word deriving (Eq, Show)
newtype WindGusts = WindGusts Word deriving (Eq, Show)
data WindSpeedUnit = KT | MPS

mkICAOCode :: String -> Either String ICAOCode
mkICAOCode code
  | null code              = Left "ICAO code should contain at least 1 letter"
  | not (all isUpper code) = Left "ICAO code can contain only uppercase letters"
  | otherwise              = Right $ ICAOCode code

mkTimestamp :: Word -> Word -> Word -> Either String Timestamp
mkTimestamp d h m = Timestamp <$> day <*> hours <*> minutes
 where
  day     = Day <$> checkRange "day" 1 31 d
  hours   = Hours <$> checkRange "hours" 0 23 h
  minutes = Minutes <$> checkRange "minutes" 0 59 m
  checkRange label lower upper x = 
    if x >= lower && x <= upper
      then Right x
      else Left errorText
   where
    errorText =
      label ++ " should be within range of " ++ show lower ++ "-" ++ show upper

mkWindInfo :: Word -> Word -> Maybe Word -> WindInfo
mkWindInfo d s g = WindInfo (WindDirection d) (WindSpeed s) (WindGusts <$> g)

mkMetar
  :: Either String ICAOCode
  -> Either String Timestamp
  -> WindInfo
  -> Either String METAR
mkMetar icaoCode timestamp windInfo =
  METAR <$> icaoCode <*> timestamp <*> Right windInfo

