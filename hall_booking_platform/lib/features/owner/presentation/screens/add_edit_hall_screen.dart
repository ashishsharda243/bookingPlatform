import 'dart:io';

import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/services/geocoding_service.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_update_request.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hall_booking_platform/core/widgets/cached_image_widget.dart';

/// Screen for adding a new hall or editing an existing one.
///
/// In edit mode, pre-populates fields from the existing hall.
/// Validates slot duration (30-480 min) and required fields.
class AddEditHallScreen extends ConsumerStatefulWidget {
  const AddEditHallScreen({super.key, this.hallId});

  /// If non-null, the screen is in edit mode for this hall.
  final String? hallId;

  bool get isEditing => hallId != null;

  @override
  ConsumerState<AddEditHallScreen> createState() => _AddEditHallScreenState();
}

class _AddEditHallScreenState extends ConsumerState<AddEditHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _amenityController = TextEditingController();
  final _mapLinkController = TextEditingController(); // Added
  final _imagePicker = ImagePicker();

  final List<String> _amenities = [];
  int _slotDurationMinutes = 60;
  bool _fieldsPopulated = false;

  Future<void> _openGoogleMaps() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat == null || lng == null) return;

    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps.')),
        );
      }
    }
  }

  /// Available slot duration options.
  static const List<int> _slotDurationOptions = [
    30, 60, 90, 120, 180, 240, 300, 360, 420, 480,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      Future.microtask(() {
        ref.read(hallFormNotifierProvider.notifier).loadHall(widget.hallId!);
      });
    } else {
      // Reset form state for new hall
      Future.microtask(() {
        ref.read(hallFormNotifierProvider.notifier).reset();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _basePriceController.dispose();
    _amenityController.dispose();
    _mapLinkController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final hall = ref.read(hallFormNotifierProvider).hall;
    // Fix for state persistence: ensure we are populating the correct hall
    if (widget.isEditing && hall != null && hall.id != widget.hallId!) {
       // Stale state, do not populate
       return;
    }
    
    if (hall != null && !_fieldsPopulated) {
      _nameController.text = hall.name;
      _descriptionController.text = hall.description;
      _addressController.text = hall.address;
      _latController.text = hall.lat.toString();
      _lngController.text = hall.lng.toString();
      _basePriceController.text = hall.basePrice.toStringAsFixed(2);
      _mapLinkController.text = hall.googleMapLink ?? '';
      _amenities
        ..clear()
        ..addAll(hall.amenities);
      _slotDurationMinutes = hall.slotDurationMinutes;
      _fieldsPopulated = true;
    }
  }

  // ... (pickImages)

  // ... (addAmenity, removeAmenity)

  Future<void> _pickLocation() async {
    final lat = double.tryParse(_latController.text) ?? 17.3850;
    final lng = double.tryParse(_lngController.text) ?? 78.4867;

    // Use GoRouter to push the LocationPickerScreen
    // The route expects extra: {'lat': double, 'lng': double}
    // And returns LatLng object (or we might need to cast it)
    final result = await context.push('/location-picker', extra: {
      'lat': lat,
      'lng': lng,
    });

    if (result is LatLng) {
      setState(() {
        _latController.text = result.latitude.toString();
        _lngController.text = result.longitude.toString();
        // Auto-generate map link
        _mapLinkController.text = 'https://www.google.com/maps/search/?api=1&query=${result.latitude},${result.longitude}';
      });

      // Reverse Geocoding
      try {
        final address = await GeocodingService().getAddressFromCoordinates(
          result.latitude, 
          result.longitude
        );
        if (address != null && mounted) {
          setState(() {
             _addressController.text = address;
          });
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address updated from map!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        // ignore error
      }
    }
  }

  Future<void> _pickImages() async {
    final existingCount =
        ref.read(hallFormNotifierProvider).hall?.imageUrls?.length ?? 0;
    final selectedCount = ref.read(hallFormNotifierProvider).selectedImages.length;
    final remaining = 10 - existingCount - selectedCount;

    if (remaining <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum of 10 images per hall.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    final pickedFiles = await _imagePicker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 70,
    );

    if (pickedFiles.isNotEmpty) {
      final files = pickedFiles.take(remaining).toList();
      ref.read(hallFormNotifierProvider.notifier).addSelectedImages(files);
    }
  }

  void _addAmenity() {
    final amenity = _amenityController.text.trim();
    if (amenity.isNotEmpty && !_amenities.contains(amenity)) {
      setState(() {
        _amenities.add(amenity);
        _amenityController.clear();
      });
    }
  }

  void _removeAmenity(String amenity) {
    setState(() {
      _amenities.remove(amenity);
    });
  }

  Future<void> _saveHall() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(hallFormNotifierProvider.notifier);

    if (widget.isEditing) {
      final request = HallUpdateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        lat: double.tryParse(_latController.text.trim()),
        lng: double.tryParse(_lngController.text.trim()),
        address: _addressController.text.trim(),
        amenities: _amenities,
        slotDurationMinutes: _slotDurationMinutes,
        basePrice: double.tryParse(_basePriceController.text.trim()),
        googleMapLink: _mapLinkController.text.trim().isEmpty 
            ? null 
            : _mapLinkController.text.trim(),
      );

      final hall = await notifier.updateHall(widget.hallId!, request);

      // Upload any selected images
      if (hall != null) {
        final selectedImages = ref.read(hallFormNotifierProvider).selectedImages;
        if (selectedImages.isNotEmpty) {
          await notifier.uploadImages(hall.id, selectedImages);
        }
      }
    } else {
      final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
      final lng = double.tryParse(_lngController.text.trim()) ?? 0.0;
      final basePrice =
          double.tryParse(_basePriceController.text.trim()) ?? 0.0;

      final request = HallCreateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        lat: lat,
        lng: lng,
        address: _addressController.text.trim(),
        amenities: _amenities,
        slotDurationMinutes: _slotDurationMinutes,
        basePrice: basePrice,
        googleMapLink: _mapLinkController.text.trim().isEmpty
            ? null
            : _mapLinkController.text.trim(),
      );

      final hall = await notifier.createHall(request);

      // Upload any selected images for the new hall
      if (hall != null) {
        final selectedImages = ref.read(hallFormNotifierProvider).selectedImages;
        if (selectedImages.isNotEmpty) {
          await notifier.uploadImages(hall.id, selectedImages);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(hallFormNotifierProvider);

    // Populate fields when hall data loads in edit mode
    if (widget.isEditing && formState.hall != null) {
      _populateFields();
    }

    // Listen for success/error messages
    ref.listen<HallFormState>(hallFormNotifierProvider, (prev, next) {
      if (next.successMessage != null && prev?.successMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(hallFormNotifierProvider.notifier).clearSuccess();

        // Navigate back after successful save (if not uploading images)
        if (!next.isUploadingImages) {
          // Refresh the dashboard
          ref.read(ownerDashboardNotifierProvider.notifier).loadHalls();
          if (mounted) context.pop();
        }
      }
      if (next.error != null && prev?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(hallFormNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Hall' : 'Add Hall'),
      ),
      body: _buildBody(formState),
    );
  }

  Widget _buildBody(HallFormState formState) {
    if (widget.isEditing && formState.isLoading && formState.hall == null) {
      return const LoadingIndicator();
    }

    if (widget.isEditing && formState.error != null && formState.hall == null) {
      return ErrorDisplay(
        message: formState.error!,
        onRetry: () {
          ref.read(hallFormNotifierProvider.notifier).loadHall(widget.hallId!);
        },
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hall Name *',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hall name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Location Picker
            if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                   const Icon(Icons.check_circle, color: AppColors.success),
                   const SizedBox(width: AppSpacing.xs),
                   Expanded(
                     child: Text(
                       'Location Selected: ${_latController.text}, ${_lngController.text}',
                       style: AppTypography.bodySmall,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: _openGoogleMaps,
                child: Row(
                  children: [
                    const Icon(Icons.map, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Verify Location on Google Maps',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            
            // Map Link
            TextFormField(
              controller: _mapLinkController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Google Map Link',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
                helperText: 'Auto-generated from location selection',
                enabled: false, // Visual indication of disabled state
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Hidden Lat/Lng fields
            Visibility(
              visible: false, 
              maintainState: true,
              child: Column(
                children: [
                  TextFormField(controller: _latController),
                  TextFormField(controller: _lngController),
                ],
              ),
            ),

            // Pick on Map Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.location_on),
                label: Text(_latController.text.isEmpty ? 'Select Location on Map' : 'Change Location'),
                 style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Base Price
            TextFormField(
              controller: _basePriceController,
              decoration: const InputDecoration(
                labelText: 'Base Price (₹) *',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Base price is required';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Slot Duration
            _buildSlotDurationSelector(),
            const SizedBox(height: AppSpacing.md),

            // Amenities
            _buildAmenitiesSection(),
            const SizedBox(height: AppSpacing.lg),

            // Images
            _buildImagesSection(formState),
            const SizedBox(height: AppSpacing.lg),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formState.isSaving || formState.isUploadingImages
                    ? null
                    : _saveHall,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: formState.isSaving || formState.isUploadingImages
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing ? 'Update Hall' : 'Create Hall'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Slot Duration *', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: _slotDurationOptions.contains(_slotDurationMinutes)
              ? _slotDurationMinutes
              : _slotDurationOptions.first,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.schedule),
            border: OutlineInputBorder(),
          ),
          items: _slotDurationOptions.map((duration) {
            final hours = duration ~/ 60;
            final minutes = duration % 60;
            String label;
            if (hours > 0 && minutes > 0) {
              label = '${hours}h ${minutes}m ($duration min)';
            } else if (hours > 0) {
              label = '${hours}h ($duration min)';
            } else {
              label = '$duration min';
            }
            return DropdownMenuItem(value: duration, child: Text(label));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _slotDurationMinutes = value);
            }
          },
          validator: (value) {
            if (value == null || value < 30 || value > 480) {
              return 'Slot duration must be between 30 and 480 minutes';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amenityController,
                decoration: const InputDecoration(
                  hintText: 'e.g. WiFi, Parking, AC',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _addAmenity(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: _addAmenity,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (_amenities.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _amenities.map((amenity) {
              return Chip(
                label: Text(amenity),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeAmenity(amenity),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImagesSection(HallFormState formState) {
    final existingUrls = formState.hall?.imageUrls ?? [];
    final selectedImages = formState.selectedImages;
    final totalCount = existingUrls.length + selectedImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Images ($totalCount/10)', style: AppTypography.labelLarge),
            TextButton.icon(
              onPressed: totalCount >= 10 ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        if (existingUrls.isEmpty && selectedImages.isEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: InkWell(
              onTap: _pickImages,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap to add images',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: existingUrls.length + selectedImages.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index < existingUrls.length) {
                  return _buildExistingImageTile(existingUrls[index]);
                }
                final localIndex = index - existingUrls.length;
                return _buildSelectedImageTile(
                  selectedImages[localIndex],
                  localIndex,
                );
              },
            ),
          ),

        if (formState.isUploadingImages) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.xs),
          Text('Uploading images...', style: AppTypography.caption),
        ],
      ],
    );
  }

  Widget _buildExistingImageTile(String url) {
    return CachedImageWidget(
      imageUrl: url,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    );
  }

  Widget _buildSelectedImageTile(XFile file, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: kIsWeb 
            ? Image.network(
                file.path,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                   return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                      child: const Icon(Icons.error));
                },
              )
            : Image.file(
                File(file.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              ref
                  .read(hallFormNotifierProvider.notifier)
                  .removeSelectedImage(index);
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
