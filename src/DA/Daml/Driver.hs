-- Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its
-- affiliates. All rights reserved.

{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module DA.Daml.Driver where

import           Prelude                                hiding (log)


import qualified Data.Text.IO                      as T
import qualified System.Directory                  as D (createDirectoryIfMissing)

import           Data.Foldable
import           Data.Text                              (Text)

import           System.FilePath                        (takeDirectory, (<.>),
                                                         (</>))
import           DA.Daml.Codegen.Templating             (mkTemplates)
import           DA.Util.Yaml

generateUpgrade :: Templates -> IO ()
generateUpgrade c = do
 traverse_ (writeDamlFile c)
     [mkTemplates c]

  where
    writeDamlFile :: Templates -> Text -> IO ()
    writeDamlFile Templates{..} contents = do
      let newPath = "." </> "daml" </> moduleName <.> "daml"
      D.createDirectoryIfMissing True $ takeDirectory newPath
      T.writeFile newPath contents
