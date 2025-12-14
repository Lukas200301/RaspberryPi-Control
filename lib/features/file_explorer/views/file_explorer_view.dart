import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/file_explorer_controller.dart';
import '../models/file_entity.dart';
import '../models/sort_option.dart';

/// File Explorer View - Modern glassmorphism design
class FileExplorerView extends GetView<FileExplorerController> {
  const FileExplorerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Load directory after first frame if not already loaded
    // This prevents blocking during app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.sshService != null &&
          controller.contents.isEmpty &&
          !controller.isLoading.value &&
          controller.errorMessage.value.isEmpty) {
        controller.loadCurrentDirectory();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Custom app bar
          _buildAppBar(context, isDark),

          // Search bar (if visible)
          Obx(() {
            if (!controller.showSearchBar.value) return const SizedBox.shrink();
            return _buildSearchBar(context, isDark);
          }),

          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadCurrentDirectory,
              child: Obx(() => _buildContent(context, isDark)),
            ),
          ),
        ],
      ),

      // Floating action buttons
      floatingActionButton: Obx(() {
        if (controller.isSelectionMode.value) {
          return _buildSelectionFAB(context, isDark);
        }
        return _buildNormalFAB(context, isDark);
      }),
    );
  }

  /// Build custom glassmorphic app bar
  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Obx(() {
      final isSelection = controller.isSelectionMode.value;
      final selectedCount = controller.selectedItems.length;

      return GlassCard(
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceSM,
        ),
        borderRadius: AppDimensions.radiusLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Leading icon/button
                if (isSelection)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.exitSelectionMode,
                    tooltip: 'Exit selection',
                  )
                else
                  Icon(
                    Icons.folder_open,
                    color: AppColors.accentCyan,
                    size: AppDimensions.iconLG,
                  ),

                const SizedBox(width: AppDimensions.spaceSM),

                // Path/Title
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.currentPath.value),
                      );
                      Get.snackbar(
                        'Copied',
                        'Path copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSelection
                              ? '$selectedCount selected'
                              : 'File Explorer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.currentPath.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                if (isSelection) ...[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: controller.selectAllFiles,
                    tooltip: 'Select all',
                    color: AppColors.accentTeal,
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: selectedCount > 0
                        ? controller.downloadSelected
                        : null,
                    tooltip: 'Download',
                    color: AppColors.accentIndigo,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: selectedCount > 0
                        ? controller.deleteSelected
                        : null,
                    tooltip: 'Delete',
                    color: AppColors.error,
                  ),
                ] else ...[
                  if (controller.currentPath.value != '/')
                    IconButton(
                      icon: Icon(
                        controller.showSearchBar.value
                            ? Icons.search_off
                            : Icons.search,
                      ),
                      onPressed: controller.toggleSearchBar,
                      tooltip: 'Search',
                      color: AppColors.accentTeal,
                    ),
                  PopupMenuButton<SortOption>(
                    icon: Icon(
                      Icons.sort,
                      color: AppColors.accentIndigo,
                    ),
                    tooltip: 'Sort',
                    onSelected: controller.changeSortOption,
                    itemBuilder: (context) => SortOption.values.map((option) {
                      return PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            if (controller.sortOption.value == option)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: AppColors.accentIndigo,
                              )
                            else
                              const SizedBox(width: 20),
                            const SizedBox(width: AppDimensions.spaceSM),
                            Text(option.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build search bar
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      child: Obx(() {
        return TextField(
          controller: controller.searchController,
          autofocus: true,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search files...',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.accentTeal,
            ),
            suffixIcon: controller.isSearching.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.searchController.clear(),
                  ),
          ),
        );
      }),
    );
  }

  /// Build main content
  Widget _buildContent(BuildContext context, bool isDark) {
    if (controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentIndigo,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'Loading...',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: GlassCard(
          margin: const EdgeInsets.all(AppDimensions.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              ElevatedButton.icon(
                onPressed: controller.loadCurrentDirectory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppDimensions.spaceMD,
        right: AppDimensions.spaceMD,
        top: AppDimensions.spaceSM,
        bottom: 140, // Extra space for FAB buttons at bottom
      ),
      itemCount: controller.filteredContents.length +
          (controller.currentPath.value != '/' ? 1 : 0),
      itemBuilder: (context, index) {
        // Parent directory item
        if (controller.currentPath.value != '/' && index == 0) {
          return _buildParentDirectoryItem(context, isDark);
        }

        // Regular file/folder item
        final actualIndex = controller.currentPath.value != '/' ? index - 1 : index;
        final item = controller.filteredContents[actualIndex];
        return _buildFileItem(context, item, isDark);
      },
    );
  }

  /// Build parent directory item (..)
  Widget _buildParentDirectoryItem(BuildContext context, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      onTap: () => controller.navigateToDirectory('..'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: AppColors.accentCyan,
              size: AppDimensions.iconMD,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Text(
              'Parent Directory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  /// Build file/folder item
  Widget _buildFileItem(BuildContext context, FileEntity item, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedItems.contains(item);
      final isSelectionMode = controller.isSelectionMode.value;

      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _handleItemLongPress(item);
        },
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
          padding: const EdgeInsets.all(AppDimensions.spaceMD),
          borderColor: isSelected
              ? AppColors.accentIndigo.withOpacity(0.5)
              : null,
          onTap: () => _handleItemTap(item),
          child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSM),
              decoration: BoxDecoration(
                color: _getIconColor(item).withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Icon(
                _getIconData(item),
                color: _getIconColor(item),
                size: AppDimensions.iconMD,
              ),
            ),

            const SizedBox(width: AppDimensions.spaceMD),

            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!item.isDirectory) ...[
                        Text(
                          item.formattedSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                      ],
                      Text(
                        item.permissions,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Courier',
                          color: isDark
                              ? AppColors.textTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (controller.showSearchBar.value && item.fullPath != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.fullPath!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accentTeal.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Selection checkbox or chevron
            if (isSelectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => controller.toggleSelectionMode(item),
                activeColor: AppColors.accentIndigo,
              )
            else if (item.isDirectory)
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
          ],
        ),
        ),
      );
    });
  }

  /// Handle item tap - Navigate folders or show file details
  void _handleItemTap(FileEntity item) {
    if (controller.isSelectionMode.value) {
      controller.toggleSelectionMode(item);
    } else {
      if (item.isDirectory) {
        controller.navigateToDirectory(item.name);
      } else {
        // Show file details dialog
        _showFileDetails(item);
      }
    }
  }

  /// Handle item long press - Enter selection mode
  void _handleItemLongPress(FileEntity item) {
    if (!controller.isSelectionMode.value) {
      controller.toggleSelectionMode(item);
    }
  }

  /// Show file details dialog
  void _showFileDetails(FileEntity item) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: _getIconColor(item).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Icon(
                      _getIconData(item),
                      color: _getIconColor(item),
                      size: AppDimensions.iconXL,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceLG),

              // File details
              _buildDetailRow('Size', item.formattedSize, isDark),
              _buildDetailRow('Permissions', item.permissions, isDark),
              if (item.extension.isNotEmpty)
                _buildDetailRow('Type', item.extension.toUpperCase(), isDark),
              if (item.fullPath != null)
                _buildDetailRow('Path', item.fullPath!, isDark),

              const SizedBox(height: AppDimensions.spaceLG),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.selectedItems.add(item);
                        controller.downloadSelected();
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentIndigo,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceMD,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.toggleSelectionMode(item);
                      },
                      icon: const Icon(Icons.checklist),
                      label: const Text('Select'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceMD,
                        ),
                        side: const BorderSide(color: AppColors.accentTeal),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon data for file type
  IconData _getIconData(FileEntity item) {
    switch (item.iconType) {
      case FileIconType.folder:
        return Icons.folder;
      case FileIconType.text:
        return Icons.description;
      case FileIconType.image:
        return Icons.image;
      case FileIconType.video:
        return Icons.video_file;
      case FileIconType.audio:
        return Icons.audio_file;
      case FileIconType.archive:
        return Icons.folder_zip;
      case FileIconType.pdf:
        return Icons.picture_as_pdf;
      case FileIconType.document:
        return Icons.article;
      case FileIconType.code:
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get icon color for file type
  Color _getIconColor(FileEntity item) {
    switch (item.iconType) {
      case FileIconType.folder:
        return AppColors.accentCyan;
      case FileIconType.text:
        return AppColors.accentTeal;
      case FileIconType.image:
        return AppColors.accentPurple;
      case FileIconType.video:
        return AppColors.error;
      case FileIconType.audio:
        return AppColors.warning;
      case FileIconType.archive:
        return AppColors.accentIndigo;
      case FileIconType.pdf:
        return AppColors.error;
      case FileIconType.document:
        return AppColors.accentBlue;
      case FileIconType.code:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Build normal floating action buttons
  Widget _buildNormalFAB(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Upload folder
        FloatingActionButton(
          heroTag: 'upload_folder',
          onPressed: () => _showUploadOptions(context),
          backgroundColor: AppColors.accentTeal,
          child: const Icon(Icons.upload_file),
        ),
        const SizedBox(height: AppDimensions.spaceMD),

        // Refresh
        FloatingActionButton(
          heroTag: 'refresh',
          onPressed: controller.loadCurrentDirectory,
          backgroundColor: AppColors.accentIndigo,
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  /// Build selection mode floating action button
  Widget _buildSelectionFAB(BuildContext context, bool isDark) {
    return FloatingActionButton.extended(
      onPressed: controller.exitSelectionMode,
      backgroundColor: AppColors.error,
      icon: const Icon(Icons.close),
      label: Text('Cancel (${controller.selectedItems.length})'),
    );
  }

  /// Show upload options
  void _showUploadOptions(BuildContext context) {
    Get.bottomSheet(
      GlassCard(
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
        borderRadius: AppDimensions.radiusXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: AppColors.accentIndigo,
                ),
              ),
              title: const Text('Upload Files'),
              subtitle: const Text('Select one or more files'),
              onTap: () {
                Get.back();
                controller.uploadFile(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: AppColors.accentTeal,
                ),
              ),
              title: const Text('Upload Folder'),
              subtitle: const Text('Select an entire folder'),
              onTap: () {
                Get.back();
                // TODO: Implement folder upload
                Get.snackbar(
                  'Coming Soon',
                  'Folder upload will be available soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: AppDimensions.spaceSM),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
