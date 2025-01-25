import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Controllers for the text fields
var controller = TextEditingController();
var dateController = TextEditingController();
var statuscontroller = TextEditingController();
var phoneController = TextEditingController();

// Lists to store the images
List<XFile> imageMeasurements = [];
List<XFile> imagePatterns = [];
List<XFile> imageMaterials = [];

// Image picker instance
final ImagePicker picker = ImagePicker();
