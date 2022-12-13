-- Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its
-- affiliates. All rights reserved.

{-# LANGUAGE OverloadedStrings #-}

module DA.Util.Text where

import           Data.Text                      ( Text )
import qualified Data.Text                     as T

indent :: Int -> Text -> Text
indent n = onLines (T.replicate n standardIndent <>)

indent' :: Int -> Text -> Text
indent' n = onLinesAfterFirst (T.replicate n standardIndent <>)

onLines :: (Text -> Text) -> Text -> Text
onLines f = T.intercalate "\n" . map f . T.lines

onLinesAfterFirst :: (Text -> Text) -> Text -> Text
onLinesAfterFirst f = T.intercalate "\n" . map' f . T.lines

map' :: (a -> a) -> [a] -> [a]
map' _ []       = []
map' f (a : as) = a : map f as

standardIndent :: Text
standardIndent = "  "
