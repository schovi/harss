{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Blaze.ByteString.Builder (copyByteString)
import Control.Monad
import Control.Monad.IO.Class
import qualified Data.ByteString.UTF8 as BU
import Data.List
import Network.HTTP.Types (status200)
import Network.Wai
import Network.Wai.Handler.Warp
import Text.HandsomeSoup
import Text.XML.HXT.Core hiding (app)
import Text.XML.Light
import Text.RSS.Export
import Text.RSS.Syntax

data Article = Article { name   :: String
                       , link   :: String
                       , author :: String } deriving Show

getArticles :: String -> IO [Article]
getArticles url = do
    doc      <- fromUrl url
    articles <- runX $ doc >>> articlesSelector >>> (nameSelector &&& linkSelector &&& authorSelector)
    return $ map mkArticle articles
  where
    articlesSelector = css "body table tr td div.modryram table tr td.z"
    nameSelector     = css "a.clanek span.clanadpis" /> getText
    linkSelector     = css "a.clanek" ! "href"
    authorSelector   = css "a" >>> hasAttrValue "href" (isPrefixOf "mailto") /> getText
    mkArticle (n, (l, a)) = Article n l a

mkFeed :: [Article] -> String
mkFeed articles
  = showTopElement . xmlRSS $ mkRSS { rssChannel = mkChannel { rssItems = map mkItem articles } }
  where
    mkRSS     = nullRSS "DFens" "http://harss.minarik.net/"
    mkChannel = nullChannel "DFens" "http://harss.minarik.net/"
    mkItem (Article name link author) = (nullItem "item title") { rssItemLink = Just link
                                                                , rssItemDescription = Just author }

app :: Application
app _ = do
  response <- liftIO . liftM (BU.fromString . mkFeed) $ getArticles "http://www.dfens-cz.com/"
  return . ResponseBuilder status200 [ ("Content-Type", "application/xml") ] $ copyByteString response

main = run 3000 app

