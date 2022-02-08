{-# LANGUAGE UndecidableInstances #-}

module Hasura.Backends.Postgres.Translate.Types
  ( ApplySortingAndSlicing (ApplySortingAndSlicing),
    ArrayConnectionSource (ArrayConnectionSource, _acsSource),
    ArrayRelationSource (ArrayRelationSource),
    ComputedFieldTableSetSource (ComputedFieldTableSetSource),
    DistinctAndOrderByExpr (ASorting),
    JoinTree (..),
    MultiRowSelectNode (..),
    ObjectRelationSource (ObjectRelationSource),
    ObjectSelectSource (ObjectSelectSource, _ossPrefix),
    PermissionLimitSubQuery (..),
    SelectNode (SelectNode),
    SelectSlicing (SelectSlicing, _ssLimit, _ssOffset),
    SelectSorting (..),
    SelectSource (SelectSource, _ssPrefix),
    SortingAndSlicing (SortingAndSlicing),
    SourcePrefixes (..),
    applySortingAndSlicing,
    noSortingAndSlicing,
    objectSelectSourceToSelectSource,
    orderByForJsonAgg,
  )
where

import Data.HashMap.Strict qualified as HM
import Data.Int (Int64)
import Hasura.Backends.Postgres.SQL.DML qualified as PG
import Hasura.Backends.Postgres.SQL.Types qualified as PG
import Hasura.Prelude
import Hasura.RQL.IR.Select
import Hasura.RQL.Types.Common

data SourcePrefixes = SourcePrefixes
  { -- | Current source prefix
    _pfThis :: !PG.Identifier,
    -- | Base table source row identifier to generate
    -- the table's column identifiers for computed field
    -- function input parameters
    _pfBase :: !PG.Identifier
  }
  deriving (Show, Eq, Generic)

instance Hashable SourcePrefixes

-- | Select portion of rows generated by the query using limit and offset
data SelectSlicing = SelectSlicing
  { _ssLimit :: !(Maybe Int),
    _ssOffset :: !(Maybe Int64)
  }
  deriving (Show, Eq, Generic)

instance Hashable SelectSlicing

data DistinctAndOrderByExpr = ASorting
  { _sortAtNode :: (PG.OrderByExp, Maybe PG.DistinctExpr),
    _sortAtBase :: Maybe (PG.OrderByExp, Maybe PG.DistinctExpr)
  }
  deriving (Show, Eq, Generic)

instance Hashable DistinctAndOrderByExpr

-- | Sorting with -- Note [Optimizing queries using limit/offset])
data SelectSorting
  = NoSorting !(Maybe PG.DistinctExpr)
  | Sorting !DistinctAndOrderByExpr
  deriving (Show, Eq, Generic)

instance Hashable SelectSorting

data SortingAndSlicing = SortingAndSlicing
  { _sasSorting :: !SelectSorting,
    _sasSlicing :: !SelectSlicing
  }
  deriving (Show, Eq, Generic)

instance Hashable SortingAndSlicing

data SelectSource = SelectSource
  { _ssPrefix :: !PG.Identifier,
    _ssFrom :: !PG.FromItem,
    _ssWhere :: !PG.BoolExp,
    _ssSortingAndSlicing :: !SortingAndSlicing
  }
  deriving (Generic)

instance Hashable SelectSource

deriving instance Show SelectSource

deriving instance Eq SelectSource

noSortingAndSlicing :: SortingAndSlicing
noSortingAndSlicing =
  SortingAndSlicing (NoSorting Nothing) noSlicing

noSlicing :: SelectSlicing
noSlicing = SelectSlicing Nothing Nothing

orderByForJsonAgg :: SelectSource -> Maybe PG.OrderByExp
orderByForJsonAgg SelectSource {..} =
  case _sasSorting _ssSortingAndSlicing of
    NoSorting {} -> Nothing
    Sorting ASorting {..} -> Just $ fst _sortAtNode

data ApplySortingAndSlicing = ApplySortingAndSlicing
  { _applyAtBase :: !(Maybe PG.OrderByExp, SelectSlicing, Maybe PG.DistinctExpr),
    _applyAtNode :: !(Maybe PG.OrderByExp, SelectSlicing, Maybe PG.DistinctExpr)
  }

applySortingAndSlicing :: SortingAndSlicing -> ApplySortingAndSlicing
applySortingAndSlicing SortingAndSlicing {..} =
  case _sasSorting of
    NoSorting distinctExp -> withNoSorting distinctExp
    Sorting sorting -> withSoritng sorting
  where
    withNoSorting distinctExp =
      ApplySortingAndSlicing (Nothing, _sasSlicing, distinctExp) (Nothing, noSlicing, Nothing)
    withSoritng ASorting {..} =
      let (nodeOrderBy, nodeDistinctOn) = _sortAtNode
       in case _sortAtBase of
            Just (baseOrderBy, baseDistinctOn) ->
              ApplySortingAndSlicing (Just baseOrderBy, _sasSlicing, baseDistinctOn) (Just nodeOrderBy, noSlicing, nodeDistinctOn)
            Nothing ->
              ApplySortingAndSlicing (Nothing, noSlicing, Nothing) (Just nodeOrderBy, _sasSlicing, nodeDistinctOn)

data SelectNode = SelectNode
  { _snExtractors :: !(HM.HashMap PG.Alias PG.SQLExp),
    _snJoinTree :: !JoinTree
  }
  deriving stock (Eq)

instance Semigroup SelectNode where
  SelectNode lExtrs lJoinTree <> SelectNode rExtrs rJoinTree =
    SelectNode (lExtrs <> rExtrs) (lJoinTree <> rJoinTree)

data ObjectSelectSource = ObjectSelectSource
  { _ossPrefix :: !PG.Identifier,
    _ossFrom :: !PG.FromItem,
    _ossWhere :: !PG.BoolExp
  }
  deriving (Show, Eq, Generic)

instance Hashable ObjectSelectSource

objectSelectSourceToSelectSource :: ObjectSelectSource -> SelectSource
objectSelectSourceToSelectSource ObjectSelectSource {..} =
  SelectSource _ossPrefix _ossFrom _ossWhere sortingAndSlicing
  where
    sortingAndSlicing = SortingAndSlicing noSorting limit1
    noSorting = NoSorting Nothing
    -- We specify 'LIMIT 1' here to mitigate misconfigured object relationships with an
    -- unexpected one-to-many/many-to-many relationship, instead of the expected one-to-one/many-to-one relationship.
    -- Because we can't detect this misconfiguration statically (it depends on the data),
    -- we force a single (or null) result instead by adding 'LIMIT 1'.
    -- Which result is returned might be non-deterministic (though only in misconfigured cases).
    -- Proper one-to-one/many-to-one object relationships should not be semantically affected by this.
    -- See: https://github.com/hasura/graphql-engine/issues/7936
    limit1 = SelectSlicing (Just 1) Nothing

data ObjectRelationSource = ObjectRelationSource
  { _orsRelationshipName :: !RelName,
    _orsRelationMapping :: !(HM.HashMap PG.PGCol PG.PGCol),
    _orsSelectSource :: !ObjectSelectSource
  }
  deriving (Generic)

instance Hashable ObjectRelationSource

deriving instance Eq ObjectRelationSource

data ArrayRelationSource = ArrayRelationSource
  { _arsAlias :: !PG.Alias,
    _arsRelationMapping :: !(HM.HashMap PG.PGCol PG.PGCol),
    _arsSelectSource :: !SelectSource
  }
  deriving (Generic)

instance Hashable ArrayRelationSource

deriving instance Eq ArrayRelationSource

data MultiRowSelectNode = MultiRowSelectNode
  { _mrsnTopExtractors :: ![PG.Extractor],
    _mrsnSelectNode :: !SelectNode
  }
  deriving stock (Eq)

instance Semigroup MultiRowSelectNode where
  MultiRowSelectNode lTopExtrs lSelNode <> MultiRowSelectNode rTopExtrs rSelNode =
    MultiRowSelectNode (lTopExtrs <> rTopExtrs) (lSelNode <> rSelNode)

data ComputedFieldTableSetSource = ComputedFieldTableSetSource
  { _cftssFieldName :: !FieldName,
    _cftssSelectSource :: !SelectSource
  }
  deriving (Generic)

instance Hashable ComputedFieldTableSetSource

deriving instance Show ComputedFieldTableSetSource

deriving instance Eq ComputedFieldTableSetSource

data ArrayConnectionSource = ArrayConnectionSource
  { _acsAlias :: !PG.Alias,
    _acsRelationMapping :: !(HM.HashMap PG.PGCol PG.PGCol),
    _acsSplitFilter :: !(Maybe PG.BoolExp),
    _acsSlice :: !(Maybe ConnectionSlice),
    _acsSource :: !SelectSource
  }
  deriving (Generic)

deriving instance Eq ArrayConnectionSource

instance Hashable ArrayConnectionSource

data JoinTree = JoinTree
  { _jtObjectRelations :: !(HM.HashMap ObjectRelationSource SelectNode),
    _jtArrayRelations :: !(HM.HashMap ArrayRelationSource MultiRowSelectNode),
    _jtArrayConnections :: !(HM.HashMap ArrayConnectionSource MultiRowSelectNode),
    _jtComputedFieldTableSets :: !(HM.HashMap ComputedFieldTableSetSource MultiRowSelectNode)
  }
  deriving stock (Eq)

instance Semigroup JoinTree where
  JoinTree lObjs lArrs lArrConns lCfts <> JoinTree rObjs rArrs rArrConns rCfts =
    JoinTree
      (HM.unionWith (<>) lObjs rObjs)
      (HM.unionWith (<>) lArrs rArrs)
      (HM.unionWith (<>) lArrConns rArrConns)
      (HM.unionWith (<>) lCfts rCfts)

instance Monoid JoinTree where
  mempty = JoinTree mempty mempty mempty mempty

data PermissionLimitSubQuery
  = -- | Permission limit
    PLSQRequired !Int
  | PLSQNotRequired
  deriving (Show, Eq)
