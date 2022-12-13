-- Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its
-- affiliates. All rights reserved.

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE RecordWildCards   #-}

module DA.Daml.Codegen.Templating where

import           Data.String.Interpolate        ( __i )
import           Data.Text                      ( Text )
import qualified Data.Text                     as T

import           DA.Util.Text
import           DA.Util.Yaml

mkTemplates :: Templates -> Text
mkTemplates Templates {..} =
  [__i|
  module #{moduleName} where
  |]
    <> "\n\n"
    <> T.intercalate "\n\n" (map mkUpgradeTemplate templates)
    <> "\n"

mkUpgradeTemplate :: Base -> Text
mkUpgradeTemplate b@Base {..} =
  let BaseT {..} = base
      parties    = signatory : [operator]
  in  [__i|

   template #{baseName}
     with
   #{toParties parties}
     where
       signatory #{T.intercalate ", " parties}
       key (#{T.intercalate ", " parties}) : (Party, Party)
       maintainer key._1

   #{toDerived b}
  |]
 where
  toParties :: [Text] -> Text
  toParties p = [__i|
              #{T.intercalate " : Party\n" (indent 2 <$> p)} : Party
            |]

  toDerived :: Base -> Text
  toDerived Base {..} =
    let BaseT {..}   = base
        parties      = signatory : [operator]
        Derived {..} = derive
    in  [__i|

            template #{baseName}#{name}
              with
            #{toParties parties}
              where
                signatory #{signatory}
                observer #{operator}
                key (#{signatory}, #{operator}) : (Party, Party)
                maintainer key._1

                choice Accept#{baseName}#{name}: ContractId #{baseName}
                  controller #{operator}
                  do
                    create #{baseName} with ..
                     |]
