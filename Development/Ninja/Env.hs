{-# LANGUAGE RecordWildCards, PatternGuards #-}

-- | A Ninja style environment, basically a linked-list of mutable hash tables.
module Development.Ninja.Env(
    Env, newEnv, scopeEnv, addEnv, askEnv
    ) where

import qualified Data.HashMap.Strict as Map
import Data.Hashable
import Data.IORef


data Env k v = Env (IORef (Map.HashMap k v)) (Maybe (Env k v))

instance Show (Env k v) where show _ = "Env"


newEnv :: IO (Env k v)
newEnv = do ref <- newIORef Map.empty; return $ Env ref Nothing


scopeEnv :: Env k v -> IO (Env k v)
scopeEnv e = do ref <- newIORef Map.empty; return $ Env ref $ Just e


addEnv :: (Eq k, Hashable k) => Env k v -> k -> v -> IO ()
addEnv (Env ref _) k v = modifyIORef ref $ Map.insert k v


askEnv :: (Eq k, Hashable k) => Env k v -> k -> IO (Maybe v)
askEnv (Env ref e) k = do
    mp <- readIORef ref
    case Map.lookup k mp of
        Just v -> return $ Just v
        Nothing | Just e <- e -> askEnv e k
        _ -> return Nothing
