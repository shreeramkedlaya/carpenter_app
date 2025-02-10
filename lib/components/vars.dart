// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';

// Controllers for the text fields
var controller = TextEditingController();
var dateController = TextEditingController();
var statusController = TextEditingController();
var phoneController = TextEditingController();

// Lists to store the images
List<XFile> imageMeasurements = [];
List<XFile> imagePatterns = [];
List<XFile> imageMaterials = [];

// Image picker instance
final ImagePicker picker = ImagePicker();

// Path to store the images
String? audioPath;

// Recording and playback flags
bool isRecording = false;
bool isPlaying = false; // Playback state

// Permission and initialization flags
bool isPermissionGranted = false;
bool isRecorderInitialized = false;
bool isPlayerInitialized = false;
bool hasRecording = false;

// List to store the voice notes
List<String> voiceNotes = [];

// recorder and player instances
FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();

// timer for recording
Timer? recordingTimer; // Timer to stop recording after 60 sec
const int maxRecordingTime = 60; // Maximum recording time in seconds

// Track the currently selected filter, defaulting to 'All'
String? selectedFilter = 'All';

// Dummy list of orders
Color? cardColor;

// data for bar graph
List<double> data = [
  1,
  5,
  10,
  15,
  20,
];
