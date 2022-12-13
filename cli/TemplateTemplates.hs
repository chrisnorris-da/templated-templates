-- Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its
-- affiliates. All rights reserved.

module Main where

import           Colog                          ( Severity(..) )
import           Data.Maybe
import           Options.Applicative
import           System.Environment             ( getProgName )

import           DA.Daml.Driver                 ( generateUpgrade )
import           DA.Util.Yaml

main :: IO ()
main = execParser opts >>= runProgram

data Command
  = Generate FilePath
  | VersionDisplay
  deriving (Eq, Show)

data CodegenOpts a = CodegenOpts
  { yamlFile     :: FilePath
  , verbosity    :: Severity
  , allowSkipped :: Bool
  }
  deriving (Eq, Show)

opts :: ParserInfo Command
opts =
  info (helper <*> commands)
    $  fullDesc
    <> progDesc "Code generation tool for daml templates"
    <> header "template-templates"

commands :: Parser Command
commands =
  subparser generate
    <|> subparser (commandGroup "Development helpers:" <> hidden)
    <|> version

summaryFile :: Parser (Maybe FilePath)
summaryFile = optional . strOption $ long "summary" <> metavar "FILE" <> help
  "Write summary as YAML to the given file"

libDirectories :: Parser [FilePath]
libDirectories =
  many . strOption $ long "lib" <> metavar "DIR" <> help "Library directory"

optVerbosity :: Parser Severity
optVerbosity =
  option (maybeReader readSeverity)
    $  long "verbosity"
    <> short 'V'
    <> help "Verbosity: (D)ebug, (I)nfo (default), (W)arn (E)rror"
    <> value Info
 where
  readSeverity :: String -> Maybe Severity
  readSeverity s = listToMaybe . mapMaybe (lookup s) $ [sevLetters, sevStrings]
  severities = [Debug .. Error]
  sevLetters = map ((: []) . head . show) severities `zip` severities
  sevStrings = map show severities `zip` severities

allowSkippedFlag :: Parser Bool
allowSkippedFlag = switch $ long "allow-skipped" <> short 'A' <> help
  "Allow skipped templates in the template configuration"

type CommonOpts b = Severity -> b

commonOpts :: Parser (CommonOpts b) -> Parser b
commonOpts h = h <*> optVerbosity

generateOpts :: Parser FilePath
generateOpts =
  argument str (metavar "YAML_FILE" <> help "Path to template.yaml file")

version :: Parser Command
version =
  flag' VersionDisplay $ long "version" <> help "Display the version and exit"

generate :: Mod CommandFields Command
generate =
  command "generate" $ info (helper <*> (Generate <$> generateOpts)) $ progDesc
    "Generate a template from the template.yaml file"


runProgram :: Command -> IO ()

runProgram (Generate yamlFile) = decodeYaml yamlFile >>= generateUpgrade

runProgram VersionDisplay      = getProgName >>= putStrLn . showVersion
  where showVersion name = "\n" <> name <> " version " <> "\n"
