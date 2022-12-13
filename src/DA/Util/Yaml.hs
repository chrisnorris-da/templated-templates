{-# LANGUAGE OverloadedStrings #-}

module DA.Util.Yaml where

import           Data.Text                      ( Text )
import qualified Data.Yaml                     as Y
import           Data.Yaml                      ( FromJSON(..)
                                                , (.:)
                                                )
import qualified Data.ByteString               as BS

data BaseT = BaseT
  { baseName  :: Text
  , signatory :: Text
  , operator  :: Text
  }
  deriving (Eq, Show)

newtype Derived
    = Derived {name :: Text}
    deriving (Eq, Show)

data Base = Base
  { base   :: BaseT
  , derive :: Derived
  }
  deriving (Eq, Show)

data Templates = Templates
  { moduleName :: String
  , templates  :: [Base]
  }
  deriving (Eq, Show)

instance FromJSON Templates where
  parseJSON (Y.Object v) =
    Templates <$> v .: "module-name" <*> v .: "templates"
  parseJSON _ = fail "Expected Object for Templates value"

instance FromJSON Base where
  parseJSON (Y.Object v) = Base <$> v .: "base" <*> v .: "derive"
  parseJSON _            = fail "Expected Object for Base value"

instance FromJSON Derived where
  parseJSON (Y.Object v) = Derived <$> v .: "name"
  parseJSON _            = fail "Expected Object for Derived value"

instance FromJSON BaseT where
  parseJSON (Y.Object v) =
    BaseT <$> v .: "baseName" <*> v .: "signatory" <*> v .: "operator"
  parseJSON _ = fail "Expected Object for BaseTemplate value"

decodeYaml :: FilePath -> IO Templates
decodeYaml f = do
  configYaml <- BS.readFile f
  Y.decodeThrow configYaml
