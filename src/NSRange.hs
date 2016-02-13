{-# LANGUAGE DeriveAnyClass, DeriveGeneric #-}
module NSRange (Range(..)) where
import Foreign
import Foreign.C.Types   (CULong)
import Foreign.CStorable (CStorable (..))
import GHC.Generics      (Generic)

data Range = Range { location :: CULong
                   , span     :: CULong
                   } deriving (Read, Show, Eq, Ord, Generic, CStorable)

instance Storable Range where
  sizeOf = cSizeOf
  alignment = cAlignment
  peek = cPeek
  poke = cPoke
