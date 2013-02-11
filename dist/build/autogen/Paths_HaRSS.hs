module Paths_HaRSS (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch


version :: Version
version = Version {versionBranch = [0,1,0,0], versionTags = []}
bindir, libdir, datadir, libexecdir :: FilePath

bindir     = "/home/vagrant/.cabal/bin"
libdir     = "/home/vagrant/.cabal/lib/HaRSS-0.1.0.0/ghc-7.4.1"
datadir    = "/home/vagrant/.cabal/share/HaRSS-0.1.0.0"
libexecdir = "/home/vagrant/.cabal/libexec"

getBinDir, getLibDir, getDataDir, getLibexecDir :: IO FilePath
getBinDir = catchIO (getEnv "HaRSS_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "HaRSS_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "HaRSS_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "HaRSS_libexecdir") (\_ -> return libexecdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
