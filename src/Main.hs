{-# LANGUAGE DataKinds, DeriveAnyClass, DeriveGeneric, FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes, RecordPuns, RecordWildCards, TemplateHaskell   #-}
{-# LANGUAGE TupleSections, TypeFamilies                                 #-}
module Main where
import NSRange

import           Control.Lens         (iforM_)
import           Control.Monad        (forM)
import           Data.Default
import qualified Data.Map             as M
import           Data.Maybe           (catMaybes)
import           Data.Proxy           (Proxy (Proxy))
import           Data.Text            (Text)
import qualified Data.Text            as T
import qualified Data.Text.IO         as T
import           Foreign              (Ptr, alloca, castPtr, nullPtr)
import           Foreign.C.Types      (CInt (..), CLong (..), CULong (..))
import           Foreign.Storable     (Storable (..))
import qualified Language.C.Types     as C
import           Language.ObjC.Inline hiding (pure)
import qualified Language.ObjC.Inline as C

data NSRange
C.context (objcCtxWithClasses [defClass "NSSpellChecker"
                              ,defClass "NSDictionary"
                              ,defClass "NSMutableDictionary"
                              ,(C.TypeName "NSRange", [t|NSRange|])
                              ])
import_ "<AppKit/AppKit.h>"
import_ "<Foundation/Foundation.h>"

type NSSpellChecker = ObjC "NSSpellChecker"

nsLog :: Text -> IO ()
nsLog txt = [C.block| void { NSLog(@"%@", $obj:(NSString *txt)); } |]

sharedChecker :: NSSpellChecker
sharedChecker = [C.pure| NSSpellChecker * { [NSSpellChecker sharedSpellChecker] } |]

language :: NSSpellChecker -> IO Text
language sc = [C.exp'| NSString *{ [($raw:(NSSpellChecker *sc)) language] }|]

availableLanguages :: NSSpellChecker -> IO [Text]
availableLanguages sc = do
  ObjC arr <- [C.exp| NSArray * { [($raw:(NSSpellChecker *sc)) availableLanguages] }|]
  fromNSArray' (ObjC (castPtr arr :: Ptr (NSArray' "NSString")))

data GrammarCheckOptions = GrammarCheckOptions { startingAt   :: CLong
                                               , targLanguage :: Text
                                               , wrap         :: Bool
                                               } deriving (Read, Show, Eq, Ord)

data GrammarCheckResult = GrammarCheckResult { inRange :: Range
                                             , details :: [GrammarDetail]
                                             } deriving (Read, Show, Eq, Ord)

data GrammarDetail = GrammarDetail { dtlRange       :: Range
                                   , dtlDescription :: Text
                                   , dtlCorrections :: [Text]
                                   } deriving (Read, Show, Eq, Ord)

instance Default GrammarCheckOptions where
  def = GrammarCheckOptions { startingAt = -1, targLanguage = "en", wrap = True}

instance Default GrammarCheckResult where
  def = GrammarCheckResult  (Range 0 0) []

instance Object "NSDictionary" where
  type Haskell "NSDictionary" = M.Map Text Text
  fromObjC_ dic = do
    ks <- fromNSArray (Proxy :: Proxy "NSString")
             =<< [C.exp| NSArray * { [($(NSDictionary *dic)) allKeys] } |]
    M.fromList <$> forM (catMaybes ks)
      (\k -> fmap (k,)
             [C.exp'| NSString * { [[($(NSDictionary *dic)) objectForKey: $txt:k ] description] } |])
  toObjC_ _ inl = do
    let size = fromIntegral $ M.size inl
    dic <- [C.exp| NSMutableDictionary * {[NSMutableDictionary dictionaryWithCapacity: $(int size)] } |]
    iforM_ inl $ \k p ->
      [C.block| void { [($raw:(NSMutableDictionary *dic)) setObject: $txt:p forKey: $txt:k] ;} |]
    return $ runObjC $ upcast dic

type NSDictionary = ObjC "NSDictionary"

toGrammarDetail :: NSDictionary -> IO GrammarDetail
toGrammarDetail dic = do
  dtlCorrections <- fmap catMaybes . fromNSArray (Proxy :: Proxy "NSString") =<< [C.exp| NSArray * { [($raw:(NSDictionary *dic)) valueForKey: NSGrammarCorrections] } |]
  dtlDescription <- [C.exp'| NSString * {[($raw:(NSDictionary *dic)) valueForKey: NSGrammarUserDescription]} |]
  loc <- [C.exp| NSUInteger { [[($raw:(NSDictionary *dic)) valueForKey: NSGrammarRange] rangeValue].location } |]
  spn <- [C.exp| NSUInteger { [[($raw:(NSDictionary *dic)) valueForKey: NSGrammarRange] rangeValue].length } |]
  let dtlRange = Range loc spn
  return GrammarDetail{..}

checkGrammar :: GrammarCheckOptions -> Text -> IO GrammarCheckResult
checkGrammar GrammarCheckOptions{..} txt = alloca $ \ranPtr -> alloca $ \arrPtr -> do
  let doesWrap = if wrap then 1 else 0
      nsarr    = castPtr ranPtr
  [C.block| void { *$(NSRange *nsarr) = [[NSSpellChecker sharedSpellChecker]
                                   checkGrammarOfString: $txt:txt
                                             startingAt: $(NSInteger startingAt)
                                               language: $txt:targLanguage
                                                   wrap: $(BOOL doesWrap)
                                 inSpellDocumentWithTag: 0
                                                details: $(NSArray **arrPtr)
                           ];  }
               |]
  arr <- peek arrPtr
  len <- [C.exp| int { $(NSArray *arr).count } |]
  dtls <- forM [0.. len - 1] $ \i ->
     toGrammarDetail =<< [C.exp|NSDictionary * { [($(NSArray *arr)) objectAtIndex: $(int i) ] } |]
  GrammarCheckResult <$> peek ranPtr <*> pure dtls

main :: IO ()
main = print =<< checkGrammar def . T.init =<< T.getLine
