/// Sort options for file list
enum SortOption {
  foldersFirst,
  filesFirst,
  nameAZ,
  nameZA,
  sizeSmallLarge,
  sizeLargeSmall,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.foldersFirst:
        return 'Folders First';
      case SortOption.filesFirst:
        return 'Files First';
      case SortOption.nameAZ:
        return 'Name A-Z';
      case SortOption.nameZA:
        return 'Name Z-A';
      case SortOption.sizeSmallLarge:
        return 'Size: Small to Large';
      case SortOption.sizeLargeSmall:
        return 'Size: Large to Small';
    }
  }
}
