# Graph Report - /Users/luowei/projects/libs/LWPhotoPicker  (2026-05-04)

## Corpus Check
- Corpus is ~9,103 words - fits in a single context window. You may not need a graph.

## Summary
- 116 nodes · 122 edges · 9 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]

## God Nodes (most connected - your core abstractions)
1. `LWPhotoPicker` - 12 edges
2. `LWAspectPhotoPickerView` - 12 edges
3. `LWPhotoPicker` - 12 edges
4. `LWPhotoPickerView` - 9 edges
5. `LWAppDelegate` - 7 edges
6. `AspectPhotoPickerViewModel` - 7 edges
7. `PhotoPickerViewModel` - 6 edges
8. `UIImage` - 5 edges
9. `LWAspectPhotoPickerUIView` - 5 edges
10. `Tests` - 4 edges

## Surprising Connections (you probably didn't know these)
- `LWAspectPhotoPickerView` --inherits--> `View`  [EXTRACTED]
  LWPhotoPicker_swift/SwiftClasses/LWAspectPhotoPickerView.swift →   _Bridges community 4 → community 2_

## Communities (15 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.18
Nodes (3): LWPhotoAlbumList, LWPhotoModel, LWPhotoPicker

### Community 1 - "Community 1"
Cohesion: 0.12
Nodes (15): LWAspectPhotoPickerView, -collectionViewcellForItemAtIndexPath, -collectionViewdidSelectItemAtIndexPath, -collectionViewlayoutsizeForItemAtIndexPath, -collectionViewnumberOfItemsInSection, -croppingImagecenterSquareSize, -didMoveToSuperview, -getImageWithAssetcompletion (+7 more)

### Community 2 - "Community 2"
Cohesion: 0.17
Nodes (7): ObservableObject, LWPhotoPickerUIView, LWPhotoPickerView, PhotoCell, PhotoPickerViewModel, UIView, View

### Community 3 - "Community 3"
Cohesion: 0.13
Nodes (14): LWPhotoAblumList, LWPhotoModel, LWPhotoPicker, -fetchAssetsInAssetCollectionascending, -getAllAssetInPhotoAblumWithAscending, -getAssetsInAssetCollectionascending, -getDestinationCollection, -getPhotoAblumList (+6 more)

### Community 4 - "Community 4"
Cohesion: 0.19
Nodes (4): AspectPhotoCell, AspectPhotoPickerViewModel, LWAspectPhotoPickerUIView, LWAspectPhotoPickerView

### Community 5 - "Community 5"
Cohesion: 0.17
Nodes (11): LWPhotoCollectionCell, -initWithFrame, LWPhotoPickerView, -collectionViewcellForItemAtIndexPath, -collectionViewdidDeselectItemAtIndexPath, -collectionViewdidSelectItemAtIndexPath, -collectionViewnumberOfItemsInSection, -diskCache (+3 more)

### Community 6 - "Community 6"
Cohesion: 0.22
Nodes (7): LWViewController, -leftPickerBtnAction, -rightPickerBtnAction, -viewDidLoad, UIImage, -blurImageWithRadius, -blurWithRectradius

### Community 7 - "Community 7"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 8 - "Community 8"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

## Knowledge Gaps
- **49 isolated node(s):** `-setUp`, `-tearDown`, `-testExample`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive` (+44 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `UIImage` connect `Community 6` to `Community 4`?**
  _High betweenness centrality (0.126) - this node is a cross-community bridge._
- **Why does `AspectPhotoPickerViewModel` connect `Community 4` to `Community 2`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **Why does `LWPhotoPicker` connect `Community 0` to `Community 6`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **What connects `-setUp`, `-tearDown`, `-testExample` to the rest of the system?**
  _49 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.12 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._